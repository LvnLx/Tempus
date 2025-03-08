import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tempus/ui/home/mixer/beat_unit_button/view_model.dart';

class BeatUnitButton extends StatelessWidget {
  const BeatUnitButton({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: () => print("hi"),
        behavior: HitTestBehavior.opaque,
        child: FittedBox(
            child: Text(
                context.watch<BeatUnitButtonViewModel>().beatUnit.toString(),
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontFamily: "NotoMusic",
                    fontWeight: FontWeight.bold))),
      );
}
