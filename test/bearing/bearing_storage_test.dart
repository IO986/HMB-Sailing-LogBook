import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/core/models/bearing_kind.dart';

/// Zameranie je navigačný záznam, nie prchavá čiara na obrazovke: musí prežiť
/// reštart, patriť konkrétnemu dňu plavby a niesť aj surové odčítanie, nielen
/// opravený výsledok.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  final noon = DateTime.utc(2026, 8, 18, 12);

  Future<({int charterId, int dayLogId})> makeDay(
      {DateTime? date, String title = 'Plavba'}) async {
    final when = date ?? noon;
    final charter = await db.insertCharter(ChartersCompanion.insert(
      title: title,
      dateFrom: when,
      dateTo: when,
      createdAt: when,
    ));
    final day = await db.insertDayLog(DayLogsCompanion.insert(
      charterId: charter.id,
      date: when,
    ));
    return (charterId: charter.id, dayLogId: day.id);
  }

  Future<int> addBearing({
    int? dayLogId,
    int? charterId,
    double magnetic = 90,
    double declination = 4.2,
    double? trueBearing,
    String? label,
    DateTime? takenAt,
    double uncertainty = 8,
    String group = 'skupina-1',
  }) =>
      db.insertBearing(BearingsCompanion.insert(
        kind: BearingKind.intersection.code,
        observerLat: const Value(43.5081),
        observerLon: const Value(16.4402),
        magneticBearing: magnetic,
        declination: declination,
        declinationSource: const Value('gps'),
        trueBearing: trueBearing ?? (magnetic + declination) % 360,
        sightGroupId: Value(group),
        label: Value(label),
        takenAt: takenAt ?? noon,
        uncertaintyDeg: Value(uncertainty),
        dayLogId: Value(dayLogId),
        charterId: Value(charterId),
      ));

  test('uložené zameranie sa vráti aj s nameraným magnetickým kurzom',
      () async {
    await addBearing(magnetic: 90, declination: 4.2, label: 'Maják Stončica');

    final stored = (await db.getAllBearings()).single;
    expect(stored.magneticBearing, 90);
    expect(stored.declination, 4.2);
    expect(stored.trueBearing, closeTo(94.2, 1e-9));
    expect(stored.label, 'Maják Stončica');
    expect(stored.observerLat, closeTo(43.5081, 1e-9));
    expect(BearingKind.fromCode(stored.kind), BearingKind.intersection);
  });

  test('bez popisu a bez fotky sa zameranie uloží tiež', () async {
    await addBearing();
    final stored = (await db.getAllBearings()).single;
    expect(stored.label, isNull);
    expect(stored.photoPath, isNull);
  });

  test('predvolená neistota je ±8°', () async {
    await db.insertBearing(BearingsCompanion.insert(
      kind: BearingKind.intersection.code,
      observerLat: const Value(43.5),
      observerLon: const Value(16.4),
      magneticBearing: 10,
      declination: 4,
      declinationSource: const Value('gps'),
      trueBearing: 14,
      sightGroupId: const Value('skupina-1'),
      takenAt: noon,
    ));
    expect((await db.getAllBearings()).single.uncertaintyDeg, 8);
  });

  test('zoznam je zoradený od najnovšieho', () async {
    await addBearing(label: 'staré', takenAt: noon);
    await addBearing(
        label: 'nové', takenAt: noon.add(const Duration(minutes: 5)));

    final all = await db.getAllBearings();
    expect(all.map((b) => b.label), ['nové', 'staré']);
  });

  test('deň vidí len svoje zamerania', () async {
    final first = await makeDay(title: 'Prvý deň');
    final second = await makeDay(
        date: noon.add(const Duration(days: 1)), title: 'Druhý deň');

    await addBearing(
        dayLogId: first.dayLogId, charterId: first.charterId, label: 'A');
    await addBearing(
        dayLogId: first.dayLogId, charterId: first.charterId, label: 'B');
    await addBearing(
        dayLogId: second.dayLogId, charterId: second.charterId, label: 'C');

    expect((await db.getBearingsForDay(first.dayLogId)).map((b) => b.label),
        ['A', 'B']);
    expect((await db.getBearingsForDay(second.dayLogId)).map((b) => b.label),
        ['C']);
  });

  test('plavba zozbiera zamerania zo všetkých svojich dní', () async {
    final day = await makeDay();
    await addBearing(dayLogId: day.dayLogId, charterId: day.charterId);
    await addBearing(
        dayLogId: day.dayLogId,
        charterId: day.charterId,
        takenAt: noon.add(const Duration(hours: 2)));
    // Zameranie mimo plavby do nej nesmie spadnúť.
    await addBearing();

    expect(await db.getBearingsForCharter(day.charterId), hasLength(2));
  });

  test('zameranie mimo trackingu nemá deň ani plavbu', () async {
    await addBearing();
    final stored = (await db.getAllBearings()).single;
    expect(stored.dayLogId, isNull);
    expect(stored.charterId, isNull);
  });

  test('premenovanie prepíše popis a prázdny ho zmaže', () async {
    final id = await addBearing(label: 'Skala');
    await db.updateBearingLabel(id, 'Maják Sušac');
    expect((await db.getAllBearings()).single.label, 'Maják Sušac');

    await db.updateBearingLabel(id, null);
    expect((await db.getAllBearings()).single.label, isNull);
  });

  test('mazanie odstráni jedno zameranie, ostatné nechá', () async {
    final keep = await addBearing(label: 'zostáva');
    final drop = await addBearing(label: 'mizne');

    await db.deleteBearing(drop);

    final all = await db.getAllBearings();
    expect(all, hasLength(1));
    expect(all.single.id, keep);
  });

  test('vyčistenie zmaže všetky zamerania', () async {
    await addBearing();
    await addBearing();
    await db.deleteAllBearings();
    expect(await db.getAllBearings(), isEmpty);
  });

  test('watchAllBearings ohlási nový záznam', () async {
    final stream = db.watchAllBearings();
    final seen = expectLater(
      stream,
      emitsThrough(predicate<List<Bearing>>(
          (rows) => rows.length == 1 && rows.single.label == 'Ostrov')),
    );
    await addBearing(label: 'Ostrov');
    await seen;
  });
}
