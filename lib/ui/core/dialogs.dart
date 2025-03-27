import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/purchase_result.dart';

enum DialogAction {
  confirm,
  inform;

  List<Widget> generate(BuildContext context, Future<void> Function() onConfirm,
      String confirmText) {
    switch (this) {
      case DialogAction.inform:
        return [
          PlatformDialogAction(
              child: Text("Ok"),
              onPressed: () => Navigator.pop(context),
              cupertino: (context, platform) =>
                  CupertinoDialogActionData(isDefaultAction: true))
        ];
      case DialogAction.confirm:
        return [
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
}

Future<void> showInputDialog(BuildContext context,
    {required String title,
    required Widget input,
    required Future<void> Function() onConfirm,
    DialogAction dialogAction = DialogAction.confirm,
    String confirmText = "Ok"}) async {
  List<Widget> actions = dialogAction.generate(context, onConfirm, confirmText);
  await _showDialog(context, title, actions, input);
}

Future<void> showPurchaseResultDialog(
        BuildContext context, PurchaseResult purchaseResult) async =>
    await showTextDialog(context,
        title: purchaseResult.status.toString(),
        message: purchaseResult.message);

Future<void> showTextDialog(BuildContext context,
    {required String title,
    required String message,
    DialogAction dialogAction = DialogAction.inform,
    Future<void> Function() onConfirm = _onConfirm,
    String confirmText = "Ok"}) async {
  List<Widget> actions = dialogAction.generate(context, onConfirm, confirmText);
  await _showDialog(context, title, actions,
      PlatformText(message, textAlign: TextAlign.center));
}

Future<void> _onConfirm() async {}

Future<void> _showDialog(BuildContext context, String title,
        List<Widget> actions, Widget child) async =>
    await showPlatformDialog(
        context: context,
        builder: (context) => PlatformAlertDialog(
            title: Text(title),
            content: Padding(padding: EdgeInsets.only(top: 8.0), child: child),
            actions: actions));
