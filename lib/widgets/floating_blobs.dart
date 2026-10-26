import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class FloatingBlobs extends StatefulWidget {
  final Widget child;
  const FloatingBlobs({super.key, required this.child});

  @override
  State<FloatingBlobs> createState() => _FloatingBlobsState();
}

class _FloatingBlobsState extends State<FloatingBlobs>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(gradient: AppGradients.background),
        ),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            final t = _ctrl.value * 2 * math.pi;
            return CustomPaint(
              painter: _BlobPainter(t),
              size: Size.infinite,
            );
          },
        ),
        widget.child,
      ],
    );
  }
}

class _BlobPainter extends CustomPainter {
  final double t;
  _BlobPainter(this.t);

  @override
  void paint(Canvas canvas, Size size) {
    _drawBlob(
      canvas,
      center: Offset(
        size.width * 0.2 + 40 * math.cos(t),
        size.height * 0.15 + 30 * math.sin(t * 1.2),
      ),
      radius: 160,
      color: AppColors.g1.withOpacity(0.35),
    );
    _drawBlob(
      canvas,
      center: Offset(
        size.width * 0.85 + 30 * math.sin(t * 0.9),
        size.height * 0.35 + 40 * math.cos(t * 1.1),
      ),
      radius: 180,
      color: AppColors.g3.withOpacity(0.25),
    );
    _drawBlob(
      canvas,
      center: Offset(
        size.width * 0.4 + 50 * math.cos(t * 1.3),
        size.height * 0.85 + 35 * math.sin(t),
      ),
      radius: 200,
      color: AppColors.g2.withOpacity(0.22),
    );
  }

  void _drawBlob(
      Canvas canvas, {
        required Offset center,
        required double radius,
        required Color color,
      }) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color, color.withOpacity(0)],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _BlobPainter old) => old.t != t;
}