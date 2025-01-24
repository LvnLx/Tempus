import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/app_state.dart';
import 'package:tempus/audio.dart';
import 'package:tempus/subdivision/subdivision.dart';

class SubdivisionController extends StatefulWidget {
  const SubdivisionController({super.key});

  @override
  State<StatefulWidget> createState() => SubdivisionControllerState();
}

class SubdivisionControllerState extends State<SubdivisionController> {
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
  }

  @override // Instead of initState, since we need access to context
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> addSubdivision() async {
    var key = UniqueKey();
    Map<Key, SubdivisionData> subdivisions =
        Provider.of<AppState>(context, listen: false).getSubdivisions();
    subdivisions = {
      ...subdivisions,
      key: SubdivisionData(option: subdivisionOptions[0], volume: 0.0)
    };
    await Provider.of<AppState>(context, listen: false)
        .setSubdivisions(subdivisions);
    Audio.addSubdivision(
        key, subdivisions[key]!.option, subdivisions[key]!.volume);
  }

  Future<void> removeSubdivison(Key key) async {
    await Provider.of<AppState>(context, listen: false).setSubdivisions({
      ...Provider.of<AppState>(context, listen: false).getSubdivisions()
    }..remove(key));
    Audio.removeSubdivision(key);
  }

  void setVolume(BuildContext context, double newVolume) async {
    await Provider.of<AppState>(context, listen: false).setVolume(newVolume);
    Audio.setVolume(newVolume);
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
                        onChanged: (double value) => setVolume(context, value),
                        value: Provider.of<AppState>(context).getVolume(),
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
              ...(Provider.of<AppState>(context)
                  .getSubdivisions()
                  .keys
                  .map((key) => Subdivision(
                      key: key,
                      onRemove: (Key key) async => await removeSubdivison(key)))
                  .toList()),
              VerticalDivider(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              if (Provider.of<AppState>(context).getSubdivisions().isEmpty)
                PlatformIconButton(
                    onPressed: addSubdivision,
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
    double volume = Provider.of<AppState>(context).getVolume();
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
