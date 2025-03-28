import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';

class ThemeSettingsPage extends StatelessWidget {
  final void Function(ThemeMode themeMode) setThemeMode;
  final SettingsThemeData Function(BuildContext context) getSettingsThemeData;
  final ThemeMode themeMode;

  const ThemeSettingsPage(
      {super.key,
      required this.setThemeMode,
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
                    onPressed: (_) async => setThemeMode(ThemeMode.system)),
                SettingsTile(
                    title: Text("Light"),
                    trailing: themeMode == ThemeMode.light
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async =>
                        setThemeMode(ThemeMode.light)),
                SettingsTile(
                    title: Text("Dark"),
                    trailing: themeMode == ThemeMode.dark
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async => setThemeMode(ThemeMode.dark)),
              ],
            ),
          ],
        ));
  }
}
