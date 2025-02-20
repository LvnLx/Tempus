import 'package:flutter/material.dart' hide showDialog;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';
import 'package:tempus/ui/home/mixer/view_model.dart';
import 'package:tempus/util.dart';

class Mixer extends StatefulWidget {
  const Mixer({super.key});

  @override
  State<StatefulWidget> createState() => MixerState();
}

class MixerState extends State<Mixer> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override // Instead of initState, since we need access to context
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _showPremiumDialog() async =>
      await showDialog(DialogConfiguration(
          context,
          "Premium Feature",
          "Simultaneous subdivisions are available with the premium version. Would you like to continue to the purchase?",
          [
            PlatformDialogAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
                cupertino: (context, platform) =>
                    CupertinoDialogActionData(isDestructiveAction: true)),
            PlatformDialogAction(
                child: Text("Purchase"),
                onPressed: () async {
                  Navigator.pop(context);
                  PurchaseResult purchaseResult =
                      await context.read<MixerViewModel>().purchasePremium();
                  if (mounted) {
                    showPurchaseDialog(context, purchaseResult);
                  }
                },
                cupertino: (context, platform) =>
                    CupertinoDialogActionData(isDefaultAction: true))
          ]));

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                        child: RotatedBox(
                      quarterTurns: 3,
                      child: PlatformSlider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (double value) =>
                            context.read<MixerViewModel>().setVolume(value),
                        value: context.watch<MixerViewModel>().volume,
                      ),
                    )),
                    SizedBox(
                      child: Center(
                        child: PlatformIconButton(
                            icon: Icon(
                          volumeIcon(),
                          size: 35,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
              ...(context
                  .watch<MixerViewModel>()
                  .subdivisions
                  .keys
                  .map((key) => Channel(
                      key: key,
                      onRemove: (Key key) async => await context
                          .read<MixerViewModel>()
                          .removeSubdivision(key)))
                  .toList()),
              VerticalDivider(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              if (context.watch<MixerViewModel>().subdivisions.length <
                  subdivisionOptions.length)
                PlatformIconButton(
                    onPressed: () async {
                      if (_canAddSubdivison()) {
                        await context.read<MixerViewModel>().addSubdivision();
                      } else {
                        await _showPremiumDialog();
                      }
                    },
                    icon: Icon(
                      PlatformIcons(context).add,
                      color: Theme.of(context).colorScheme.primary,
                      size: 35,
                    ))
            ],
          ),
        ),
      ),
    );
  }

  bool _canAddSubdivison() =>
      context.read<MixerViewModel>().subdivisions.isEmpty ||
      context.read<MixerViewModel>().isPremium;

  IconData volumeIcon() {
    double volume = context.watch<MixerViewModel>().volume;
    if (volume > 0.66) {
      return PlatformIcons(context).volumeUp;
    } else if (volume > 0.33) {
      return PlatformIcons(context).volumeDown;
    } else if (volume > 0.0) {
      return PlatformIcons(context).volumeMute;
    } else {
      return PlatformIcons(context).volumeOff;
    }
  }
}
