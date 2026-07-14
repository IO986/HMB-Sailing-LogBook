import 'package:dio/dio.dart';
import 'package:hmb_core/hmb_core.dart' hide LocationService;

/// SyncTransport for hmba.boats' Strapi backend. Lives entirely in the app —
/// `hmb_core` never imports Strapi, never sees a collection name, never sees
/// this file.
///
/// - `POST {baseUrl}/api/{collection}`, body `{"data": {...payload, "clientId": item.id}}`
/// - `clientId` is unique in Strapi, so a collision on it is idempotency
///   working as intended, not a failure — mapped to [SyncItemOutcome.duplicate].
/// - Attachments are uploaded first via `POST /api/upload` (multipart); the
///   returned file id is merged into the payload under the attachment's
///   `field` name before the record itself is created.
/// - `entityType` → Strapi collection mapping is the app's own concern
///   ([collectionByEntityType]), never `hmb_core`'s.
class StrapiTransport implements SyncTransport {
  StrapiTransport({
    required String baseUrl,
    required String Function() authToken,
    required Map<String, String> collectionByEntityType,
    Dio? dio,
  })  : _authToken = authToken,
        _collectionByEntityType = collectionByEntityType,
        _dio = dio ?? Dio(BaseOptions(baseUrl: baseUrl));

  final Dio _dio;
  final String Function() _authToken;
  final Map<String, String> _collectionByEntityType;

  @override
  // Strapi has no bulk-create endpoint for a single content type — one
  // request per item.
  int get batchSize => 1;

  @override
  Future<bool> isReachable() async => true;

  @override
  Future<List<SyncItemResult>> push(List<OutboxItem> batch) async => [
        for (final item in batch) await _pushOne(item),
      ];

  Future<SyncItemResult> _pushOne(OutboxItem item) async {
    final collection = _collectionByEntityType[item.entityType];
    if (collection == null) {
      return SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.failure,
        errorMessage:
            'no Strapi collection mapped for entityType "${item.entityType}"',
        retryable: false,
      );
    }

    final payload = Map<String, dynamic>.from(item.payload);
    for (final attachment in item.attachments) {
      // Already uploaded on a previous attempt (retry) — reuse the id
      // instead of uploading again.
      if (attachment.remoteRef != null) {
        payload[attachment.field] = attachment.remoteRef;
        continue;
      }
      final fileId = await _uploadAttachment(attachment);
      if (fileId == null) {
        return SyncItemResult(
          itemId: item.id,
          outcome: SyncItemOutcome.failure,
          errorMessage:
              'attachment upload failed for field "${attachment.field}"',
          retryable: true,
        );
      }
      payload[attachment.field] = fileId;
    }

    try {
      final response = await _dio.post<Map<String, dynamic>>(
        '/api/$collection',
        data: {
          'data': {...payload, 'clientId': item.id},
        },
        options: Options(headers: _headers()),
      );
      final remoteId =
          (response.data?['data'] as Map<String, dynamic>?)?['id']?.toString();
      return SyncItemResult(
        itemId: item.id,
        outcome: SyncItemOutcome.success,
        remoteId: remoteId,
        httpStatus: response.statusCode,
      );
    } on DioException catch (e) {
      return _resultForError(item.id, e);
    }
  }

  Future<dynamic> _uploadAttachment(Attachment attachment) async {
    try {
      final form = FormData.fromMap({
        'files': await MultipartFile.fromFile(
          attachment.localPath,
          filename: attachment.localPath.split('/').last,
        ),
      });
      final response = await _dio.post<List<dynamic>>(
        '/api/upload',
        data: form,
        options: Options(headers: _headers()),
      );
      final uploaded = response.data?.first as Map<String, dynamic>?;
      return uploaded?['id'];
    } catch (_) {
      return null;
    }
  }

  Map<String, String> _headers() => {'Authorization': 'Bearer ${_authToken()}'};

  SyncItemResult _resultForError(String itemId, DioException e) {
    final status = e.response?.statusCode;

    // clientId collision = idempotency working, not a failure — Strapi
    // reports a uniqueness violation as 409, or sometimes as a 400
    // ValidationError naming the field.
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
    if (body is Map && body['error'] is Map) {
      final message =
          (body['error'] as Map)['message']?.toString().toLowerCase() ?? '';
      return message.contains('clientid') || message.contains('unique');
    }
    return false;
  }
}
