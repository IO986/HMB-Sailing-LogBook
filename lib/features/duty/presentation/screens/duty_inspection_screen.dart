import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../../../core/database/app_database.dart';
import '../../../../l10n/app_localizations.dart';
import '../../providers/duty_provider.dart';

/// Full-screen answer to "who is on duty right now", meant to be handed to an
/// inspection boarding the vessel.
///
/// Deliberately has no editing affordances at all: nothing reachable from this
/// screen may change a record while someone else is holding the phone.
class DutyInspectionScreen extends ConsumerStatefulWidget {
  final Charter charter;
  const DutyInspectionScreen({super.key, required this.charter});

  @override
  ConsumerState<DutyInspectionScreen> createState() =>
      _DutyInspectionScreenState();
}

class _DutyInspectionScreenState extends ConsumerState<DutyInspectionScreen> {
  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    WakelockPlus.disable();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final charter = widget.charter;
    final running =
        ref.watch(runningDutiesProvider(charter.id)).valueOrNull ??
            const <DutyPeriod>[];
    final now = ref.watch(dutyClockProvider).valueOrNull ?? DateTime.now();

    return Scaffold(
      backgroundColor: const Color(0xFF07121F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                  child: Text(
                    charter.vesselName ?? charter.title,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ]),
              if (charter.mmsi != null || charter.callsign != null)
                Text(
                  [
                    if (charter.mmsi != null) 'MMSI ${charter.mmsi}',
                    if (charter.callsign != null) charter.callsign!,
                  ].join('   ·   '),
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
              if (charter.skipperName != null)
                Text('${l.pdfSkipperLabel}: ${charter.skipperName}',
                    style:
                        const TextStyle(color: Colors.white70, fontSize: 14)),

              const SizedBox(height: 8),
              // Both clocks: an inspector's paperwork and the log run on UTC,
              // the crew think in local time.
              Text(
                '${DateFormat('HH:mm:ss').format(now)}  ·  '
                '${DateFormat('HH:mm:ss').format(now.toUtc())} UTC',
                style: const TextStyle(
                    color: Colors.white, fontSize: 15, letterSpacing: 1),
              ),

              const SizedBox(height: 24),
              Text(l.dutyRoster.toUpperCase(),
                  style: const TextStyle(
                      color: Colors.white38,
                      fontSize: 12,
                      letterSpacing: 2,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              Expanded(
                child: running.isEmpty
                    ? _NobodyOnDuty(text: l.dutyNobodyOnDuty)
                    : ListView(
                        children: running
                            .map((d) => _DutyBlock(duty: d, now: now))
                            .toList(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DutyBlock extends StatelessWidget {
  final DutyPeriod duty;
  final DateTime now;
  const _DutyBlock({required this.duty, required this.now});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final elapsed = now.toUtc().difference(duty.fromUtc);
    final local = duty.fromUtc.toLocal();

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.greenAccent.withValues(alpha: 0.35)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(duty.crewName,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(
          '${l.dutySince(DateFormat('HH:mm').format(local))}  '
          '(${DateFormat('HH:mm').format(duty.fromUtc)} UTC)',
          style: const TextStyle(color: Colors.white70, fontSize: 15),
        ),
        const SizedBox(height: 2),
        Text(l.dutyElapsed(elapsed.inHours, elapsed.inMinutes % 60),
            style: TextStyle(
                color: Colors.greenAccent.shade200,
                fontSize: 17,
                fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

class _NobodyOnDuty extends StatelessWidget {
  final String text;
  const _NobodyOnDuty({required this.text});

  @override
  Widget build(BuildContext context) {
    // An explicit statement, never an empty screen — an inspector must not be
    // left wondering whether the app simply failed to load.
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white24),
        ),
        child: Text(text,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white70, fontSize: 18)),
      ),
    );
  }
}
