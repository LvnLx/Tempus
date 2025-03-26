import 'package:flutter/material.dart';

class Bar extends StatelessWidget {
  final Axis orientation;
  final double girth;

  const Bar({super.key, required this.orientation, this.girth = 16.0});

  @override
  Widget build(BuildContext context) => orientation == Axis.horizontal
      ? Divider(color: Theme.of(context).colorScheme.onSurface, height: girth)
      : VerticalDivider(
          color: Theme.of(context).colorScheme.onSurface, width: girth);
}
