import 'package:flutter/material.dart';
import 'package:tempus/domain/models/beat_unit.dart';

class BeatUnitButton extends StatelessWidget {
  final BeatUnit beatUnit;

  const BeatUnitButton({super.key, required this.beatUnit});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => print("hi"),
        behavior: HitTestBehavior.opaque,
        child: FittedBox(
            child: Text(beatUnit.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: "NotoMusic",
                    fontWeight: FontWeight.bold))),
      );
}
