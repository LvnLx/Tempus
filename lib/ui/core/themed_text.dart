import 'package:flutter/material.dart';

class ThemedText extends StatelessWidget {
  final String text;
  final bool isMusicalSymbal;

  const ThemedText(this.text, {super.key, this.isMusicalSymbal = false});

  @override
  Widget build(BuildContext context) => Text(text,
      style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
          fontFamily: isMusicalSymbal ? "NotoMusic" : "SFMono",
          fontWeight: isMusicalSymbal ? FontWeight.bold : FontWeight.normal));
}
