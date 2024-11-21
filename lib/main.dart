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
                      onPrimary: Colors.black,
                      secondary: Colors.grey,
                      onSecondary: Colors.white,
                      error: Colors.red,
                      onError: Colors.white,
                      surface: Colors.black,
                      onSurface: Colors.white)),
              materialLightTheme: ThemeData(
                  colorScheme: ColorScheme(
                      brightness: Brightness.light,
                      primary: Colors.black,
                      onPrimary: Colors.white,
                      secondary: Colors.grey,
                      onSecondary: Colors.black,
                      error: Colors.red,
                      onError: Colors.black,
                      surface: Colors.white,
                      onSurface: Colors.black)),
              builder: (context) => PlatformApp(
                  home: Container(
                      color: Theme.of(context).colorScheme.surface,
                      child: SafeArea(
                          child: Flex(
                        direction: Axis.vertical,
                        children: [
                          Expanded(child: SubdivisionController()),
                          Divider(
                              color: Theme.of(context).colorScheme.secondary),
                          Expanded(child: PlaybackController())
                        ],
                      )))),
            ));
  }
}
