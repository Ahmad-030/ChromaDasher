// ═══════════════════════════════════════════════════════════════════════════
//  3.  PAUSE OVERLAY  (wired to AudioService — with mute/unmute button)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/audio_service.dart';
import 'package:chromadasher/theme.dart';
import 'package:flutter/material.dart';

class PauseOverlay extends StatefulWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
  });

  @override
  State<PauseOverlay> createState() => _PauseOverlayState();
}

class _PauseOverlayState extends State<PauseOverlay>
    with SingleTickerProviderStateMixin {
  bool _musicOn = AudioService.instance.musicOn;

  late final AnimationController _entryCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 350))
    ..forward();

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleMusic() async {
    await AudioService.instance.toggle();
    setState(() => _musicOn = AudioService.instance.musicOn);
  }

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {}, // absorb taps so game doesn't jump
        child: Stack(
          children: [
            // ── Dark overlay ──
            Container(color: Colors.black.withOpacity(0.78)),

            // ── Subtle scanlines ──
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ScanlinePainter(),
            ),

            // ── Card ──
            Center(
              child: FadeTransition(
                opacity: _entryCtrl,
                child: SlideTransition(
                  position: Tween<Offset>(
                      begin: const Offset(0, 0.08), end: Offset.zero)
                      .animate(CurvedAnimation(
                      parent: _entryCtrl,
                      curve: Curves.easeOutCubic)),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 28),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 36),
                    decoration: CD.neonBox(CD.cyan, r: 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // ── Title ──
                        const Icon(Icons.pause_circle_outline_rounded,
                            color: CD.cyan, size: 52),
                        const SizedBox(height: 12),
                        Text('PAUSED',
                            style: CD.glow(30, CD.cyan, ls: 8)),
                        const SizedBox(height: 4),
                        Text('Game is on hold',
                            style: CD.body(
                                13, Colors.white.withOpacity(0.4))),

                        const SizedBox(height: 28),
                        NeonDivider(color: CD.cyan),
                        const SizedBox(height: 24),

                        // ── Resume ──
                        NeonButton(
                          label: 'RESUME',
                          icon: Icons.play_arrow_rounded,
                          color: CD.cyan,
                          onTap: widget.onResume,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 48, vertical: 16),
                        ),
                        const SizedBox(height: 14),

                        // ── Restart ──
                        NeonButton(
                          label: 'RESTART',
                          icon: Icons.replay_rounded,
                          color: CD.amber,
                          onTap: widget.onRestart,
                        ),
                        const SizedBox(height: 14),

                        // ── Mute / Unmute ──
                        _MusicToggleButton(
                          musicOn: _musicOn,
                          onToggle: _toggleMusic,
                        ),
                        const SizedBox(height: 14),

                        // ── Main Menu ──
                        NeonButton(
                          label: 'MAIN MENU',
                          icon: Icons.home_rounded,
                          color: CD.red,
                          onTap: widget.onMainMenu,
                        ),
                      ],
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

// ─── Animated mute/unmute button ─────────────────────────────────────────────
class _MusicToggleButton extends StatefulWidget {
  final bool musicOn;
  final VoidCallback onToggle;

  const _MusicToggleButton({
    required this.musicOn,
    required this.onToggle,
  });

  @override
  State<_MusicToggleButton> createState() => _MusicToggleButtonState();
}

class _MusicToggleButtonState extends State<_MusicToggleButton>
    with SingleTickerProviderStateMixin {
  bool _pressed = false;

  late final AnimationController _bounceCtrl = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 200));

  @override
  void didUpdateWidget(_MusicToggleButton old) {
    super.didUpdateWidget(old);
    if (old.musicOn != widget.musicOn) {
      _bounceCtrl.forward(from: 0).then((_) => _bounceCtrl.reverse());
    }
  }

  @override
  void dispose() {
    _bounceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.musicOn ? CD.green : Colors.white38;
    final icon =
    widget.musicOn ? Icons.volume_up_rounded : Icons.volume_off_rounded;
    final label = widget.musicOn ? 'MUSIC ON' : 'MUSIC OFF';

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onToggle();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
        padding:
        const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: color, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(_pressed ? 0.55 : 0.30),
              blurRadius: _pressed ? 28 : 16,
              spreadRadius: _pressed ? 3 : 1,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Icon(icon,
                  key: ValueKey(icon), color: color, size: 18),
            ),
            const SizedBox(width: 10),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: CD.label(15, color),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Scanlines ────────────────────────────────────────────────────────────────
class _ScanlinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.02)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 3) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}