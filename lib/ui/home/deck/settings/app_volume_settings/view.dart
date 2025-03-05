import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter_settings_ui/flutter_settings_ui.dart';
import 'package:provider/provider.dart';
import 'package:tempus/ui/home/deck/settings/app_volume_settings/view_model.dart';
import 'package:tempus/ui/home/deck/settings/view.dart';

class AppVolumeSettings extends StatelessWidget {
  const AppVolumeSettings({super.key});

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
                    width: constraints.maxWidth,
                    child: PlatformSlider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        value: context
                            .watch<AppVolumeSettingsViewModel>()
                            .appVolume,
                        onChanged: (value) => context
                            .read<AppVolumeSettingsViewModel>()
                            .setAppVolume(value)),
                  ),
                ),
                description: Text(
                    "This affects all audio from the app, but is separate from your device's settings. This setting can be useful when multiple apps are playing audio at the same time"),
                trailing: DefaultTextStyle(
                    style: TextStyle(
                        fontSize: 17,
                        color: getSettingsThemeData(context).trailingTextColor),
                    child: FittedBox(
                      child: Text(
                          "${(context.watch<AppVolumeSettingsViewModel>().appVolume * 100).round()}%"),
                    )),
              )
            ])
          ]));
}
