import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/constants/options.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/selector.dart';

class SubdivisionOptionButton extends StatelessWidget {
  final Future<void> Function(int updatedSubdivisionOption) callback;
  final int subdivisionOption;

  const SubdivisionOptionButton(
      {super.key, required this.callback, required this.subdivisionOption});

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showDialog(callback, context, subdivisionOption),
      child: ScaledPadding(
          scale: 0.8,
          child: FittedBox(child: Text(subdivisionOption.toString()))));

  Future<void> showDialog(
      Future<void> Function(int updatedSubdivisionOption) callback,
      BuildContext context,
      int initialSubdivisionOption) async {
    int updatedSubdivisionOption = initialSubdivisionOption;

    return await showPlatformDialog(
        context: context,
        builder: (_) => PlatformAlertDialog(
                title: Text("Subdivision Option"),
                content: Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: SizedBox(
                      height: (TextPainter(
                              text: TextSpan(text: "\n\n"),
                              maxLines: 2,
                              textScaler: MediaQuery.of(context).textScaler,
                              textDirection: TextDirection.ltr)
                            ..layout())
                          .size
                          .height,
                      child: LayoutBuilder(
                        builder: (_, constraints) => Selector(
                            callback: (index) async =>
                                updatedSubdivisionOption =
                                    Options.subdivisionOptions[index],
                            itemExtent: constraints.maxWidth / 6,
                            initialItemIndex: Options.subdivisionOptions
                                .indexOf(initialSubdivisionOption),
                            options: Options.subdivisionOptions
                                .map((numeratorOption) => FittedBox(
                                      child: PlatformText(
                                          numeratorOption.toString(),
                                          style:
                                              TextStyle(fontFamily: "SFMono")),
                                    ))
                                .toList(),
                            orientation: Axis.horizontal,
                            useTheme: false),
                      ),
                    )),
                actions: [
                  PlatformDialogAction(
                      child: Text("Cancel"),
                      onPressed: () => Navigator.pop(context),
                      cupertino: (context, platform) =>
                          CupertinoDialogActionData(isDestructiveAction: true)),
                  PlatformDialogAction(
                      child: Text("Set"),
                      onPressed: () async {
                        Navigator.pop(context);
                        await callback(updatedSubdivisionOption);
                      },
                      cupertino: (context, platform) =>
                          CupertinoDialogActionData(isDefaultAction: true))
                ]));
  }
}
