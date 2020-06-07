import 'package:flutter/material.dart';
import 'package:ozero/models.dart';

import 'di/di.dart';

class Earnings extends StatelessWidget {
  final List<int> turn;

  const Earnings({Key key, @required this.turn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (turn[0] == turn[1]) {
      Providers.earningInputBloc.perform(Earning(playerTurn: turn[1]));
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: StreamBuilder<int>(
              initialData: 0,
              stream: Providers.earningInputBloc.data
                  .map((event) => event.money)
                  .distinct(),
              builder: (context, snapshot) {
                final sign = snapshot.data > 0 ? '+' : '';
                return Text(
                  '💲 $sign${snapshot.data}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[800],
                    fontSize: 18,
                  ),
                );
              },
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.green[700],
              inactiveTrackColor: Colors.green[100],
              trackShape: RoundedRectSliderTrackShape(),
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Colors.greenAccent[700],
              overlayColor: Colors.green.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
              tickMarkShape: RoundSliderTickMarkShape(),
              activeTickMarkColor: Colors.green[700],
              inactiveTickMarkColor: Colors.green[100],
            ),
            child: StreamBuilder<int>(
              initialData: 0,
              stream: Providers.earningInputBloc.data
                  .map((event) => event.money)
                  .distinct(),
              builder: (context, snapshot) {
                return Slider(
                  value: snapshot.data.toDouble(),
                  min: -1000,
                  max: 1000,
                  divisions: 200,
                  onChanged: (value) {
                    Providers.earningInputBloc
                        .perform(Earning(money: value.toInt()));
                  },
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 16),
            child: StreamBuilder<int>(
              initialData: 0,
              stream: Providers.earningInputBloc.data
                  .map((event) => event.reputation)
                  .distinct(),
              builder: (context, snapshot) {
                final sign = snapshot.data > 0 ? '+' : '';
                return Text(
                  '⭐️ $sign${snapshot.data}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.yellow[800],
                    fontSize: 18,
                  ),
                );
              },
            ),
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: Colors.yellow[700],
              inactiveTrackColor: Colors.yellow[100],
              trackShape: RoundedRectSliderTrackShape(),
              trackHeight: 4.0,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              thumbColor: Colors.yellowAccent[700],
              overlayColor: Colors.yellow.withAlpha(32),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 28.0),
              tickMarkShape: RoundSliderTickMarkShape(),
              activeTickMarkColor: Colors.yellow[700],
              inactiveTickMarkColor: Colors.yellow[100],
            ),
            child: StreamBuilder<int>(
              initialData: 0,
              stream: Providers.earningInputBloc.data
                  .map((event) => event.reputation)
                  .distinct(),
              builder: (context, snapshot) {
                return Slider(
                  value: snapshot.data.toDouble(),
                  min: -100,
                  max: 100,
                  divisions: 40,
                  onChanged: (value) {
                    Providers.earningInputBloc
                        .perform(Earning(reputation: value.toInt()));
                  },
                );
              },
            ),
          ),
        ],
      );
    } else {
      return Padding(
        padding: EdgeInsets.only(top: 16),
        child: Row(
          children: [
            Expanded(
              child: StreamBuilder<int>(
                initialData: 0,
                stream: Providers.earningsBloc.data
                    .map((event) => event[turn[0]].money)
                    .distinct(),
                builder: (context, snapshot) {
                  final sign = snapshot.data > 0 ? '+' : '';
                  return Text(
                    '💲 $sign${snapshot.data}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                      fontSize: 18,
                    ),
                  );
                },
              ),
            ),
            Expanded(
              child: StreamBuilder<int>(
                initialData: 0,
                stream: Providers.earningsBloc.data
                    .map((event) => event[turn[0]].reputation)
                    .distinct(),
                builder: (context, snapshot) {
                  final sign = snapshot.data > 0 ? '+' : '';
                  return Text(
                    '⭐️ $sign${snapshot.data}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow[800],
                      fontSize: 18,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }
  }
}
