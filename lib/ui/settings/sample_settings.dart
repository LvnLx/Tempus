import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/shared_preferences_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/ui/settings/settings.dart';
import 'package:tempus/util.dart';

class SampleSettings extends StatelessWidget {
  const SampleSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PlatformIconButton(
          icon: Icon(
            PlatformIcons(context).leftChevron,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Select a sample",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
      body: SettingsList(
          applicationType: ApplicationType.both,
          darkTheme: getSettingsThemeData(context),
          lightTheme: getSettingsThemeData(context),
          sections: [
            SettingsSection(
              title: Text("Free"),
              tiles: samplePairs
                  .where((samplePair) => !samplePair.isPremium)
                  .map((samplePair) =>
                      getSamplePairSettingsTiles(context, samplePair, true))
                  .toList(),
            ),
            SettingsSection(
                title: Text("Premium"),
                tiles: samplePairs
                    .where((samplePair) => samplePair.isPremium)
                    .map((samplePair) =>
                        getSamplePairSettingsTiles(context, samplePair, false))
                    .toList())
          ]),
    );
  }

  SettingsTile getSamplePairSettingsTiles(
      BuildContext context, SamplePair samplePair, bool isFree) {
    return SettingsTile(
        enabled: isFree || Provider.of<SharedPreferencesService>(context).getIsPremium(),
        title: Text(capitalizeFirst(samplePair.name)),
        trailing: () {
          SamplePair activeSamplePair =
              Provider.of<SharedPreferencesService>(context).getSamplePair();
          if (activeSamplePair.name == samplePair.name &&
              activeSamplePair.isPremium == samplePair.isPremium) {
            return Icon(PlatformIcons(context).checkMark);
          } else {
            return null;
          }
        }(),
        onPressed: (context) async {
          await Provider.of<SharedPreferencesService>(context, listen: false)
              .setSamplePair(samplePair);
          await AudioService.setSample(true, samplePair.downbeatSample);
          await AudioService.setSample(false, samplePair.subdivisionSample);
        });
  }
}
