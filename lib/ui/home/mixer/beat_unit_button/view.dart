import 'package:flutter/material.dart';
import 'package:tempus/domain/models/fraction.dart';
import 'package:tempus/ui/core/themed_text.dart';

class BeatUnitButton extends StatelessWidget {
  final BeatUnit beatUnit;

  const BeatUnitButton({super.key, required this.beatUnit});

  @override
  Widget build(BuildContext context) => GestureDetector(
      onTap: () => print("hi"),
      behavior: HitTestBehavior.opaque,
      child: FittedBox(
          child: ThemedText(beatUnit.toString(), isMusicalSymbal: true)));
}
