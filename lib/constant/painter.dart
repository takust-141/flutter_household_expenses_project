import 'package:flutter/material.dart';

//-----スラッシュ-----
class SlashPainter extends CustomPainter {
  final Color lineColor;
  final Color backgroundColor;
  final bool downRight;

  SlashPainter({
    Color? lineColor,
    Color? backgroundColor,
    bool? downRight,
  })  : lineColor = lineColor ?? Colors.grey,
        backgroundColor = backgroundColor ?? Colors.white,
        downRight = downRight ?? true;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = backgroundColor;
    paint.strokeWidth = 4.5;
    _drawLine(canvas, size, paint);

    paint.color = lineColor;
    paint.strokeWidth = 1.5;
    _drawLine(canvas, size, paint);
  }

  // 線を描画するヘルパーメソッド
  void _drawLine(Canvas canvas, Size size, Paint paint) {
    if (downRight) {
      canvas.drawLine(
          const Offset(0, 0), Offset(size.width, size.height), paint);
    } else {
      canvas.drawLine(Offset(0, size.height), Offset(size.width, 0), paint);
    }
  }

  @override
  bool shouldRepaint(covariant SlashPainter oldDelegate) {
    return false;
  }
}

//-----イコールアイコン-----
class EqualPainter extends CustomPainter {
  final Color lineColor;
  final Color backgroundColor;
  final bool downRight;

  EqualPainter({
    Color? lineColor,
    Color? backgroundColor,
    bool? downRight,
  })  : lineColor = lineColor ?? Colors.grey,
        backgroundColor = backgroundColor ?? Colors.white,
        downRight = downRight ?? true;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    paint.color = backgroundColor;
    paint.strokeWidth = 4.5;

    paint.color = lineColor;
    paint.strokeWidth = 1.5;

    canvas.drawLine(const Offset(0, 0), Offset(size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant SlashPainter oldDelegate) {
    return false;
  }
}
