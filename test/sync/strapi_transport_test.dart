import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/sync/strapi_transport.dart';

/// No real sockets — hands canned [ResponseBody]s (or throws) back to dio
/// based on the request it's given, and records every request it saw.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter(this._handler);

  final Future<ResponseBody> Function(RequestOptions options) _handler;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return _handler(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody _jsonBody(Object data, int status) => ResponseBody.fromString(
      jsonEncode(data),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

({Dio dio, _FakeAdapter adapter}) _dioWith(
  Future<ResponseBody> Function(RequestOptions options) handler,
) {
  final dio = Dio(BaseOptions(baseUrl: 'https://cms.example'));
  final adapter = _FakeAdapter(handler);
  dio.httpClientAdapter = adapter;
  return (dio: dio, adapter: adapter);
}

OutboxItem _item({List<Attachment> attachments = const []}) => OutboxItem(
      id: 'item-1',
      entityType: 'record',
      operation: SyncOperation.create,
      payload: const {'note': 'hi'},
      createdAt: DateTime.utc(2026, 1, 1),
      attachments: attachments,
    );

void main() {
  test('posts to /api/{collection} with clientId + auth header, keeps remoteId', () async {
    final d = _dioWith(
      (options) async => _jsonBody({
        'data': {'id': 42},
      }, 200),
    );
    final transport = StrapiTransport(
      baseUrl: 'https://cms.example',
      authToken: () => 'tok',
      collectionByEntityType: const {'record': 'records'},
      dio: d.dio,
    );

    final results = await transport.push([_item()]);

    final sent = d.adapter.requests.single;
    expect(sent.path, '/api/records');
    expect(sent.headers['Authorization'], 'Bearer tok');
    final body = sent.data as Map<String, dynamic>;
    final inner = body['data'] as Map<String, dynamic>;
    expect(inner['clientId'], 'item-1');
    expect(inner['note'], 'hi');

    expect(results.single.itemId, 'item-1');
    expect(results.single.outcome, SyncItemOutcome.success);
    expect(results.single.remoteId, '42');
  });

  test('unmapped entityType fails without ever calling the network', () async {
    final d = _dioWith((options) async {
      fail('should never reach the network for an unmapped entityType');
    });
    final transport = StrapiTransport(
      baseUrl: 'https://cms.example',
      authToken: () => 'tok',
      collectionByEntityType: const {},
      dio: d.dio,
    );

    final results = await transport.push([_item()]);
    expect(results.single.outcome, SyncItemOutcome.failure);
    expect(results.single.retryable, isFalse);
    expect(d.adapter.requests, isEmpty);
  });

  group('duplicate (clientId collision)', () {
    test('409 maps to duplicate', () async {
      final d = _dioWith((options) async => _jsonBody(const {}, 409));
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );
      final results = await transport.push([_item()]);
      expect(results.single.outcome, SyncItemOutcome.duplicate);
    });

    test('400 naming the unique clientId field maps to duplicate, not failure', () async {
      final d = _dioWith(
        (options) async => _jsonBody({
          'error': {'message': 'This attribute must be unique (clientId)'},
        }, 400),
      );
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );
      final results = await transport.push([_item()]);
      expect(results.single.outcome, SyncItemOutcome.duplicate);
    });

    test('duplicate is never marked retryable (it is treated as sent)', () async {
      final d = _dioWith((options) async => _jsonBody(const {}, 409));
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );
      final results = await transport.push([_item()]);
      expect(results.single.retryable, isFalse);
    });
  });

  group('retryable statuses', () {
    for (final status in [408, 429, 500, 502, 503]) {
      test('$status is retryable', () async {
        final d = _dioWith((options) async => _jsonBody(const {}, status));
        final transport = StrapiTransport(
          baseUrl: 'https://cms.example',
          authToken: () => 't',
          collectionByEntityType: const {'record': 'records'},
          dio: d.dio,
        );
        final results = await transport.push([_item()]);
        expect(results.single.outcome, SyncItemOutcome.failure);
        expect(results.single.retryable, isTrue);
      });
    }

    test('a connection timeout is retryable', () async {
      final d = _dioWith(
        (options) async => throw DioException(
          requestOptions: options,
          type: DioExceptionType.connectionTimeout,
        ),
      );
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );
      final results = await transport.push([_item()]);
      expect(results.single.outcome, SyncItemOutcome.failure);
      expect(results.single.retryable, isTrue);
    });
  });

  group('non-retryable statuses', () {
    for (final status in [400, 401, 403, 404, 422]) {
      test('$status (not a duplicate) is non-retryable', () async {
        final d = _dioWith((options) async => _jsonBody(const {}, status));
        final transport = StrapiTransport(
          baseUrl: 'https://cms.example',
          authToken: () => 't',
          collectionByEntityType: const {'record': 'records'},
          dio: d.dio,
        );
        final results = await transport.push([_item()]);
        expect(results.single.outcome, SyncItemOutcome.failure);
        expect(results.single.retryable, isFalse);
      });
    }
  });

  group('attachments', () {
    late Directory tempDir;
    late String photoPath;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('strapi_transport_test_');
      photoPath = '${tempDir.path}/photo.jpg';
      File(photoPath).writeAsBytesSync([1, 2, 3]);
    });

    tearDown(() async {
      // dio's MultipartFile keeps a Windows file handle open briefly after
      // the request completes — best-effort cleanup, not the point of the
      // test.
      try {
        await tempDir.delete(recursive: true);
      } catch (_) {}
    });

    test('uploads via /api/upload first, merges file id into the payload field', () async {
      final d = _dioWith((options) async {
        if (options.path == '/api/upload') {
          return _jsonBody([
            {'id': 7},
          ], 200);
        }
        return _jsonBody({
          'data': {'id': 1},
        }, 200);
      });
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );

      final item = _item(
        attachments: [
          Attachment(
            localPath: photoPath,
            field: 'photo',
            mimeType: 'image/jpeg',
            sizeBytes: 3,
          ),
        ],
      );
      final results = await transport.push([item]);

      expect(d.adapter.requests[0].path, '/api/upload');
      expect(d.adapter.requests[1].path, '/api/records');
      final recordBody =
          (d.adapter.requests[1].data as Map<String, dynamic>)['data']
              as Map<String, dynamic>;
      expect(recordBody['photo'], 7);
      expect(results.single.outcome, SyncItemOutcome.success);
    });

    test('attachment upload failure fails the whole item, never sends the record', () async {
      final d = _dioWith((options) async {
        if (options.path == '/api/upload') {
          throw DioException(requestOptions: options, error: 'boom');
        }
        fail('record must never be posted when its attachment failed to upload');
      });
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );

      final item = _item(
        attachments: [
          Attachment(
            localPath: photoPath,
            field: 'photo',
            mimeType: 'image/jpeg',
            sizeBytes: 3,
          ),
        ],
      );
      final results = await transport.push([item]);

      expect(results.single.outcome, SyncItemOutcome.failure);
      expect(results.single.retryable, isTrue);
      expect(d.adapter.requests, hasLength(1)); // upload only, no record post
    });

    test('an already-uploaded attachment (remoteRef set) is not re-uploaded', () async {
      late RequestOptions captured;
      final d = _dioWith((options) async {
        expect(options.path, '/api/records'); // /api/upload never called
        captured = options;
        return _jsonBody({
          'data': {'id': 1},
        }, 200);
      });
      final transport = StrapiTransport(
        baseUrl: 'https://cms.example',
        authToken: () => 't',
        collectionByEntityType: const {'record': 'records'},
        dio: d.dio,
      );

      final item = _item(
        attachments: const [
          Attachment(
            localPath: '/tmp/photo.jpg',
            field: 'photo',
            mimeType: 'image/jpeg',
            sizeBytes: 3,
            remoteRef: '7',
          ),
        ],
      );
      final results = await transport.push([item]);

      expect(d.adapter.requests, hasLength(1));
      expect(results.single.outcome, SyncItemOutcome.success);
      final recordBody =
          (captured.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      expect(recordBody['photo'], '7'); // reused the existing remoteRef
    });
  });
}
