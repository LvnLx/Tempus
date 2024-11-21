import 'package:flutter/cupertino.dart';
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
    return PlatformProvider(
        builder: (context) => PlatformTheme(
              themeMode: ThemeMode.system,
              materialDarkTheme: ThemeData(
                  colorScheme: ColorScheme(
                      brightness: Brightness.dark,
                      primary: Colors.white,
                      onPrimary: Color.fromRGBO(31, 31, 31, 1.0),
                      secondary: Color.fromRGBO(112, 112, 112, 1.0),
                      onSecondary: Colors.white, 
                      error: Colors.red,
                      onError: Colors.white,
                      surface: Color.fromRGBO(31, 31, 31, 1.0),
                      onSurface: Color.fromRGBO(64, 64, 64, 1.0))),
              materialLightTheme: ThemeData(
                  colorScheme: ColorScheme(
                      brightness: Brightness.light,
                      primary: Color.fromRGBO(31, 31, 31, 1.0),
                      onPrimary: Colors.white,
                      secondary: Color.fromRGBO(147, 147, 147, 1.0),
                      onSecondary: Color.fromRGBO(31, 31, 31, 1.0),
                      error: Colors.red,
                      onError: Color.fromRGBO(31, 31, 31, 1.0),
                      surface: Colors.white,
                      onSurface: Color.fromRGBO(211, 211, 211, 1.0))),
              builder: (context) => PlatformApp(
                  home: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: SafeArea(
                          child: Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(child: SubdivisionController()),
                          Divider(
                              color: Theme.of(context).colorScheme.onSurface),
                          Expanded(child: PlaybackController())
                        ],
                      )))),
            ));
  }
}
