import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/settings/sample_settings.dart';
import 'package:tempus/settings/theme_settings.dart';
import 'package:tempus/util.dart';

class Settings extends StatelessWidget {
  Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PlatformIconButton(
          icon: Icon(
            PlatformIcons(context).clear,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Settings",
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
            title: Text("Audio"),
            tiles: [
              SettingsTile.navigation(
                title: Text("Downbeat sample"),
                value: Text(capitalizeFirst(
                    Provider.of<AppState>(context).getDownbeatSampleName())),
                onPressed: (context) => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SampleSettings(sampleSetting: SampleSetting.downbeat))),
              ),
              SettingsTile.navigation(
                  title: Text("Subdivision sample"),
                  value: Text(capitalizeFirst(
                      Provider.of<AppState>(context).getSubdivisionSampleName())),
                onPressed: (context) => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SampleSettings(sampleSetting: SampleSetting.subdivision))),
              )
            ],
          ),
          SettingsSection(title: Text("Display"), tiles: [
            SettingsTile.navigation(
              title: Text("Theme"),
              value: Text(capitalizeFirst(
                  Provider.of<AppState>(context).getThemeMode().name)),
              onPressed: (context) => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ThemeSettings())),
            )
          ])
        ],
      ),
    );
  }
}

SettingsThemeData getSettingsThemeData(context) {
  return SettingsThemeData(
      dividerColor: Theme.of(context).colorScheme.onSurface,
      inactiveSubtitleColor: Colors.red,
      inactiveTitleColor: Colors.orange,
      leadingIconsColor: Theme.of(context).colorScheme.primary,
      settingsListBackground: Theme.of(context).colorScheme.surface,
      settingsSectionBackground: Theme.of(context).colorScheme.onSurface,
      settingsTileTextColor: Theme.of(context).colorScheme.primary,
      tileDescriptionTextColor: Colors.yellow,
      tileHighlightColor: Theme.of(context).colorScheme.secondary,
      titleTextColor: Theme.of(context).colorScheme.secondary,
      trailingTextColor: Theme.of(context).colorScheme.secondary);
}
