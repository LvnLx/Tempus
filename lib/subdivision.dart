import 'package:flutter/material.dart';
import 'package:metronomic/audio.dart';

typedef SubdivisionCallback = void Function(Key key);

const List<String> subdivisionOptions = [
  '2',
  '3',
  '4',
  '5',
  '6',
];

class Subdivision extends StatefulWidget {
  final SubdivisionCallback onRemove;

  Subdivision({required Key key, required this.onRemove}) : super(key: key);

  @override
  SubdivisionState createState() => SubdivisionState();

  String getSubdivisionOption() {
    final SubdivisionState subdivisionState = SubdivisionState();
    return subdivisionState.option;
  }

  double getSubdivisionVolume() {
    final SubdivisionState subdivisionState = SubdivisionState();
    return subdivisionState.volume;
  }
}

class SubdivisionState extends State<Subdivision> {
  bool _muted = true;
  double volume = 0.5;
  String option = subdivisionOptions[0];

  void setOption(String newOption) {
    setState(() {
      option = newOption;
    });
    Audio.setSubdivisionOption(widget.key!, newOption);
  }

  void setVolume(double newVolume) {
    setState(() {
      volume = newVolume;
    });
    if (!_muted) {
      Audio.setSubdivisionVolume(widget.key!, newVolume);
    }
  }

  void toggleMuted() {
    setState(() {
      _muted = !_muted;
    });
    _muted
        ? Audio.setSubdivisionVolume(widget.key!, 0.0)
        : Audio.setSubdivisionVolume(widget.key!, volume);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Padding(
                  padding: EdgeInsets.fromLTRB(8.0, 0.0, 0.0, 0.0),
                  child: DropdownButton(
                    isExpanded: true,
                    iconSize: 0,
                    underline: Container(),
                    value: option,
                    items: subdivisionOptions
                        .map<DropdownMenuItem<String>>((String option) {
                      return DropdownMenuItem(
                          value: option,
                          child: Center(
                            child: Text(
                              option,
                              style: (TextStyle(
                                  fontSize: 32,
                                  color: _muted ? Colors.grey : Colors.white)),
                              textAlign: TextAlign.center,
                            ),
                          ));
                    }).toList(),
                    onChanged: (String? newOption) {
                      if (newOption != option) {
                        setOption(newOption!);
                      }
                    },
                  )),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: Slider(
                activeColor: _muted ? Colors.grey : Colors.white,
                value: volume,
                onChanged: (double newVolume) => setVolume(newVolume),
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: IconButton(
                onPressed: () => toggleMuted(),
                icon: Icon(
                  _muted ? Icons.volume_off : Icons.volume_up,
                  size: 32,
                ),
                color: _muted ? Colors.red : Colors.white,
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.1,
              child: Padding(
                padding: EdgeInsets.fromLTRB(0.0, 0.0, 8.0, 0.0),
                child: IconButton(
                  onPressed: () => widget.onRemove(widget.key!),
                  icon: Icon(Icons.close, size: 32),
                  color: Colors.red,
                ),
              ),
            )
          ],
        ),
      ],
    );
  }
}
