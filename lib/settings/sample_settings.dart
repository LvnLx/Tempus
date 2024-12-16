import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';

class SampleSettings extends StatelessWidget {
  final SampleSetting sampleSetting;

  const SampleSettings({super.key, required this.sampleSetting});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: PlatformIconButton(
          icon: Icon(
            PlatformIcons(context).leftChevron,
            color: Theme.of(context).colorScheme.primary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Select a sample",
            style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            )),
      ),
    );
  }
}

enum SampleSetting {
  downbeat,
  subdivision;

  Future<void> saveSample(BuildContext context, String sample) async {
    final AppState provider = Provider.of<AppState>(context, listen: false);
    switch (this) {
      case SampleSetting.downbeat:
        await provider.setDownbeatSample(sample);
      case SampleSetting.subdivision:
        await provider.setSubdivisionSample(sample);
    }
  }
}
