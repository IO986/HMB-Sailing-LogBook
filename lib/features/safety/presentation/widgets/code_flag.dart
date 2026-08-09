import 'dart:math' as math;

import 'package:flutter/material.dart';

/// International Code of Signals letter flags.
///
/// Kept apart from the reference screen so the drawing can be unit-tested:
/// several letters share a colour pair (A/M/S are white+blue, J/N/P/X are
/// blue+white) and only the pattern tells them apart, which is exactly the
/// kind of thing that silently regresses.

// Flag colours. Deliberately not Material shades: code flags are printed in
// flat signal colours, and Material blue/red read far too light next to each
// other on a swatch this small.
const _white = Color(0xFFFFFFFF);
const _black = Color(0xFF111111);
const _blue = Color(0xFF0A3EA0);
const _red = Color(0xFFD00A17);
const _yellow = Color(0xFFFFD200);

/// Layout of a code flag, following the ICS blazons.
///
/// Colours are listed hoist-to-fly for vertical divisions and top-to-bottom
/// for horizontal ones.
enum FlagPattern {
  /// One colour over the whole flag (Q).
  solid,

  /// Equal horizontal bands, top to bottom (C, E, J).
  horizontal,

  /// Equal vertical bands, hoist to fly (G, H, K, T).
  vertical,

  /// Horizontal 1:2:1 bands - a "Spanish fess" (D).
  wideBand,

  /// Four quarters, first colour at the upper hoist (L, U).
  quartered,

  /// 4x4 chequy, first colour at the upper hoist (N).
  checker,

  /// Upright cross: [field, cross] (R, X).
  cross,

  /// Diagonal cross: [field, saltire] (M, V).
  saltire,

  /// Centred rectangle: [field, rectangle] (P, S).
  inescutcheon,

  /// Three nested rectangles: [outer, fimbriation, centre] (W).
  bordered,

  /// Centred disc: [field, disc] (I).
  circle,

  /// Lozenge touching all four edges: [field, lozenge] (F).
  diamond,

  /// Split along the upper-hoist to lower-fly diagonal: [above, below] (O).
  perBend,

  /// Diagonal stripes perpendicular to that diagonal (Y).
  diagonalStripes,

  /// Four triangles cut by both diagonals: [top, hoist, bottom, fly] (Z).
  perSaltire,

  /// Vertical halves with the fly cut into a swallowtail (A, B).
  swallowtail,
}

@immutable
class CodeFlag {
  const CodeFlag(this.pattern, this.colors);

  final FlagPattern pattern;
  final List<Color> colors;
}

/// The 26 letter flags, keyed by letter.
const Map<String, CodeFlag> codeFlags = {
  'A': CodeFlag(FlagPattern.swallowtail, [_white, _blue]),
  'B': CodeFlag(FlagPattern.swallowtail, [_red]),
  'C': CodeFlag(FlagPattern.horizontal, [_blue, _white, _red, _white, _blue]),
  'D': CodeFlag(FlagPattern.wideBand, [_yellow, _blue, _yellow]),
  'E': CodeFlag(FlagPattern.horizontal, [_blue, _red]),
  'F': CodeFlag(FlagPattern.diamond, [_white, _red]),
  'G': CodeFlag(
      FlagPattern.vertical, [_yellow, _blue, _yellow, _blue, _yellow, _blue]),
  'H': CodeFlag(FlagPattern.vertical, [_white, _red]),
  'I': CodeFlag(FlagPattern.circle, [_yellow, _black]),
  'J': CodeFlag(FlagPattern.horizontal, [_blue, _white, _blue]),
  'K': CodeFlag(FlagPattern.vertical, [_yellow, _blue]),
  'L': CodeFlag(FlagPattern.quartered, [_yellow, _black]),
  'M': CodeFlag(FlagPattern.saltire, [_blue, _white]),
  'N': CodeFlag(FlagPattern.checker, [_blue, _white]),
  'O': CodeFlag(FlagPattern.perBend, [_red, _yellow]),
  'P': CodeFlag(FlagPattern.inescutcheon, [_blue, _white]),
  'Q': CodeFlag(FlagPattern.solid, [_yellow]),
  'R': CodeFlag(FlagPattern.cross, [_red, _yellow]),
  'S': CodeFlag(FlagPattern.inescutcheon, [_white, _blue]),
  'T': CodeFlag(FlagPattern.vertical, [_red, _white, _blue]),
  'U': CodeFlag(FlagPattern.quartered, [_red, _white]),
  'V': CodeFlag(FlagPattern.saltire, [_white, _red]),
  'W': CodeFlag(FlagPattern.bordered, [_blue, _white, _red]),
  'X': CodeFlag(FlagPattern.cross, [_white, _blue]),
  'Y': CodeFlag(FlagPattern.diagonalStripes, [_yellow, _red]),
  'Z': CodeFlag(FlagPattern.perSaltire, [_yellow, _black, _red, _blue]),
};

/// Draws the code flag for [letter].
class CodeFlagView extends StatelessWidget {
  const CodeFlagView({
    required this.letter,
    this.width = 52,
    this.height = 36,
    super.key,
  });

  final String letter;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        width: width,
        height: height,
        child: CustomPaint(painter: CodeFlagPainter(codeFlags[letter]!)),
      ),
    );
  }
}

