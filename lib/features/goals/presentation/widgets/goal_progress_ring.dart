import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme.dart';

/// A circular progress ring widget for displaying goal progress.
///
/// This widget renders a circular progress indicator with customizable:
/// - Progress value (0.0 to 1.0)
/// - Ring color
/// - Ring size and stroke width
/// - Child widget displayed in the center
class GoalProgressRing extends StatelessWidget {
  /// Creates a circular progress ring.
  ///
  /// The [progress] value should be between 0.0 and 1.0.
  /// The [child] widget is displayed in the center of the ring.
  const GoalProgressRing({
    required this.progress,
    required this.child,
    this.size = 72,
    this.strokeWidth = 6,
    this.color = SpendexColors.primary,
    super.key,
  });

  /// The progress value from 0.0 (empty) to 1.0 (complete).
  final double progress;

  /// The widget to display in the center of the ring.
  final Widget child;

  /// The diameter of the progress ring.
  final double size;

  /// The width of the progress ring stroke.
  final double strokeWidth;

  /// The color of the progress indicator.
  final Color color;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size(size, size),
            painter: CircularProgressPainter(
              progress: progress,
              color: color,
              backgroundColor: isDark
                  ? SpendexColors.darkBorder
                  : SpendexColors.lightBorder,
              strokeWidth: strokeWidth,
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Custom painter for drawing the circular progress ring.
///
/// This painter draws both the background circle and the progress arc
/// with rounded stroke caps for a polished appearance.
class CircularProgressPainter extends CustomPainter {
  /// Creates a circular progress painter.
  const CircularProgressPainter({
    required this.progress,
    required this.color,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  /// The progress value from 0.0 to 1.0.
  final double progress;

  /// The color of the progress arc.
  final Color color;

  /// The color of the background circle.
  final Color backgroundColor;

  /// The width of the stroke.
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);

    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * progress.clamp(0.0, 1.0);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(CircularProgressPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color != color ||
        oldDelegate.backgroundColor != backgroundColor ||
        oldDelegate.strokeWidth != strokeWidth;
  }
}
