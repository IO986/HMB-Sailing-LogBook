import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import 'sync_envelope.dart';

/// Generic SyncTransport for a custom server — the same wire contract as
/// [StrapiTransport] (see docs/SYNC_API.md), with none of Strapi's REST
/// conventions: no `{"data": ...}` wrapper, no separate `/api/upload` step.
///
/// - `POST {baseUrl}/{entityType}`, body is the envelope itself
///   (`buildSyncEnvelope`).
/// - Attachments too small a contract to assume an upload endpoint exists
///   for — inlined as base64 inside the envelope's `attachments` array.
/// - HTTPS is enforced at construction time: a plain-HTTP [baseUrl] throws
///   [ArgumentError] rather than ever making a request with it.
class RestTransport implements SyncTransport {
  RestTransport({
    required String baseUrl,
    required String Function() authToken,
    required String appVersion,
    Dio? dio,
  })  : _authToken = authToken,
        _appVersion = appVersion,
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: _requireHttps(baseUrl),
              // Same reasoning as StrapiTransport: no timeout means a
              // doomed request can hold the radio "searching" far longer
              // than useful, which compounds with a large queue.
              connectTimeout: const Duration(seconds: 10),
              sendTimeout: const Duration(seconds: 20),
              receiveTimeout: const Duration(seconds: 20),
            ));

  final Dio _dio;
  final String Function() _authToken;
  final String _appVersion;

  static String _requireHttps(String url) {
    final scheme = Uri.tryParse(url)?.scheme;
    if (scheme != 'https') {
      throw ArgumentError(
        'Custom sync server URL must use HTTPS (the auth token travels in '
        'the Authorization header): $url',
      );
    }
    return url;
  }

  @override
  // No documented bulk endpoint for an arbitrary custom server — one
  // request per item, same as StrapiTransport.
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async => true;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async => [
        for (final item in batch) await _pushOne(item),
      ];

  Future<SyncItemResult> _pushOne(OutboxItem item) async {
    final attachments = <Map<String, dynamic>>[];
    for (final attachment in item.attachments) {
      final file = File(attachment.localPath);
      if (!await file.exists()) {
        return SyncItemResult(
          itemId: item.id,
          outcome: SyncItemOutcome.failure,
          errorMessage: 'attachment file missing: ${attachment.localPath}',
          retryable: false,
        );
      }
      attachments.add({
        'field': attachment.field,
        'mimeType': attachment.mimeType,
        'data': base64Encode(await file.readAsBytes()),
      });
    }

    final envelope = buildSyncEnvelope(
      item: item,
      appVersion: _appVersion,
      attachments: attachments,
    );

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/${item.entityType}',
        data: envelope,
        options: Options(headers: _headers()),
      );
      return SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.success,
        remoteId: response.data?['id']?.toString(),
        httpStatus: response.statusCode,
      );
    } on DioException catch (e) {
      return _resultForError(item.id, e);
    }
  }

  Map<String, String> _headers() => {'Authorization': 'Bearer ${_authToken()}'};

  SyncItemResult _resultForError(String itemId, DioException e) {
    final status = e.response?.statusCode;

    if (status == 409 || (status == 400 && _looksLikeDuplicate(e))) {
      return SyncItemResult(
        itemId: itemId,
        outcome: SyncItemOutcome.duplicate,
        httpStatus: status,
      );
    }

    final retryable = status == 408 ||
        status == 429 ||
        (status != null && status >= 500) ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.connectionError;

    return SyncItemResult(
      itemId: itemId,
      outcome: SyncItemOutcome.failure,
      errorMessage: e.message,
      httpStatus: status,
      retryable: retryable,
    );
  }

  bool _looksLikeDuplicate(DioException e) {
    final body = e.response?.data;
    if (body is! Map) return false;
    final message = (body['message'] ?? (body['error'] is Map ? (body['error'] as Map)['message'] : null))
        ?.toString()
        .toLowerCase();
    if (message == null) return false;
    return message.contains('clientid') ||
        message.contains('unique') ||
        message.contains('duplicate');
  }
}
