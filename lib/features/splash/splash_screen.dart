import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hmb_sailing_log/l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale, _tagline;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200));
    _fade = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.5, curve: Curves.easeIn));
    _scale = Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.6, curve: Curves.elasticOut)));
    _tagline = CurvedAnimation(parent: _ctrl, curve: const Interval(0.5, 0.9, curve: Curves.easeIn));

    _ctrl.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 400));
      if (mounted) context.go('/map');
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [Color(0xFF0A2342), Color(0xFF1A5276), Color(0xFF2874A6)],
          ),
        ),
        child: Stack(children: [
          Positioned(bottom: 0, left: 0, right: 0, child: _Waves()),
          Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            ScaleTransition(scale: _scale, child: FadeTransition(opacity: _fade,
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                  border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30)],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset('assets/icons/app_icon.png', fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(Icons.sailing, color: Colors.white, size: 80)),
              ),
            )),
            const SizedBox(height: 32),
            FadeTransition(opacity: _fade, child: const Text('HMB Sailing Log',
                style: TextStyle(color: Colors.white, fontSize: 32,
                    fontWeight: FontWeight.bold, letterSpacing: 1.5))),
            const SizedBox(height: 8),
            FadeTransition(opacity: _tagline, child: Text(AppLocalizations.of(context).appTagline,
                style: const TextStyle(color: Colors.white70, fontSize: 15))),
            const SizedBox(height: 60),
            FadeTransition(opacity: _tagline, child: SizedBox(width: 40, height: 40,
              child: CircularProgressIndicator(strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation(Colors.white.withOpacity(0.6))))),
          ])),
        ]),
      ),
    );
  }
}

class _Waves extends StatelessWidget {
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 200,
    child: CustomPaint(painter: _WavePainter(),
        size: Size(MediaQuery.of(context).size.width, 200)),
  );
}

class _WavePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p1 = Paint()..color = Colors.white.withOpacity(0.05)..style = PaintingStyle.fill;
    final p2 = Paint()..color = Colors.white.withOpacity(0.08)..style = PaintingStyle.fill;
    final path1 = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.4, size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.8, size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path1, p1);
    final path2 = Path()
      ..moveTo(0, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.55, size.width * 0.6, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.85, size.height * 0.9, size.width, size.height * 0.75)
      ..lineTo(size.width, size.height)..lineTo(0, size.height)..close();
    canvas.drawPath(path2, p2);
  }
  @override
  bool shouldRepaint(_WavePainter old) => false;
}
