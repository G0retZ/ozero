import 'package:flutter/material.dart';
import 'package:ozero/di/di.dart';

import 'bloc/turn.dart';

class GamePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaisedButton(
          onPressed: () => Providers.turnBloc.perform(TurnAction.END_GAME),
          child: Text('Finish game'),
        ),
        Expanded(
          child: Row(
            children: [
              StreamBuilder<bool>(
                stream: Providers.turnHistoryBloc.data
                    .map((event) => event != null && event[0] != 0)
                    .distinct(),
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_back,
                    ),
                    onPressed: snapshot.data != null && snapshot.data
                        ? () => Providers.turnHistoryBloc
                            .perform(TurnHistoryAction.PREV_TURN)
                        : null,
                  );
                },
              ),
              Expanded(
                child: Center(
                  child: StreamBuilder<int>(
                    stream:
                        Providers.turnHistoryBloc.data.map((event) => event[0]),
                    builder: (context, snapshot) {
                      return Text(
                        'This turn is ${snapshot.data}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(0xFF, 0, 0, 0),
                          fontSize: 35,
                        ),
                      );
                    },
                  ),
                ),
              ),
              StreamBuilder<bool>(
                stream: Providers.turnHistoryBloc.data
                    .map((event) => event != null && event[0] != event[1])
                    .distinct(),
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_forward,
                    ),
                    onPressed: snapshot.data != null && snapshot.data
                        ? () => Providers.turnHistoryBloc
                            .perform(TurnHistoryAction.NEXT_TURN)
                        : null,
                  );
                },
              )
            ],
          ),
        ),
        RaisedButton(
          onPressed: () => Providers.turnBloc.perform(TurnAction.NEXT_TURN),
          child: Text('Next Turn'),
        ),
      ],
    );
  }
}
