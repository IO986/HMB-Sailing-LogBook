import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;
import 'package:hmb_sailing_log/sync/rest_transport.dart';

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
  final dio = Dio(BaseOptions(baseUrl: 'https://custom.example'));
  final adapter = _FakeAdapter(handler);
  dio.httpClientAdapter = adapter;
  return (dio: dio, adapter: adapter);
}

RestTransport _transport(Dio dio) => RestTransport(
      baseUrl: 'https://custom.example',
      authToken: () => 'tok',
      appVersion: '1.2.3+45',
      dio: dio,
    );

OutboxItem _item({List<Attachment> attachments = const []}) => OutboxItem(
      id: 'item-1',
      entityType: 'log_entry',
      operation: SyncOperation.create,
      payload: const {'note': 'hi'},
      createdAt: DateTime.utc(2026, 1, 1, 9, 12, 3),
      attachments: attachments,
    );

void main() {
  group('HTTPS enforcement', () {
    test('rejects a plain-HTTP base URL at construction', () {
      expect(
        () => RestTransport(
          baseUrl: 'http://custom.example',
          authToken: () => 't',
          appVersion: '1.0',
        ),
        throwsArgumentError,
      );
    });

    test('rejects an unparsable base URL', () {
      expect(
        () => RestTransport(baseUrl: 'not a url', authToken: () => 't', appVersion: '1.0'),
        throwsArgumentError,
      );
    });

    test('accepts an HTTPS base URL', () {
      expect(
        () => RestTransport(
          baseUrl: 'https://custom.example',
          authToken: () => 't',
          appVersion: '1.0',
        ),
        returnsNormally,
      );
    });
  });

  test('posts the envelope directly to /{entityType} — no data wrapper', () async {
    final d = _dioWith((options) async => _jsonBody({'id': 'srv-1'}, 200));

    final results = await _transport(d.dio).push([_item()]);

    final sent = d.adapter.requests.single;
    expect(sent.path, '/log_entry');
    expect(sent.headers['Authorization'], 'Bearer tok');

    final envelope = sent.data as Map<String, dynamic>;
    expect(envelope.containsKey('data'), isFalse); // no Strapi-style wrapper
    expect(envelope['clientId'], 'item-1');
    expect(envelope['entityType'], 'log_entry');
    expect(envelope['operation'], 'create');
    expect(envelope['appVersion'], '1.2.3+45');
    expect(envelope['payload'], {'note': 'hi'});

    expect(results.single.outcome, SyncItemOutcome.success);
    expect(results.single.remoteId, 'srv-1');
  });

  test('attachments are inlined as base64, no separate upload request', () async {
    final dir = await Directory.systemTemp.createTemp('rest_transport_test_');
    try {
      final photo = File('${dir.path}/photo.jpg')..writeAsBytesSync([1, 2, 3]);
      final d = _dioWith((options) async => _jsonBody({'id': '1'}, 200));

      final item = _item(
        attachments: [
          Attachment(
            localPath: photo.path,
            field: 'photo',
            mimeType: 'image/jpeg',
            sizeBytes: 3,
          ),
        ],
      );
      final results = await _transport(d.dio).push([item]);

      expect(d.adapter.requests, hasLength(1)); // single request, no upload step
      final envelope = d.adapter.requests.single.data as Map<String, dynamic>;
      final attachments = envelope['attachments'] as List<dynamic>;
      final entry = attachments.single as Map<String, dynamic>;
      expect(entry['field'], 'photo');
      expect(entry['mimeType'], 'image/jpeg');
      expect(base64Decode(entry['data'] as String), [1, 2, 3]);
      expect(results.single.outcome, SyncItemOutcome.success);
    } finally {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
    }
  });

  test('missing attachment file fails the item without a network call', () async {
    final d = _dioWith((options) async {
      fail('must never reach the network when the attachment file is missing');
    });
    final item = _item(
      attachments: const [
        Attachment(
          localPath: '/nonexistent/photo.jpg',
          field: 'photo',
          mimeType: 'image/jpeg',
          sizeBytes: 3,
        ),
      ],
    );
    final results = await _transport(d.dio).push([item]);
    expect(results.single.outcome, SyncItemOutcome.failure);
    expect(results.single.retryable, isFalse);
    expect(d.adapter.requests, isEmpty);
  });

  group('duplicate / retryable / non-retryable — same rules as StrapiTransport', () {
    test('409 maps to duplicate', () async {
      final d = _dioWith((options) async => _jsonBody(const {}, 409));
      final results = await _transport(d.dio).push([_item()]);
      expect(results.single.outcome, SyncItemOutcome.duplicate);
    });

    test('400 naming a unique-field violation maps to duplicate', () async {
      final d = _dioWith(
        (options) async => _jsonBody({'message': 'duplicate clientId'}, 400),
      );
      final results = await _transport(d.dio).push([_item()]);
      expect(results.single.outcome, SyncItemOutcome.duplicate);
    });

    for (final status in [408, 429, 500, 503]) {
      test('$status is retryable', () async {
        final d = _dioWith((options) async => _jsonBody(const {}, status));
        final results = await _transport(d.dio).push([_item()]);
        expect(results.single.outcome, SyncItemOutcome.failure);
        expect(results.single.retryable, isTrue);
      });
    }

    for (final status in [400, 401, 403, 404, 422]) {
      test('$status (not a duplicate) is non-retryable', () async {
        final d = _dioWith((options) async => _jsonBody(const {}, status));
        final results = await _transport(d.dio).push([_item()]);
        expect(results.single.outcome, SyncItemOutcome.failure);
        expect(results.single.retryable, isFalse);
      });
    }
  });
}
