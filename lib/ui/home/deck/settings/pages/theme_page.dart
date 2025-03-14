import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class ThemeSettings extends StatelessWidget {
  final Future<void> Function(ThemeMode updatedThemeMode) callback;
  final SettingsThemeData Function(BuildContext context) getSettingsThemeData;
  final ThemeMode themeMode;

  const ThemeSettings(
      {super.key,
      required this.callback,
      required this.getSettingsThemeData,
      required this.themeMode});

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
          title: Text("Select a theme",
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
              tiles: [
                SettingsTile(
                    title: Text("System"),
                    trailing: themeMode == ThemeMode.system
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (_) async => await callback(ThemeMode.system)),
                SettingsTile(
                    title: Text("Light"),
                    trailing: themeMode == ThemeMode.light
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async =>
                        await callback(ThemeMode.light)),
                SettingsTile(
                    title: Text("Dark"),
                    trailing: themeMode == ThemeMode.dark
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async =>
                        await callback(ThemeMode.dark)),
              ],
            ),
          ],
        ));
  }
}
