
// ═══════════════════════════════════════════════════════════════════════════
//  3.  PAUSE OVERLAY  (place inside your GameScreen's Stack)
// ═══════════════════════════════════════════════════════════════════════════
import 'package:chromadasher/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PauseOverlay extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onMainMenu;
  final bool soundOn;
  final ValueChanged<bool> onSoundToggle;

  const PauseOverlay({
    super.key,
    required this.onResume,
    required this.onRestart,
    required this.onMainMenu,
    required this.soundOn,
    required this.onSoundToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () {}, // absorb taps
        child: Stack(
          children: [
            // Blur-style overlay
            Container(
              color: Colors.black.withOpacity(0.78),
            ),

            // Scanlines
            CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _ScanlinePainter(),
            ),

            Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 28),
                padding: const EdgeInsets.symmetric(
                    horizontal: 32, vertical: 36),
                decoration: CD.neonBox(CD.cyan, r: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Title
                    const Icon(Icons.pause_circle_outline_rounded,
                        color: CD.cyan, size: 52),
                    const SizedBox(height: 12),
                    Text('PAUSED', style: CD.glow(30, CD.cyan, ls: 8)),
                    const SizedBox(height: 4),
                    Text('Game is on hold',
                        style:
                        CD.body(13, Colors.white.withOpacity(0.4))),
                    const SizedBox(height: 32),

                    NeonDivider(color: CD.cyan),
                    const SizedBox(height: 24),

                    // Resume
                    NeonButton(
                      label: 'RESUME',
                      icon: Icons.play_arrow_rounded,
                      color: CD.cyan,
                      onTap: onResume,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 48, vertical: 16),
                    ),
                    const SizedBox(height: 14),

                    // Restart
                    NeonButton(
                      label: 'RESTART',
                      icon: Icons.replay_rounded,
                      color: CD.amber,
                      onTap: onRestart,
                    ),
                    const SizedBox(height: 14),

                    // Sound toggle
                    NeonButton(
                      label: soundOn ? 'SOUND ON' : 'SOUND OFF',
                      icon: soundOn
                          ? Icons.volume_up_rounded
                          : Icons.volume_off_rounded,
                      color: soundOn ? CD.green : Colors.white38,
                      onTap: () => onSoundToggle(!soundOn),
                    ),
                    const SizedBox(height: 14),

                    // Main Menu
                    NeonButton(
                      label: 'MAIN MENU',
                      icon: Icons.home_rounded,
                      color: CD.red,
                      onTap: onMainMenu,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
