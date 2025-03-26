import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/purchase_result.dart';

class DialogConfiguration {
  BuildContext context;
  String title;
  String message;
  List<Widget>? actions;

  DialogConfiguration.inform(this.context,
      {required this.title, required this.message}) {
    actions = [
      PlatformDialogAction(
          child: Text("Ok"),
          onPressed: () => Navigator.pop(context),
          cupertino: (context, platform) =>
              CupertinoDialogActionData(isDefaultAction: true))
    ];
  }

  DialogConfiguration.confirm(this.context,
      {required this.title,
      required this.message,
      required Future<void> Function() onConfirm,
      String confirmText = "Ok"}) {
    actions = [
      PlatformDialogAction(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
          cupertino: (context, platform) =>
              CupertinoDialogActionData(isDestructiveAction: true)),
      PlatformDialogAction(
          child: Text(confirmText),
          onPressed: () async {
            Navigator.pop(context);
            await onConfirm();
          },
          cupertino: (context, platform) =>
              CupertinoDialogActionData(isDefaultAction: true))
    ];
  }
}

Future<void> showDialog(DialogConfiguration dialogConfiguration) async =>
    await showPlatformDialog(
        context: dialogConfiguration.context,
        builder: (context) => PlatformAlertDialog(
            title: Text(dialogConfiguration.title),
            content: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: PlatformText(dialogConfiguration.message,
                    textAlign: TextAlign.center)),
            actions: dialogConfiguration.actions));

Future<void> showPurchaseResultDialog(
        BuildContext context, PurchaseResult purchaseResult) async =>
    await showDialog(DialogConfiguration.inform(context,
        title: purchaseResult.status.toString(),
        message: purchaseResult.message));
