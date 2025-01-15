import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/settings/settings.dart';

class SampleSettings extends StatelessWidget {
  final SampleSetting sampleSetting;

  const SampleSettings({super.key, required this.sampleSetting});

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
              tiles: sampleNames
                  .map((sampleName) => SettingsTile(
                        title: Text(sampleName.replaceAll("_", " ")),
                        trailing: sampleSetting.getSampleName(context) == sampleName
                            ? Icon(PlatformIcons(context).checkMark)
                            : null,
                        onPressed: (context) async =>
                            sampleSetting.setSampleName(context, sampleName),
                      ))
                  .toList(),
            )
          ]),
    );
  }
}

enum SampleSetting {
  downbeat,
  subdivision;

  String getSampleName(BuildContext context) {
    final AppState provider = Provider.of<AppState>(context);
    switch (this) {
      case SampleSetting.downbeat:
        return provider.getDownbeatSampleName();
      case SampleSetting.subdivision:
        return provider.getSubdivisionSampleName();
    }
  }

  Future<void> setSampleName(BuildContext context, String sampleName) async {
    final AppState provider = Provider.of<AppState>(context, listen: false);
    switch (this) {
      case SampleSetting.downbeat:
        await provider.setDownbeatSampleName(sampleName);
        await Audio.setSample(true, sampleName);
      case SampleSetting.subdivision:
        await provider.setSubdivisionSampleName(sampleName);
        await Audio.setSample(false, sampleName);
    }
  }
}
