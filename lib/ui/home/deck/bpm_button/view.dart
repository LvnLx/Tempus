import 'package:flutter/material.dart' hide Axis;
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/scaled_padding.dart';

class BpmButton extends StatelessWidget {
  final Future<void> Function() callback;
  final IconData iconData;

  const BpmButton(
      {super.key, required, required this.callback, required this.iconData});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async => await callback(),
      child: AxisSizedBox(
        reference: ReferenceAxis.vertical,
        child: ScaledPadding(
          child: Icon(
            iconData,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
