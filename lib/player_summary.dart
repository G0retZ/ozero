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
        Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              '${player.name}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF000000),
                fontSize: 16,
              ),
            ),
            Row(
              children: <Widget>[
                Icon(
                  Icons.monetization_on,
                  color: Color(0xFF008000),
                ),
                Text(
                  '${player.money}',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                  ),
                ),
                Icon(
                  Icons.star_half,
                  color: Color(0xFFFFD700),
                ),
                Text(
                  '${player.reputation}',
                  style: TextStyle(
                    color: Color(0xFF000000),
                    fontSize: 16,
                  ),
                ),
              ],
            )
          ],
        )
      ],
    ),
  );
}
