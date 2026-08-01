import 'package:flutter/material.dart';

/// Stylized icosahedron (d20) outline for counter / tabletop affordances.
class D20Icon extends StatelessWidget {
  const D20Icon({
    super.key,
    required this.size,
    required this.color,
  });

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _D20IconPainter(color: color),
    );
  }
}

class _D20IconPainter extends CustomPainter {
  _D20IconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w * 0.5;
    final stroke = (w * 0.09).clamp(1.25, 2.5);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    // Classic front-facing d20: upper + lower triangle sharing the waist.
    final top = Offset(cx, h * 0.06);
    final left = Offset(w * 0.08, h * 0.52);
    final right = Offset(w * 0.92, h * 0.52);
    final bottom = Offset(cx, h * 0.94);

    final outline = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(left.dx, left.dy)
      ..lineTo(right.dx, right.dy)
      ..close()
      ..moveTo(left.dx, left.dy)
      ..lineTo(bottom.dx, bottom.dy)
      ..lineTo(right.dx, right.dy)
      ..close();

    canvas.drawPath(outline, paint);

    // Center facet — reads as a die face at small sizes.
    final facet = Path()
      ..moveTo(top.dx, top.dy)
      ..lineTo(cx, h * 0.52)
      ..lineTo(left.dx, left.dy)
      ..close();
    canvas.drawPath(facet, paint..strokeWidth = stroke * 0.85);

    // Optional "20" only when large enough to stay legible.
    if (w >= 28) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '20',
          style: TextStyle(
            color: color,
            fontSize: w * 0.28,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          cx - textPainter.width * 0.5,
          h * 0.56 - textPainter.height * 0.5,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _D20IconPainter oldDelegate) =>
      oldDelegate.color != color;
}
