import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (_, constraints) => Stack(children: [
              PageView(controller: pageController, children: [
                Flex(direction: Axis.vertical, children: [
                  Expanded(
                      flex: 5,
                      child: LayoutBuilder(
                          builder: (_, dialConstraints) => Stack(children: [
                                Center(
                                    child: SizedBox(
                                        height: min(dialConstraints.maxHeight,
                                            dialConstraints.maxWidth),
                                        width: min(dialConstraints.maxHeight,
                                            dialConstraints.maxWidth),
                                        child: BpmDial(
                                            callbackThreshold: 20,
                                            callback: (int change) async =>
                                                await context
                                                    .read<DeckViewModel>()
                                                    .setBpm(context
                                                            .read<
                                                                DeckViewModel>()
                                                            .bpm +
                                                        change)))),
                                Center(
                                    child: SizedBox(
                                        height: min(dialConstraints.maxHeight,
                                            dialConstraints.maxWidth),
                                        width: min(dialConstraints.maxHeight,
                                            dialConstraints.maxWidth),
                                        child: Row(children: [
                                          Expanded(
                                            child: BpmButton(
                                                callback: () async => await context
                                                    .read<DeckViewModel>()
                                                    .setBpm(context
                                                            .read<
                                                                DeckViewModel>()
                                                            .bpm -
                                                        1),
                                                iconData: PlatformIcons(context)
                                                    .remove),
                                          ),
                                          Expanded(
                                              flex: 3,
                                              child: GestureDetector(
                                                  onTap: () async =>
                                                      await context
                                                          .read<DeckViewModel>()
                                                          .togglePlayback(),
                                                  child: SizedBox.expand(
                                                      child: FittedBox(
                                                          child: Icon(
                                                              context
                                                                      .watch<
                                                                          DeckViewModel>()
                                                                      .playback
                                                                  ? CupertinoIcons
                                                                      .pause
                                                                  : Icons
                                                                      .play_arrow_rounded,
                                                              color: Theme.of(
                                                                      context)
                                                                  .colorScheme
                                                                  .primary))))),
                                          Expanded(
                                              child: BpmButton(
                                                  callback: () async =>
                                                      await context
                                                          .read<DeckViewModel>()
                                                          .setBpm(context
                                                                  .read<
                                                                      DeckViewModel>()
                                                                  .bpm +
                                                              1),
                                                  iconData:
                                                      PlatformIcons(context)
                                                          .add))
                                        ])))
                              ]))),
                  Expanded(
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                        Padding(
                            padding: const EdgeInsets.only(left: 24.0),
                            child: GestureDetector(
                                onTap: () async => await showPlatformModalSheet(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        Settings()),
                                child: AxisSizedBox(
                                    reference: Axis.vertical,
                                    child: FittedBox(
                                        child: Icon(
                                      PlatformIcons(context).settings,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ))))),
                        Padding(
                            padding: const EdgeInsets.only(right: 24.0),
                            child: GestureDetector(
                                onTap: context.read<DeckViewModel>().tapTempo,
                                child: AxisSizedBox(
                                    reference: Axis.vertical,
                                    child: FittedBox(
                                        child: Icon(
                                      Icons.touch_app,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    )))))
                      ]))
                ]),
                Flex(direction: Axis.vertical)
              ]),
              Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  SmoothPageIndicator(
                      controller: pageController,
                      count: 2,
                      effect: ColorTransitionEffect(
                          activeDotColor: Theme.of(context).colorScheme.primary,
                          dotColor: Theme.of(context).colorScheme.onSurface))
                ])
              ])
            ]));
  }
}
