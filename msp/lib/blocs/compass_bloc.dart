
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';

class CompassBlock {
  final _compassFetcher = StreamController<int>();
  int calibrationDegree = 0;
  Stream<int> get stream => _compassFetcher.stream;

  startListenCompass() {
    FlutterCompass.events?.listen((event) {
      var heading = event.heading?.toInt() ?? 0;
      _compassFetcher.sink.add((heading - calibrationDegree + 360).remainder(360));
    });
  }

  calibrate(int degree) {
    calibrationDegree = degree + calibrationDegree;
  }

  stopListenCompass() {
    FlutterCompass.events?.listen(null);
  }

  dispose() {
    stopListenCompass();
    // _compassFetcher.close();
  }
}

final compassBloc = CompassBlock();