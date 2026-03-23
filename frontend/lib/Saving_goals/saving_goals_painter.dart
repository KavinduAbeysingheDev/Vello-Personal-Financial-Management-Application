import 'package:flutter/material.dart';

class VelloLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color =
          const Color(0xFF059669) // Teal Green from Figma theme
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // ─────────────────────────────────────────────────────────────
    // Segment 1: CENTER BAR — tall, pointed top, wider mid, tapers to bottom
    // ─────────────────────────────────────────────────────────────
    final center = Path()
      ..moveTo(w * 0.50, h * 0.18) // pointed top
      ..lineTo(w * 0.545, h * 0.38) // upper right edge
      ..lineTo(w * 0.545, h * 0.75) // lower right edge
      ..lineTo(w * 0.50, h * 0.82) // bottom point
      ..lineTo(w * 0.455, h * 0.75) // lower left edge
      ..lineTo(w * 0.455, h * 0.38) // upper left edge
      ..close();
    canvas.drawPath(center, paint);

    // ─────────────────────────────────────────────────────────────
    // Segment 2: LEFT INNER BAR — tilted, wide top-left, narrows to bottom
    // ─────────────────────────────────────────────────────────────
    final leftInner = Path()
      ..moveTo(w * 0.33, h * 0.36) // top left
      ..lineTo(w * 0.375, h * 0.36) // top right
      ..lineTo(w * 0.455, h * 0.78) // bottom right (near center bottom)
      ..lineTo(w * 0.415, h * 0.78) // bottom left
      ..close();
    canvas.drawPath(leftInner, paint);

    // ─────────────────────────────────────────────────────────────
    // Segment 3: RIGHT INNER BAR — mirror of left inner bar
    // ─────────────────────────────────────────────────────────────
    final rightInner = Path()
      ..moveTo(w * 0.67, h * 0.36) // top right
      ..lineTo(w * 0.625, h * 0.36) // top left
      ..lineTo(w * 0.545, h * 0.78) // bottom left
      ..lineTo(w * 0.585, h * 0.78) // bottom right
      ..close();
    canvas.drawPath(rightInner, paint);

    // ─────────────────────────────────────────────────────────────
    // Segment 4: LEFT OUTER BRACKET — angled like "<", tapered
    // ─────────────────────────────────────────────────────────────
    final leftOuter = Path()
      ..moveTo(w * 0.205, h * 0.54) // leftmost tip
      ..lineTo(w * 0.30, h * 0.43) // top
      ..lineTo(w * 0.335, h * 0.45) // top inner edge
      ..lineTo(w * 0.245, h * 0.545) // inner tip
      ..lineTo(w * 0.335, h * 0.66) // bottom inner edge
      ..lineTo(w * 0.30, h * 0.68) // bottom
      ..close();
    canvas.drawPath(leftOuter, paint);

    // ─────────────────────────────────────────────────────────────
    // Segment 5: RIGHT OUTER BRACKET — mirror of left outer ">"
    // ─────────────────────────────────────────────────────────────
    final rightOuter = Path()
      ..moveTo(w * 0.795, h * 0.54) // rightmost tip
      ..lineTo(w * 0.70, h * 0.43) // top
      ..lineTo(w * 0.665, h * 0.45) // top inner edge
      ..lineTo(w * 0.755, h * 0.545) // inner tip
      ..lineTo(w * 0.665, h * 0.66) // bottom inner edge
      ..lineTo(w * 0.70, h * 0.68) // bottom
      ..close();
    canvas.drawPath(rightOuter, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
