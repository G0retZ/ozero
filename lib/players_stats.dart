import 'package:flutter/material.dart';
import 'package:ozero/bloc/players.dart';
import 'package:ozero/di/di.dart';
import 'package:ozero/models.dart';

class PlayersStats extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PlayersStatsState();
}

class _PlayersStatsState extends State<PlayersStats> {
  final PlayersStat _playersStat = Providers.createPlayersStatBloc();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Player>>(
      initialData: [],
      stream: _playersStat.data,
      builder: (context, snapshot) {
        return ListView.builder(
          padding: EdgeInsets.only(top: 32, bottom: 32),
          itemCount: snapshot.data.length,
          itemBuilder: (BuildContext context, int position) {
            final player = snapshot.data[position];
            return Padding(
              padding: EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
              child: Row(
                children: <Widget>[
                  Image(
                    width: 64,
                    height: 64,
                    image: AssetImage(player.image),
                  ),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.only(
                                top: 8, bottom: 8, left: 12, right: 8),
                            child: Text(
                              '${player.name}',
                              textAlign: TextAlign.start,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                        Row(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Text(
                                '💲 ${player.money}',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Text(
                                '⭐ ${player.reputation}',
                                style: TextStyle(
                                  color: Colors.yellow[800],
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
    _playersStat.dispose();
  }
}
