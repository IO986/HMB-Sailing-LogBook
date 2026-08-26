import 'package:flutter/material.dart';

import '../../core/models/point_of_sail.dart';
import '../utils/sail_direction_labels.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

/// The paper logbook's boat silhouette, as a tappable field.
///
/// The printed form has one box: a hull seen from above with the points of
/// sail written down both sides and `S-` / `P-` underneath. That is one fact
/// in two coordinates — "beam reach on starboard" — so the picker keeps the
/// same shape: pick a position on the side the wind comes from, and the tack
/// falls out of which side you tapped. Running sits alone at the bottom,
/// because with the wind dead astern there is no side to record.
///
/// Tapping the selected position again clears the field. A skipper who did
/// not read the wind should be able to leave the box empty, exactly like on
/// paper — an entry that guesses is worse than one that admits it does not
/// know.
class SailDirectionPicker extends StatelessWidget {
  const SailDirectionPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  final SailDirection? value;
  final ValueChanged<SailDirection?> onChanged;

  static const _sided = [
    PointOfSail.closeHauled,
    PointOfSail.closeReach,
    PointOfSail.beamReach,
    PointOfSail.broadReach,
  ];

  void _pick(PointOfSail p, Tack? tack) {
    final next = SailDirection(p, p == PointOfSail.running ? null : tack);
    onChanged(next == value ? null : next);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;

    Widget side(Tack tack) => Column(
          crossAxisAlignment: tack == Tack.port
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tackLabel(tack, l),
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: tack == Tack.starboard
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 4),
            for (final p in _sided)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _PosChip(
                  text: pointOfSailLabel(p, l),
                  selected: value?.pointOfSail == p && value?.tack == tack,
                  accent: tack == Tack.starboard
                      ? Colors.green.shade700
                      : Colors.red.shade700,
                  onTap: () => _pick(p, tack),
                ),
              ),
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: side(Tack.port)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: _HullSilhouette(),
            ),
            Expanded(child: side(Tack.starboard)),
          ],
        ),
        const SizedBox(height: 6),
        Center(
          child: _PosChip(
            text: pointOfSailLabel(PointOfSail.running, l),
            selected: value?.pointOfSail == PointOfSail.running,
            accent: scheme.primary,
            onTap: () => _pick(PointOfSail.running, null),
          ),
        ),
      ],
    );
  }
}

class _PosChip extends StatelessWidget {
  const _PosChip({
    required this.text,
    required this.selected,
    required this.accent,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.15) : null,
          border: Border.all(
            color: selected ? accent : scheme.outlineVariant,
            width: selected ? 1.6 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? accent : scheme.onSurface,
          ),
        ),
      ),
    );
  }
}

/// Hull seen from above, bow up — the same drawing the paper form carries,
/// so the printed and the in-app logbook read alike.
class _HullSilhouette extends StatelessWidget {
  const _HullSilhouette();

  @override
  Widget build(BuildContext context) => CustomPaint(
        size: const Size(34, 150),
        painter: _HullPainter(Theme.of(context).colorScheme.onSurfaceVariant),
      );
}

class _HullPainter extends CustomPainter {
  const _HullPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final path = Path()
      ..moveTo(w / 2, 0)
      ..cubicTo(w, h * 0.28, w, h * 0.72, w * 0.80, h)
      ..lineTo(w * 0.20, h)
      ..cubicTo(0, h * 0.72, 0, h * 0.28, w / 2, 0)
      ..close();

    canvas
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.fill
          ..color = color.withValues(alpha: 0.08),
      )
      ..drawPath(
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = color,
      )
      // Centreline: the mast/keel line, which is what the angles are read from.
      ..drawLine(
        Offset(w / 2, h * 0.12),
        Offset(w / 2, h * 0.92),
        Paint()
          ..strokeWidth = 1
          ..color = color.withValues(alpha: 0.5),
      );
  }

  @override
  bool shouldRepaint(_HullPainter oldDelegate) => oldDelegate.color != color;
}
