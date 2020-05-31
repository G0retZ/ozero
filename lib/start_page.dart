import 'package:flutter/material.dart';
import 'package:ozero/di/di.dart';

import 'bloc/turn.dart';

class StartPage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton(
        onPressed: () => Providers.turnBloc.perform(TurnAction.START_GAME),
        child: Text("Start game"),
      ),
    );
  }
}
