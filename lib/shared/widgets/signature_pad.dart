import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

class SignaturePad extends StatefulWidget {
  final List<List<Offset>> strokes;
  final void Function(List<Offset>) onStrokeAdded;
  final VoidCallback? onDrawStart;
  final VoidCallback? onDrawEnd;
  final Color inkColor;
  final Color backgroundColor;

  const SignaturePad({
    super.key,
    required this.strokes,
    required this.onStrokeAdded,
    this.onDrawStart,
    this.onDrawEnd,
    this.inkColor = Colors.black,
    this.backgroundColor = Colors.white,
  });

  @override
  State<SignaturePad> createState() => SignaturePadState();
}

class SignaturePadState extends State<SignaturePad> {
  List<Offset> _current = [];
  bool _isDrawing = false;
  Size? _size;

  // Re-renders strokes from path data — avoids RepaintBoundary.toImage()
  // which throws !debugNeedsPaint on Impeller after any setState().
  Future<Uint8List?> toBytes({double pixelRatio = 2.0}) async {
    final size = _size;
    if (size == null || size.isEmpty) return null;

    final w = (size.width * pixelRatio).round();
    final h = (size.height * pixelRatio).round();

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
      Paint()..color = widget.backgroundColor,
    );
    canvas.scale(pixelRatio, pixelRatio);

    final ink = Paint()
      ..color = widget.inkColor
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    for (final stroke in widget.strokes) {
      if (stroke.length < 2) continue;
      final path = Path()..moveTo(stroke[0].dx, stroke[0].dy);
      for (int i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, ink);
    }

    final picture = recorder.endRecording();
    final image = await picture.toImage(w, h);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  void _onDown(Offset pos) {
    widget.onDrawStart?.call();
    setState(() { _isDrawing = true; _current = [pos]; });
  }

  void _onMove(Offset pos) {
    if (!_isDrawing) return;
    setState(() => _current = [..._current, pos]);
  }

  void _onUp() {
    if (_current.length > 1) widget.onStrokeAdded(List.of(_current));
    widget.onDrawEnd?.call();
    setState(() { _isDrawing = false; _current = []; });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _size = constraints.biggest;
        return Container(
          color: widget.backgroundColor,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (e) => _onDown(e.localPosition),
            onPointerMove: (e) => _onMove(e.localPosition),
            onPointerUp: (_) => _onUp(),
            onPointerCancel: (_) => _onUp(),
            child: CustomPaint(
              painter: _Painter(widget.strokes, _current, widget.inkColor),
              child: const SizedBox(width: double.infinity, height: double.infinity),
            ),
          ),
        );
      },
    );
  }
}

class _Painter extends CustomPainter {
  final List<List<Offset>> strokes;
  final List<Offset> current;
  final Color color;
  _Painter(this.strokes, this.current, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;
    for (final s in strokes) _draw(canvas, s, p);
    if (current.length > 1) _draw(canvas, current, p);
  }

  void _draw(Canvas canvas, List<Offset> pts, Paint p) {
    final path = Path()..moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < pts.length; i++) path.lineTo(pts[i].dx, pts[i].dy);
    canvas.drawPath(path, p);
  }

  @override
  bool shouldRepaint(_Painter old) => true;
}
