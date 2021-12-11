import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:msp/blocs/accelerometer_bloc.dart';
import 'package:msp/models/accelerometer.dart';
import 'package:msp/ui/component/compass_widget.dart';
import 'package:msp/ui/component/step_count_widget.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tuple/tuple.dart';

class PositionList extends StatefulWidget {
  @override
  _PositionListState createState() => _PositionListState();
}

class _PositionListState extends State<PositionList> {
  final List<Accelerometer> accelerometerData1 = [];

  final List<Accelerometer> accelerometerData2 = [];

  final List<Accelerometer> accelerometerData3 = [];

  final List<Accelerometer> accelerometerData4 = [];

  final List<Tuple2<ChartSeriesController, List<Accelerometer>>> chartDataTupleList = [];

  @override
  void initState() {
    try {
      accelerometerBloc.start();
      accelerometerBloc.stream.listen(dataListen);

    } catch (e) {}
    super.initState();
  }

  @override
  void dispose() {
    accelerometerBloc.stop();
    super.dispose();
  }

  void init() {}

  void dataListen(Accelerometer event) {
    if (chartDataTupleList.isEmpty) {
      return;
    }
    for (var element in chartDataTupleList) {
      final controller = element.item1;
      final accelerometerData = element.item2;

      accelerometerData.add(event);
      controller.updateDataSource(addedDataIndex: accelerometerData.length - 1);
      if (accelerometerData.length > 30) {
        controller.updateDataSource(removedDataIndex: 0);
        accelerometerData.removeAt(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const edgeDefault = EdgeInsets.all(5.0);
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [CompassWidget(), StepCountWidget()],
          ),
          Expanded(child: Padding(padding: edgeDefault, child: chart(accelerometerData1, (datum, _) => datum.x))),
          Expanded(child: Padding(padding: edgeDefault, child: chart(accelerometerData2, (datum, _) => datum.y))),
          Expanded(child: Padding(padding: edgeDefault, child: chart(accelerometerData3, (datum, _) => datum.z))),
          Expanded(child: Padding(padding: edgeDefault, child: chart(accelerometerData4, (datum, _) => datum.norm)))
        ]);
  }

  SfCartesianChart chart(List<Accelerometer> accelerometerData, ChartValueMapper<Accelerometer, num> yValueMapper) {
    return SfCartesianChart(
      series: <LineSeries<Accelerometer, int>>[
        LineSeries<Accelerometer, int>(
          onRendererCreated: (ChartSeriesController controller) {
            chartDataTupleList.add(Tuple2(controller, accelerometerData));
          },
          dataSource: accelerometerData,
          xValueMapper: (datum, _) => datum.seq,
          yValueMapper: yValueMapper,
        ),
      ],
    );
  }
}
