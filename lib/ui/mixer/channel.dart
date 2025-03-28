import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/domain/models/subdivision.dart';
import 'package:tempus/ui/core/themed_divider.dart';
import 'package:tempus/ui/core/themed_button.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/themed_slider.dart';
import 'package:tempus/ui/mixer/subdivision_option_button.dart';

class Channel extends StatelessWidget {
  final void Function(Key key) onRemove;
  final Future<void> Function(Key key, int option) setSubdivisionOption;
  final Future<void> Function(Key key, double volume) setSubdivisionVolume;
  final Map<Key, Subdivision> subdivisions;

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
          ThemedDivider(orientation: Axis.vertical),
          SizedBox(
            width: constraints.maxHeight / 6,
            child: Column(children: [
              Expanded(
                  flex: 10,
                  child: RotatedBox(
                      quarterTurns: 3,
                      child: ThemedSlider(
                          onChanged: (value) async =>
                              await setSubdivisionVolume(key!, value),
                          value: subdivisions[key]!.volume))),
              Expanded(child: ThemedDivider(orientation: Axis.horizontal)),
              Expanded(
                  flex: 3,
                  child: SubdivisionOptionButton(
                      callback: (updatedSubdivisionOption) =>
                          setSubdivisionOption(key!, updatedSubdivisionOption),
                      subdivisionOption: subdivisions[key]!.option)),
              Expanded(child: ThemedDivider(orientation: Axis.horizontal)),
              Expanded(
                flex: 3,
                child: ThemedButton(
                  onPressed: () async => onRemove(key!),
                  child: ScaledPadding(
                    scale: 0.8,
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
