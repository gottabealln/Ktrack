import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/quotes.dart';
import '../widgets/floating_blobs.dart';

class LoadingScreen extends StatefulWidget {
  final VoidCallback onDone;
  const LoadingScreen({super.key, required this.onDone});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late AnimationController _ringCtrl;
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeOut;

  @override
  void initState() {
    super.initState();

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();

    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeOut = Tween<double>(begin: 1, end: 0).animate(_fadeCtrl);

    // Auto-advance after 3.2s
    Future.delayed(const Duration(milliseconds: 3200), () async {
      await _fadeCtrl.forward();
      widget.onDone();
    });
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quote = getDailyQuote();

    return FadeTransition(
      opacity: _fadeOut,
      child: FloatingBlobs(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),

                  // Pulsing logo with rotating rings
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Rotating ring 1
                        RotationTransition(
                          turns: _ringCtrl,
                          child: CustomPaint(
                            size: const Size(220, 220),
                            painter: _RingPainter(
                              color: AppColors.g3.withOpacity(0.6),
                              strokeWidth: 2,
                              dashCount: 40,
                            ),
                          ),
                        ),
                        // Counter-rotating ring 2
                        RotationTransition(
                          turns: ReverseAnimation(_ringCtrl),
                          child: CustomPaint(
                            size: const Size(170, 170),
                            painter: _RingPainter(
                              color: AppColors.g2.withOpacity(0.7),
                              strokeWidth: 3,
                              dashCount: 30,
                            ),
                          ),
                        ),
                        // Pulsing glowing heart
                        AnimatedBuilder(
                          animation: _pulseCtrl,
                          builder: (_, __) {
                            final s =
                                1.0 + (_pulseCtrl.value * 0.12);
                            return Transform.scale(
                              scale: s,
                              child: Container(
                                width: 110,
                                height: 110,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: AppGradients.warm,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.g3
                                          .withOpacity(0.55),
                                      blurRadius: 40,
                                      spreadRadius: 8,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.favorite,
                                  color: Colors.white,
                                  size: 46,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Title with shimmer
                  ShaderMask(
                    shaderCallback: (rect) => const LinearGradient(
                      colors: [
                        AppColors.g3,
                        AppColors.g4,
                        AppColors.g2,
                        AppColors.g5,
                      ],
                    ).createShader(rect),
                    child: Text(
                      'KTRACK',
                      style: AppText.h1.copyWith(
                        color: Colors.white,
                        fontSize: 40,
                        letterSpacing: 3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                  Text(
                    'your calm companion',
                    style: AppText.small.copyWith(
                      letterSpacing: 2,
                      color: AppColors.text,
                    ),
                  ),

                  const Spacer(),

                  // Quote card
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: AppDecorations.glassCard(),
                    child: Column(
                      children: [
                        const Icon(Icons.auto_awesome,
                            color: AppColors.g4, size: 20),
                        const SizedBox(height: 10),
                        Text(
                          quote,
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Loading bar
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: SizedBox(
                      height: 6,
                      child: LayoutBuilder(
                        builder: (_, c) => AnimatedBuilder(
                          animation: _ringCtrl,
                          builder: (_, __) => Container(
                            width: c.maxWidth * _ringCtrl.value,
                            decoration: const BoxDecoration(
                              gradient: AppGradients.warm,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text('loading...', style: AppText.small),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _RingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final dashAngle = (2 * 3.14159) / dashCount;

    for (int i = 0; i < dashCount; i++) {
      final start = i * dashAngle;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        dashAngle * 0.5,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.color != color || old.dashCount != dashCount;
}