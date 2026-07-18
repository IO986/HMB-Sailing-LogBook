import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/services/moon_calculator.dart';
import '../../../miles/services/solar_calculator.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// Karta so slnkom (východ/západ pre danú GPS polohu) a fázou mesiaca
/// (globálna, poloha nepotrebná). Oba výpočty sú čisto lokálne – žiadne
/// volanie API (pozri [SolarCalculator], [MoonCalculator]).
class SunMoonCard extends StatelessWidget {
  final double? lat;
  final double? lon;
  final DateTime date;

  SunMoonCard({super.key, required this.lat, required this.lon, DateTime? date})
      : date = date ?? DateTime.now();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final times = (lat != null && lon != null)
        ? SolarCalculator.sunriseSunsetUtc(date, lat!, lon!)
        : null;
    final illumination = MoonCalculator.illumination(date);
    final phaseIndex = MoonCalculator.phaseIndex(date);
    final waxing = MoonCalculator.isWaxing(date);
    final phaseNames = [
      l.moonPhaseNew, l.moonPhaseWaxingCrescent, l.moonPhaseFirstQuarter,
      l.moonPhaseWaxingGibbous, l.moonPhaseFull, l.moonPhaseWaningGibbous,
      l.moonPhaseLastQuarter, l.moonPhaseWaningCrescent,
    ];
    final timeFmt = DateFormat.Hm();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              const Icon(Icons.brightness_4_outlined, size: 18),
              const SizedBox(width: 6),
              Text(l.sunAndMoonCard,
                  style: Theme.of(context)
                      .textTheme
                      .titleSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: times == null
                      ? Text(l.noSunMoonGps,
                          style: const TextStyle(color: Colors.grey))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _SunRow(
                              icon: Icons.wb_sunny_outlined,
                              label: l.sunriseLabel,
                              value: times.sunrise != null
                                  ? timeFmt.format(times.sunrise!.toLocal())
                                  : '—',
                            ),
                            const SizedBox(height: 6),
                            _SunRow(
                              icon: Icons.nights_stay_outlined,
                              label: l.sunsetLabel,
                              value: times.sunset != null
                                  ? timeFmt.format(times.sunset!.toLocal())
                                  : '—',
                            ),
                          ],
                        ),
                ),
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CustomPaint(
                    painter: _MoonPhasePainter(
                      illumination: illumination,
                      waxing: waxing,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 96,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(phaseNames[phaseIndex],
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 13)),
                      Text(
                          '${l.moonIlluminationLabel}: '
                          '${(illumination * 100).round()}%',
                          style: const TextStyle(fontSize: 11, color: Colors.grey)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SunRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _SunRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Row(children: [
        Icon(icon, size: 18, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ', style: const TextStyle(color: Colors.grey)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ]);
}

/// Kresli disk mesiaca: tmavá základňa + osvetlená plocha zložená z
/// polkruhu a elipsy (terminátor), presne ako sa mesačná fáza reálne javí.
class _MoonPhasePainter extends CustomPainter {
  final double illumination; // 0 (novmesiac) .. 1 (spln)
  final bool waxing;
  final Color color;

  _MoonPhasePainter(
      {required this.illumination, required this.waxing, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final r = min(size.width, size.height) / 2 - 2;
    final center = Offset(size.width / 2, size.height / 2);

    final darkPaint = Paint()..color = color.withValues(alpha: 0.15);
    final brightPaint = Paint()..color = color;
    final outlinePaint = Paint()
      ..color = color.withValues(alpha: 0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawCircle(center, r, darkPaint);

    // Konvencia: dorastajúci mesiac je osvetlený vpravo (severná pologuľa).
    final rightLit = waxing;
    final halfDisc = _halfDisc(center, r, rightLit);

    final Path litPath;
    if (illumination <= 0.5) {
      // kosáčik: polkruh mínus stredová elipsa (elipsa zmenšuje osvetlenú plochu)
      final ellipseRx = r * (1 - 2 * illumination);
      final ellipse = Path()
        ..addOval(Rect.fromCenter(center: center, width: ellipseRx * 2, height: r * 2));
      litPath = Path.combine(PathOperation.difference, halfDisc, ellipse);
    } else {
      // dvíhajúci mesiac (gibbous): polkruh plus lunula na druhej strane
      final ellipseRx = r * (2 * illumination - 1);
      final ellipse = Path()
        ..addOval(Rect.fromCenter(center: center, width: ellipseRx * 2, height: r * 2));
      litPath = Path.combine(PathOperation.union, halfDisc, ellipse);
    }

    canvas.drawPath(litPath, brightPaint);
    canvas.drawCircle(center, r, outlinePaint);
  }

  Path _halfDisc(Offset center, double r, bool right) {
    final top = Offset(center.dx, center.dy - r);
    final bottom = Offset(center.dx, center.dy + r);
    return Path()
      ..moveTo(top.dx, top.dy)
      ..arcToPoint(bottom, radius: Radius.circular(r), clockwise: right)
      ..close();
  }

  @override
  bool shouldRepaint(_MoonPhasePainter old) =>
      old.illumination != illumination || old.waxing != waxing || old.color != color;
}
