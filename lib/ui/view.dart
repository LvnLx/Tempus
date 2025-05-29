import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/device_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/tap_tempo_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/ui/clock/view.dart';
import 'package:tempus/ui/clock/view_model.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/deck/view.dart';
import 'package:tempus/ui/deck/view_model.dart';
import 'package:tempus/ui/mixer/view.dart';
import 'package:tempus/ui/mixer/view_model.dart';
import 'package:tempus/ui/settings/view_model.dart';
import 'package:tempus/ui/view_model.dart';

class Main extends StatelessWidget {
  const Main({super.key});

  Future<void> initializeProviders(BuildContext context) async {
    try {
      await context.read<AssetService>().init();
      // ignore: use_build_context_synchronously
      await context.read<DeviceService>().init();
      // ignore: use_build_context_synchronously
      await context.read<PreferenceService>().init();
      // ignore: use_build_context_synchronously
      await context.read<AudioService>().init();
      // ignore: use_build_context_synchronously
      await context.read<PurchaseService>().init();
      // ignore: use_build_context_synchronously
      await context.read<ThemeService>().init();
      // ignore: use_build_context_synchronously
      await context.read<DeckViewModel>().init();
    } catch (error) {
      print(error);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) => Material(
          child: MultiProvider(
              providers: [
            Provider(create: (_) => AssetService()),
            Provider(create: (_) => DeviceService()),
            Provider(
                create: (context) =>
                    PreferenceService(context.read<AssetService>())),
            Provider(
                create: (context) => AudioService(context.read<AssetService>(),
                    context.read<PreferenceService>())),
            Provider(
                create: (context) =>
                    PurchaseService(context.read<PreferenceService>())),
            Provider(
                create: (context) =>
                    TapTempoService(context.read<AudioService>())),
            Provider(
                create: (context) =>
                    ThemeService(context.read<PreferenceService>())),
            ChangeNotifierProvider(
                create: (context) => ClockViewModel(
                    context.read<AudioService>(),
                    context.read<PurchaseService>(),
                    context.read<TapTempoService>())),
            ChangeNotifierProvider(
                create: (context) => DeckViewModel(context.read<AudioService>(),
                    context.read<TapTempoService>())),
            ChangeNotifierProvider(
                create: (context) =>
                    MainViewModel(context.read<ThemeService>())),
            ChangeNotifierProvider(
                create: (context) => MixerViewModel(
                    context.read<AudioService>(),
                    context.read<PurchaseService>())),
            ChangeNotifierProvider(
                create: (context) => SettingsViewModel(
                    context.read<AssetService>(),
                    context.read<AudioService>(),
                    context.read<DeviceService>(),
                    context.read<PreferenceService>(),
                    context.read<PurchaseService>(),
                    context.read<ThemeService>()))
          ],
              builder: (context, child) => FutureBuilder(
                  future: initializeProviders(context),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return PlatformProvider(
                          builder: (context) => PlatformTheme(
                                themeMode:
                                    context.watch<MainViewModel>().themeMode,
                                materialDarkTheme:
                                    context.read<MainViewModel>().darkThemeData,
                                materialLightTheme: context
                                    .read<MainViewModel>()
                                    .lightThemeData,
                                builder: (context) => PlatformApp(
                                    debugShowCheckedModeBanner: false,
                                    localizationsDelegates: <LocalizationsDelegate<
                                        dynamic>>[
                                      DefaultMaterialLocalizations.delegate,
                                      DefaultWidgetsLocalizations.delegate,
                                      DefaultCupertinoLocalizations.delegate,
                                    ],
                                    home: Container(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .surface,
                                        child: SafeArea(
                                            child: Column(
                                          children: [
                                            Expanded(flex: 6, child: Mixer()),
                                            ThemedDivider(
                                                orientation: Axis.horizontal),
                                            Expanded(child: Clock()),
                                            ThemedDivider(
                                                orientation: Axis.horizontal),
                                            Expanded(flex: 6, child: Deck())
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
                                                  .read<MainViewModel>()
                                                  .lightThemeData
                                                  .colorScheme
                                                  .primary)))));
                    }
                  })));
}
