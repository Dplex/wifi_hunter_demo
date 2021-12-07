
import 'dart:async';

import 'package:msp/resources/particle_provider.dart';
import 'package:rxdart/rxdart.dart';
import 'package:msp/models/particle.dart';
import 'package:sensors_plus/sensors_plus.dart';

class ParticleBloc {
  final _repository = ParticleProvider();
  final _particleFetcher = StreamController<Particle>();
  int seq = 0;
  Stream<Particle> get allParticle => _particleFetcher.stream;

  fetchAll() {
    Particle particle = _repository.fetch();
    _particleFetcher.sink.add(particle);
  }

  dispose() {
    stopUserSensor();
    // _particleFetcher.close();
  }

  listenUserSensor() {
    Future.delayed(const Duration(seconds: 2), () {
      userAccelerometerEvents.listen((event) {
        seq++;
        _particleFetcher.sink.add(Particle()..setPosition(event.x, event.y, event.z, seq));
      });
    });
  }

  stopUserSensor() {
    userAccelerometerEvents.listen(null);
  }
}

final particleBloc = ParticleBloc();
