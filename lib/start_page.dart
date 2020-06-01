import 'dart:async';

import 'package:flutter/material.dart';
import 'package:ozero/config.dart';
import 'package:ozero/di/di.dart';
import 'package:ozero/models.dart';
import 'package:ozero/player_summary.dart';

import 'bloc/turn.dart';

class StartPage extends StatelessWidget {
  final StreamController<int> _sliderValue = StreamController<int>.broadcast();

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 32, bottom: 32),
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: StreamBuilder<List<Player>>(
          stream: Providers.playersBloc.data,
          builder: (context, snapshot) {
            if (snapshot.data != null) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RaisedButton(
                    onPressed: () => Providers.playersBloc.perform(null),
                    child: Text('Cancel'),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 32, bottom: 32),
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext context, int position) {
                        return getPlayerSummary(snapshot.data[position]);
                      },
                    ),
                  ),
                  RaisedButton(
                    onPressed: () =>
                        Providers.turnBloc.perform(TurnAction.START_GAME),
                    child: Text('Start game'),
                  ),
                ],
              );
            } else {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Number of players',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000000),
                      fontSize: 20,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 32),
                    child: StreamBuilder<int>(
                      initialData: availablePlayers.length,
                      stream: _sliderValue.stream,
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000000),
                            fontSize: 48,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(bottom: 32, left: 32, right: 32),
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: Colors.green[700],
                        inactiveTrackColor: Colors.green[100],
                        trackShape: RoundedRectSliderTrackShape(),
                        trackHeight: 8.0,
                        thumbShape:
                            RoundSliderThumbShape(enabledThumbRadius: 12.0),
                        thumbColor: Colors.redAccent,
                        overlayColor: Colors.red.withAlpha(32),
                        overlayShape:
                            RoundSliderOverlayShape(overlayRadius: 28.0),
                        tickMarkShape: RoundSliderTickMarkShape(),
                        activeTickMarkColor: Colors.red[700],
                        inactiveTickMarkColor: Colors.red[100],
                      ),
                      child: StreamBuilder<int>(
                        initialData: availablePlayers.length,
                        stream: _sliderValue.stream,
                        builder: (context, snapshot) {
                          var minPlayers = MIN_PLAYERS.toDouble();
                          var number = snapshot.data == null
                              ? minPlayers
                              : snapshot.data.toDouble();
                          return Slider(
                            value: number,
                            min: minPlayers,
                            max: availablePlayers.length.toDouble(),
                            onChanged: (value) {
                              _sliderValue.add(value.toInt());
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  StreamBuilder<int>(
                    initialData: availablePlayers.length,
                    stream: _sliderValue.stream,
                    builder: (context, snapshot) {
                      return RaisedButton(
                        onPressed: () =>
                            Providers.playersBloc.perform(snapshot.data),
                        child: Text('Create game'),
                      );
                    },
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
