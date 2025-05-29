import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/core/themed_text.dart';

class BpmButton extends StatelessWidget {
  final int bpm;
  final Queue<int> tapTimes;

  const BpmButton({super.key, required this.bpm, required this.tapTimes});

  @override
  Widget build(BuildContext context) => LayoutBuilder(
        builder: (_, constraints) => SizedBox(
          height: constraints.maxHeight / 3 * 2,
          width: constraints.maxHeight,
          child: ScaledPadding(
            scale: 0.9,
            child: FittedBox(
                  child: ThemedText(
                      tapTimes.length == 1 ? "TAP" : bpm.toString()),
                ),
          ),
        ),
      );
}
