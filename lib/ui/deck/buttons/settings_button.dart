import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:tempus/ui/core/axis_sizer.dart';
import 'package:tempus/ui/core/scaled_padding.dart';
import 'package:tempus/ui/settings/view.dart';

class SettingsButton extends StatelessWidget {
  const SettingsButton({super.key});

  @override
  Widget build(BuildContext context) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async => await showPlatformModalSheet(
          context: context, builder: (BuildContext context) => Settings()),
      child: AxisSizedBox(
          reference: Axis.vertical,
          child: ScaledPadding(
              scale: 0.8,
              child: FittedBox(
                  child: Icon(PlatformIcons(context).settings,
                      color: Theme.of(context).colorScheme.primary)))));
}
