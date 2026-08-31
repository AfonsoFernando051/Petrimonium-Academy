import 'package:flutter/material.dart';

/// Supported tail placement directions for [ComicBubblePainter].
enum PetBubbleTailPosition {
  bottomLeft,
  bottomRight,
  bottomCenter,
  topLeft,
  topRight,
  topCenter,
  left,
  right,
  none,
}

/// Custom vector painter that renders a comic-inspired dialogue bubble shell
/// complete with integrated pointer tail, dual stroke, and soft drop shadow.
class ComicBubblePainter extends CustomPainter {
  const ComicBubblePainter({
    required this.gradient,
    required this.borderColor,
    required this.glowColor,
    this.tailPosition = PetBubbleTailPosition.bottomLeft,
    this.borderRadius = 18.0,
    this.tailWidth = 18.0,
    this.tailHeight = 14.0,
    this.strokeWidth = 2.0,
    this.tailOffset = 36.0,
  });

  final Gradient gradient;
  final Color borderColor;
  final Color glowColor;
  final PetBubbleTailPosition tailPosition;
  final double borderRadius;
  final double tailWidth;
  final double tailHeight;
  final double strokeWidth;

  /// Distance from the corner to the center of the tail.
  final double tailOffset;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final path = getBubblePath(size);

    // 1. Draw Glow / Drop Shadow
    final shadowPaint = Paint()
      ..color = glowColor
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16.0);
    canvas.drawPath(path, shadowPaint);

    // 2. Fill Gradient Surface
    final rect = Offset.zero & size;
    final fillPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // 3. Draw Outer Border Stroke
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, borderPaint);
  }

  /// Calculates the integrated unified path for the main body and tail.
  Path getBubblePath(Size size) {
    final path = Path();

    // Adjust body bounds based on tail position so tail extends outward
    final double left = tailPosition == PetBubbleTailPosition.left ? tailHeight : 0.0;
    final double top = (tailPosition == PetBubbleTailPosition.topLeft ||
            tailPosition == PetBubbleTailPosition.topRight ||
            tailPosition == PetBubbleTailPosition.topCenter)
        ? tailHeight
        : 0.0;
    final double right = tailPosition == PetBubbleTailPosition.right ? size.width - tailHeight : size.width;
    final double bottom = (tailPosition == PetBubbleTailPosition.bottomLeft ||
            tailPosition == PetBubbleTailPosition.bottomRight ||
            tailPosition == PetBubbleTailPosition.bottomCenter)
        ? size.height - tailHeight
        : size.height;

    final double r = borderRadius.clamp(0.0, (bottom - top) / 2);

    // Start top-left corner
    path.moveTo(left + r, top);

    // --- TOP EDGE ---
    if (tailPosition == PetBubbleTailPosition.topLeft ||
        tailPosition == PetBubbleTailPosition.topCenter ||
        tailPosition == PetBubbleTailPosition.topRight) {
      final double tailCX = switch (tailPosition) {
        PetBubbleTailPosition.topLeft => left + r + tailOffset,
        PetBubbleTailPosition.topRight => right - r - tailOffset,
        _ => (left + right) / 2,
      };
      final double tLeft = (tailCX - tailWidth / 2).clamp(left + r, right - r - tailWidth);
      final double tRight = tLeft + tailWidth;

      path.lineTo(tLeft, top);
      // Bezier curve to tip pointing UP
      path.cubicTo(
        tLeft + tailWidth * 0.2,
        top,
        tailCX - tailWidth * 0.1,
        0.0,
        tailCX,
        0.0,
      );
      path.cubicTo(
        tailCX + tailWidth * 0.1,
        0.0,
        tRight - tailWidth * 0.2,
        top,
        tRight,
        top,
      );
    }
    path.lineTo(right - r, top);
    path.arcToPoint(Offset(right, top + r), radius: Radius.circular(r));

    // --- RIGHT EDGE ---
    if (tailPosition == PetBubbleTailPosition.right) {
      final double tailCY = (top + bottom) / 2;
      final double tTop = tailCY - tailWidth / 2;
      final double tBottom = tailCY + tailWidth / 2;

      path.lineTo(right, tTop);
      path.cubicTo(
        right,
        tTop + tailWidth * 0.2,
        size.width,
        tailCY - tailWidth * 0.1,
        size.width,
        tailCY,
      );
      path.cubicTo(
        size.width,
        tailCY + tailWidth * 0.1,
        right,
        tBottom - tailWidth * 0.2,
        right,
        tBottom,
      );
    }
    path.lineTo(right, bottom - r);
    path.arcToPoint(Offset(right - r, bottom), radius: Radius.circular(r));

    // --- BOTTOM EDGE ---
    if (tailPosition == PetBubbleTailPosition.bottomLeft ||
        tailPosition == PetBubbleTailPosition.bottomCenter ||
        tailPosition == PetBubbleTailPosition.bottomRight) {
      final double tailCX = switch (tailPosition) {
        PetBubbleTailPosition.bottomLeft => left + r + tailOffset,
        PetBubbleTailPosition.bottomRight => right - r - tailOffset,
        _ => (left + right) / 2,
      };
      final double tLeft = (tailCX - tailWidth / 2).clamp(left + r, right - r - tailWidth);
      final double tRight = tLeft + tailWidth;

      path.lineTo(tRight, bottom);
      // Bezier curve to tip pointing DOWN towards Pet
      path.cubicTo(
        tRight - tailWidth * 0.2,
        bottom,
        tailCX + tailWidth * 0.1,
        size.height,
        tailCX,
        size.height,
      );
      path.cubicTo(
        tailCX - tailWidth * 0.1,
        size.height,
        tLeft + tailWidth * 0.2,
        bottom,
        tLeft,
        bottom,
      );
    }
    path.lineTo(left + r, bottom);
    path.arcToPoint(Offset(left, bottom - r), radius: Radius.circular(r));

    // --- LEFT EDGE ---
    if (tailPosition == PetBubbleTailPosition.left) {
      final double tailCY = (top + bottom) / 2;
      final double tTop = tailCY - tailWidth / 2;
      final double tBottom = tailCY + tailWidth / 2;

      path.lineTo(left, tBottom);
      path.cubicTo(
        left,
        tBottom - tailWidth * 0.2,
        0.0,
        tailCY + tailWidth * 0.1,
        0.0,
        tailCY,
      );
      path.cubicTo(
        0.0,
        tailCY - tailWidth * 0.1,
        left,
        tTop + tailWidth * 0.2,
        left,
        tTop,
      );
    }
    path.lineTo(left, top + r);
    path.arcToPoint(Offset(left + r, top), radius: Radius.circular(r));

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant ComicBubblePainter oldDelegate) {
    return oldDelegate.gradient != gradient ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.glowColor != glowColor ||
        oldDelegate.tailPosition != tailPosition ||
        oldDelegate.borderRadius != borderRadius ||
        oldDelegate.tailWidth != tailWidth ||
        oldDelegate.tailHeight != tailHeight ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.tailOffset != tailOffset;
  }
}
