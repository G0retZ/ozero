import 'dart:math';

import 'package:flutter/material.dart';
import 'package:ozero/di/di.dart';
import 'package:ozero/game_page.dart';
import 'package:ozero/start_page.dart';

class HomePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    MediaQueryData queryData = MediaQuery.of(context);
    final width = queryData.size.width;
    final height = queryData.size.height;
    return Stack(
      children: <Widget>[
        Center(
          child: Image(
            width: max(width, height),
            height: max(width, height),
            image: AssetImage("images/Splash.jpeg"),
          ),
        ),
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.white.withAlpha(192),
        ),
        StreamBuilder<bool>(
          initialData: false,
          stream:
              Providers.turnBloc.data.map((event) => event != null).distinct(),
          builder: (context, snapshot) {
            if (snapshot.data != null && snapshot.data) {
              return GamePage();
            } else {
              return StartPage();
            }
          },
        ),
      ],
    );
  }
}
