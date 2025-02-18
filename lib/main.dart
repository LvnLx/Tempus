import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/ui/mixer/view.dart';
import 'package:tempus/ui/deck/view.dart';

void main() async {
  runApp(Main());
}

class Main extends StatelessWidget {
  Main({super.key});

  Future<void> initializeProviders(BuildContext context) async {
    try {
      await context.read<PurchaseService>().init();
      await context.read<PreferenceService>().loadPreferences();
      await context.read<ThemeService>().init();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MultiProvider(
        providers: [
          Provider(create: (_) => AudioService()),
          ChangeNotifierProvider(
              create: (context) =>
                  PreferenceService(context.read<AudioService>())),
          ChangeNotifierProvider(
              create: (context) =>
                  PurchaseService(context.read<PreferenceService>())),
          ChangeNotifierProvider(
              create: (context) =>
                  ThemeService(context.read<PreferenceService>()))
        ],
        builder: (context, child) => FutureBuilder(
          future: initializeProviders(context),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return PlatformProvider(
                  builder: (context) => PlatformTheme(
                        themeMode: context.watch<ThemeService>().themeMode,
                        materialDarkTheme:
                            context.watch<ThemeService>().darkThemeData,
                        materialLightTheme:
                            context.watch<ThemeService>().lightThemeData,
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
                                      color: context
                                          .watch<ThemeService>()
                                          .lightThemeData
                                          .colorScheme
                                          .primary)))));
            }
          },
        ),
      ),
    );
  }
}
