import 'package:flutter/material.dart';
import 'package:ozero/di/di.dart';
import 'package:ozero/flip.dart';
import 'package:ozero/turn_page.dart';

import 'bloc/turn.dart';

class GamePage extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RaisedButton(
          onPressed: () {
            Providers.turnBloc.perform(TurnAction.END_GAME);
            Providers.playersBloc.perform(null);
          },
          child: Text('Finish game'),
        ),
        Expanded(
          child: Row(
            children: [
              StreamBuilder<bool>(
                initialData: false,
                stream: Providers.turnHistoryBloc.data
                    .map((event) => event[0] != 0)
                    .distinct(),
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios,
                    ),
                    onPressed: snapshot.data
                        ? () => Providers.turnHistoryBloc
                            .perform(TurnHistoryAction.PREV_TURN)
                        : null,
                  );
                },
              ),
              Expanded(
                child: StreamBuilder<int>(
                  initialData: 0,
                  stream:
                      Providers.turnHistoryBloc.data.map((event) => event[0]),
                  builder: (context, snapshot) {
                    return AnimatedSwitcher(
                      duration: Duration(milliseconds: 500),
                      transitionBuilder:
                          (Widget child, Animation<double> animation) {
                        return FlipTransition(
                          child: child,
                          turns: animation,
                        );
                      },
                      child: getTurnPage(snapshot.data),
                    );
                  },
                ),
              ),
              StreamBuilder<bool>(
                initialData: false,
                stream: Providers.turnHistoryBloc.data
                    .map((event) => event[0] != event[1])
                    .distinct(),
                builder: (context, snapshot) {
                  return IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                    ),
                    onPressed: snapshot.data
                        ? () =>
                        Providers.turnHistoryBloc
                            .perform(TurnHistoryAction.NEXT_TURN)
                        : null,
                  );
                },
              )
            ],
          ),
        ),
        StreamBuilder<bool>(
          initialData: true,
          stream: Providers.turnHistoryBloc.data
              .map((event) => event[0] == event[1])
              .distinct(),
          builder: (context, snapshot) {
            var isCurrent = snapshot.data;
            return RaisedButton(
              onPressed: isCurrent
                  ? () => Providers.turnBloc.perform(TurnAction.NEXT_TURN)
                  : () =>
                  Providers.turnHistoryBloc
                      .perform(TurnHistoryAction.CURRENT_TURN),
              child: isCurrent ? Text('Next Turn') : Text('Go to current'),
            );
          },
        ),
      ],
    );
  }
}
