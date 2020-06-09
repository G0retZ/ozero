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
      ArgumentError.checkNotNull(_players, '_players');
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

/// Summarizes the users accounts.
/// Input - Void.
/// Output - current users list with current balance.
class PlayersStat extends Bloc<void, List<Player>> {
  StreamSubscription<List<Player>> _playersSubscription;
  StreamSubscription<List<Earning>> _earningsSubscription;
  StreamSubscription<List<Remittance>> _remittancesSubscription;
  StreamSubscription<List<DirtyTrick>> _moneyLossesSubscription;
  StreamSubscription<List<DirtyTrick>> _reputationLossesSubscription;

  List<Player> _players;
  List<Earning> _earnings;
  List<Remittance> _remittances;
  List<DirtyTrick> _moneyLosses;
  List<DirtyTrick> _reputationLosses;

  PlayersStat(
    Bloc<dynamic, List<Player>> playersBloc,
    Bloc<dynamic, List<Earning>> earningsBloc,
    Bloc<dynamic, List<Remittance>> remittancesBloc,
    Bloc<dynamic, List<DirtyTrick>> moneyLossesBloc,
    Bloc<dynamic, List<DirtyTrick>> reputationLossesBloc,
  ) {
    _playersSubscription =
        playersBloc.data.listen((it) => consumeNewItems(() => _players = it));
    _earningsSubscription =
        earningsBloc.data.listen((it) => consumeNewItems(() => _earnings = it));
    _remittancesSubscription = remittancesBloc.data
        .listen((it) => consumeNewItems(() => _remittances = it));
    _moneyLossesSubscription = moneyLossesBloc.data
        .listen((it) => consumeNewItems(() => _moneyLosses = it));
    _reputationLossesSubscription = reputationLossesBloc.data
        .listen((it) => consumeNewItems(() => _reputationLosses = it));
  }

  @override
  Future<bool> perform(void action) async {
    return true;
  }

  void consumeNewItems(void action()) {
    action();
    if (_players == null) {
      return;
    }
    final money = _players.map((e) => e.money).toList();
    final reputation = _players.map((e) => e.reputation).toList();
    if (_earnings != null) {
      _earnings.forEach((earning) {
        final turn = earning.playerTurn % _players.length;
        money[turn] = money[turn] + earning.money;
        reputation[turn] = reputation[turn] + earning.reputation;
      });
    }
    if (_remittances != null) {
      _remittances.forEach((remittance) {
        final sender = remittance.senderTurn % _players.length;
        final receiver = remittance.receiver % _players.length;
        money[sender] = money[sender] - remittance.money;
        money[receiver] = money[receiver] + remittance.money;
      });
    }
    if (_moneyLosses != null) {
      _moneyLosses.forEach((moneyLoss) {
        final victim = moneyLoss.victimTurn % _players.length;
        final scum = moneyLoss.scum % _players.length;
        money[victim] = money[victim] - moneyLoss.loss;
        money[scum] = money[scum] + moneyLoss.fee;
      });
    }
    if (_reputationLosses != null) {
      _reputationLosses.forEach((reputationLoss) {
        final victim = reputationLoss.victimTurn % _players.length;
        final scum = reputationLoss.scum % _players.length;
        reputation[victim] = reputation[victim] - reputationLoss.loss;
        money[scum] = money[scum] + reputationLoss.fee;
      });
    }
    iSink.add(
      _players.asMap().entries.map(
        (entry) {
          return Player(
            name: entry.value.name,
            image: entry.value.image,
            money: money[entry.key],
            reputation: reputation[entry.key],
          );
        },
      ).toList(),
    );
  }

  @override
  void dispose() {
    _playersSubscription.cancel();
    _earningsSubscription.cancel();
    _remittancesSubscription.cancel();
    _moneyLossesSubscription.cancel();
    _reputationLossesSubscription.cancel();
    super.dispose();
  }
}
