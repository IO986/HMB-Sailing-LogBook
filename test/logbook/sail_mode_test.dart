import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/sail_mode.dart';

/// Propulsion used to live as a `[motor,main]` prefix inside the skipper's
/// note. Automatic entries never wrote that prefix, so the detail screen fell
/// back to its initialiser and showed "motor" for every one of them — even
/// after the skipper had switched the engine off. It now has its own column.
void main() {
  group('parseSailMode', () {
    test('reads the column when it is set', () {
      final parsed = parseSailMode('main,genoa', 'Reefed down');
      expect(parsed.modes, {'main', 'genoa'});
      expect(parsed.note, 'Reefed down');
    });

    test('falls back to the old note prefix', () {
      final parsed = parseSailMode(null, '[motor,main] Leaving the marina');
      expect(parsed.modes, {'motor', 'main'});
      expect(parsed.note, 'Leaving the marina');
    });

    test('strips a leftover prefix even when the column wins', () {
      // A row written by an older build and re-synced from the server.
      final parsed = parseSailMode('main', '[motor] Under sail now');
      expect(parsed.modes, {'main'});
      expect(parsed.note, 'Under sail now');
    });

    test('no propulsion recorded is empty, not motor', () {
      final parsed = parseSailMode(null, 'Automatic entry');
      expect(parsed.modes, isEmpty);
      expect(parsed.note, 'Automatic entry');
    });

    test('handles nulls, blanks and stray whitespace', () {
      expect(parseSailMode(null, null).modes, isEmpty);
      expect(parseSailMode(null, null).note, '');
      expect(parseSailMode('', '[ motor , main ] x').modes, {'motor', 'main'});
      expect(parseSailMode('[]', '[] plain').note, 'plain');
    });
  });

  group('carrying the mode into automatic entries', () {
    late AppDatabase db;

    setUp(() {
      db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    });
    tearDown(() async => db.close());

    Future<int> makeDay() async {
      final charter = await db.insertCharter(ChartersCompanion.insert(
        title: 'Plavba',
        dateFrom: DateTime(2026, 8, 8),
        dateTo: DateTime(2026, 8, 8),
        createdAt: DateTime(2026, 8, 8),
      ));
      final day = await db.insertDayLog(DayLogsCompanion.insert(
        charterId: charter.id,
        date: DateTime(2026, 8, 8),
      ));
      return day.id;
    }

    Future<void> addEntry(int dayLogId, DateTime at,
            {String? sailMode, bool auto = false}) =>
        db.insertLogbookEntry(LogbookEntriesCompanion.insert(
          dayLogId: Value(dayLogId),
          timestamp: at,
          sailMode: Value(sailMode),
          isAutoEntry: Value(auto),
        ));

    test('a day with no entries has no mode to carry', () async {
      expect(await db.lastSailModeForDay(await makeDay()), isNull);
    });

    test('the most recent recorded mode wins', () async {
      final dayLogId = await makeDay();
      // Motoring out of the marina, then sails up and engine off.
      await addEntry(dayLogId, DateTime.utc(2026, 8, 8, 9), sailMode: 'motor');
      await addEntry(dayLogId, DateTime.utc(2026, 8, 8, 10),
          sailMode: 'main,genoa');

      expect(await db.lastSailModeForDay(dayLogId), 'main,genoa');
    });

    test('entries without a mode do not overwrite the last known one',
        () async {
      final dayLogId = await makeDay();
      await addEntry(dayLogId, DateTime.utc(2026, 8, 8, 10),
          sailMode: 'main,genoa');
      // An older automatic entry written before the mode was ever set.
      await addEntry(dayLogId, DateTime.utc(2026, 8, 8, 11), auto: true);

      expect(await db.lastSailModeForDay(dayLogId), 'main,genoa');
    });

    test('another day does not leak its mode in', () async {
      final dayOne = await makeDay();
      final dayTwo = await makeDay();
      await addEntry(dayOne, DateTime.utc(2026, 8, 8, 9), sailMode: 'motor');

      expect(await db.lastSailModeForDay(dayTwo), isNull);
    });
  });
}
