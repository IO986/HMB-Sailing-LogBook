import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart' as drift;
import 'package:hmb_core/hmb_core.dart' hide LocationService;

import '../core/database/app_database.dart';

/// Backs `hmb_core`'s generic [RecordStore] with the app's own drift `outbox`
/// table (see `OutboxRows` in app_database.dart) instead of an in-memory or
/// generic-JSON-blob store, so the sync queue survives restarts and gets a
/// real SQL index on `(status, created_at)`.
///
/// Only ever wired up for the outbox collection — [collection] is accepted
/// (per the [RecordStore] interface) but not branched on, since this store
/// has exactly one caller: `OutboxRepository` from `hmb_core`.
class DriftOutboxRecordStore implements RecordStore {
  DriftOutboxRecordStore(this._db);

  final AppDatabase _db;
  final _changes = StreamController<void>.broadcast();

  @override
  Future<void> put(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    await _db.upsertOutboxRow(_toCompanion(id, data));
    _changes.add(null);
  }

  @override
  Future<Map<String, dynamic>?> getById(String collection, String id) async {
    final row = await _db.getOutboxRow(id);
    return row == null ? null : _toJson(row);
  }

  @override
  Future<List<Map<String, dynamic>>> getAll(String collection) async =>
      (await _db.getAllOutboxRows()).map(_toJson).toList();

  @override
  Future<void> delete(String collection, String id) async {
    await _db.deleteOutboxRow(id);
    _changes.add(null);
  }

  @override
  Future<void> deleteWhere(
    String collection,
    bool Function(Map<String, dynamic> record) test,
  ) async {
    final rows = await _db.getAllOutboxRows();
    final toDelete = rows.where((r) => test(_toJson(r)));
    var deletedAny = false;
    for (final row in toDelete) {
      await _db.deleteOutboxRow(row.id);
      deletedAny = true;
    }
    if (deletedAny) _changes.add(null);
  }

  @override
  Stream<void> watch(String collection) => _changes.stream;

  OutboxRowsCompanion _toCompanion(String id, Map<String, dynamic> data) =>
      OutboxRowsCompanion.insert(
        id: id,
        entityType: data['entityType'] as String,
        entityId: drift.Value(data['entityId'] as String?),
        operation: data['operation'] as String,
        payload: jsonEncode(data['payload']),
        attachments: jsonEncode(data['attachments']),
        status: data['status'] as String,
        retryCount: drift.Value(data['retryCount'] as int? ?? 0),
        createdAt: DateTime.parse(data['createdAt'] as String),
        lastAttemptAt: drift.Value(_parseNullable(data['lastAttemptAt'])),
        syncedAt: drift.Value(_parseNullable(data['syncedAt'])),
        errorMessage: drift.Value(data['errorMessage'] as String?),
        lastHttpStatus: drift.Value(data['lastHttpStatus'] as int?),
        version: drift.Value(data['version'] as String?),
        remoteId: drift.Value(data['remoteId'] as String?),
      );

  Map<String, dynamic> _toJson(OutboxRow row) => {
        'id': row.id,
        'entityType': row.entityType,
        'entityId': row.entityId,
        'operation': row.operation,
        'payload': jsonDecode(row.payload),
        'attachments': jsonDecode(row.attachments),
        'status': row.status,
        'retryCount': row.retryCount,
        'createdAt': row.createdAt.toUtc().toIso8601String(),
        'lastAttemptAt': row.lastAttemptAt?.toUtc().toIso8601String(),
        'syncedAt': row.syncedAt?.toUtc().toIso8601String(),
        'errorMessage': row.errorMessage,
        'lastHttpStatus': row.lastHttpStatus,
        'version': row.version,
        'remoteId': row.remoteId,
      };

  static DateTime? _parseNullable(dynamic value) =>
      value == null ? null : DateTime.parse(value as String);
}
