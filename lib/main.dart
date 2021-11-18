import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:sensors/sensors.dart';
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
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  WiFiHunterResult presentResult = WiFiHunterResult();
  Color huntButtonColor = Colors.lightBlue;
  String? text;
  String? text2;
  String? text3;
  double currentDegree = 0;
  double calibrationDegree = 0;
  late TabController tabController;
  String url = 'http://13.124.21.200:8882/save_fingerprint';

  Future<void> huntWiFis() async {
    setState(() => huntButtonColor = Colors.red);

    WiFiHunterResult temp = WiFiHunterResult();
      while(true) {
        try {
          temp = (await WiFiHunter.huntWiFiNetworks)!;
          setState(() {
            temp.results.sort((a, b) => b.level - a.level);
            presentResult.results = temp.results.sublist(0, temp.results.length > 3 ? 3 : temp.results.length);
            wiFiHunterResult = temp;
          });
          http.Response response = await http.post(
              Uri.parse(url),
              headers: {'Content-Type': 'application/json'},
              body: json.encode( {
                'userid': 'test_jhr',
                'locationid': 'jhr',
                'deviceid': 'test_jhr',
                'timestamp': 0,
                'wifi': wiFiHunterResult.results.map((e) => {
                  'mac': e.BSSID,
                  'rssi': e.level,
                  'frequency': e.frequency
                }).toList(),
                'ref_point': '00'
              })
          );
          print(response);
        } on PlatformException catch (exception) {
          print(exception.toString());
        }
      }

    if (!mounted) return;

    setState(() => huntButtonColor = Colors.lightBlue);
  }
  void calibration() {
    calibrationDegree = currentDegree;
  }
  @override
  void initState() {
    tabController = TabController(length: 2, vsync: this);
    tabController.addListener(() {
      print(tabController.index);
    });
    FlutterCompass.events!.listen((event) {
      setState(() {
        currentDegree = event.heading!;
        text = '${(event.heading! - calibrationDegree + 360).toInt().remainder(360)}°';
      });
    });
    accelerometerEvents.listen((event) {
      setState(() {
        text2 = '[AccelerometerEvent (x: ${event.x.toStringAsFixed(2)}, y: ${event.y.toStringAsFixed(2)}, z: ${event.z.toStringAsFixed(2)})]';
      });
    });
    gyroscopeEvents.listen((event) {
      setState(() {
        text3 = '[GyroscopeEvent (x: ${event.x.toStringAsFixed(2)}, y: ${event.y.toStringAsFixed(2)}, z: ${event.z.toStringAsFixed(2)})]';
      });
    });
    super.initState();
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
              Tab(text: 'tt'),
              Tab(text: 'wer',)
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
                      Container(
                        margin: const EdgeInsets.symmetric(vertical: 20.0),
                        child: ElevatedButton(
                            style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(huntButtonColor)),
                            onPressed: () => huntWiFis(),
                            child: const Text('Hunt Networks')
                        ),
                      ),
                      text != null? Container(
                        child: Text(text!),
                      ) : Container(),
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
            Icon(Icons.account_box)
          ],
        ),
      ),
    ),
    );
  }
}
