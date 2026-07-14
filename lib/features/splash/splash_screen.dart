import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/providers/locale_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});
  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale, _tagline;

  // Nepretržité vlnenie loga ako vlajka vo vetre — beží celý čas, kým je
  // splash zobrazený, nezávisle od nástupnej fade/scale animácie.
  late final AnimationController _waveCtrl;

  static const _langs = [
    ('🇸🇰', 'Slovenčina', 'sk'),
    ('🇬🇧', 'English', 'en'),
    ('🇩🇪', 'Deutsch', 'de'),
    ('🇪🇸', 'Español', 'es'),
    ('🇺🇦', 'Українська', 'uk'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2200));
    _fade = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _tagline = CurvedAnimation(
        parent: _ctrl,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn));

    _waveCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 2400))
      ..repeat();

    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final isFirstLaunch = prefs.getBool('first_launch') ?? false;
      if (!mounted) return;
      if (isFirstLaunch) {
        await _showLanguagePicker();
      }
      if (mounted) context.go('/map');
    });
  }

  Future<void> _showLanguagePicker() async {
    final current = ref.read(localeProvider).languageCode;
    String selected = current;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🌐',
                    style: TextStyle(fontSize: 36)),
                const SizedBox(height: 8),
                const Text(
                  'Select Language / Vyberte jazyk',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ..._langs.map((l) => ListTile(
                      leading: Text(l.$1,
                          style: const TextStyle(fontSize: 22)),
                      title: Text(l.$2),
                      trailing: selected == l.$3
                          ? const Icon(Icons.check_circle,
                              color: Colors.blue)
                          : null,
                      dense: true,
                      onTap: () => setDialogState(() => selected = l.$3),
                    )),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Continue'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Save choice and clear first-launch flag
    await ref.read(localeProvider.notifier).setLocale(selected);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('first_launch');
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2342), Color(0xFF1A5276), Color(0xFF2874A6)],
          ),
        ),
        child: Stack(children: [
          Positioned(
              bottom: 0, left: 0, right: 0, child: _Waves()),
          Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: _FlagWaveImage(
                    assetPath: 'assets/icons/hmb_logo_splash.png',
                    width: 260,
                    wave: _waveCtrl,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fade,
                child: const Text('SAILLOG',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5)),
              ),
              const SizedBox(height: 60),
              FadeTransition(
                opacity: _tagline,
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(
                        Colors.white.withOpacity(0.6)),
                  ),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

/// Logo vlnené ako vlajka vo vetre: obrázok sa rozreže na zvislé pásiky a
/// každý sa zvisle posunie podľa sínusovky, s amplitúdou rastúcou od ľavého
/// (pevného) k pravému (voľnému) okraju — presné mesh-warpovanie by
/// vyžadovalo fragment shader, tento efekt lacno vyzerá takmer rovnako.
class _FlagWaveImage extends StatefulWidget {
  final String assetPath;
  final double width;
  final Animation<double> wave;
  const _FlagWaveImage(
      {required this.assetPath, required this.width, required this.wave});

  @override
  State<_FlagWaveImage> createState() => _FlagWaveImageState();
}

class _FlagWaveImageState extends State<_FlagWaveImage> {
  ui.Image? _image;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final data = await rootBundle.load(widget.assetPath);
    final codec =
        await ui.instantiateImageCodec(data.buffer.asUint8List());
    final frame = await codec.getNextFrame();
    if (mounted) setState(() => _image = frame.image);
  }

  @override
  Widget build(BuildContext context) {
    final image = _image;
    if (image == null) {
      // Placeholder rovnakej šírky, kým sa obrázok dekóduje — zabráni
      // poskoku layoutu pri objavení loga.
      return SizedBox(width: widget.width, height: widget.width * 0.5);
    }
    final height = widget.width * image.height / image.width;
    return SizedBox(
      width: widget.width,
      height: height,
      child: AnimatedBuilder(
        animation: widget.wave,
        builder: (_, __) => CustomPaint(
          painter: _FlagWavePainter(image: image, time: widget.wave.value),
        ),
      ),
    );
  }
}

class _FlagWavePainter extends CustomPainter {
  final ui.Image image;
  final double time;
  static const _strips = 28;
  static const _amplitude = 6.0;
  static const _wavelength = 1.3;

  _FlagWavePainter({required this.image, required this.time});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.low;
    final srcStripW = image.width / _strips;
    final dstStripW = size.width / _strips;
    for (var i = 0; i < _strips; i++) {
      final t = i / (_strips - 1);
      final srcRect = Rect.fromLTWH(
          i * srcStripW, 0, srcStripW + 1, image.height.toDouble());
      // Amplitúda rastie smerom k pravému okraju (voľný koniec vlajky),
      // ľavý okraj (pri "stožiari") sa takmer nehýbe.
      final dy = _amplitude * t * math.sin(2 * math.pi * (t * _wavelength - time));
      final dstRect = Rect.fromLTWH(
          i * dstStripW, dy, dstStripW + 1, size.height);
      canvas.drawImageRect(image, srcRect, dstRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _FlagWavePainter old) => old.time != time;
}

class _Waves extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
        height: 200,
        child: CustomPaint(
            painter: _WavePainter(),
            size: Size(MediaQuery.of(context).size.width, 200)),
      );
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    final p2 = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.4,
          size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width,
          size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path1, p1);
    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.55,
          size.width * 0.6, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.9, size.width,
          size.height * 0.75)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(path2, p2);
  }

  @override
  bool shouldRepaint(_WavePainter old) => false;
}
