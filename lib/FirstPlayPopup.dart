// ═══════════════════════════════════════════════════════════════════════════
//  FIRST-PLAY TUTORIAL POPUP
//  Shows once (stored in SharedPreferences). Explains the core mechanic.
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirstPlayPopup {
  static const _key = 'chroma_seen_tutorial';

  static Future<bool> shouldShow() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_key) ?? false);
  }

  static Future<void> markSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  static Future<void> showIfNeeded(BuildContext context) async {
    if (!await shouldShow()) return;
    await markSeen();
    if (!context.mounted) return;
    await showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.85),
      builder: (_) => const _TutorialDialog(),
    );
  }
}

class _TutorialDialog extends StatefulWidget {
  const _TutorialDialog();
  @override
  State<_TutorialDialog> createState() => _TutorialDialogState();
}

class _TutorialDialogState extends State<_TutorialDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
  AnimationController(
      vsync: this, duration: const Duration(milliseconds: 500))
    ..forward();

  int _page = 0;

  static const _steps = [
    _Step(
      icon: Icons.sync_rounded,
      color: CD.magenta,
      title: 'TAP SWAP!',
      body:
      'When the world switches, tap the big\nSWAP button at the bottom to change\nyour character\'s theme.',
    ),
    _Step(
      icon: Icons.warning_amber_rounded,
      color: CD.amber,
      title: 'DON\'T WAIT!',
      body:
      'If you stay mismatched for 3 seconds\nyou\'re eliminated. A red flash warns you.\nSwap fast!',
    ),
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_page < _steps.length - 1) {
      setState(() => _page++);
      _ctrl.forward(from: 0);
    } else {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final step = _steps[_page];
    final isLast = _page == _steps.length - 1;

    return Center(
      child: FadeTransition(
        opacity: _ctrl,
        child: SlideTransition(
          position: Tween<Offset>(
              begin: const Offset(0, 0.06), end: Offset.zero)
              .animate(CurvedAnimation(
              parent: _ctrl, curve: Curves.easeOutCubic)),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 24),
            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
            decoration: CD.neonBox(step.color, r: 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Step dots ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_steps.length, (i) {
                    final active = i == _page;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: active ? 22 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: active ? step.color : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                        boxShadow: active
                            ? [
                          BoxShadow(
                              color: step.color.withOpacity(0.6),
                              blurRadius: 8)
                        ]
                            : [],
                      ),
                    );
                  }),
                ),

                const SizedBox(height: 28),

                // ── Icon ──
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: step.color.withOpacity(0.12),
                    border: Border.all(
                        color: step.color.withOpacity(0.6), width: 2),
                    boxShadow: [
                      BoxShadow(
                          color: step.color.withOpacity(0.4),
                          blurRadius: 28),
                    ],
                  ),
                  child: Icon(step.icon, color: step.color, size: 38),
                ),

                const SizedBox(height: 20),

                Text(step.title, style: CD.glow(20, step.color, ls: 3)),

                const SizedBox(height: 14),

                Text(
                  step.body,
                  style: CD.body(14, Colors.white.withOpacity(0.75)),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                NeonButton(
                  label: isLast ? 'GOT IT — LET\'S GO!' : 'NEXT',
                  icon: isLast
                      ? Icons.play_arrow_rounded
                      : Icons.arrow_forward_rounded,
                  color: step.color,
                  fontSize: 14,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 36, vertical: 16),
                  onTap: _next,
                ),

                if (!isLast) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Text(
                      'SKIP',
                      style: CD.label(
                          11, Colors.white.withOpacity(0.3), ls: 2),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Step {
  final IconData icon;
  final Color color;
  final String title;
  final String body;
  const _Step({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });
}