import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ThemedSlider extends StatelessWidget {
  final Future<void> Function(double value) onChanged;
  final double value;

  const ThemedSlider({super.key, required this.onChanged, required this.value});

  @override
  Widget build(BuildContext context) => PlatformSlider(
      activeColor: Theme.of(context).colorScheme.primary,
      value: value,
      onChanged: (double value) async {
        HapticFeedback.selectionClick();
        onChanged(value);
      });
}
