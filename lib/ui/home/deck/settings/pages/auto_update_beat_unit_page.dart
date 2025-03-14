import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class AutoUpdateBeatUnitPage extends StatelessWidget {
  final Future<void> Function(bool updatedValue) setAutoUpdateBeatUnit;
  final bool initialValue;
  final SettingsThemeData Function(BuildContext context) getSettingsThemeData;

  const AutoUpdateBeatUnitPage(
      {super.key,
      required this.setAutoUpdateBeatUnit,
      required this.initialValue,
      required this.getSettingsThemeData});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          title: Text("Toggle auto updating",
              style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          leading: PlatformIconButton(
              icon: Icon(PlatformIcons(context).leftChevron),
              onPressed: () => Navigator.pop(context))),
      body: SettingsList(
          applicationType: ApplicationType.both,
          darkTheme: getSettingsThemeData(context),
          lightTheme: getSettingsThemeData(context),
          sections: [
            SettingsSection(title: Text("Beat unit"), tiles: [
              SettingsTile.switchTile(
                title: PlatformText("Auto update"),
                description: Text(
                    "Automatically updates the beat unit to the best matching option for the given time signature. For example, a time signature change to 6/8 would automatically update the beat unit to a dotted quarter note"),
                initialValue: initialValue,
                onToggle: (value) async => await setAutoUpdateBeatUnit(value),
              ),
            ])
          ]));
}
