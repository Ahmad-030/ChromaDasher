
// ═══════════════════════════════════════════════════════════════════════════
//  4.  GAME OVER SCREEN
// ═══════════════════════════════════════════════════════════════════════════
import 'dart:math' show Random, sin;
import 'dart:ui' show Color, Rect, Offset, Canvas, Size, Paint;

import 'package:chromadasher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GameOverScreen extends StatefulWidget {
  final int score;
  final double timeSurvived;
  final String mode; // 'endless' or 'timer'

  const GameOverScreen({
    super.key,
    required this.score,
    required this.timeSurvived,
    this.mode = 'endless',
  });

  @override
  State<GameOverScreen> createState() => _GameOverScreenState();
}

class _GameOverScreenState extends State<GameOverScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800))
    ..forward();

  late final AnimationController _glitchCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 80))
    ..repeat(reverse: true);

  late final AnimationController _confettiCtrl = AnimationController(
      vsync: this, duration: const Duration(seconds: 3))
    ..forward();

  static const int _highScore = 0; // Replace with SharedPreferences read
  late final bool _isNewBest = widget.score > _highScore;

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glitchCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CD.bg,
      body: NeonBg(
        child: Stack(
          children: [
            // Confetti
            if (_isNewBest)
              AnimatedBuilder(
                animation: _confettiCtrl,
                builder: (_, __) => CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: _ConfettiPainter(_confettiCtrl.value),
                ),
              ),

            SafeArea(
              child: Center(
                child: FadeTransition(
                  opacity: _entryCtrl,
                  child: SlideTransition(
                    position: Tween<Offset>(
                        begin: const Offset(0, 0.1), end: Offset.zero)
                        .animate(CurvedAnimation(
                        parent: _entryCtrl,
                        curve: Curves.easeOutCubic)),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        children: [
                          const SizedBox(height: 20),

                          // ── Game Over title ──
                          AnimatedBuilder(
                            animation: _glitchCtrl,
                            builder: (_, __) => Stack(
                              children: [
                                // Glitch layer
                                Transform.translate(
                                  offset: Offset(
                                      _glitchCtrl.value * 3 - 1.5, 0),
                                  child: Text('GAME OVER',
                                      style: CD.glow(36, CD.red, ls: 6)
                                          .copyWith(
                                          color: CD.cyan
                                              .withOpacity(0.3))),
                                ),
                                Text('GAME OVER',
                                    style: CD.glow(36, CD.red, ls: 6)),
                              ],
                            ),
                          ),

                          const SizedBox(height: 6),

                          if (_isNewBest)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 6),
                              decoration: CD.neonBox(CD.amber, r: 8),
                              child: Text('✦  NEW BEST  ✦',
                                  style: CD.label(12, CD.amber, ls: 3)),
                            ),

                          const SizedBox(height: 28),

                          // ── Score card ──
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 28),
                            decoration: CD.neonBox(CD.cyan, r: 20),
                            child: Column(
                              children: [
                                Text('SCORE',
                                    style: CD.label(
                                        11,
                                        CD.cyan.withOpacity(0.6),
                                        ls: 4)),
                                const SizedBox(height: 6),
                                Text(
                                  widget.score.toString().padLeft(6, '0'),
                                  style: CD.glow(56, CD.cyan, ls: 4),
                                ),
                                const SizedBox(height: 20),
                                NeonDivider(color: CD.cyan),
                                const SizedBox(height: 16),
                                Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _StatChip(
                                      label: 'TIME',
                                      value:
                                      '${widget.timeSurvived.toStringAsFixed(1)}s',
                                      color: CD.violet,
                                    ),
                                    _StatChip(
                                      label: 'MODE',
                                      value: widget.mode.toUpperCase(),
                                      color: CD.amber,
                                    ),
                                    _StatChip(
                                      label: 'BEST',
                                      value: _isNewBest
                                          ? widget.score
                                          .toString()
                                          .padLeft(6, '0')
                                          : _highScore
                                          .toString()
                                          .padLeft(6, '0'),
                                      color: CD.green,
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 32),

                          // ── Actions ──
                          NeonButton(
                            label: 'PLAY AGAIN',
                            icon: Icons.replay_rounded,
                            color: CD.cyan,
                            fontSize: 16,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 48, vertical: 18),
                            onTap: () => Navigator.pushReplacementNamed(
                                context, '/game',
                                arguments: widget.mode),
                          ),
                          const SizedBox(height: 16),
                          NeonButton(
                            label: 'LEADERBOARD',
                            icon: Icons.leaderboard_rounded,
                            color: CD.violet,
                            onTap: () =>
                                Navigator.pushNamed(context, '/highscore'),
                          ),
                          const SizedBox(height: 16),
                          NeonButton(
                            label: 'MAIN MENU',
                            icon: Icons.home_rounded,
                            color: Colors.white38,
                            onTap: () => Navigator.pushNamedAndRemoveUntil(
                                context, '/menu', (_) => false),
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatChip(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: CD.label(9, color.withOpacity(0.6), ls: 2)),
        const SizedBox(height: 4),
        Text(value, style: CD.label(13, color, ls: 1)),
      ],
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  static final Random _r = Random(77);
  static final List<_ConfettiParticle> _pts = List.generate(
    80,
        (i) => _ConfettiParticle(_r),
  );

  _ConfettiPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    for (final p in _pts) {
      final y = (p.startY + t * p.speed * size.height) % size.height;
      final x = p.x * size.width + sin(t * 6 + p.phase) * 20;
      paint.color = p.color.withOpacity((1 - t * 0.6).clamp(0, 1));
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.rotation);
      canvas.drawRect(
          Rect.fromCenter(
              center: Offset.zero, width: p.size, height: p.size * 0.5),
          paint);
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_ConfettiPainter old) => old.t != t;
}

class _ConfettiParticle {
  final double x, startY, speed, size, phase, rotation;
  final Color color;

  static const List<Color> _colors = [
    CD.cyan, CD.magenta, CD.amber, CD.violet, CD.green
  ];

  _ConfettiParticle(Random r)
      : x = r.nextDouble(),
        startY = -r.nextDouble() * 0.5,
        speed = 0.15 + r.nextDouble() * 0.25,
        size = 5 + r.nextDouble() * 7,
        phase = r.nextDouble() * 6.28,
        rotation = (r.nextDouble() - 0.5) * 10,
        color = _colors[r.nextInt(_colors.length)];
}
