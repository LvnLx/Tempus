import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomical/subdivision/subdivision_controller.dart';
import 'package:metronomical/playback/playback_controller.dart';

void main() async {
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: PlatformApp(
          home: Container(
              color: Color.fromRGBO(30, 30, 30, 1.0),
              child: SafeArea(
                  child: Flex(
                direction: Axis.vertical,
                children: [
                  Expanded(child: SubdivisionController()),
                  Divider(color: Color.fromRGBO(60, 60, 60, 1.0)),
                  Expanded(child: PlaybackController())
                ],
              )))),
    );
  }
}
