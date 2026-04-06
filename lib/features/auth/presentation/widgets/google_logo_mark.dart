import 'dart:math' as math;

import 'package:flutter/material.dart';

class GoogleLogoMark extends StatelessWidget {
  const GoogleLogoMark({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: CustomPaint(
        size: Size.square(size * 0.82),
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final strokeWidth = size.shortestSide * 0.22;
    final radius = (size.shortestSide - strokeWidth) / 2;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromCircle(center: center, radius: radius);

    // Approximate the multicolor Google "G" ring.
    _arc(
      canvas,
      paint..color = const Color(0xFFEA4335),
      rect,
      _deg(-140),
      _deg(80),
    );
    _arc(
      canvas,
      paint..color = const Color(0xFF4285F4),
      rect,
      _deg(-50),
      _deg(85),
    );
    _arc(
      canvas,
      paint..color = const Color(0xFF34A853),
      rect,
      _deg(45),
      _deg(95),
    );
    _arc(
      canvas,
      paint..color = const Color(0xFFFBBC05),
      rect,
      _deg(140),
      _deg(90),
    );

    // Create the "G" opening on the right.
    final erase = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth * 1.15
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;
    _arc(canvas, erase, rect, _deg(-15), _deg(35));

    // Draw the inner bar of the "G".
    final barPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF4285F4);

    final barY = center.dy;
    final barStart = Offset(center.dx + radius * 0.15, barY);
    final barEnd = Offset(center.dx + radius * 0.95, barY);
    canvas.drawLine(barStart, barEnd, barPaint);
  }

  double _deg(double degrees) => degrees * math.pi / 180;

  void _arc(
    Canvas canvas,
    Paint paint,
    Rect rect,
    double startAngle,
    double sweepAngle,
  ) {
    canvas.drawArc(rect, startAngle, sweepAngle, false, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
