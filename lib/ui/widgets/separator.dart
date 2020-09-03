import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final bool horizontal;
  final Color color;

  const Separator({
    Key key,
    this.strokeWidth = 1,
    this.horizontal = true,
    this.dashWidth = 5,
    this.dashSpace = 5,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LineDashedPainter(
        strokeWidth: strokeWidth,
        horizontal: horizontal,
        dashWidth: dashWidth,
        dashSpace: dashSpace,
        color: color,
      ),
    );
  }
}

class _LineDashedPainter extends CustomPainter with EquatableMixin {
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final bool horizontal;
  final Color color;

  final _paint = Paint();

  _LineDashedPainter({
    this.strokeWidth = 1,
    this.horizontal = true,
    this.dashWidth = 5,
    this.dashSpace = 5,
    @required this.color,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    _paint.strokeWidth = strokeWidth;
    _paint.color = color;

    final space = dashSpace + dashWidth;

    if (horizontal) {
      var max = size.width;
      var startX = 0.0;

      while (max >= 0) {
        canvas.drawLine(
          Offset(startX, 0),
          Offset(startX + dashWidth, 0),
          _paint,
        );

        startX += space;
        max -= space;
      }
    } else {
      var max = size.height;
      var startY = 0.0;

      while (max >= 0) {
        canvas.drawLine(
          Offset(0, startY),
          Offset(0, startY + dashWidth),
          _paint,
        );

        startY += space;
        max -= space;
      }
    }
  }

  @override
  bool shouldRepaint(_LineDashedPainter painter) => this != painter;

  @override
  List<Object> get props => [
        strokeWidth,
        dashWidth,
        dashSpace,
        horizontal,
        color,
      ];
}
