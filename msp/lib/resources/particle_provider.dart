import 'package:msp/models/particle.dart';
import 'dart:math';

class ParticleProvider {
  double _x = 0;
  double _y = 0;
  double _z = 0;

  Particle fetch() {
    _x += 1;
    _y += Random().nextInt(1537);
    return Particle()..setPosition(_x, _y, 0, 0);
  }


}
