import 'package:flutter_compass/flutter_compass.dart';
import 'package:msp/blocs/stream_bloc.dart';

class CompassBloc extends StreamBloc<int> {
  int calibrationDegree = 0;

  @override
  void start() {
    super.start();
    subscription = FlutterCompass.events?.listen((event) {
      var heading = event.heading?.toInt() ?? 0;
      pub((heading - calibrationDegree + 360).remainder(360));
    });
  }

  calibrate(int degree) {
    calibrationDegree = degree + calibrationDegree;
  }

}

final compassBloc = CompassBloc();
