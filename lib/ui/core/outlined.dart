import 'package:flutter/material.dart';

class Outlined extends StatelessWidget {
  final Widget child;

  const Outlined({super.key, required this.child});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onSurface),
            borderRadius: BorderRadius.circular(8.0)),
        child: child,
      );
}
