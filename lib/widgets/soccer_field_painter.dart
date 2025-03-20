import 'package:flutter/material.dart';

class SoccerFieldPainter extends CustomPainter {
  final Color lineColor;
  final Color fieldColor;
  final double strokeWidth;

  SoccerFieldPainter({
    this.lineColor = Colors.white,
    this.fieldColor = const Color(0xFF2E7D32), // Dark green
    this.strokeWidth = 2.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = fieldColor
          ..style = PaintingStyle.fill;

    // Draw field background
    canvas.drawRect(Offset.zero & size, paint);

    paint
      ..color = lineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    // Draw field outline
    canvas.drawRect(
      Rect.fromLTWH(
        strokeWidth / 2,
        strokeWidth / 2,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      paint,
    );

    // Draw center line
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // Draw center circle
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.15,
      paint,
    );

    // Draw center dot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      strokeWidth * 2,
      paint,
    );

    // Draw penalty areas
    final penaltyAreaWidth = size.width * 0.4;
    final penaltyAreaHeight = size.height * 0.2;

    // Top penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyAreaWidth) / 2,
        0,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      paint..style = PaintingStyle.stroke,
    );

    // Bottom penalty area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyAreaWidth) / 2,
        size.height - penaltyAreaHeight,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      paint,
    );

    // Draw goal areas
    final goalAreaWidth = size.width * 0.2;
    final goalAreaHeight = size.height * 0.1;

    // Top goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaWidth) / 2,
        0,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );

    // Bottom goal area
    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaWidth) / 2,
        size.height - goalAreaHeight,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is SoccerFieldPainter) {
      return oldDelegate.lineColor != lineColor ||
          oldDelegate.fieldColor != fieldColor ||
          oldDelegate.strokeWidth != strokeWidth;
    }
    return true;
  }
}
