import 'dart:math' as math;

class Accelerometer {
  late double x;
  late double y;
  late double z;
  late int seq;

  double get norm => _getNorm();

  Accelerometer(double _x, double _y, double _z, int _seq) {
    x = _x;
    y = _y;
    z = _z;
    seq = _seq;
  }

  @override
  String toString() {
    return '$x : $y : $z';
  }

  double _getNorm() {
    return math.sqrt([x, y, z].map((e) => math.pow(e, 2)).reduce((v, e) => v + e));
  }
}
