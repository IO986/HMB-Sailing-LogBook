import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/charter_source.dart';

void main() {
  group('CharterSource.isRetrospective', () {
    test('gpx and paper are written after the fact, live is not', () {
      expect(CharterSource.isRetrospective(CharterSource.gpx), isTrue);
      expect(CharterSource.isRetrospective(CharterSource.paper), isTrue);
      expect(CharterSource.isRetrospective(CharterSource.live), isFalse);
    });

    test('persisted values stay stable', () {
      expect(CharterSource.live, 'live');
      expect(CharterSource.gpx, 'gpx');
      expect(CharterSource.paper, 'paper');
    });
  });

  group('dayLogIdForNow', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    });
    tearDown(() async => db.close());

    Future<Charter> charter(String source, DateTime from) =>
        db.insertCharter(ChartersCompanion.insert(
          title: source,
          dateFrom: from,
          dateTo: from,
          createdAt: from,
          source: Value(source),
        ));

    test('never appends today\'s event to a paper or gpx voyage', () async {
      final live = await charter(CharterSource.live, DateTime(2020));
      // Newer dateFrom than the live voyage: before the fix a gpx one would
      // already have won; a paper one must not.
      await charter(CharterSource.paper, DateTime(2030));
      await charter(CharterSource.gpx, DateTime(2031));

      final id = await db.dayLogIdForNow();
      expect(id, isNotNull);
      final day = await (db.select(db.dayLogs)
            ..where((d) => d.id.equals(id!)))
          .getSingle();
      expect(day.charterId, live.id);
    });

    test('with only retrospective voyages the event stays unassigned',
        () async {
      await charter(CharterSource.paper, DateTime(2024));
      await charter(CharterSource.gpx, DateTime(2025));
      expect(await db.dayLogIdForNow(), isNull);
    });
  });
}
