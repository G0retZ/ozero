import 'dart:async';
import 'dart:math';

import 'package:ozero/models.dart';
import 'package:ozero/storage/common.dart';

import '../config.dart';
import 'common.dart';

// Controls players.
// Input - number of players or null to clear.
// Output - current players list
class PlayersBloc extends Bloc<int, List<Player>> {
  final DataStorage<List<Player>> _playersStorage;
  List<Player> _players;

  PlayersBloc(this._playersStorage) {
    _playersStorage.loadData().then((value) {
      iSink.add(_players = value);
    });
  }

  @override
  Stream<List<Player>> get data =>
      _players != null ? super.data.startWith(_players) : super.data;

  @override
  Future<bool> perform(int action) async {
    var result = false;
    if (action == null) {
      ArgumentError.checkNotNull(_players, "_players");
      result = await _playersStorage.saveData(null);
      if (result) {
        iSink.add(_players = null);
      }
    } else if (_players == null) {
      final players = (availablePlayers.toList()..shuffle(Random())).sublist(
          0,
          RangeError.checkValueInInterval(
              action, MIN_PLAYERS, availablePlayers.length));
      result = await _playersStorage.saveData(players);
      if (result) {
        iSink.add(_players = players);
      }
    } else {
      throw StateError('Finish current game first!');
    }
    return result;
  }
}
