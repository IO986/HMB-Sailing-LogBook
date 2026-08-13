import 'package:drift/drift.dart' show DatabaseConnection;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/database/app_database.dart';
import 'package:hmb_sailing_log/features/map/providers/map_provider.dart';
import 'package:hmb_sailing_log/main.dart' show databaseProvider;
import 'package:shared_preferences/shared_preferences.dart';

/// Navigation to a waypoint must not outlive the waypoint.
///
/// Reported from testing: a waypoint was set as the VMG target on the
/// instruments panel, then deleted on the map. The panel kept showing
/// bearing and distance to a point that no longer existed, and the only way
/// out was to reopen the picker and choose "no target". The target used to
/// be a snapshot of the whole Waypoint held in the instruments screen, so
/// nothing could reach it from the map.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late ProviderContainer container;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    db = AppDatabase.forTesting(DatabaseConnection(NativeDatabase.memory()));
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });
  tearDown(() async {
    container.dispose();
    await db.close();
  });

  Future<int> addWaypoint(String name) async {
    final id = await db.insertWaypoint(WaypointsCompanion.insert(
      name: name,
      latitude: 43.5,
      longitude: 16.4,
      createdAt: DateTime(2026, 8, 13),
    ));
    container.invalidate(waypointsProvider);
    await container.read(waypointsProvider.future);
    return id;
  }

  test('no target selected means no navigation', () async {
    await addWaypoint('Vis');
    expect(container.read(navTargetProvider), isNull);
  });

  test('a selected target resolves to the waypoint itself', () async {
    final id = await addWaypoint('Vis');
    container.read(navTargetIdProvider.notifier).state = id;

    final target = container.read(navTargetProvider);
    expect(target, isNotNull);
    expect(target!.id, id);
    expect(target.name, 'Vis');
  });

  test('deleting the target waypoint switches the navigation off', () async {
    final id = await addWaypoint('Vis');
    container.read(navTargetIdProvider.notifier).state = id;
    expect(container.read(navTargetProvider), isNotNull);

    await container.read(mapNotifierProvider.notifier).deleteWaypoint(id);
    await container.read(waypointsProvider.future);

    expect(container.read(navTargetIdProvider), isNull,
        reason: 'the id must be cleared, not just fail to resolve');
    expect(container.read(navTargetProvider), isNull);
  });

  test('deleting some other waypoint leaves the navigation alone', () async {
    final target = await addWaypoint('Vis');
    final other = await addWaypoint('Hvar');
    container.read(navTargetIdProvider.notifier).state = target;

    await container.read(mapNotifierProvider.notifier).deleteWaypoint(other);
    await container.read(waypointsProvider.future);

    expect(container.read(navTargetIdProvider), target);
    expect(container.read(navTargetProvider)?.name, 'Vis');
  });

  test('a target that vanished behind our back resolves to null', () async {
    final id = await addWaypoint('Vis');
    container.read(navTargetIdProvider.notifier).state = id;

    // Straight through the DB, bypassing the notifier - stands in for any
    // future path that removes a waypoint without clearing the target.
    await db.deleteWaypoint(id);
    container.invalidate(waypointsProvider);
    await container.read(waypointsProvider.future);

    expect(container.read(navTargetProvider), isNull);
  });

  test('renaming the target keeps the navigation on it', () async {
    final id = await addWaypoint('Vis');
    container.read(navTargetIdProvider.notifier).state = id;

    await container.read(mapNotifierProvider.notifier).renameWaypoint(id, 'Komiža');
    await container.read(waypointsProvider.future);

    expect(container.read(navTargetProvider)?.name, 'Komiža');
  });
}
