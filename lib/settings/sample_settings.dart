import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/settings/settings.dart';
import 'package:tempus/util.dart';

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
              tiles: Sample.values
                  .map((sample) => SettingsTile(
                        title: Text(capitalizeFirst(sample.name)),
                        trailing: sampleSetting.getSample(context) == sample
                            ? Icon(PlatformIcons(context).checkMark)
                            : null,
                        onPressed: (context) async =>
                            sampleSetting.setSample(context, sample),
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

  Sample getSample(BuildContext context) {
    final AppState provider = Provider.of<AppState>(context);
    switch (this) {
      case SampleSetting.downbeat:
        return provider.getDownbeatSample();
      case SampleSetting.subdivision:
        return provider.getSubdivisionSample();
    }
  }

  Future<void> setSample(BuildContext context, Sample sample) async {
    final AppState provider = Provider.of<AppState>(context, listen: false);
    switch (this) {
      case SampleSetting.downbeat:
        await provider.setDownbeatSample(sample);
        await Audio.setSample(true, sample);
      case SampleSetting.subdivision:
        await provider.setSubdivisionSample(sample);
        await Audio.setSample(false, sample);
    }
  }
}
