import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:msp/ui/map_list.dart';
import 'package:msp/ui/sensor_list.dart';
import 'package:msp/ui/setting_list.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

    return MaterialApp(
        builder: BotToastInit(),
        theme: ThemeData.dark(),
        home: DefaultTabController(
          length: 3,
          child: WillPopScope(
            onWillPop: () {
              return Future.value(false);
            },
            child: Scaffold(
              appBar: AppBar(
                title: const Text('MSP - Particle Filter'),
                bottom: const TabBar(
                    tabs: [Tab(icon: Icon(Icons.loop)), Tab(icon: Icon(Icons.map)), Tab(icon: Icon(Icons.settings))]),
              ),
              body: TabBarView(physics: const NeverScrollableScrollPhysics(), children: [PositionList(), MapList(), SettingList()]),
            ),
          ),
        ));
  }
}
