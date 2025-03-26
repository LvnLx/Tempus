import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/ui/core/bar.dart';
import 'package:tempus/ui/core/outlined.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/home/mixer/subdivision_option_button.dart';

class Channel extends StatelessWidget {
  final void Function(Key key) onRemove;
  final Future<void> Function(Key key, int option) setSubdivisionOption;
  final Future<void> Function(Key key, double volume) setSubdivisionVolume;
  final Map<Key, SubdivisionData> subdivisions;

  Channel(
      {required Key key,
      required this.onRemove,
      required this.setSubdivisionOption,
      required this.setSubdivisionVolume,
      required this.subdivisions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) => Row(
        children: [
          Bar(orientation: Axis.vertical),
          SizedBox(
            width: constraints.maxHeight / 6,
            child: Column(children: [
              Expanded(
                  flex: 10,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: PlatformSlider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (double value) async =>
                            await setSubdivisionVolume(key!, value),
                        value: subdivisions[key]!.volume,
                      ))),
              Expanded(child: Bar(orientation: Axis.horizontal)),
              Expanded(
                  flex: 3,
                  child: SubdivisionOptionButton(
                      callback: (updatedSubdivisionOption) =>
                          setSubdivisionOption(key!, updatedSubdivisionOption),
                      subdivisionOption: subdivisions[key]!.option)),
              Expanded(child: Bar(orientation: Axis.horizontal)),
              Expanded(
                flex: 3,
                child: GestureDetector(
                  onTap: () => onRemove(key!),
                  child: Outlined(
                    child: ScaledPadding(
                      scale: 0.8,
                      child: Icon(PlatformIcons(context).clear,
                          color: Theme.of(context).colorScheme.error),
                    ),
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
