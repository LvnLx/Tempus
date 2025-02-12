import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class DialogConfiguration {
  BuildContext context;
  String title;
  String message;
  List<Widget>? actions;

  DialogConfiguration(this.context, this.title, this.message,
      [List<Widget>? actions])
      : actions = actions ??
            [
              PlatformDialogAction(
                  child: Text("Ok"),
                  onPressed: () => Navigator.pop(context),
                  cupertino: (context, platform) =>
                      CupertinoDialogActionData(isDefaultAction: true))
            ];
}

String capitalizeFirst(String input) {
  if (input.isEmpty) return input;
  return input[0].toUpperCase() + input.substring(1).toLowerCase();
}

Future<void> showDialog(DialogConfiguration dialogConfiguration) async =>
    await showPlatformDialog(
        context: dialogConfiguration.context,
        builder: (context) => PlatformAlertDialog(
            title: Text(dialogConfiguration.title),
            content: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                child: PlatformText(dialogConfiguration.message,
                    textAlign: TextAlign.center)),
            actions: dialogConfiguration.actions));
