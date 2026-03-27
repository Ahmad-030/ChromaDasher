
// ═══════════════════════════════════════════════════════════════════════════
//  6.  ABOUT SCREEN
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CD.bg,
      body: NeonBg(
        child: SafeArea(
          child: Column(
            children: [
              // ── App bar ──
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: CD.neonBox(CD.cyan, r: 12),
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: CD.cyan, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('ABOUT', style: CD.glow(22, CD.cyan, ls: 4)),
                  ],
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Logo ──
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(colors: [
                                  CD.violet.withOpacity(0.6),
                                  Colors.black,
                                ]),
                                border: Border.all(
                                    color: CD.cyan.withOpacity(0.6),
                                    width: 2),
                                boxShadow: [
                                  BoxShadow(
                                      color: CD.cyan.withOpacity(0.3),
                                      blurRadius: 30),
                                ],
                              ),
                              child: const Icon(Icons.speed_rounded,
                                  color: CD.cyan, size: 44),
                            ),
                            const SizedBox(height: 14),
                            Text('CHROMADASHER',
                                style: CD.glow(24, CD.cyan, ls: 5)),
                            const SizedBox(height: 4),
                            Text('Version 1.0.0',
                                style: CD.body(
                                    12, Colors.white.withOpacity(0.4))),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),
                      NeonDivider(color: CD.violet),
                      const SizedBox(height: 24),

                      // ── About text ──
                      Text('WHAT IS CHROMADASHER?',
                          style:
                          CD.label(13, CD.magenta, ls: 2)),
                      const SizedBox(height: 12),
                      Text(
                        'ChromaDasher is a lightning-fast endless runner '
                            'where the world itself constantly shifts beneath your feet. '
                            'Every 10 seconds the environment transforms into a '
                            'completely different theme — and so must you.',
                        style:
                        CD.body(13, Colors.white.withOpacity(0.75)),
                      ),

                      const SizedBox(height: 24),

                      Text('FEATURES', style: CD.label(13, CD.amber, ls: 2)),
                      const SizedBox(height: 12),

                      ...[
                        (Icons.swap_horiz_rounded, CD.cyan,
                        'Dynamic Theme Swapping',
                        'Match your character to the world or face elimination.'),
                        (Icons.speed_rounded, CD.magenta,
                        'Ever-Increasing Speed',
                        'The longer you survive, the faster the world races.'),
                        (Icons.auto_awesome_rounded, CD.violet,
                        'Neon Glow Visuals',
                        'Immersive particle effects and smooth theme transitions.'),
                        (Icons.devices_rounded, CD.amber,
                        'Responsive Design',
                        'Crafted to look stunning on all Android screen sizes.'),
                        (Icons.leaderboard_rounded, CD.green,
                        'Endless & Timer Modes',
                        'Two distinct play styles to master.'),
                      ].map((item) => _FeatureRow(
                        icon: item.$1,
                        color: item.$2,
                        title: item.$3,
                        subtitle: item.$4,
                      )),

                      const SizedBox(height: 24),
                      NeonDivider(color: CD.violet),
                      const SizedBox(height: 20),

                      // ── How to play ──
                      Text('HOW TO PLAY',
                          style: CD.label(13, CD.cyan, ls: 2)),
                      const SizedBox(height: 14),

                      ...[
                        (1, 'Tap the screen to jump over obstacles.'),
                        (2, 'Watch the NEXT timer in the top bar.'),
                        (3,
                        'When the world theme changes, tap SWAP at the bottom to match your character.'),
                        (4, 'Stay mismatched for 3 seconds and it\'s game over.'),
                        (5, 'Survive longer for a higher score!'),
                      ].map((step) => _StepRow(
                          number: step.$1, text: step.$2 as String)),

                      const SizedBox(height: 28),
                      NeonDivider(color: CD.violet),
                      const SizedBox(height: 20),

                      // ── Developer ──
                      Text('DEVELOPER', style: CD.label(13, CD.violet, ls: 2)),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: CD.neonBox(CD.violet, r: 16),
                        child: Row(
                          children: [
                            Container(
                              width: 54,
                              height: 54,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: CD.violet.withOpacity(0.2),
                                border: Border.all(
                                    color: CD.violet.withOpacity(0.6),
                                    width: 1.5),
                              ),
                              child: const Icon(Icons.person_rounded,
                                  color: CD.violet, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('developername',
                                    style: CD.label(15, Colors.white, ls: 1)),
                                const SizedBox(height: 4),
                                Text('developername.dev@gmail.com',
                                    style: CD.body(
                                        10,
                                        CD.violet.withOpacity(0.8))),
                                const SizedBox(height: 2),
                                Text('Android Developer',
                                    style: CD.body(
                                        11,
                                        Colors.white.withOpacity(0.4))),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 32),

                      Center(
                        child: Text(
                          '© 2024 developername. All rights reserved.',
                          style: CD.body(
                              11, Colors.white.withOpacity(0.25)),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;

  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.12),
              border: Border.all(color: color.withOpacity(0.4)),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: CD.label(13, Colors.white, ls: 0.5)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: CD.body(12, Colors.white.withOpacity(0.5))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  final int number;
  final String text;

  const _StepRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: CD.cyan.withOpacity(0.15),
              border:
              Border.all(color: CD.cyan.withOpacity(0.5), width: 1.2),
            ),
            child: Center(
              child: Text('$number',
                  style: CD.label(11, CD.cyan, ls: 0)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(text,
                  style: CD.body(13, Colors.white.withOpacity(0.7))),
            ),
          ),
        ],
      ),
    );
  }
}
