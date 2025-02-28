import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/dialogs.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/home/mixer/channel/view.dart';
import 'package:tempus/ui/home/mixer/view_model.dart';

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
                Column(
                  children: [
                    Expanded(
                        flex: 5,
                        child: RotatedBox(
                          quarterTurns: 3,
                          child: PlatformSlider(
                            activeColor: Theme.of(context).colorScheme.primary,
                            onChanged: (double value) =>
                                context.read<MixerViewModel>().setVolume(value),
                            value: context.watch<MixerViewModel>().volume,
                          ),
                        )),
                    Expanded(
                      child: AxisSizedBox(
                        reference: Axis.vertical,
                        child: ScaledPadding(
                          child: Icon(
                            volumeIcon(),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                  GestureDetector(
                      onTap: () async {
                        if (_canAddSubdivison()) {
                          await context.read<MixerViewModel>().addSubdivision();
                        } else {
                          await showPurchaseDialog(
                              context,
                              "Simultaneous subdivisions are available with the premium version. Would you like to continue to the purchase?",
                              context.read<MixerViewModel>().purchasePremium);
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
