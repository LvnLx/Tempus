import 'package:flutter/material.dart' hide showDialog;
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/shared_preferences_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/data/services/purchases_service.dart';
import 'package:tempus/ui/mixer/subdivision.dart';
import 'package:tempus/util.dart';

class Mixer extends StatefulWidget {
  const Mixer({super.key});

  @override
  State<StatefulWidget> createState() => MixerState();
}

class MixerState extends State<Mixer> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override // Instead of initState, since we need access to context
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _handleAddSubdivisionPressed(BuildContext context) async {
    if (_canAddSubdivison()) {
      await _addSubdivision();
    } else {
      await _showPremiumDialog();
    }
  }

  Future<void> _handleOnRemovePressed(Key key) async {
    await Provider.of<SharedPreferencesService>(context, listen: false).setSubdivisions({
      ...Provider.of<SharedPreferencesService>(context, listen: false).getSubdivisions()
    }..remove(key));
    AudioService.removeSubdivision(key);
  }

  bool _canAddSubdivison() =>
      Provider.of<SharedPreferencesService>(context, listen: false).getSubdivisions().isEmpty ||
      Provider.of<SharedPreferencesService>(context, listen: false).getIsPremium();

  Future<void> _addSubdivision() async {
    UniqueKey key = UniqueKey();
    Map<Key, SubdivisionData> subdivisions =
        Provider.of<SharedPreferencesService>(context, listen: false).getSubdivisions();
    subdivisions = {
      ...subdivisions,
      key: SubdivisionData(option: subdivisionOptions[0], volume: 0.0)
    };

    await Provider.of<SharedPreferencesService>(context, listen: false)
        .setSubdivisions(subdivisions);
    await AudioService.addSubdivision(
        key, subdivisions[key]!.option, subdivisions[key]!.volume);
  }

  Future<void> _showPremiumDialog() async =>
      await showDialog(DialogConfiguration(
          context,
          "Premium Feature",
          "Simultaneous subdivisions are available with the premium version. Would you like to continue to the purchase?",
          [
            PlatformDialogAction(
                child: Text("Cancel"),
                onPressed: () => Navigator.pop(context),
                cupertino: (context, platform) =>
                    CupertinoDialogActionData(isDestructiveAction: true)),
            PlatformDialogAction(
                child: Text("Purchase"),
                onPressed: () async {
                  Navigator.pop(context);
                  await PurchasesService.purchasePremium(context);
                },
                cupertino: (context, platform) =>
                    CupertinoDialogActionData(isDefaultAction: true))
          ]));

  void _handleVolumeChanged(BuildContext context, double newVolume) async {
    await Provider.of<SharedPreferencesService>(context, listen: false).setVolume(newVolume);
    await AudioService.setVolume(newVolume);
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Scrollbar(
        controller: scrollController,
        child: SingleChildScrollView(
          controller: scrollController,
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Expanded(
                        child: RotatedBox(
                      quarterTurns: 3,
                      child: PlatformSlider(
                        activeColor: Theme.of(context).colorScheme.primary,
                        onChanged: (double value) =>
                            _handleVolumeChanged(context, value),
                        value: Provider.of<SharedPreferencesService>(context).getVolume(),
                      ),
                    )),
                    SizedBox(
                      child: Center(
                        child: PlatformIconButton(
                            icon: Icon(
                          volumeIcon(),
                          size: 35,
                          color: Theme.of(context).colorScheme.primary,
                        )),
                      ),
                    ),
                  ],
                ),
              ),
              ...(Provider.of<SharedPreferencesService>(context)
                  .getSubdivisions()
                  .keys
                  .map((key) => Subdivision(
                      key: key,
                      onRemove: (Key key) async =>
                          await _handleOnRemovePressed(key)))
                  .toList()),
              VerticalDivider(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              if (Provider.of<SharedPreferencesService>(context).getSubdivisions().length <
                  subdivisionOptions.length)
                PlatformIconButton(
                    onPressed: () => _handleAddSubdivisionPressed(context),
                    icon: Icon(
                      PlatformIcons(context).add,
                      color: Theme.of(context).colorScheme.primary,
                      size: 35,
                    ))
            ],
          ),
        ),
      ),
    );
  }

  IconData volumeIcon() {
    double volume = Provider.of<SharedPreferencesService>(context).getVolume();
    if (volume > 0.66) {
      return PlatformIcons(context).volumeUp;
    } else if (volume > 0.33) {
      return PlatformIcons(context).volumeDown;
    } else if (volume > 0.0) {
      return PlatformIcons(context).volumeMute;
    } else {
      return PlatformIcons(context).volumeOff;
    }
  }
}
