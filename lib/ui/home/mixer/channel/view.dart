import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart' hide Selector;
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/home/mixer/channel/view_model.dart';
import 'package:tempus/ui/home/mixer/subdivision_option_button/view.dart';

class Channel extends StatefulWidget {
  final void Function(Key key) onRemove;

  Channel({required Key key, required this.onRemove}) : super(key: key);

  @override
  ChannelState createState() => ChannelState();
}

class ChannelState extends State<Channel> {
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
                  flex: 4,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: PlatformSlider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (double value) async => await context
                            .read<ChannelViewModel>()
                            .setSubdivisionVolume(widget.key!, value),
                        value: context
                            .watch<ChannelViewModel>()
                            .subdivisions[widget.key]!
                            .volume,
                      ))),
              Expanded(
                  child: SubdivisionOptionButton(
                      callback: (updatedSubdivisionOption) => context
                          .read<ChannelViewModel>()
                          .setSubdivisionOption(
                              widget.key!, updatedSubdivisionOption),
                      subdivisionOption: context
                          .watch<ChannelViewModel>()
                          .subdivisions[widget.key]!
                          .option)),
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
