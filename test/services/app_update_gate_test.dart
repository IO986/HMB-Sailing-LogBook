import 'package:flutter_test/flutter_test.dart';
import 'package:hmb_sailing_log/core/services/app_update_service.dart';

/// Kontrola aktualizácie sa smie spýtať Play len vtedy, keď to skipera
/// nemôže vyrušiť. Samotné Play API sa v teste nespustí, ale toto
/// rozhodovanie je práve tá časť, na ktorej záleží.
void main() {
  final now = DateTime.utc(2026, 8, 27, 12);

  test('prvé spustenie sa pýta', () {
    expect(
        shouldCheckForUpdate(now: now, lastCheck: null, isTracking: false),
        isTrue);
  });

  test('počas plavby nikdy', () {
    expect(
        shouldCheckForUpdate(now: now, lastCheck: null, isTracking: true),
        isFalse,
        reason: 'Play by uprostred plavby vyhodilo súhlasový dialóg');
  });

  test('druhýkrát v ten istý deň už nie', () {
    expect(
        shouldCheckForUpdate(
            now: now,
            lastCheck: now.subtract(const Duration(hours: 3)),
            isTracking: false),
        isFalse);
  });

  test('na druhý deň zase áno', () {
    expect(
        shouldCheckForUpdate(
            now: now,
            lastCheck: now.subtract(const Duration(days: 1, minutes: 1)),
            isTracking: false),
        isTrue);
  });

  test('čas posunutý dozadu kontrolu nezablokuje navždy', () {
    expect(
        shouldCheckForUpdate(
            now: now,
            lastCheck: now.add(const Duration(days: 30)),
            isTracking: false),
        isTrue,
        reason: 'hodiny na telefóne sa dajú prestaviť');
  });
}
