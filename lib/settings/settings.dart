import 'dart:async';

import 'package:flutter/material.dart' hide showDialog;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/constants.dart';
import 'package:tempus/settings/sample_settings.dart';
import 'package:tempus/settings/theme_settings.dart';
import 'package:tempus/store.dart';
import 'package:tempus/util.dart';
import 'package:url_launcher/url_launcher.dart';

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
          SettingsSection(title: Text("Premium Access"), tiles: [
            SettingsTile(
              title: Text("Status"),
              trailing: DefaultTextStyle(
                style: TextStyle(
                    fontSize: 17,
                    color: getSettingsThemeData(context).trailingTextColor),
                child: Text(Provider.of<AppState>(context).getIsPremium()
                    ? "Active"
                    : "Inactive"),
              ),
            ),
            SettingsTile(
                title: Text("Purchase"),
                onPressed: (context) async =>
                    await Store.purchasePremium(context)),
            SettingsTile(
                title: Text("Restore"),
                onPressed: (context) async =>
                    await Store.restorePremium(context))
          ]),
          SettingsSection(
            title: Text("Audio"),
            tiles: [
              SettingsTile.navigation(
                title: Text("Sample"),
                value:
                    Text(capitalizeFirst(Provider.of<AppState>(context).getSamplePair().name)),
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
          SettingsSection(title: Text("App State"), tiles: [
            SettingsTile(
                title: Text("Reset metronome"),
                onPressed: (context) => showDialog(DialogConfiguration(
                        context,
                        "Reset Metronome",
                        "All of the metronome's settings will be reset to their default values",
                        [
                          PlatformDialogAction(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                              cupertino: (context, platform) =>
                                  CupertinoDialogActionData(
                                      isDefaultAction: true)),
                          PlatformDialogAction(
                              child: Text("Ok"),
                              onPressed: () async {
                                Navigator.pop(context);
                                await Provider.of<AppState>(context,
                                        listen: false)
                                    .resetMetronome();
                              },
                              cupertino: (context, platform) =>
                                  CupertinoDialogActionData(
                                      isDestructiveAction: true))
                        ]))),
            SettingsTile(
                title: Text("Reset app"),
                onPressed: (context) => showDialog(DialogConfiguration(
                        context,
                        "Reset App",
                        "All of the app's settings will be reset to their default values, including the metronome's settings",
                        [
                          PlatformDialogAction(
                              child: Text("Cancel"),
                              onPressed: () => Navigator.pop(context),
                              cupertino: (context, platform) =>
                                  CupertinoDialogActionData(
                                      isDefaultAction: true)),
                          PlatformDialogAction(
                              child: Text("Ok"),
                              onPressed: () async {
                                Navigator.pop(context);
                                await Provider.of<AppState>(context,
                                        listen: false)
                                    .resetApp();
                              },
                              cupertino: (context, platform) =>
                                  CupertinoDialogActionData(
                                      isDestructiveAction: true))
                        ])))
          ]),
          SettingsSection(title: Text("Help"), tiles: [
            SettingsTile(
                title: Text("Contact"),
                onPressed: (context) async => await _showEmail(
                    context, Constants.contactEmail, "Tempus%20Contact")),
            SettingsTile(
                title: Text("Feedback"),
                onPressed: (context) async => await _showEmail(
                    context, Constants.feedbackEmail, "Tempus%20Feedback")),
            SettingsTile(
                title: Text("Support"),
                onPressed: (context) async => await _showEmail(
                    context, Constants.supportEmail, "Tempus%20Support")),
          ])
        ],
      ),
    );
  }
}

Future<void> _showEmail(
    BuildContext context, String email, String subject) async {
  if (!await launchUrl(Uri.parse("mailto:$email?subject=$subject"))) {
    if (context.mounted) {
      showDialog(DialogConfiguration(context, "Email Failed",
          "Unable to open the mail app. Please reach out to $email manually"));
    }
  }
}

SettingsThemeData getSettingsThemeData(context) {
  return SettingsThemeData(
      dividerColor: Theme.of(context).colorScheme.surface,
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
