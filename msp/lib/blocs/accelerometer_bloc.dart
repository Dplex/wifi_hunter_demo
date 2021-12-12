import 'dart:async';
import 'dart:developer' as developer;
import 'package:msp/blocs/stream_bloc.dart';
import 'package:msp/config.dart';
import 'package:msp/models/accelerometer.dart';
import 'package:sensors_plus/sensors_plus.dart';

class AccelerometerBloc extends StreamBloc<Accelerometer> {
  int seq = 0;
  int count = 0;
  double norm = 0;
  int lastEpoch = 0;
  StreamController<int> _stepCounterFetcher = StreamController<int>();

  Stream<int> get stepCounterStream => _stepCounterFetcher.stream;

  StreamSubscription? _stepSubscription;

  @override
  void start() {
    if (isStarted) return;
    super.start();
    _stepCounterFetcher = StreamController<int>();
    count = 0;
    seq = 0;
    Future.delayed(const Duration(seconds: 1), () {
      subscription = userAccelerometerEvents.listen((event) {
        seq++;
        var accelerometer = Accelerometer(event.x, event.y, event.z, seq);
        pub(accelerometer);
        checkStep(accelerometer.norm);
      });
    });
  }

  Future checkStep(double _norm) async {
    var currentEpoch = DateTime.now().millisecondsSinceEpoch;
    if (norm < _norm &&
        _norm >= configuration.triggerNorm &&
        currentEpoch - lastEpoch > configuration.triggerIntervalMin) {
      lastEpoch = currentEpoch;
      count++;
      _stepCounterFetcher.sink.add(count);
      developer.log('step : $count');
    }
    norm = _norm;
  }

  @override
  void stop() {
    _stepSubscription?.cancel();
    _stepSubscription = null;
    _stepCounterFetcher.close();
    super.stop();
  }
}

final accelerometerBloc = AccelerometerBloc();
