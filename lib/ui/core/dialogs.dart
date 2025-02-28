import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/purchase_result.dart';

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

Future<void> showPurchaseDialog(BuildContext context, String message,
        Future<PurchaseResult> Function() callback) async =>
    await showDialog(DialogConfiguration(context, "Premium Feature", message, [
      PlatformDialogAction(
          child: Text("Cancel"),
          onPressed: () => Navigator.pop(context),
          cupertino: (context, platform) =>
              CupertinoDialogActionData(isDestructiveAction: true)),
      PlatformDialogAction(
          child: Text("Purchase"),
          onPressed: () async {
            Navigator.pop(context);
            PurchaseResult purchaseResult = await callback();
            if (context.mounted) {
              showPurchaseResultDialog(context, purchaseResult);
            }
          },
          cupertino: (context, platform) =>
              CupertinoDialogActionData(isDefaultAction: true))
    ]));

Future<void> showPurchaseResultDialog(
        BuildContext context, PurchaseResult purchaseResult) async =>
    await showPlatformDialog(
        context: context,
        builder: (context) => PlatformAlertDialog(
                title: Text(purchaseResult.status.toString()),
                content: Padding(
                    padding: EdgeInsets.fromLTRB(0.0, 8.0, 0.0, 0.0),
                    child: PlatformText(purchaseResult.message,
                        textAlign: TextAlign.center)),
                actions: [
                  PlatformDialogAction(
                      child: Text("Ok"),
                      onPressed: () => Navigator.pop(context),
                      cupertino: (context, platform) =>
                          CupertinoDialogActionData(isDefaultAction: true))
                ]));
