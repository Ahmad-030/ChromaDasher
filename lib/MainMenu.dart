// ═══════════════════════════════════════════════════════════════════════════
//  2.  MAIN MENU SCREEN  (with music toggle)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/audio_service.dart';
import 'package:chromadasher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({super.key});

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900))
    ..forward();

  late final AnimationController _titlePulse = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1400))
    ..repeat(reverse: true);

  // Mirror the current music state so the icon rebuilds on toggle.
  bool _musicOn = AudioService.instance.musicOn;

  @override
  void dispose() {
    _entryCtrl.dispose();
    _titlePulse.dispose();
    super.dispose();
  }

  Future<void> _toggleMusic() async {
    await AudioService.instance.toggle();
    setState(() => _musicOn = AudioService.instance.musicOn);
    HapticFeedback.selectionClick();
  }

  Widget _stagger(Widget child, int index) {
    final start = index * 0.10;
    final end = (start + 0.55).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(start, end, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(
            begin: const Offset(0, 0.25), end: Offset.zero)
            .animate(CurvedAnimation(
            parent: _entryCtrl,
            curve: Interval(start, end, curve: Curves.easeOutCubic))),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CD.bg,
      body: NeonBg(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 28),
            child: Column(
              children: [
                // ── Top-right music toggle ──
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: _toggleMusic,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.all(10),
                          decoration: CD.neonBox(
                            _musicOn ? CD.cyan : Colors.white38,
                            r: 14,
                          ),
                          child: Icon(
                            _musicOn
                                ? Icons.music_note_rounded
                                : Icons.music_off_rounded,
                            color: _musicOn ? CD.cyan : Colors.white38,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Logo ──
                _stagger(
                  AnimatedBuilder(
                    animation: _titlePulse,
                    builder: (_, __) => Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: CD.cyan.withOpacity(
                                      0.3 + 0.15 * _titlePulse.value),
                                  blurRadius: 50),
                            ],
                          ),
                          child: const Icon(Icons.speed_rounded,
                              color: CD.cyan, size: 48),
                        ),
                        const SizedBox(height: 6),
                        Text('CHROMA', style: CD.glow(34, CD.cyan, ls: 8)),
                        Text('DASHER', style: CD.glow(34, CD.magenta, ls: 8)),
                        const SizedBox(height: 4),
                        Text('ENDLESS THEME RUNNER',
                            style: CD.label(10,
                                Colors.white.withOpacity(0.45),
                                ls: 3)),
                      ],
                    ),
                  ),
                  0,
                ),

                const SizedBox(height: 44),

                // ── Mode Buttons ──
                _stagger(
                  _ModeCard(
                    icon: Icons.all_inclusive,
                    title: 'ENDLESS MODE',
                    subtitle: 'Survive as long as possible',
                    color: CD.cyan,
                    onTap: () => Navigator.pushNamed(context, '/game',
                        arguments: 'endless'),
                  ),
                  1,
                ),

                const SizedBox(height: 14),

                _stagger(
                  _ModeCard(
                    icon: Icons.timer_outlined,
                    title: 'TIMER MODE',
                    subtitle: '60 seconds — beat your best',
                    color: CD.amber,
                    onTap: () => Navigator.pushNamed(context, '/game',
                        arguments: 'timer'),
                  ),
                  2,
                ),

                const SizedBox(height: 14),

                _stagger(
                  _ModeCard(
                    icon: Icons.leaderboard_rounded,
                    title: 'LEADERBOARD',
                    subtitle: 'View your top scores',
                    color: CD.violet,
                    onTap: () => Navigator.pushNamed(context, '/highscore'),
                  ),
                  3,
                ),

                const SizedBox(height: 28),

                _stagger(
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: NeonDivider(color: CD.cyan.withOpacity(0.4)),
                  ),
                  4,
                ),

                const SizedBox(height: 20),

                _stagger(
                  _ModeCard(
                    icon: Icons.info_outline_rounded,
                    title: 'ABOUT',
                    subtitle: 'Game info, features & how to play',
                    color: CD.violet,
                    onTap: () => Navigator.pushNamed(context, '/about'),
                  ),
                  5,
                ),

                const SizedBox(height: 14),

                _stagger(
                  _ModeCard(
                    icon: Icons.shield_outlined,
                    title: 'PRIVACY POLICY',
                    subtitle: 'How we handle your data',
                    color: Colors.white54,
                    onTap: () => Navigator.pushNamed(context, '/privacy'),
                  ),
                  6,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _ModeCard extends StatefulWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ModeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  State<_ModeCard> createState() => _ModeCardState();
}

class _ModeCardState extends State<_ModeCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        transform: Matrix4.identity()..scale(_pressed ? 0.97 : 1.0),
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
        decoration: CD.neonBox(widget.color),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.color.withOpacity(0.15),
                border:
                Border.all(color: widget.color.withOpacity(0.5)),
              ),
              child: Icon(widget.icon, color: widget.color, size: 24),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.title,
                      style: CD.label(15, widget.color, ls: 1.5)),
                  const SizedBox(height: 3),
                  Text(widget.subtitle,
                      style:
                      CD.body(12, Colors.white.withOpacity(0.5))),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: widget.color.withOpacity(0.6), size: 16),
          ],
        ),
      ),
    );
  }
}