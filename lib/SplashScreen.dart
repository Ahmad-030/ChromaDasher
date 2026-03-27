

// ═══════════════════════════════════════════════════════════════════════════
//  1.  SPLASH SCREEN
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1200))
    ..forward();

  late final AnimationController _pulseCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);

  late final AnimationController _scanCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2000))
    ..forward();

  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Auto-navigate after 3 seconds
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/menu');
      }
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _pulseCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CD.bg,
      body: NeonBg(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Logo icon ──
              AnimatedBuilder(
                animation: _pulseCtrl,
                builder: (_, __) => Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: CD.cyan.withOpacity(0.8 + 0.2 * _pulseCtrl.value),
                        width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: CD.cyan
                              .withOpacity(0.35 + 0.2 * _pulseCtrl.value),
                          blurRadius: 40 + 20 * _pulseCtrl.value),
                      BoxShadow(
                          color: CD.magenta.withOpacity(0.2),
                          blurRadius: 60),
                    ],
                    gradient: RadialGradient(colors: [
                      CD.violet.withOpacity(0.6),
                      Colors.black,
                    ]),
                  ),
                  child: const Icon(Icons.speed_rounded,
                      color: CD.cyan, size: 54),
                ),
              ),

              const SizedBox(height: 36),

              // ── Title ──
              FadeTransition(
                opacity: _logoCtrl,
                child: SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(0, 0.3), end: Offset.zero)
                      .animate(CurvedAnimation(
                      parent: _logoCtrl, curve: Curves.easeOutCubic)),
                  child: Column(
                    children: [
                      Text('CHROMA', style: CD.glow(42, CD.cyan, ls: 10)),
                      Text('DASHER', style: CD.glow(42, CD.magenta, ls: 10)),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // ── Scan-line loader ──
              AnimatedBuilder(
                animation: _scanCtrl,
                builder: (_, __) {
                  return SizedBox(
                    width: 200,
                    child: Stack(
                      children: [
                        Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: Colors.white10,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                        FractionallySizedBox(
                          widthFactor: _scanCtrl.value,
                          child: Container(
                            height: 3,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                  colors: [CD.cyan, CD.magenta]),
                              boxShadow: [
                                BoxShadow(
                                    color: CD.cyan.withOpacity(0.6),
                                    blurRadius: 8)
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 20),

              Text('LOADING…',
                  style: CD.label(11, CD.cyan.withOpacity(0.6), ls: 4)),

              const SizedBox(height: 80),

              ],
          ),
        ),
      ),
    );
  }
}