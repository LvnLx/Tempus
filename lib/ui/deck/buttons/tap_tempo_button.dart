import 'package:flutter/material.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/scaled_padding.dart';

class TapTempoButton extends StatelessWidget {
  final void Function() onPressed;

  const TapTempoButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: AxisSizedBox(
          reference: Axis.vertical,
          child: ScaledPadding(
              scale: 0.8,
              child: FittedBox(
                  child: Icon(Icons.touch_app_rounded,
                      color: Theme.of(context).colorScheme.primary)))));
}
