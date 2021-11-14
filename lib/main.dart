import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:wifi_hunter/wifi_hunter.dart';
import 'package:wifi_hunter/wifi_hunter_result.dart';
import 'package:sensors/sensors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  WiFiHunterResult wiFiHunterResult = WiFiHunterResult();
  WiFiHunterResult presentResult = WiFiHunterResult();
  Color huntButtonColor = Colors.lightBlue;
  String? text;
  String? text2;
  String? text3;
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
        } on PlatformException catch (exception) {
          print(exception.toString());
        }
      }

    if (!mounted) return;

    setState(() => huntButtonColor = Colors.lightBlue);
  }

  @override
  void initState() {
    FlutterCompass.events!.listen((event) {
      setState(() {
        text = '${(event.heading! + 180).toInt()}°';
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
            tabs: [
              Tab(text: 'tt'),
              Tab(text: 'wer',)
            ],
          ),
        ),
        body: TabBarView(
          children: [
            SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
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

    // return MaterialApp(
    //   home: Scaffold(
    //     appBar: AppBar(
    //       title: const Text('JHR Test compass & wifiHunter'),
    //     ),
    //     body: SingleChildScrollView(
    //       scrollDirection: Axis.vertical,
    //       physics: const BouncingScrollPhysics(),
    //       child: Column(
    //         mainAxisAlignment: MainAxisAlignment.center,
    //         crossAxisAlignment: CrossAxisAlignment.center,
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           Container(
    //             margin: const EdgeInsets.symmetric(vertical: 20.0),
    //             child: ElevatedButton(
    //                 style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(huntButtonColor)),
    //                 onPressed: () => huntWiFis(),
    //                 child: const Text('Hunt Networks')
    //             ),
    //           ),
    //           text != null? Container(
    //             child: Text(text!),
    //           ) : Container(),
    //           text2 != null? Container(
    //             child: Text(text2!),
    //           ) : Container(),
    //           text3 != null? Container(
    //             child: Text(text3!),
    //           ) : Container(),
    //           wiFiHunterResult.results.isNotEmpty ? Container(
    //             margin: const EdgeInsets.only(bottom: 20.0, left: 30.0, right: 30.0),
    //             child: Column(
    //                 mainAxisAlignment: MainAxisAlignment.center,
    //                 crossAxisAlignment: CrossAxisAlignment.center,
    //                 mainAxisSize: MainAxisSize.min,
    //                 children: List.generate(wiFiHunterResult.results.length, (index) =>
    //                     Container(
    //                       margin: const EdgeInsets.symmetric(vertical: 10.0),
    //                       child: ListTile(
    //                           leading: Text(wiFiHunterResult.results[index].level.toString() + ' dbm'),
    //                           title: Text(wiFiHunterResult.results[index].SSID),
    //                           subtitle: Column(
    //                               mainAxisAlignment: MainAxisAlignment.start,
    //                               crossAxisAlignment: CrossAxisAlignment.start,
    //                               mainAxisSize: MainAxisSize.min,
    //                               children: [
    //                                 Text('BSSID : ' + wiFiHunterResult.results[index].BSSID),
    //                                 Text('Frequency : ' + wiFiHunterResult.results[index].frequency.toString()),
    //                                 Text('Timestamp : ' + wiFiHunterResult.results[index].timestamp.toString())
    //                               ]
    //                           )
    //                       ),
    //                     )
    //                 )
    //             ),
    //           ) : Container()
    //         ],
    //       ),
    //     ),
    //   ),
    // );
  }
}
