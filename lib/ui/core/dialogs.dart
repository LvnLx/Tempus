import 'package:flutter/widgets.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/purchase_result.dart';

Future<void> showPurchaseDialog(
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
