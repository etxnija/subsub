import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:subsub/models/position.dart';

class FieldScreen extends ConsumerWidget {
  const FieldScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('7v7 Formation (2-3-1)'),
      ),
      body: _buildField(),
    );
  }

  Widget _buildField() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[800],
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: CustomPaint(
            painter: HalfFieldPainter(),
            child: Stack(
              children: Position.standardPositions.map((position) {
                return _buildPositionMarker(
                  position,
                  constraints.maxWidth - 32, // Account for margin
                  constraints.maxHeight - 32,
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPositionMarker(Position position, double width, double height) {
    const markerSize = 40.0;
    return Positioned(
      // Subtract half the marker size to center it on the position
      left: (position.defaultLocation.dx * width) - (markerSize / 2),
      top: (position.defaultLocation.dy * height) - (markerSize / 2),
      child: Container(
        width: markerSize,
        height: markerSize,
        decoration: BoxDecoration(
          color: _getColorForCategory(position.category),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Text(
            position.abbreviation,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }

  Color _getColorForCategory(String category) {
    switch (category) {
      case 'Goalkeeper':
        return Colors.yellow[700]!;
      case 'Defense':
        return Colors.blue[700]!;
      case 'Midfield':
        return Colors.green[700]!;
      case 'Forward':
        return Colors.red[700]!;
      default:
        return Colors.grey;
    }
  }
}

class HalfFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Center circle (half)
    final centerY = size.height;
    final radius = size.width / 6;
    canvas.drawArc(
      Rect.fromCircle(
        center: Offset(size.width / 2, centerY),
        radius: radius,
      ),
      3.14159, // PI
      3.14159, // PI
      false,
      paint,
    );

    // Penalty area
    final penaltyAreaWidth = size.width * 0.6;
    final penaltyAreaHeight = size.height * 0.3;

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - penaltyAreaWidth) / 2,
        0,
        penaltyAreaWidth,
        penaltyAreaHeight,
      ),
      paint,
    );

    // Goal area
    final goalAreaWidth = size.width * 0.3;
    final goalAreaHeight = size.height * 0.15;

    canvas.drawRect(
      Rect.fromLTWH(
        (size.width - goalAreaWidth) / 2,
        0,
        goalAreaWidth,
        goalAreaHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 