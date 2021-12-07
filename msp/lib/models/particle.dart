import 'dart:math' as math;
class Particle {
  late double sensorX;
  late double sensorY;
  late double sensorZ;
  late int seq;
  late double _weight;
  late double _speed;
  late double _speedAngle;

  void setPosition(double _x, double _y, double _z, int _seq) {
    sensorX = _x;
    sensorY = _y;
    sensorZ = _z;
    seq = _seq;
  }

  @override
  String toString() {
    return '$sensorX : $sensorY : $sensorZ';
  }

  double getNorm() {
    return math.sqrt([sensorX, sensorY, sensorZ].map((e) => math.pow(e, 2)).reduce((a, b) => a + b));
  }
}