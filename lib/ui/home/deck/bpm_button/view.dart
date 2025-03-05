import 'package:flutter/material.dart';
import 'package:tempus/ui/core/scaled_padding.dart';

class BpmButton extends StatelessWidget {
  final Future<void> Function() callback;
  final IconData iconData;

  const BpmButton(
      {super.key, required, required this.callback, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: GestureDetector(
        onTap: () async => await callback(),
        child: ScaledPadding(
          child: FittedBox(
            child: Icon(
              iconData,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
      ),
    );
  }
}
