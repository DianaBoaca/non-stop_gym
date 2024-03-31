import 'package:flutter/material.dart';

class BusyIndicator extends StatefulWidget {
  const BusyIndicator({
    super.key,
    required this.checkedInClients,
  });

  final int checkedInClients;

  @override
  State<BusyIndicator> createState() => _BusyIndicatorState();
}

class _BusyIndicatorState extends State<BusyIndicator> {
  final List<int> _emojis = [0x1F60A, 0x1F605, 0x1F633];
  final List<String> _texts = [
    'Lejer',
    'Destul de aglomerat',
    'Foarte aglomerat'
  ];
  final List<MaterialColor> _colors = [Colors.green, Colors.yellow, Colors.red];
  double _percentage = 0;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      _percentage = widget.checkedInClients / 50;
      if (_percentage <= 0.33) {
        _index = 0;
      } else if (_percentage <= 0.66) {
        _index = 1;
      } else {
        _index = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${_texts[_index]} ${String.fromCharCode(_emojis[_index])}',
          style: TextStyle(
            fontSize: 25,
            color: _colors[_index],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 30,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: _colors,
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * (_percentage),
                    child: Container(
                      width: 5,
                      height: 30,
                      color: Colors.white,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
