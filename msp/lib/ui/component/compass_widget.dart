import 'dart:async';
import 'dart:developer' as developer;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:msp/blocs/compass_bloc.dart';

class CompassWidget extends StatefulWidget {
  @override
  _CompassWidgetState createState() => _CompassWidgetState();
}

class _CompassWidgetState extends State<CompassWidget> {
  int turns = 0;
  bool isActive = false;
  StreamSubscription? compassBlocStreamSubscription;

  @override
  void dispose() {
    developer.log('Compass Widget Dispose');
    isActive = false;
    try {
      compassBlocStreamSubscription?.cancel();
      compassBlocStreamSubscription = null;
      compassBloc.stop();
    } catch (exception) {
      developer.log('Dispose Error', error: exception);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    developer.log('Compass Widget Init');
    isActive = true;
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        compassBloc.start();
        compassBlocStreamSubscription = compassBloc.stream.listen((event) {
          if (isActive) {
            setState(() => turns = event);
          }
        });
      } catch (exception) {
        developer.log('Init Error', error: exception);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
        child: Transform.rotate(
            angle: turns * 3.14 / 180,
            child: IconButton(
              iconSize: 36,
              icon: const Icon(Icons.arrow_upward_sharp),
              onPressed: () {
                compassBloc.calibrate(turns);
              },
            )));
  }
}
