import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart' hide Selector;
import 'package:tempus/ui/home/mixer/channel/view_model.dart';
import 'package:tempus/ui/home/mixer/selector/view.dart';

final List<int> subdivisionOptions = List.generate(8, (index) => (index + 2));

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
    return Row(
      children: [
        VerticalDivider(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
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
            SizedBox(
                width: 50,
                height: 120,
                child: Selector(
                    key: widget.key!,
                    initialItem: context
                            .read<ChannelViewModel>()
                            .subdivisions[key]!
                            .option -
                        2,
                    callback:
                        context.read<ChannelViewModel>().setSubdivisionOption)),
            SizedBox(
              child: PlatformIconButton(
                  onPressed: () => widget.onRemove(widget.key!),
                  icon: Icon(PlatformIcons(context).clear,
                      color: Theme.of(context).colorScheme.error, size: 35)),
            )
          ]),
        ),
      ],
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
