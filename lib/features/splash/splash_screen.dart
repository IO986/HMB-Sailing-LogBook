import 'package:flutter/material.dart';
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
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade, _scale, _tagline;

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
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withOpacity(0.1),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 30)
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => const Icon(
                          Icons.sailing,
                          color: Colors.white,
                          size: 80),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              FadeTransition(
                opacity: _fade,
                child: const Text('HMB Sailing Log',
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
