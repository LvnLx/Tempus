import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:tempus/domain/models/sample_set.dart';
import 'package:tempus/domain/util.dart';

class SampleSetPage extends StatelessWidget {
  final SettingsThemeData Function(BuildContext context) getSettingsThemeData;
  final bool isPremium;
  final SampleSet sampleSet;
  final List<SampleSet> sampleSets;
  final Future<void> Function(SampleSet sampleSet) setSampleSet;

  const SampleSetPage(
      {super.key,
      required this.getSettingsThemeData,
      required this.isPremium,
      required this.sampleSet,
      required this.sampleSets,
      required this.setSampleSet});

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
        title: Text("Select a sample set",
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
              tiles: sampleSets
                  .where((sampleSet) => !sampleSet.isPremium)
                  .map((sampleSet) =>
                      getSampleSetSettingsTile(context, sampleSet, true))
                  .toList(),
            ),
            SettingsSection(
                title: Text("Premium"),
                tiles: sampleSets
                    .where((sampleSet) => sampleSet.isPremium)
                    .map((sampleSet) =>
                        getSampleSetSettingsTile(context, sampleSet, false))
                    .toList())
          ]),
    );
  }

  SettingsTile getSampleSetSettingsTile(
          BuildContext context, SampleSet currentSampleSet, bool isFree) =>
      SettingsTile(
          enabled: isFree || isPremium,
          title: Text(capitalizeFirst(currentSampleSet.name)),
          trailing: () {
            SampleSet activeSampleSet = sampleSet;
            if (activeSampleSet.name == currentSampleSet.name &&
                activeSampleSet.isPremium == currentSampleSet.isPremium) {
              return Icon(PlatformIcons(context).checkMark);
            } else {
              return null;
            }
          }(),
          onPressed: (context) async => await setSampleSet(currentSampleSet));
}
