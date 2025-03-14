// ignore_for_file: use_build_context_synchronously

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/ui/home/deck/view.dart';
import 'package:tempus/ui/home/deck/view_model.dart';
import 'package:tempus/ui/home/mixer/view.dart';
import 'package:tempus/ui/home/view_model.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  Future<void> initializeProviders(BuildContext context) async {
    try {
      await context.read<AssetService>().init();
      await context.read<AudioService>().init();
      await context.read<PurchaseService>().init();
      await context.read<ThemeService>().init();
      await context.read<DeckViewModel>().init();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: initializeProviders(context),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return PlatformProvider(
              builder: (context) => PlatformTheme(
                    themeMode: context.watch<HomeViewModel>().themeMode,
                    materialDarkTheme:
                        context.read<HomeViewModel>().darkThemeData,
                    materialLightTheme:
                        context.read<HomeViewModel>().lightThemeData,
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
                                child: Column(
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
                                      .read<HomeViewModel>()
                                      .lightThemeData
                                      .colorScheme
                                      .primary)))));
        }
      },
    );
  }
}
