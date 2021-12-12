import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:tuple/tuple.dart';

final mapImage = Image.asset('assets/images/F10.png');
final mapOpacity = Colors.black.withOpacity(0.7);
const realImageSize = Tuple2(1256.0, 1007.0);
const mapLoadDuration = Duration(milliseconds: 300);



class Configuration {
  String triggerNormValue = '1.8';
  double get triggerNorm => double.tryParse(triggerNormValue) ?? 0.0;

  String triggerIntervalMinValue = '400';
  int get triggerIntervalMin => int.tryParse(triggerIntervalMinValue) ?? 0;
}

final configuration = Configuration();