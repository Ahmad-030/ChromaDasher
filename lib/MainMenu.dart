// ═══════════════════════════════════════════════════════════════════════════
//  2.  MAIN MENU SCREEN
// ═══════════════════════════════════════════════════════════════════════════
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

  bool _soundOn = true;
  bool _musicOn = true;

  @override
  void dispose() {
    _entryCtrl.dispose();
    _titlePulse.dispose();
    super.dispose();
  }

  Widget _stagger(Widget child, int index) {
    final start = index * 0.12;
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
          child: Column(
            children: [
              const SizedBox(height: 36),

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

              const Spacer(),

              // ── Bottom bar ──
              _stagger(
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _IconToggle(
                        icon: _soundOn
                            ? Icons.volume_up_rounded
                            : Icons.volume_off_rounded,
                        label: 'SFX',
                        active: _soundOn,
                        color: CD.cyan,
                        onTap: () => setState(() => _soundOn = !_soundOn),
                      ),
                      _IconToggle(
                        icon: _musicOn
                            ? Icons.music_note_rounded
                            : Icons.music_off_rounded,
                        label: 'MUSIC',
                        active: _musicOn,
                        color: CD.magenta,
                        onTap: () => setState(() => _musicOn = !_musicOn),
                      ),
                      _IconToggle(
                        icon: Icons.info_outline_rounded,
                        label: 'ABOUT',
                        active: true,
                        color: CD.violet,
                        onTap: () => Navigator.pushNamed(context, '/about'),
                      ),
                      _IconToggle(
                        icon: Icons.shield_outlined,
                        label: 'PRIVACY',
                        active: true,
                        color: Colors.white54,
                        onTap: () =>
                            Navigator.pushNamed(context, '/privacy'),
                      ),
                    ],
                  ),
                ),
                5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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
                border: Border.all(color: widget.color.withOpacity(0.5)),
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
                      style: CD.body(12, Colors.white.withOpacity(0.5))),
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

class _IconToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color color;
  final VoidCallback onTap;

  const _IconToggle({
    required this.icon,
    required this.label,
    required this.active,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = active ? color : Colors.white24;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: active ? c.withOpacity(0.12) : Colors.transparent,
              border: Border.all(color: c.withOpacity(0.5)),
              boxShadow: active
                  ? [BoxShadow(color: c.withOpacity(0.3), blurRadius: 16)]
                  : [],
            ),
            child: Icon(icon, color: c, size: 22),
          ),
          const SizedBox(height: 5),
          Text(label, style: CD.label(9, c, ls: 1)),
        ],
      ),
    );
  }
}
