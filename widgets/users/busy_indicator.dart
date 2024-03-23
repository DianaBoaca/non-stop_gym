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
  final List<int> emojis = [0x1F60A, 0x1F605, 0x1F633];
  final List<String> texts = [
    'Lejer',
    'Destul de aglomerat',
    'Foarte aglomerat'
  ];
  final List<MaterialColor> colors = [Colors.green, Colors.yellow, Colors.red];
  double percentage = 0;
  int index = 0;

  @override
  void initState() {
    super.initState();
    setState(() {
      percentage = widget.checkedInClients / 50;
      if (percentage <= 0.33) {
        index = 0;
      } else if (percentage <= 0.66) {
        index = 1;
      } else {
        index = 2;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          '${texts[index]} ${String.fromCharCode(emojis[index])}',
          style: TextStyle(
            fontSize: 25,
            color: colors[index],
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
                        colors: colors,
                        stops: const [0, 0.5, 1],
                      ),
                    ),
                  ),
                  Positioned(
                    left: constraints.maxWidth * (percentage),
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
