import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

import '../../../../main.dart';
import '../../providers/tracking_provider.dart';
import 'tracking_control_dialogs.dart';

/// Ako často sa kontroluje, či plavba nestojí. Nie je to drahé — jeden
/// indexovaný dotaz — a dlhší interval by predlžoval práve to ticho, ktoré
/// má banner odhaliť.
const _pollEvery = Duration(seconds: 20);

/// Ako dlho sa nič nezapísalo, alebo `null`, keď je všetko v poriadku.
///
/// Otvorená plavba, ktorá sa nezapisuje, je najhorší možný stav appky: skiper
/// verí, že sa denník píše, a nepíše sa. Vo štvrtok tak zmizlo 45 minút
/// plavby a nikto si to nevšimol, kým sa neexportovalo PDF. Foreground
/// service beh nezaručí — Honor a Huawei appku zabíjajú vlastnou správou
/// napájania — takže appka musí aspoň nahlas povedať, že stojí.
final trackingStalledProvider = StreamProvider<Duration?>((ref) async* {
  // Kým trasovanie beží, nie je čo hlásiť. Prepnutie sem dorazí okamžite,
  // takže banner po obnovení zmizne bez čakania na ďalší tik.
  final isTracking = ref.watch(isTrackingProvider);
  if (isTracking) {
    yield null;
    return;
  }
  final db = ref.watch(databaseProvider);
  while (true) {
    final interrupted = await db.getInterruptedSession();
    if (interrupted == null) {
      yield null;
    } else {
      final last = await db.getLastTrackPoint(interrupted.sessionId);
      yield last == null
          ? null
          : DateTime.now().toUtc().difference(last.timestamp.toUtc());
    }
    await Future<void>.delayed(_pollEvery);
  }
});

/// Červený pruh cez celú šírku, kým otvorená plavba nezapisuje.
class TrackingStalledBanner extends ConsumerWidget {
  const TrackingStalledBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stalled = ref.watch(trackingStalledProvider).valueOrNull;
    if (stalled == null) return const SizedBox.shrink();

    final l = AppLocalizations.of(context);
    return Material(
      color: Colors.red.shade700,
      child: InkWell(
        onTap: () => _resume(context, ref),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(children: [
            const Icon(Icons.gps_off, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l.trackingStalledTitle,
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13)),
                  Text(l.trackingStalledSince('${stalled.inMinutes}'),
                      style: const TextStyle(
                          color: Colors.white70, fontSize: 11)),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _resume(context, ref),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: Text(l.trackingResumeAction),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    final voyage = await findInterruptedVoyage(ref.read(databaseProvider));
    if (voyage == null || !context.mounted) return;
    await resumeInterruptedVoyage(context, ref, voyage);
  }
}
