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

enum TurnHistoryAction { PREV_TURN, NEXT_TURN }

// Controls the players turns history.
// Input - current turn history action
// Output - List with selected turn index (0) and current turn index (1)
class TurnHistoryBloc extends Bloc<TurnHistoryAction, List<int>> {
  final Bloc<TurnAction, int> _turnBloc;
  int _selectedTurn;
  int _currentTurn;

  TurnHistoryBloc(this._turnBloc) {
    _turnBloc.data.listen((event) {
      _currentTurn = event;
      if (_selectedTurn == null) {
        iSink.add([_selectedTurn = _currentTurn, _currentTurn]);
      }
    });
  }

  @override
  Stream<List<int>> get data => _selectedTurn != null
      ? super.data.startWith([_selectedTurn, _currentTurn])
      : super.data;

  @override
  Future<bool> perform(TurnHistoryAction action) async {
    var turn = 0;
    switch (action) {
      case TurnHistoryAction.PREV_TURN:
        turn = RangeError.checkValueInInterval(
            ArgumentError.checkNotNull(_selectedTurn, "_selectedTurn") - 1,
            0,
            ArgumentError.checkNotNull(_currentTurn, "_currentTurn"));
        break;
      case TurnHistoryAction.NEXT_TURN:
        turn = RangeError.checkValueInInterval(
            ArgumentError.checkNotNull(_selectedTurn, "_selectedTurn") + 1,
            0,
            ArgumentError.checkNotNull(_currentTurn, "_currentTurn"));
        break;
    }
    iSink.add([_selectedTurn = turn, _currentTurn]);
    return true;
  }
}
