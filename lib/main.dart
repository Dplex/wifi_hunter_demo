import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:pedometer/pedometer.dart';
import 'package:wifi_hunter_demo/rest.dart';
import 'package:http/http.dart' as http;


void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = '?', _steps = '?';
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  WiFiHunterResult presentResult = WiFiHunterResult();
  Color huntButtonColor = Colors.lightBlue;
  String? text;
  String? text2;
  String? text3;
  Map? response1;
  Map? response2;
  Map? response3;
  final textController01 = TextEditingController();
  final textController02 = TextEditingController();
  final textController1 = TextEditingController();
  final textController2 = TextEditingController();
  final textController3 = TextEditingController();
  int test = 0;
  double currentDegree = 0;
  double calibrationDegree = 0;
  late TabController tabController;
  String url = '';
  bool isHunt = false;
  String huntButtonString = 'Start Network Hunt';
  late Timer timer = Timer.periodic(Duration(days: 1), (timer) { });
  Future<void> huntWiFis() async {
    if (huntButtonColor == Colors.red) {
      isHunt = false;
      setState(() {
        huntButtonColor = Colors.green;
        huntButtonString = 'Start Network Hunt';
        presentResult.results = <WiFiHunterResultEntry>[];
      });
      return;
    }
    setState(() {
      huntButtonColor = Colors.red;
      huntButtonString = 'Stop Network Hunt';
    });
    isHunt = true;
    WiFiHunterResult temp = WiFiHunterResult();
    while(isHunt) {
      try {
        temp = (await WiFiHunter.huntWiFiNetworks)!;
        if (!isHunt)
          break;
        setState(() {
          temp.results.sort((a, b) => b.level - a.level);
          presentResult.results = temp.results.sublist(0, temp.results.length > 3 ? 3 : temp.results.length);
          wiFiHunterResult = temp;
        });
        http.Response response = await sendFingerprint(textController01.text, wiFiHunterResult.results, textController02.text);
        print(response);
      } on PlatformException catch (exception) {
        print(exception.toString());
      }
    }
    presentResult.results = <WiFiHunterResultEntry>[];
  }

  void wifiStatistics() {
    dashboard1(textController1.text, textController2.text).then((value) => setState(() => response1 = value));
  }

  void currentWifi() {
    dashboard2().then((value) => setState(() => response2 = value));
  }

  void fingerPrintStatistics() {
    dashboard3(textController3.text).then((value) => setState(() => response3 = value));
  }

  void calibration() {
    calibrationDegree = currentDegree;
  }
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      print(tabController.index);
      if (tabController.index == 1) {
        timer.cancel();
      }
    });
    FlutterCompass.events!.listen((event) {
      setState(() {
        currentDegree = event.heading!;
        text = '${(event.heading! - calibrationDegree + 360).toInt().remainder(360)}°';
      });
    });
    super.initState();
    initPlatformState();
  }

  void onStepCount(StepCount event) {
    print(event);
    setState(() {
      _steps = event.steps.toString();
    });
  }

  void onPedestrianStatusChanged(PedestrianStatus event) {
    print(event);
    setState(() {
      _status = event.status;
    });
  }

  void onPedestrianStatusError(error) {
    print('onPedestrianStatusError: $error');
    setState(() {
      _status = 'Pedestrian Status not available';
    });
    print(_status);
  }

  void onStepCountError(error) {
    print('onStepCountError: $error');
    setState(() {
      _steps = 'Step Count not available';
    });
  }

  void initPlatformState() {
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;
    _pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
        .onError(onPedestrianStatusError);

    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(onStepCount).onError(onStepCountError);

    if (!mounted) return;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            controller: tabController,
            tabs: [
              Tab(text: 'WIFI FINGERPRINT'),
              Tab(text: 'API',)
            ],
          ),
        ),
        body: TabBarView(
          controller: tabController,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton(onPressed: () => calibration(), child: const Text('Calibration')),
                  text != null? Container(
                    child: Text(text!),
                  ) : Container(),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Steps taken:',
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          _steps,
                          style: TextStyle(fontSize: 10),
                        ),
                        Text(
                          'Pedestrian status:',
                          style: TextStyle(fontSize: 10),
                        ),
                        Icon(
                          _status == 'walking'
                              ? Icons.directions_walk
                              : _status == 'stopped'
                              ? Icons.accessibility_new
                              : Icons.error,
                          size: 20,
                        ),
                        Center(
                          child: Text(
                            _status,
                            style: _status == 'walking' || _status == 'stopped'
                                ? TextStyle(fontSize: 30)
                                : TextStyle(fontSize: 20, color: Colors.red),
                          ),
                        )
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Row(
                      children: [
                        SizedBox(width: 100, child: TextField(controller: textController01, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'location id'))),
                        Icon(Icons.margin),
                        SizedBox(width: 100, child: TextField(controller: textController02, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'refPoint'))),
                        ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(huntButtonColor)),
                            onPressed: () => huntWiFis(),
                            child: Text(huntButtonString)
                        ),
                      ],
                    ),

                  ),

                  text2 != null? Container(
                    child: Text(text2!),
                  ) : Container(),
                  text3 != null? Container(
                    child: Text(text3!),
                  ) : Container(),
                  presentResult.results.isNotEmpty ? Container(
                    margin: const EdgeInsets.only(bottom: 20.0, left: 30.0, right: 30.0),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(presentResult.results.length, (index) =>
                            Container(
                              margin: const EdgeInsets.symmetric(vertical: 10.0),
                              child: ListTile(
                                  leading: Text(presentResult.results[index].level.toString() + ' dbm'),
                                  title: Text(presentResult.results[index].SSID),
                                  subtitle: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text('BSSID : ' + presentResult.results[index].BSSID),
                                        Text('Frequency : ' + presentResult.results[index].frequency.toString()),
                                        Text('Timestamp : ' + presentResult.results[index].timestamp.toString())
                                      ]
                                  )
                              ),
                            )
                        )
                    ),
                  ) : Container()
                ],
              ),
            ),
            Column(
              children: [
                Icon(Icons.account_box),
                Row(
                  children: [
                    SizedBox(width: 100, child: TextField(controller: textController1, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'location id'))),
                    Icon(Icons.control_point),
                    SizedBox(width: 100, child: TextField(controller: textController2, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'refPoint'))),
                    ElevatedButton(onPressed: () => wifiStatistics(), child: const Text('ref_point의 wifi 정보'),),
                  ],
                ),
                Text(response1.toString()),
                ElevatedButton(onPressed: () => currentWifi(), child: const Text('Current Wifi Status')),
                Text(response2.toString()),
                Row(
                    children: [
                      SizedBox(width: 100, child: TextField(controller: textController3, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'location id'))),
                      ElevatedButton(onPressed: () => fingerPrintStatistics(), child: const Text('fingerprint 수집현황'),),
                    ]
                ),
                Text(response3.toString()),
              ],
            )
          ],
        ),
      ),
    ),
    );
  }
}
