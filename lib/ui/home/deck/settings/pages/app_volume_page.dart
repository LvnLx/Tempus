import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:tempus/ui/core/themed_slider.dart';

class AppVolumePage extends StatelessWidget {
  final double appVolume;
  final SettingsThemeData Function(BuildContext context) getSettingsThemeData;
  final Future<void> Function(double volume) setAppVolume;

  const AppVolumePage(
      {super.key,
      required this.appVolume,
      required this.getSettingsThemeData,
      required this.setAppVolume});

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
          leading: PlatformIconButton(
              icon: Icon(PlatformIcons(context).leftChevron,
                  color: Theme.of(context).colorScheme.primary),
              onPressed: () => Navigator.pop(context)),
          title: Text("Set the app's volume",
              style: TextStyle(color: Theme.of(context).colorScheme.primary))),
      body: SettingsList(
          applicationType: ApplicationType.both,
          darkTheme: getSettingsThemeData(context),
          lightTheme: getSettingsThemeData(context),
          sections: [
            SettingsSection(title: Text("App volume"), tiles: [
              SettingsTile(
                title: LayoutBuilder(
                  builder: (_, constraints) => SizedBox(
                    width: constraints.maxWidth * 0.95,
                    child: ThemedSlider(
                        value: appVolume,
                        onChanged: (value) => setAppVolume(value)),
                  ),
                ),
                description: Text(
                    "Affects all audio from the app, but is separate from your device's settings. This setting can be useful when multiple apps are playing audio at the same time"),
                trailing: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 17,
                        color: getSettingsThemeData(context).trailingTextColor),
                    child: FittedBox(
                      child: Text("${(appVolume * 100).round()}%"),
                    )),
              )
            ])
          ]));
}
