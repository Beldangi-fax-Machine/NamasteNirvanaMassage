import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class LotusIcon extends StatelessWidget {
  final double size;
  final Color? color;

  const LotusIcon({
    super.key,
    this.size = 100,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _LotusPainter(color: color ?? AppColors.accent),
    );
  }
}

class _LotusPainter extends CustomPainter {
  final Color color;

  _LotusPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // Center petal (top)
    _drawPetal(
      canvas,
      paint,
      center,
      size.width * 0.12,
      size.height * 0.4,
      0,
    );

    // Left petals
    _drawPetal(
      canvas,
      paint.copyWith(color.withOpacity(0.85)),
      center,
      size.width * 0.1,
      size.height * 0.32,
      -35,
    );

    _drawPetal(
      canvas,
      paint.copyWith(color.withOpacity(0.7)),
      center,
      size.width * 0.08,
      size.height * 0.25,
      -65,
    );

    // Right petals
    _drawPetal(
      canvas,
      paint.copyWith(color.withOpacity(0.85)),
      center,
      size.width * 0.1,
      size.height * 0.32,
      35,
    );

    _drawPetal(
      canvas,
      paint.copyWith(color.withOpacity(0.7)),
      center,
      size.width * 0.08,
      size.height * 0.25,
      65,
    );
  }

  void _drawPetal(
    Canvas canvas,
    Paint paint,
    Offset center,
    double width,
    double height,
    double angleDegrees,
  ) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angleDegrees * 3.14159 / 180);

    final path = Path();
    path.moveTo(0, 0);
    path.quadraticBezierTo(
      width,
      -height * 0.6,
      0,
      -height,
    );
    path.quadraticBezierTo(
      -width,
      -height * 0.6,
      0,
      0,
    );
    path.close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

extension on Paint {
  Paint copyWith(Color color) {
    return Paint()
      ..color = color
      ..style = style
      ..strokeWidth = strokeWidth;
  }
}
