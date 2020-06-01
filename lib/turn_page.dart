import 'package:flutter/material.dart';

import 'di/di.dart';

Widget getTurnPage(int turn) {
  return Container(
    key: ValueKey<int>(turn),
    width: double.infinity,
    height: double.infinity,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(24),
      border: Border.all(
        color: Color(0x40000000),
        width: 1,
      ),
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: EdgeInsets.all(16),
        color: Color(0xFFFFFFFF),
        child: Column(
          children: [
            StreamBuilder<String>(
              stream: Providers.playersBloc.data
                  .map((event) => event[turn % event.length].name),
              builder: (context, snapshot) {
                return Text(
                  '${turn + 1}. ${snapshot.data}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000000),
                    fontSize: 32,
                  ),
                );
              },
            ),
            StreamBuilder<String>(
              stream: Providers.playersBloc.data
                  .map((event) => event[turn % event.length].image),
              builder: (context, snapshot) {
                return Image(
                  width: 240,
                  height: 240,
                  image: AssetImage(snapshot.data),
                );
              },
            ),
          ],
        ),
      ),
    ),
  );
}
