import 'package:flutter/material.dart';
import 'dart:math' as math;

class TuangkangAnimatedLogo extends StatefulWidget {
  final String fontFamily;

  const TuangkangAnimatedLogo({
    Key? key,
    this.fontFamily = 'Impact',
  }) : super(key: key);

  @override
  State<TuangkangAnimatedLogo> createState() => _TuangkangAnimatedLogoState();
}

class _TuangkangAnimatedLogoState extends State<TuangkangAnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          painter: TuangkangPainter(
            animation: _controller.value,
            fontFamily: widget.fontFamily,
          ),
          size: Size.infinite,
        );
      },
    );
  }
}

class TuangkangPainter extends CustomPainter {
  final double animation;
  final String fontFamily;

  TuangkangPainter({
    required this.animation,
    required this.fontFamily,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    const text = 'Tuangkang';
    const textLength = text.length;
    const timePerChar = 1.0 / textLength;

    double currentX = centerX - 200;

    for (int i = 0; i < textLength; i++) {
      final charStartTime = i * timePerChar;
      final charEndTime = (i + 1) * timePerChar;

      double charProgress = 0.0;
      if (animation >= charStartTime && animation < charEndTime) {
        charProgress = (animation - charStartTime) / timePerChar;
      } else if (animation >= charEndTime) {
        charProgress = 1.0;
      }

      if (charProgress > 0) {
        _drawAnimatedChar(
          canvas,
          text[i],
          Offset(currentX, centerY),
          charProgress,
        );
      }

      currentX += 65;
    }
  }

  void _drawAnimatedChar(
    Canvas canvas,
    String char,
    Offset position,
    double progress,
  ) {
    // Buat text painter untuk get text dimensions
    final textPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          color: Colors.cyan,
          fontSize: 96,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();

    canvas.save();
    canvas.translate(position.dx, position.dy - textPainter.height / 2);

    // Create paint dengan stroke untuk efek outline

    final fillPaint = Paint()
      ..color = Colors.cyan.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    // Animate opacity dan scale
    final opacity = math.min(1.0, progress * 1.5);
    final scale = 0.7 + (progress * 0.3);

    canvas.save();
    canvas.scale(scale);

    // Draw dengan clipping untuk efek "menulis"
    // Kita draw text penuh tapi dengan opacity gradient

    // Draw background dengan progress mask
    canvas.drawRect(
      Rect.fromLTWH(
        0,
        0,
        textPainter.width * progress,
        textPainter.height,
      ),
      fillPaint,
    );

    // Draw text biasa
    textPainter.paint(
      canvas,
      const Offset(0, 0),
    );

    // Draw outline stroke untuk efek lebih bold
    final strokeTextPainter = TextPainter(
      text: TextSpan(
        text: char,
        style: TextStyle(
          color: Colors.cyan.withValues(alpha: opacity),
          fontSize: 96,
          fontWeight: FontWeight.w900,
          fontFamily: fontFamily,
          letterSpacing: 2,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    strokeTextPainter.layout();

    // Draw glow effect
    for (int i = 2; i > 0; i--) {
      canvas.drawRect(
        Rect.fromLTWH(
          -i.toDouble(),
          -i.toDouble(),
          textPainter.width + (i * 2),
          textPainter.height + (i * 2),
        ),
        Paint()
          ..color = Colors.cyan.withValues(alpha: 0.05 / i)
          ..maskFilter = MaskFilter.blur(
            BlurStyle.outer,
            i * 2.0,
          ),
      );
    }

    canvas.restore();
    canvas.restore();
  }

  @override
  bool shouldRepaint(TuangkangPainter oldDelegate) {
    return oldDelegate.animation != animation ||
        oldDelegate.fontFamily != fontFamily;
  }
}
