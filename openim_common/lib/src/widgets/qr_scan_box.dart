// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';

class QrScanBoxPainter extends CustomPainter {
  final double animationValue;
  final bool isForward;
  final Color boxLineColor;

  QrScanBoxPainter(
      {required this.animationValue,
      required this.isForward,
      required this.boxLineColor});

  @override
  void paint(Canvas canvas, Size size) {
    // Outer rounded rectangle with soft shadow
    final borderRadius = const BorderRadius.all(Radius.circular(20)).toRRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
    );

    // Draw outer border with soft color
    canvas.drawRRect(
      borderRadius,
      Paint()
        ..color = Colors.white.withOpacity(0.2)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw corners with cute minimalist style
    final cornerPaint = Paint()
      ..color = boxLineColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final path = Path();

    // leftTop
    path.moveTo(0, 50);
    path.lineTo(0, 20);
    path.quadraticBezierTo(0, 0, 20, 0);
    path.lineTo(50, 0);

    // rightTop
    path.moveTo(size.width - 50, 0);
    path.lineTo(size.width - 20, 0);
    path.quadraticBezierTo(size.width, 0, size.width, 20);
    path.lineTo(size.width, 50);

    // rightBottom
    path.moveTo(size.width, size.height - 50);
    path.lineTo(size.width, size.height - 20);
    path.quadraticBezierTo(
        size.width, size.height, size.width - 20, size.height);
    path.lineTo(size.width - 50, size.height);

    // leftBottom
    path.moveTo(50, size.height);
    path.lineTo(20, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - 20);
    path.lineTo(0, size.height - 50);

    canvas.drawPath(path, cornerPaint);

    // Add subtle glow effect to corners
    final glowPaint = Paint()
      ..color = boxLineColor.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2);

    canvas.drawPath(path, glowPaint);

    // Clip the canvas to the rounded rectangle
    canvas.clipRRect(
        const BorderRadius.all(Radius.circular(20)).toRRect(Offset.zero & size));

    // Draw scan line with smooth gradient
    final linePaint = Paint();
    final lineSize = size.height * 0.3;
    final leftPress = (size.height + lineSize) * animationValue - lineSize;
    linePaint.style = PaintingStyle.stroke;

    // Softer gradient for cute minimalist style
    linePaint.shader = LinearGradient(
      colors: [
        Colors.transparent,
        boxLineColor.withOpacity(0.2),
        boxLineColor.withOpacity(0.6),
        boxLineColor.withOpacity(0.2),
        Colors.transparent,
      ],
      stops: const [0.0, 0.2, 0.5, 0.8, 1.0],
      begin: isForward ? Alignment.topCenter : const Alignment(0.0, 2.0),
      end: isForward ? const Alignment(0.0, 0.6) : Alignment.topCenter,
    ).createShader(Rect.fromLTWH(0, leftPress, size.width, lineSize));

    // Draw scan lines with soft effect
    for (int i = 0; i < size.width / 4; i++) {
      canvas.drawLine(
        Offset(
          i * 4.0,
          leftPress,
        ),
        Offset(i * 4.0, leftPress + lineSize),
        linePaint,
      );
    }

    // Draw horizontal line with soft glow
    final glowLinePaint = Paint()
      ..color = boxLineColor.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

    canvas.drawLine(
      Offset(20, leftPress + lineSize * 0.5),
      Offset(size.width - 20, leftPress + lineSize * 0.5),
      glowLinePaint,
    );
  }

  @override
  bool shouldRepaint(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;

  @override
  bool shouldRebuildSemantics(QrScanBoxPainter oldDelegate) =>
      animationValue != oldDelegate.animationValue;
}
