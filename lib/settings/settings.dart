import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/settings/sample_settings.dart';
import 'package:tempus/settings/theme_settings.dart';
import 'package:tempus/util.dart';
import 'package:url_launcher/url_launcher.dart';

Uri _emailUri =
    Uri.parse("mailto:noreply.lvnlx@gmail.com?subject=Tempus%20Feedback");

class Settings extends StatefulWidget {
  Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
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
                title: Text("Sample"),
                value:
                    Text(Provider.of<AppState>(context).getSamplePair().name),
                onPressed: (context) => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => SampleSettings())),
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
          ]),
          SettingsSection(title: Text("Other"), tiles: [
            SettingsTile(
                title: Text("Feedback"),
                onPressed: (context) async => await _showEmail()),
            SettingsTile(
                title: Text("Reset metronome"),
                onPressed: (context) => _showResetDialog(
                    context,
                    "Reset metronome?",
                    "The BPM and volume of the downbeat will be reset to their default values, and all subdivisions will be removed",
                    Provider.of<AppState>(context, listen: false)
                        .resetMetronome)),
            SettingsTile(
                title: Text("Reset app"),
                onPressed: (context) => _showResetDialog(
                    context,
                    "Reset app?",
                    "The app will revert to it's original state, with all default values",
                    Provider.of<AppState>(context, listen: false).resetApp))
          ])
        ],
      ),
    );
  }
}

Future<void> _showEmail() async {
  if (!await launchUrl(_emailUri)) {
    print("Failed to show email");
  }
}

_showResetDialog(BuildContext context, String title, String content,
    Function resetCallback) {
  showPlatformDialog(
      context: context,
      builder: (context) => PlatformAlertDialog(
              title: Text(title),
              content: Text(content),
              actions: [
                PlatformDialogAction(
                    child: Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                    cupertino: (context, platform) =>
                        CupertinoDialogActionData(isDefaultAction: true)),
                PlatformDialogAction(
                    child: Text("Ok"),
                    onPressed: () async {
                      Navigator.pop(context);
                      await resetCallback();
                    },
                    cupertino: (context, platform) =>
                        CupertinoDialogActionData(isDestructiveAction: true))
              ]));
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
      tileDescriptionTextColor: Theme.of(context).colorScheme.secondary,
      tileHighlightColor: Theme.of(context).colorScheme.secondary,
      titleTextColor: Theme.of(context).colorScheme.secondary,
      trailingTextColor: Theme.of(context).colorScheme.secondary);
}
