import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/ui/home/deck/settings/app_volume_settings/view_model.dart';
import 'package:tempus/ui/home/deck/settings/sample_settings/view_model.dart';
import 'package:tempus/ui/home/deck/settings/theme_settings/view_model.dart';
import 'package:tempus/ui/home/deck/settings/view_model.dart';
import 'package:tempus/ui/home/deck/view_model.dart';
import 'package:tempus/ui/home/mixer/channel/view_model.dart';
import 'package:tempus/ui/home/mixer/view_model.dart';
import 'package:tempus/ui/home/view.dart';
import 'package:tempus/ui/home/view_model.dart';

void main() async {
  runApp(Main());
}

class Main extends StatelessWidget {
  Main({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      child: MultiProvider(
        providers: [
          Provider(create: (_) => AssetService()),
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
                  ThemeService(context.read<PreferenceService>())),
          ChangeNotifierProvider(
              create: (context) =>
                  AppVolumeSettingsViewModel(context.read<AudioService>())),
          ChangeNotifierProvider(
              create: (context) =>
                  ChannelViewModel(context.read<AudioService>())),
          ChangeNotifierProvider(
              create: (context) => DeckViewModel(context.read<AudioService>())),
          ChangeNotifierProvider(
              create: (context) => HomeViewModel(context.read<ThemeService>())),
          ChangeNotifierProvider(
              create: (context) => MixerViewModel(context.read<AudioService>(),
                  context.read<PurchaseService>())),
          ChangeNotifierProvider(
              create: (context) => SampleSettingsViewModel(
                  context.read<AssetService>(),
                  context.read<AudioService>(),
                  context.read<PurchaseService>())),
          ChangeNotifierProvider(
              create: (context) => SettingsViewModel(
                  context.read<AudioService>(),
                  context.read<PurchaseService>(),
                  context.read<ThemeService>())),
          ChangeNotifierProvider(
              create: (context) =>
                  ThemeSettingsViewModel(context.read<ThemeService>()))
        ],
        builder: (context, child) => Home(),
      ),
    );
  }
}
