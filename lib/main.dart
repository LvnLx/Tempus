import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/subdivision/subdivision_controller.dart';
import 'package:tempus/playback/playback_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  AppState appState = AppState();

  runApp(ChangeNotifierProvider(create: (_) => appState, child: Main()));
}

class Main extends StatefulWidget {
  Main({super.key});

  @override
  State<Main> createState() => MainState();
}

class MainState extends State<Main> {

  Future<void> initializeAppState() async {
    try {
      await Provider.of<AppState>(context, listen: false).loadPreferences();
    } catch (error) {
      print(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeAppState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PlatformProvider(
              builder: (context) => PlatformTheme(
                    themeMode: Provider.of<AppState>(context).getThemeMode(),
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
                        localizationsDelegates: <LocalizationsDelegate<
                            dynamic>>[
                          DefaultMaterialLocalizations.delegate,
                          DefaultWidgetsLocalizations.delegate,
                          DefaultCupertinoLocalizations.delegate,
                        ],
                        home: Container(
                            color: Theme.of(context).colorScheme.surface,
                            child: SafeArea(
                                child: Flex(
                              direction: Axis.vertical,
                              children: [
                                Expanded(child: SubdivisionController()),
                                Divider(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface),
                                Expanded(child: PlaybackController())
                              ],
                            )))),
                  ));
        } else {
          return PlatformCircularProgressIndicator();
        }
      },
    );
  }
}
