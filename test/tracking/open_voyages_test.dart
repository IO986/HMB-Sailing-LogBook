import 'package:drift/drift.dart' show DatabaseConnection, Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/charter/providers/charter_provider.dart';
import 'package:hmb_sailing_log/main.dart';

/// Pri výcviku beží niekoľko plavieb naraz — jedna na žiaka. Po prerušení sa
/// skiper potreboval vrátiť do tej správnej, nie do poslednej založenej, a
/// ponuka pri štarte to dovtedy nevedela.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
  });
  tearDown(() async => db.close());

  Future<Charter> voyage(
    String title,
    DateTime from, {
    bool checkedOut = false,
    String source = 'live',
  }) =>
      db.insertCharter(ChartersCompanion.insert(
        title: title,
        dateFrom: from,
        dateTo: from.add(const Duration(days: 7)),
        createdAt: from,
        checkOutDone: Value(checkedOut),
        source: Value(source),
      ));

  ProviderContainer container() {
    final c = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    addTearDown(c.dispose);
    return c;
  }

  test('rozostavané plavby sú všetky, najnovšia prvá', () async {
    await voyage('Žiak A', DateTime(2026, 6, 1));
    await voyage('Žiak B', DateTime(2026, 6, 8));
    await voyage('Žiak C', DateTime(2026, 5, 20));

    final open = await container().read(openVoyagesProvider.future);

    expect(open.map((c) => c.title).toList(), ['Žiak B', 'Žiak A', 'Žiak C']);
  });

  test('odovzdaná plavba a importovaná trasa medzi ne nepatria', () async {
    await voyage('Beží', DateTime(2026, 6, 1));
    await voyage('Odovzdaná', DateTime(2026, 6, 5), checkedOut: true);
    await voyage('Z GPX', DateTime(2026, 6, 9), source: 'gpx');

    final open = await container().read(openVoyagesProvider.future);

    expect(open.map((c) => c.title).toList(), ['Beží']);
  });

  test('ponuka „pokračovať" berie prvú z toho istého zoznamu', () async {
    await voyage('Staršia', DateTime(2026, 6, 1));
    await voyage('Najnovšia', DateTime(2026, 6, 8));

    final c = container();
    final last = await c.read(openVoyageProvider.future);
    final open = await c.read(openVoyagesProvider.future);

    expect(last?.title, 'Najnovšia');
    expect(open.first.title, last?.title);
  });

  test('bez rozostavanej plavby nie je z čoho vyberať', () async {
    await voyage('Odovzdaná', DateTime(2026, 6, 5), checkedOut: true);

    final c = container();
    expect(await c.read(openVoyagesProvider.future), isEmpty);
    expect(await c.read(openVoyageProvider.future), isNull);
  });
}
