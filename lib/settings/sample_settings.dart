import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/settings/settings.dart';

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
                  .map((samplePair) => SettingsTile(
                      title: Text(samplePair.name),
                      trailing:
                          Provider.of<AppState>(context).getSamplePair().name ==
                                  samplePair.name
                              ? Icon(PlatformIcons(context).checkMark)
                              : null,
                      onPressed: (context) async {
                        await Provider.of<AppState>(context, listen: false)
                            .setSamplePair(samplePair);
                        await Audio.setSample(true, samplePair.downbeatSample);
                        await Audio.setSample(
                            false, samplePair.subdivisionSample);
                      }))
                  .toList(),
            ),
            SettingsSection(
              title: Text("Premium"),tiles: [
              SettingsTile(
                title: Text("Coming soon"),
                enabled: false,
              )
            ])
          ]),
    );
  }
}
