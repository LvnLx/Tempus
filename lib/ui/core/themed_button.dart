import 'package:flutter/material.dart';

class ThemedButton extends StatelessWidget {
  final Widget child;
  final Future<void> Function() onPressed;

  const ThemedButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () async => await onPressed(),
        child: Container(
          decoration: BoxDecoration(
              border:
                  Border.all(color: Theme.of(context).colorScheme.onSurface),
              borderRadius: BorderRadius.circular(8.0)),
          child: child,
        ),
      );
}
