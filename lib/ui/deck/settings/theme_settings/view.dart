import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/preference_service.dart';
import 'package:tempus/ui/deck/settings/view.dart';

class ThemeSettings extends StatelessWidget {
  const ThemeSettings({super.key});

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
          title: Text("Theme",
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
                    trailing: context.watch<PreferenceService>().getThemeMode() ==
                            ThemeMode.system
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async =>
                        await context.read<PreferenceService>()
                            .setThemeMode(ThemeMode.system)),
                SettingsTile(
                    title: Text("Light"),
                    trailing: context.watch<PreferenceService>().getThemeMode() ==
                            ThemeMode.light
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async =>
                        await context.read<PreferenceService>()
                            .setThemeMode(ThemeMode.light)),
                SettingsTile(
                    title: Text("Dark"),
                    trailing: context.watch<PreferenceService>().getThemeMode() ==
                            ThemeMode.dark
                        ? Icon(PlatformIcons(context).checkMark)
                        : null,
                    onPressed: (context) async =>
                        await context.read<PreferenceService>()
                            .setThemeMode(ThemeMode.dark)),
              ],
            ),
          ],
        ));
  }
}
