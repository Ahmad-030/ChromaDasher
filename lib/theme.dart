

import 'dart:math' show Random, sin, pi;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CD {
  CD._();

  static const Color bg       = Color(0xFF050510);
  static const Color bgMid    = Color(0xFF0D0D2B);
  static const Color cyan     = Color(0xFF00FFFF);
  static const Color magenta  = Color(0xFFFF00FF);
  static const Color violet   = Color(0xFF7B2FFF);
  static const Color amber    = Color(0xFFFFB800);
  static const Color red      = Color(0xFFFF2D55);
  static const Color green    = Color(0xFF39FF14);

  static TextStyle glow(double sz, Color c, {double ls = 3}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: sz,
    fontWeight: FontWeight.w900,
    color: c,
    letterSpacing: ls,
    shadows: [
      Shadow(color: c.withOpacity(0.9), blurRadius: 12),
      Shadow(color: c.withOpacity(0.5), blurRadius: 36),
    ],
  );

  static TextStyle label(double sz, Color c, {double ls = 2}) => TextStyle(
    fontFamily: 'monospace',
    fontSize: sz,
    fontWeight: FontWeight.w700,
    color: c,
    letterSpacing: ls,
  );

  static TextStyle body(double sz, Color c) => TextStyle(
    fontFamily: 'monospace',
    fontSize: sz,
    color: c,
    height: 1.65,
  );

  static BoxDecoration neonBox(Color c, {double r = 16, Color? fill}) =>
      BoxDecoration(
        color: fill ?? Colors.black.withOpacity(0.5),
        borderRadius: BorderRadius.circular(r),
        border: Border.all(color: c.withOpacity(0.65), width: 1.5),
        boxShadow: [
          BoxShadow(color: c.withOpacity(0.28), blurRadius: 22, spreadRadius: 2),
          BoxShadow(color: c.withOpacity(0.12), blurRadius: 60),
        ],
      );
}


// ───────────────────────────────────────────────────────────────────────────
//  SHARED: Neon Animated Background
// ───────────────────────────────────────────────────────────────────────────


class NeonBg extends StatefulWidget {
  final Widget child;
  const NeonBg({required this.child});

  @override
  State<NeonBg> createState() => NeonBgState();
}

class NeonBgState extends State<NeonBg> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
  AnimationController(vsync: this, duration: const Duration(seconds: 8))
    ..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      // Base gradient
      Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF050510), Color(0xFF0E0025), Color(0xFF000D1F)],
          ),
        ),
      ),
      // Animated orbs + particles
      AnimatedBuilder(
        animation: _ctrl,
        builder: (_, __) => CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _BgPainter(_ctrl.value),
        ),
      ),
      widget.child,
    ]);
  }
}

class _BgPainter extends CustomPainter {
  final double t;
  static final Random _r = Random(42);
  static final List<_Star> _stars = List.generate(
    80,
        (i) => _Star(_r.nextDouble(), _r.nextDouble(), _r.nextDouble() * 1.8 + 0.4),
  );

  _BgPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    // Pulsing orbs
    _drawOrb(canvas, size, paint,
        Offset(size.width * 0.15, size.height * 0.25),
        CD.violet.withOpacity(0.18 + 0.06 * sin(t * 2 * pi)),
        size.width * 0.38);
    _drawOrb(canvas, size, paint,
        Offset(size.width * 0.85, size.height * 0.65),
        CD.cyan.withOpacity(0.14 + 0.05 * sin(t * 2 * pi + 1.5)),
        size.width * 0.32);
    _drawOrb(canvas, size, paint,
        Offset(size.width * 0.5, size.height * 0.85),
        CD.magenta.withOpacity(0.10 + 0.04 * sin(t * 2 * pi + 3)),
        size.width * 0.28);

    // Stars
    for (final s in _stars) {
      final twinkle = (sin(t * 2 * pi * 1.3 + s.phase * 6.28) * 0.35 + 0.65);
      paint.color = Colors.white.withOpacity(0.55 * twinkle);
      canvas.drawCircle(
          Offset(s.x * size.width, s.y * size.height * 0.75), s.size, paint);
    }

    // Horizontal scan lines (subtle)
    paint
      ..color = CD.cyan.withOpacity(0.03)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    for (double y = 0; y < size.height; y += 4) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
    paint.style = PaintingStyle.fill;
  }

  void _drawOrb(Canvas canvas, Size size, Paint paint, Offset center,
      Color color, double radius) {
    paint.shader = RadialGradient(
      colors: [color, Colors.transparent],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
    paint.shader = null;
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _Star {
  final double x, y, phase, size;
  _Star(this.x, this.y, this.size) : phase = Random().nextDouble();
}

// ───────────────────────────────────────────────────────────────────────────
//  SHARED: Neon Button
// ───────────────────────────────────────────────────────────────────────────
class NeonButton extends StatefulWidget {
  final String label;
  final IconData? icon;
  final Color color;
  final VoidCallback onTap;
  final double fontSize;
  final EdgeInsets padding;

  const NeonButton({
    required this.label,
    required this.color,
    required this.onTap,
    this.icon,
    this.fontSize = 15,
    this.padding = const EdgeInsets.symmetric(horizontal: 36, vertical: 16),
  });

  @override
  State<NeonButton> createState() => NeonButtonState();
}

class NeonButtonState extends State<NeonButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 120));

  bool _pressed = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

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
        transform: Matrix4.identity()..scale(_pressed ? 0.95 : 1.0),
        padding: widget.padding,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(color: widget.color, width: 1.8),
          boxShadow: [
            BoxShadow(
              color: widget.color.withOpacity(_pressed ? 0.6 : 0.35),
              blurRadius: _pressed ? 30 : 18,
              spreadRadius: _pressed ? 4 : 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: widget.color, size: widget.fontSize + 2),
              const SizedBox(width: 10),
            ],
            Text(widget.label, style: CD.label(widget.fontSize, widget.color)),
          ],
        ),
      ),
    );
  }
}

// ───────────────────────────────────────────────────────────────────────────
//  SHARED: Section divider
// ───────────────────────────────────────────────────────────────────────────
class NeonDivider extends StatelessWidget {
  final Color color;
  const NeonDivider({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1.5,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, color.withOpacity(0.7), Colors.transparent],
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.4), blurRadius: 8)],
      ),
    );
  }
}