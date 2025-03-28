import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class HapticsPage extends StatelessWidget {
  final bool beatHaptics;
  final bool downbeatHaptics;
  final bool innerBeatHaptics;
  final SettingsThemeData Function(BuildContext context) getSettingsThemeData;
  final Future<void> Function(bool value) setBeatHaptics;
  final Future<void> Function(bool value) setDownbeatHaptics;
  final Future<void> Function(bool value) setInnerBeatHaptics;

  const HapticsPage(
      {super.key,
      required this.getSettingsThemeData,
      required this.beatHaptics,
      required this.downbeatHaptics,
      required this.innerBeatHaptics,
      required this.setBeatHaptics,
      required this.setDownbeatHaptics,
      required this.setInnerBeatHaptics});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        leading: PlatformIconButton(
          icon: Icon(
            PlatformIcons(context).leftChevron,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Manage haptics",
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
            title: Text("Haptics"),
            tiles: [
              SettingsTile.switchTile(
                  title: Text("Beat"),
                  initialValue: beatHaptics,
                  onToggle: (value) async => await setBeatHaptics(value)),
              SettingsTile.switchTile(
                  title: Text("Downbeat"),
                  initialValue: downbeatHaptics,
                  onToggle: (value) async => await setDownbeatHaptics(value)),
              SettingsTile.switchTile(
                  title: Text("Inner beat"),
                  initialValue: innerBeatHaptics,
                  onToggle: (value) async => await setInnerBeatHaptics(value)),
            ],
          ),
        ],
      ));
}
