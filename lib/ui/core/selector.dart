import 'package:flutter/material.dart';

class Selector extends StatelessWidget {
  final Future<void> Function(int index)? callback;
  final int initialItemIndex;
  final double itemExtent;
  final List<Widget> options;
  final Axis orientation;
  final bool useTheme;

  const Selector(
      {super.key,
      required this.itemExtent,
      required this.initialItemIndex,
      required this.options,
      this.callback,
      this.orientation = Axis.vertical,
      this.useTheme = true});

  @override
  Widget build(BuildContext context) => RotatedBox(
      quarterTurns: orientation == Axis.horizontal ? 3 : 0,
      child: ListWheelScrollView(
          controller:
              FixedExtentScrollController(initialItem: initialItemIndex),
          itemExtent: itemExtent,
          onSelectedItemChanged: (index) {
            if (callback != null) {
              callback!(index);
            }
          },
          overAndUnderCenterOpacity: 0.5,
          perspective: 0.005,
          physics: FixedExtentScrollPhysics(),
          children: List<Widget>.generate(
              options.length,
              (index) => RotatedBox(
                  quarterTurns: orientation == Axis.horizontal ? 1 : 0,
                  child: FittedBox(child: options[index])))));
}
