import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:metronomic/subdivision/subdivisionController.dart';
import 'package:metronomic/playback/playbackController.dart';

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
          child: OrientationBuilder(
            builder: (context, orientation) {
              return Flex(
                direction: orientation == Orientation.portrait
                    ? Axis.vertical
                    : Axis.horizontal,
                children: [
                  Expanded(child: SubdivisionController()),
                  orientation == Orientation.portrait
                      ? Divider(
                          color: Color.fromRGBO(60, 60, 60, 1.0),
                        )
                      : VerticalDivider(),
                  Expanded(child: PlaybackController())
                ],
              );
            },
          ),
        ),
      ),
    ));
  }
}
