import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/domain/constants/options.dart';
import 'package:tempus/domain/models/purchase_result.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/themed_text.dart';
import 'package:tempus/ui/mixer/channel.dart';
import 'package:tempus/ui/mixer/fixed_channel.dart';
import 'package:tempus/ui/mixer/view_model.dart';

class Mixer extends StatefulWidget {
  const Mixer({super.key});

  @override
  State<StatefulWidget> createState() => MixerState();
}

class MixerState extends State<Mixer> {
  final ScrollController scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Align(
        alignment: Alignment.centerLeft,
        child: Scrollbar(
          controller: scrollController,
          child: SingleChildScrollView(
            controller: scrollController,
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                Padding(padding: EdgeInsets.only(left: 8.0)),
                FixedChannel(
                    sliderCallback:
                        context.read<MixerViewModel>().setDownbeatVolume,
                    volumeValueNotifier: context
                        .read<MixerViewModel>()
                        .downbeatVolumeValueNotifier,
                    child: ScaledPadding(
                        scale: 0.8,
                        child: FittedBox(child: ThemedText("ACC.")))),
                ThemedDivider(orientation: Axis.vertical),
                FixedChannel(
                    sliderCallback:
                        context.read<MixerViewModel>().setBeatVolume,
                    volumeValueNotifier:
                        context.read<MixerViewModel>().beatVolumeValueNotifier,
                    child: ScaledPadding(
                        scale: 0.8,
                        child: FittedBox(
                            child: ThemedText(
                                context.watch<MixerViewModel>().playback
                                    ? context
                                        .watch<MixerViewModel>()
                                        .count
                                        .toString()
                                    : "BEAT")))),
                ...(context
                    .watch<MixerViewModel>()
                    .subdivisions
                    .keys
                    .map((key) => Channel(
                          key: key,
                          onRemove: (Key key) async => await context
                              .read<MixerViewModel>()
                              .removeSubdivision(key),
                          setSubdivisionOption: context
                              .read<MixerViewModel>()
                              .setSubdivisionOption,
                          setSubdivisionVolume: context
                              .read<MixerViewModel>()
                              .setSubdivisionVolume,
                          subdivisions:
                              context.watch<MixerViewModel>().subdivisions,
                        ))
                    .toList()),
                ThemedDivider(orientation: Axis.vertical),
                if (context.watch<MixerViewModel>().subdivisions.length <
                    Options.subdivisionOptions.length)
                  GestureDetector(
                      onTap: () async {
                        if (_canAddSubdivison()) {
                          await context.read<MixerViewModel>().addSubdivision();
                        } else {
                          await _showPurchaseDialog(context);
                        }
                      },
                      child: SizedBox(
                        width: constraints.maxHeight / 6,
                        child: AxisSizedBox(
                          reference: Axis.vertical,
                          child: ScaledPadding(
                            child: Icon(
                              PlatformIcons(context).add,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                      ))
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _canAddSubdivison() =>
      context.read<MixerViewModel>().subdivisions.isEmpty ||
      context.read<MixerViewModel>().isPremium;

  Future<void> _showPurchaseDialog(BuildContext context) async =>
      await showTextDialog(context,
          title: "Premium Feature",
          message:
              "Simultaneous subdivisions are available with the premium version. Would you like to continue to the purchase?",
          dialogAction: DialogAction.confirm,
          confirmText: "Purchase", onConfirm: () async {
        PurchaseResult purchaseResult =
            await context.read<MixerViewModel>().purchasePremium();
        if (context.mounted) {
          await showPurchaseResultDialog(context, purchaseResult);
        }
      });
}
