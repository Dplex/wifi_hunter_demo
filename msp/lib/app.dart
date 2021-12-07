import 'package:flutter/material.dart';
import 'package:msp/ui/map_list.dart';
import 'package:msp/ui/position_list.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('MSP'),
            bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.loop)),
              Tab(icon: Icon(Icons.map))
            ]),
          ),
          body: TabBarView(children: [PositionList()..init(), MapList()]),
        ),
      ),
      // home: Scaffold(
      //   body: PositionList()..init(),
      // ),
    );
  }
}