/// Paints a [CodeFlag] over the whole canvas, hoist on the left.
///
/// Swallowtail flags clip themselves; every other pattern fills the rect.
class CodeFlagPainter extends CustomPainter {
  const CodeFlagPainter(this.flag);

  final CodeFlag flag;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final c = flag.colors;

    void box(double l, double t, double r, double b, Color color) =>
        canvas.drawRect(Rect.fromLTRB(l, t, r, b), Paint()..color = color);

    void poly(List<Offset> points, Color color) => canvas.drawPath(
        Path()..addPolygon(points, true), Paint()..color = color);

    void bands(List<Color> stripes, {required bool horizontal}) {
      final step = (horizontal ? h : w) / stripes.length;
      for (var i = 0; i < stripes.length; i++) {
        if (horizontal) {
          box(0, i * step, w, (i + 1) * step, stripes[i]);
        } else {
          box(i * step, 0, (i + 1) * step, h, stripes[i]);
        }
      }
    }

    switch (flag.pattern) {
      case FlagPattern.solid:
        box(0, 0, w, h, c[0]);

      case FlagPattern.horizontal:
        bands(c, horizontal: true);

      case FlagPattern.vertical:
        bands(c, horizontal: false);

      case FlagPattern.wideBand:
        box(0, 0, w, h, c[0]);
        box(0, h * 0.25, w, h * 0.75, c[1]);

      case FlagPattern.quartered:
        box(0, 0, w, h, c[1]);
        box(0, 0, w / 2, h / 2, c[0]);
        box(w / 2, h / 2, w, h, c[0]);

      case FlagPattern.checker:
        const n = 4;
        final cw = w / n;
        final ch = h / n;
        for (var row = 0; row < n; row++) {
          for (var col = 0; col < n; col++) {
            box(col * cw, row * ch, (col + 1) * cw, (row + 1) * ch,
                (row + col).isEven ? c[0] : c[1]);
          }
        }

      case FlagPattern.cross:
        box(0, 0, w, h, c[0]);
        box(w * 0.36, 0, w * 0.64, h, c[1]);
        box(0, h * 0.36, w, h * 0.64, c[1]);

      case FlagPattern.saltire:
        box(0, 0, w, h, c[0]);
        final arm = h * 0.19;
        poly([
          Offset.zero,
          Offset(arm, 0),
          Offset(w, h - arm),
          Offset(w, h),
          Offset(w - arm, h),
          Offset(0, arm),
        ], c[1]);
        poly([
          Offset(w, 0),
          Offset(w, arm),
          Offset(arm, h),
          Offset(0, h),
          Offset(0, h - arm),
          Offset(w - arm, 0),
        ], c[1]);

      case FlagPattern.inescutcheon:
        box(0, 0, w, h, c[0]);
        box(w * 0.30, h * 0.28, w * 0.70, h * 0.72, c[1]);

      case FlagPattern.bordered:
        box(0, 0, w, h, c[0]);
        box(w * 0.18, h * 0.18, w * 0.82, h * 0.82, c[1]);
        box(w * 0.32, h * 0.32, w * 0.68, h * 0.68, c[2]);

      case FlagPattern.circle:
        box(0, 0, w, h, c[0]);
        canvas.drawCircle(Offset(w / 2, h / 2), h * 0.24, Paint()..color = c[1]);

      case FlagPattern.diamond:
        box(0, 0, w, h, c[0]);
        poly([
          Offset(w / 2, 0),
          Offset(w, h / 2),
          Offset(w / 2, h),
          Offset(0, h / 2),
        ], c[1]);

      case FlagPattern.perBend:
        // Cut by the upper-hoist to lower-fly diagonal, c[0] above it.
        box(0, 0, w, h, c[0]);
        poly([Offset.zero, Offset(0, h), Offset(w, h)], c[1]);

      case FlagPattern.diagonalStripes:
        // Stripes run perpendicular to the upper-hoist to lower-fly diagonal.
        canvas
          ..save()
          ..clipRect(Rect.fromLTWH(0, 0, w, h))
          ..translate(w / 2, h / 2)
          ..rotate(math.pi / 4);
        final span = w + h;
        final stripe = span / 9;
        for (var i = -5; i < 5; i++) {
          box(i * stripe, -span, (i + 1) * stripe, span, i.isEven ? c[0] : c[1]);
        }
        canvas.restore();

      case FlagPattern.perSaltire:
        // [top, hoist, bottom, fly]
        final centre = Offset(w / 2, h / 2);
        poly([Offset.zero, Offset(w, 0), centre], c[0]);
        poly([Offset.zero, Offset(0, h), centre], c[1]);
        poly([Offset(0, h), Offset(w, h), centre], c[2]);
        poly([Offset(w, 0), Offset(w, h), centre], c[3]);

      case FlagPattern.swallowtail:
        canvas
          ..save()
          ..clipPath(Path()
            ..addPolygon([
              Offset.zero,
              Offset(w, 0),
              Offset(w * 0.72, h / 2),
              Offset(w, h),
              Offset(0, h),
            ], true));
        if (c.length == 1) {
          box(0, 0, w, h, c[0]);
        } else {
          bands(c, horizontal: false);
        }
        canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CodeFlagPainter oldDelegate) =>
      oldDelegate.flag != flag;
}
