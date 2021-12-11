import 'dart:developer' as developer;

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:tuple/tuple.dart';

class ParticleService {
  late final Tuple2<double, double> _mapInfo;

  final List<Tuple4<double, double, double, double>> _blockList;

  final GlobalKey _key;

  ParticleService(this._key, Tuple2<double, double> imageSize, this._blockList) {
    _mapInfo = Tuple2(this._key.currentContext!.size!.width, this._key.currentContext!.size!.height);
    BotToast.showText(
        text:
            'Map Size(${imageSize.item1}, ${imageSize.item2}) Display ${this._key.currentContext!.size.toString()}');
  }

  getBlocks() {
    developer.log('${_blockList.map((e) => e.toString()).toList().toString()}');
  }

//411 734

}
