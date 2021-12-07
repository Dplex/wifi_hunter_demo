import 'package:flutter/material.dart';
import 'package:msp/blocs/compass_bloc.dart';
import 'package:msp/blocs/particle_bloc.dart';
import 'package:msp/models/particle.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:tuple/tuple.dart';

class PositionList extends StatelessWidget {

  final List<Particle> particleData1 = [];
  final List<Particle> particleData2 = [];
  final List<Particle> particleData3 = [];
  final List<Particle> particleData4 = [];
  final List<Tuple2<ChartSeriesController, List<Particle>>> chartDataTupleList = [];

  void init() {
    try {
      particleBloc.listenUserSensor();
      particleBloc.allParticle.listen(dataListen);
    } catch (e) {}
  }

  void dataListen(Particle event) {
    if (chartDataTupleList.isEmpty) {
      return;
    }
    for (var element in chartDataTupleList) {
      final controller = element.item1;
      final particleData = element.item2;

      particleData.add(event);
      controller.updateDataSource(
          addedDataIndex: particleData.length - 1
      );

      if (particleData.length > 30) {
        controller.updateDataSource(
            removedDataIndex: 0
        );
        particleData.removeAt(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RotatingWidget(),
          Expanded(child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: chart(particleData1, (datum, _) => datum.sensorX))),
          Expanded(child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: chart(particleData2, (datum, _) => datum.sensorY))),
          Expanded(child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: chart(particleData3, (datum, _) => datum.sensorZ))),
          Expanded(child: Padding(
              padding: const EdgeInsets.all(5.0),
              child: chart(particleData4, (datum, _) => datum.getNorm())))
        ]
    );
  }

  SfCartesianChart chart(
      List<Particle> particleData,
      ChartValueMapper<Particle, num> yValueMapper) {
    return SfCartesianChart(
      series: <LineSeries<Particle, int>>[
        LineSeries<Particle, int>(
          onRendererCreated: (ChartSeriesController controller) {
            chartDataTupleList.add(Tuple2(controller, particleData));
          },
          dataSource: particleData,
          xValueMapper: (datum, _) => datum.seq,
          yValueMapper: yValueMapper,
        ),
      ],
    );
  }
}

class RotatingWidget extends StatefulWidget {

  @override
  _RotatingWidgetState createState() => _RotatingWidgetState();
}

class _RotatingWidgetState extends State<RotatingWidget> {
  int turns = 0;
  bool isActive = false;
  @override
  void dispose() {
    isActive = false;
    try {
      compassBloc.stream.listen(null);
      compassBloc.dispose();
    } catch(exception) {}
    super.dispose();
  }

  @override
  void initState() {
    isActive = true;
    try {
      compassBloc.startListenCompass();
      compassBloc.stream.listen((event) {
        if (isActive) {
          setState(() => turns = event);
        }
      });
    } catch(exception) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return  Center(
        child: Transform.rotate(
            angle: turns * 3.14 / 180,
            child: IconButton(
              iconSize: 36,
              icon: const Icon(Icons.arrow_upward_sharp),
              onPressed: () {
                compassBloc.calibrate(turns);
              },
            )
        )
    );
  }
}
