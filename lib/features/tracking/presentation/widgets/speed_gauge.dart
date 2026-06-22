import 'dart:math';
import 'package:flutter/material.dart';

class SpeedGauge extends StatelessWidget {
  final double speedKnots;
  final double maxSpeed;

  const SpeedGauge({
    super.key,
    required this.speedKnots,
    this.maxSpeed = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CustomPaint(
                painter: _GaugePainter(
                  value: speedKnots.clamp(0, maxSpeed) / maxSpeed,
                  color: _speedColor(speedKnots),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        speedKnots.toStringAsFixed(1),
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'uzlov',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _speedColor(double knots) {
    if (knots < 5) return Colors.blue;
    if (knots < 10) return Colors.green;
    if (knots < 15) return Colors.orange;
    return Colors.red;
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;

  _GaugePainter({required this.value, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    // Background arc
    final bgPaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 16
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      pi * 0.75,
      pi * 1.5,
      false,
      bgPaint,
    );

    // Value arc
    if (value > 0) {
      final valuePaint = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 16
        ..strokeCap = StrokeCap.round;

      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        pi * 0.75,
        pi * 1.5 * value,
        false,
        valuePaint,
      );
    }
  }

  @override
  bool shouldRepaint(_GaugePainter old) =>
      old.value != value || old.color != color;
}
