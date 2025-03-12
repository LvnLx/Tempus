import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:tempus/domain/models/sample_set.dart';
import 'package:tempus/ui/home/deck/settings/sample_settings/view_model.dart';
import 'package:tempus/ui/home/deck/settings/view.dart';
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
              tiles: context
                  .watch<SampleSettingsViewModel>()
                  .sampleSets
                  .where((sampleSet) => !sampleSet.isPremium)
                  .map((sampleSet) =>
                      getSampleSetSettingsTiles(context, sampleSet, true))
                  .toList(),
            ),
            SettingsSection(
                title: Text("Premium"),
                tiles: context
                    .watch<SampleSettingsViewModel>()
                    .sampleSets
                    .where((sampleSet) => sampleSet.isPremium)
                    .map((sampleSet) =>
                        getSampleSetSettingsTiles(context, sampleSet, false))
                    .toList())
          ]),
    );
  }

  SettingsTile getSampleSetSettingsTiles(
      BuildContext context, SampleSet sampleSet, bool isFree) {
    return SettingsTile(
        enabled: isFree || context.watch<SampleSettingsViewModel>().isPremium,
        title: Text(capitalizeFirst(sampleSet.name)),
        trailing: () {
          SampleSet activeSampleSet =
              context.watch<SampleSettingsViewModel>().sampleSet;
          if (activeSampleSet.name == sampleSet.name &&
              activeSampleSet.isPremium == sampleSet.isPremium) {
            return Icon(PlatformIcons(context).checkMark);
          } else {
            return null;
          }
        }(),
        onPressed: (context) async => await context
            .read<SampleSettingsViewModel>()
            .setSampleSets(sampleSet));
  }
}
