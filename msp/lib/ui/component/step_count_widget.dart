import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:msp/blocs/accelerometer_bloc.dart';
import 'package:sensors_plus/sensors_plus.dart';

class StepCountWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StepCountWidgetState();
}

class _StepCountWidgetState extends State<StatefulWidget> {
  int count = 0;
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();
    developer.log('StepCountWidget Init');
    Future.delayed(const Duration(milliseconds: 500), () {
      accelerometerBloc.start();
      _streamSubscription = accelerometerBloc.stepCounterStream.listen((event) => setState(() {
            count = event;
          }));
    });
  }

  @override
  void dispose() {
    developer.log('StepCountWidget Finish');
    _streamSubscription?.cancel();
    accelerometerBloc.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(count.toString());
}
