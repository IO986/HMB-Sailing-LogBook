import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/miles/services/voyage_miles_summary.dart';

/// The mileage number alone says nothing about where the crew actually went.
/// A school or a charter company reads the chain of ports first — Biograd –
/// Žut – Veli Rat – Zadar – Biograd — so the certificate carries it.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<DayLog> day(int dayOfMonth, String? from, String? to) async {
    final c = await db.insertCharter(ChartersCompanion.insert(
      title: 'Plavba',
      dateFrom: DateTime(2026, 5, 2),
      dateTo: DateTime(2026, 5, 9),
      createdAt: DateTime(2026, 5, 2),
    ));
    return db.insertDayLog(DayLogsCompanion.insert(
      charterId: c.id,
      date: DateTime(2026, 5, dayOfMonth),
      portFrom: Value(from),
      portTo: Value(to),
    ));
  }

  test('the chain follows the days and merges repeated stops', () async {
    final days = [
      await day(2, 'Biograd', 'Žut'),
      await day(3, 'Žut', 'Veli Rat'),
      await day(4, 'Veli Rat', 'Zadar'),
      await day(5, 'Zadar', 'Biograd'),
    ];

    expect(routeStopsOf(days),
        ['Biograd', 'Žut', 'Veli Rat', 'Zadar', 'Biograd']);
  });

  test('days out of order are sorted by date first', () async {
    final days = [
      await day(4, 'Veli Rat', 'Zadar'),
      await day(2, 'Biograd', 'Žut'),
      await day(3, 'Žut', 'Veli Rat'),
    ];

    expect(routeStopsOf(days), ['Biograd', 'Žut', 'Veli Rat', 'Zadar']);
  });

  /// A day whose geocoding had no internet must not break the chain in two.
  test('a day with no port recorded is skipped, not a gap', () async {
    final days = [
      await day(2, 'Biograd', 'Žut'),
      await day(3, null, null),
      await day(4, 'Veli Rat', 'Zadar'),
    ];

    expect(routeStopsOf(days), ['Biograd', 'Žut', 'Veli Rat', 'Zadar']);
  });

  test('an overnight stop written in two spellings still merges', () async {
    final days = [
      await day(2, 'Biograd', 'Zadar'),
      await day(3, 'ZADAR', 'Biograd'),
    ];

    expect(routeStopsOf(days), ['Biograd', 'Zadar', 'Biograd']);
  });

  test('a voyage with no ports at all has no route to print', () async {
    expect(routeStopsOf([await day(2, null, null)]), isEmpty);
    expect(routeStopsOf(const []), isEmpty);
  });

  test('the summary carries the route to the certificate', () async {
    final days = [
      await day(2, 'Biograd', 'Žut'),
      await day(3, 'Žut', 'Biograd'),
    ];
    final summary = summariseVoyage(days: days, points: const []);

    expect(summary.routeLine, 'Biograd – Žut – Biograd');
  });
}
