import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart' hide Selector;
import 'package:tempus/constants.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/selector.dart';
import 'package:tempus/ui/home/mixer/channel/view_model.dart';

class Channel extends StatefulWidget {
  final void Function(Key key) onRemove;

  Channel({required Key key, required this.onRemove}) : super(key: key);

  @override
  ChannelState createState() => ChannelState();
}

class ChannelState extends State<Channel> {
  late Key key;
  PageController scrollController = PageController(viewportFraction: 0.5);

  @override
  void initState() {
    super.initState();

    key = widget.key!;
    scrollController.addListener(() {
      if (scrollController.position.isScrollingNotifier.value == false) {
        final int currentPage = scrollController.page!.round();
        scrollController.animateToPage(
          currentPage,
          curve: Curves.easeOut,
          duration: Duration(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Row(
        children: [
          VerticalDivider(
            color: Theme.of(context).colorScheme.onSurface,
          ),
          SizedBox(
            width: constraints.maxHeight / 6,
            child: Column(children: [
              Expanded(
                  flex: 3,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: PlatformSlider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (double value) async => await context
                            .read<ChannelViewModel>()
                            .setSubdivisionVolume(widget.key!, value),
                        value: context
                            .watch<ChannelViewModel>()
                            .subdivisions[key]!
                            .volume,
                      ))),
              Expanded(
                flex: 2,
                child: LayoutBuilder(
                    builder: (_, constraints) => Selector(
                        callback: (index) async => context
                            .read<ChannelViewModel>()
                            .setSubdivisionOption(
                                key, Constants.subdivisionOptions[index]),
                        itemExtent: constraints.maxHeight / 3,
                        initialItemIndex: Constants.subdivisionOptions.indexOf(
                            context
                                .read<ChannelViewModel>()
                                .subdivisions[key]!
                                .option),
                        options: Constants.subdivisionOptions)),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => widget.onRemove(widget.key!),
                  child: ScaledPadding(
                    child: Icon(PlatformIcons(context).clear,
                        color: Theme.of(context).colorScheme.error),
                  ),
                ),
              )
            ]),
          ),
        ],
      ),
    );
  }
}

class SubdivisionData {
  int option;
  double volume;

  SubdivisionData({required this.option, required this.volume});

  Map<String, dynamic> toJson() => {"option": option, "volume": volume};

  static SubdivisionData fromJson(Map<String, dynamic> json) =>
      SubdivisionData(option: json["option"], volume: json["volume"]);
}
