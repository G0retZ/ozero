import 'dart:async';

import 'package:ozero/storage/common.dart';

import 'common.dart';

enum TurnAction { START_GAME, NEXT_TURN, END_GAME }

// Controls the players turns.
// Input - current turn action
// Output - current turn index
class TurnBloc extends Bloc<TurnAction, int> {
  final DataStorage<int> _turnStorage;
  int _currentTurn;

  TurnBloc(this._turnStorage) {
    _turnStorage.loadData().then((value) {
      iSink.add(_currentTurn = value);
    });
  }

  @override
  Stream<int> get data =>
      _currentTurn != null ? super.data.startWith(_currentTurn) : super.data;

  @override
  Future<bool> perform(TurnAction action) async {
    var result = false;
    switch (action) {
      case TurnAction.START_GAME:
        if (_currentTurn != null) {
          throw StateError('Finish current game first!');
        }
        result = await _tryToSave(0);
        break;
      case TurnAction.NEXT_TURN:
        final turn =
            ArgumentError.checkNotNull(_currentTurn, "_currentTurn") + 1;
        result = await _tryToSave(turn);
        break;
      case TurnAction.END_GAME:
        ArgumentError.checkNotNull(_currentTurn, "_currentTurn");
        result = await _tryToSave(null);
        break;
    }
    return result;
  }

  Future<bool> _tryToSave(int data) async {
    final result = await _turnStorage.saveData(data);
    if (result) {
      iSink.add(_currentTurn = data);
    }
    return result;
  }
}
