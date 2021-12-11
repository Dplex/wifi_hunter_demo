import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class MspPainter extends CustomPainter {
  final double radians;
  final List<Tuple4<double, double, double, double>> blockList;
  final Tuple4<double, double, double, double>? current;
  final List<Tuple2<double, double>> currentParticle;

  MspPainter(this.radians, this.blockList, this.current, this.currentParticle);

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke;
    for (Tuple2 particle in currentParticle) {
      canvas.drawCircle(Offset(particle.item1, particle.item2), (this.radians - 5).abs() * 10 + 2, paint);
    }

    paint.color = Colors.red;
    paint.strokeWidth = 3;

    for (Tuple4 block in blockList) {
      canvas.drawLine(Offset(block.item1, block.item2), Offset(block.item3, block.item4), paint);
    }

    if (current != null) {
      paint.color = Colors.orangeAccent;
      canvas.drawLine(Offset(current!.item1, current!.item2), Offset(current!.item3, current!.item4), paint);
    }
  }

  @override
  bool shouldRepaint(MspPainter oldDelegate) {
    return this.radians != oldDelegate.radians;
  }
}