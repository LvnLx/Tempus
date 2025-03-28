import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/asset_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/device_service.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/data/services/purchase_service.dart';
import 'package:tempus/data/services/theme_service.dart';
import 'package:tempus/ui/deck/settings/view_model.dart';
import 'package:tempus/ui/deck/view_model.dart';
import 'package:tempus/ui/mixer/view_model.dart';
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
                  ThemeService(context.read<PreferenceService>())),
          ChangeNotifierProvider(
              create: (context) => DeckViewModel(context.read<AudioService>(),
                  context.read<PurchaseService>())),
          ChangeNotifierProvider(
              create: (context) => HomeViewModel(
                  context.read<AudioService>(),
                  context.read<DeviceService>(),
                  context.read<PreferenceService>(),
                  context.read<ThemeService>())),
          ChangeNotifierProvider(
              create: (context) => MixerViewModel(context.read<AudioService>(),
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
        builder: (context, child) => Home(),
      ),
    );
  }
}
