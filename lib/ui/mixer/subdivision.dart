import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';
import 'package:tempus/data/services/shared_preferences_service.dart';
import 'package:tempus/data/services/audio_service.dart';
import 'package:tempus/ui/mixer/scroll_wheel.dart';

final List<int> subdivisionOptions = List.generate(8, (index) => (index + 2));

class Subdivision extends StatefulWidget {
  final void Function(Key key) onRemove;

  Subdivision({required Key key, required this.onRemove}) : super(key: key);

  @override
  SubdivisionState createState() => SubdivisionState();
}

class SubdivisionState extends State<Subdivision> {
  late Key key;
  PageController scrollController = PageController(viewportFraction: 0.5);

  Future<void> setOption(int option) async {
    await Provider.of<SharedPreferencesService>(context, listen: false).setSubdivisions({
      ...Provider.of<SharedPreferencesService>(context, listen: false).getSubdivisions()
    }..update(
        key,
        (subdivisionData) =>
            SubdivisionData(option: option, volume: subdivisionData.volume)));
    AudioService.setSubdivisionOption(widget.key!, option);
  }

  Future<void> setVolume(double volume) async {
    await Provider.of<SharedPreferencesService>(context, listen: false).setSubdivisions({
      ...Provider.of<SharedPreferencesService>(context, listen: false).getSubdivisions()
    }..update(
        key,
        (subdivisionData) =>
            SubdivisionData(option: subdivisionData.option, volume: volume)));
    AudioService.setSubdivisionVolume(widget.key!, volume);
  }

  @override
  void initState() {
    super.initState();

    key = widget.key!;
    scrollController.addListener(() {
      if (scrollController.position.isScrollingNotifier.value == false) {
        final int currentPage = scrollController.page!.round();
        scrollController.animateToPage(
          currentPage,
          curve: Curves.easeOut,
          duration: Duration(),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        VerticalDivider(
          color: Theme.of(context).colorScheme.onSurface,
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Expanded(
                child: RotatedBox(
                    quarterTurns: 3,
                    child: PlatformSlider(
                      activeColor: Theme.of(context).colorScheme.primary,
                      onChanged: (double value) async => await setVolume(value),
                      value: Provider.of<SharedPreferencesService>(context)
                          .getSubdivisions()[key]!
                          .volume,
                    ))),
            SizedBox(
                width: 50,
                height: 120,
                child: ScrollWheel(
                    initialItem: Provider.of<SharedPreferencesService>(context, listen: false)
                            .getSubdivisions()[key]!
                            .option -
                        2,
                    callback: setOption)),
            SizedBox(
              child: PlatformIconButton(
                  onPressed: () => widget.onRemove(widget.key!),
                  icon: Icon(PlatformIcons(context).clear,
                      color: Theme.of(context).colorScheme.error, size: 35)),
            )
          ]),
        ),
      ],
    );
  }
}

class SubdivisionData {
  int option;
  double volume;

  SubdivisionData({required this.option, required this.volume});

  Map<String, dynamic> toJson() => {"option": option, "volume": volume};

  static SubdivisionData fromJson(Map<String, dynamic> json) =>
      SubdivisionData(option: json["option"], volume: json["volume"]);
}
