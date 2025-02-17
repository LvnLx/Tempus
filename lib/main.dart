import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/shared_preferences_service.dart';
import 'package:tempus/data/services/purchases_service.dart';
import 'package:tempus/ui/mixer/mixer.dart';
import 'package:tempus/ui/deck/deck.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SharedPreferencesService appState = SharedPreferencesService();

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
      await Provider.of<SharedPreferencesService>(context, listen: false).loadPreferences();
      await PurchasesService.initPurchases();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: FutureBuilder(
        future: initializeAppState(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return PlatformProvider(
                builder: (context) => PlatformTheme(
                      themeMode: Provider.of<SharedPreferencesService>(context).getThemeMode(),
                      materialDarkTheme: darkThemeData,
                      materialLightTheme: lightThemeData,
                      builder: (context) => PlatformApp(
                          debugShowCheckedModeBanner: false,
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
                                  Expanded(child: Mixer()),
                                  Divider(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface),
                                  Expanded(child: Deck())
                                ],
                              )))),
                    ));
          } else {
            return Card(
                child: Center(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: PlatformCircularProgressIndicator(
                            material: (context, platform) =>
                                MaterialProgressIndicatorData(
                                    color:
                                        lightThemeData.colorScheme.primary)))));
          }
        },
      ),
    );
  }
}

final ThemeData lightThemeData = ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary: Color.fromRGBO(31, 31, 31, 1.0),
        onPrimary: Colors.white,
        secondary: Color.fromRGBO(147, 147, 147, 1.0),
        onSecondary: Color.fromRGBO(31, 31, 31, 1.0),
        error: Colors.red,
        onError: Color.fromRGBO(31, 31, 31, 1.0),
        surface: Colors.white,
        onSurface: Color.fromRGBO(211, 211, 211, 1.0)));

final ThemeData darkThemeData = ThemeData(
    colorScheme: ColorScheme(
        brightness: Brightness.dark,
        primary: Colors.white,
        onPrimary: Color.fromRGBO(31, 31, 31, 1.0),
        secondary: Color.fromRGBO(112, 112, 112, 1.0),
        onSecondary: Colors.white,
        error: Colors.red,
        onError: Colors.white,
        surface: Color.fromRGBO(31, 31, 31, 1.0),
        onSurface: Color.fromRGBO(64, 64, 64, 1.0)));
