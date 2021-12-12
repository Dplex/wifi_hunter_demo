import 'package:flutter/material.dart';
import 'package:msp/ui/component/card_widget.dart';

import '../config.dart';
import 'dart:developer' as developer;

class SettingList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        CardWidget('Step Threshold', 'Step 인지를 위한 Threshold Value', configuration.triggerNormValue,
            (value) => configuration.triggerNormValue = value),
        CardWidget('Step Interval', 'Step 마다의 최소 interval time (ms)', configuration.triggerIntervalMinValue,
            (value) => configuration.triggerIntervalMinValue = value),
      ],
    );
  }
}
