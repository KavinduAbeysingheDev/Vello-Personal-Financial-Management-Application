import 'package:flutter/material.dart';

class VelloLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFFFBBF24) // Gold
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    // Center Vertical Spine (slightly shorter for diamond feel)
    canvas.drawLine(Offset(w * 0.5, h * 0.2), Offset(w * 0.5, h * 0.8), paint);

    // Inner Diagonal Bars
    // Left inner
    canvas.drawLine(
      Offset(w * 0.38, h * 0.35),
      Offset(w * 0.46, h * 0.75),
      paint,
    );
    // Right inner
    canvas.drawLine(
      Offset(w * 0.62, h * 0.35),
      Offset(w * 0.54, h * 0.75),
      paint,
    );

    // Outer Diagonal Bars (forming the side tips of the diamond)
    // Left outer
    canvas.drawLine(
      Offset(w * 0.22, h * 0.45),
      Offset(w * 0.4, h * 0.65),
      paint,
    );
    // Right outer
    canvas.drawLine(
      Offset(w * 0.78, h * 0.45),
      Offset(w * 0.6, h * 0.65),
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
