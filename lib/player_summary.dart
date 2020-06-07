import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'models.dart';

Widget getPlayerSummary(Player player) {
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
                  padding:
                      EdgeInsets.only(top: 8, bottom: 8, left: 12, right: 8),
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
}
