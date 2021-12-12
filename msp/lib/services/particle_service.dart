import 'dart:async';
import 'dart:developer' as developer;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:msp/blocs/accelerometer_bloc.dart';
import 'package:msp/blocs/compass_bloc.dart';
import 'package:tuple/tuple.dart';

class ParticleService {
  late final Tuple2<double, double> _mapInfo;
  //411 734
  final List<Tuple4<double, double, double, double>> _blockList;
  final GlobalKey _key;

  int _turns = 0;
  StreamSubscription? compassBlocStreamSubscription;

  ParticleService(this._key, Tuple2<double, double> imageSize, this._blockList) {
    _mapInfo = Tuple2(_key.currentContext!.size!.width, _key.currentContext!.size!.height);
    BotToast.showText(
        text: 'Map Size(${imageSize.item1}, ${imageSize.item2}) Display ${_key.currentContext!.size.toString()}');
    start();
  }

  getBlocks() {
    developer.log(_blockList.map((e) => e.toString()).toList().toString());
  }

  start() {
    accelerometerBloc.start();
    accelerometerBloc.stepCounterStream.listen((event) {
      developer.log(event.toString());
    });
    compassBloc.start();
    compassBlocStreamSubscription = compassBloc.stream.listen((event) {
      _turns = event;
    });
  }

  shutdown() {
    developer.log('shutdown');
    accelerometerBloc.stop();
    compassBlocStreamSubscription?.cancel();
    compassBlocStreamSubscription = null;
    compassBloc.stop();
  }

  hotStop() {
    compassBlocStreamSubscription?.cancel();
    compassBlocStreamSubscription = null;
  }
}
