

import 'package:flutter/cupertino.dart';
import 'package:msp/blocs/accelerometer_bloc.dart';

class StepCountWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _StepCountWidgetState();
}

class _StepCountWidgetState extends State<StatefulWidget> {

  int count = 0;

  @override
  void initState() {
    accelerometerBloc.stepCounterStream.listen((event) => setState(() {
      count = event;
    }));
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Text(count.toString());

}