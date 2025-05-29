import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/deck/buttons/bpm_button.dart';
import 'package:tempus/ui/deck/bpm_dial.dart';
import 'package:tempus/ui/settings/view.dart';
import 'package:tempus/ui/deck/view_model.dart';

class Deck extends StatefulWidget {
  const Deck({super.key});

  @override
  State<StatefulWidget> createState() => DeckState();
}

class DeckState extends State<Deck> {
  PageController pageController = PageController();
  bool canScrollPages = true;

  @override
  Widget build(BuildContext context) => Column(children: [
        Expanded(
          flex: 5,
          child: PageView(
              controller: pageController,
              physics: canScrollPages
                  ? ScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              children: [
                Stack(children: [
                  LayoutBuilder(
                      builder: (_, constraints) => Center(
                          child: SizedBox(
                              height: min(
                                  constraints.maxHeight, constraints.maxWidth),
                              width: min(
                                  constraints.maxHeight, constraints.maxWidth),
                              child: Stack(children: [
                                BpmDial(
                                    callbackThreshold: 20,
                                    callback: (int change) async =>
                                        await context
                                            .read<DeckViewModel>()
                                            .setBpm(context
                                                    .read<DeckViewModel>()
                                                    .bpm +
                                                change)),
                                Row(children: [
                                  Expanded(
                                      child: BpmButton(
                                          callback: () async => await context
                                              .read<DeckViewModel>()
                                              .setBpm(context
                                                      .read<DeckViewModel>()
                                                      .bpm -
                                                  1),
                                          iconData:
                                              PlatformIcons(context).remove)),
                                  Expanded(
                                      flex: 3,
                                      child: GestureDetector(
                                          onTap: () async => await context
                                              .read<DeckViewModel>()
                                              .togglePlayback(),
                                          child: SizedBox.expand(
                                              child: FittedBox(
                                                  child: Icon(
                                                      context
                                                              .watch<
                                                                  DeckViewModel>()
                                                              .playback
                                                          ? CupertinoIcons.pause
                                                          : Icons
                                                              .play_arrow_rounded,
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary))))),
                                  Expanded(
                                      child: BpmButton(
                                          callback: () async => await context
                                              .read<DeckViewModel>()
                                              .setBpm(context
                                                      .read<DeckViewModel>()
                                                      .bpm +
                                                  1),
                                          iconData: PlatformIcons(context).add))
                                ])
                              ]))))
                ]),
                Flex(direction: Axis.vertical)
              ]),
        ),
        ThemedDivider(orientation: Axis.horizontal),
        Expanded(
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
            GestureDetector(
                onTap: () async => await showPlatformModalSheet(
                    context: context,
                    builder: (BuildContext context) => Settings()),
                child: AxisSizedBox(
                    reference: Axis.vertical,
                    child: FittedBox(
                        child: Icon(PlatformIcons(context).settings,
                            color: Theme.of(context).colorScheme.primary)))),
            SmoothPageIndicator(
                controller: pageController,
                count: 2,
                effect: ColorTransitionEffect(
                    activeDotColor: Theme.of(context).colorScheme.primary,
                    dotColor: Theme.of(context).colorScheme.onSurface)),
            GestureDetector(
                onTap: context.read<DeckViewModel>().tapTempo,
                child: AxisSizedBox(
                    reference: Axis.vertical,
                    child: FittedBox(
                        child: Icon(Icons.touch_app,
                            color: Theme.of(context).colorScheme.primary))))
          ]),
        )
      ]);
}
