import 'dart:convert';

import 'package:ozero/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'common.dart';

class CurrentTurnStorage extends DataStorage<int> {
  @override
  Future<int> loadData() async {
    return (await SharedPreferences.getInstance()).getInt('turn');
  }

  @override
  Future<bool> saveData(int data) async {
    return await (await SharedPreferences.getInstance()).setInt('turn', data);
  }
}

class ListDataStorage<D> extends DataStorage<List<D>> {
  final String _key;
  final D Function(dynamic) _create;

  ListDataStorage(this._key, this._create);

  @override
  Future<List<D>> loadData() async {
    final string = (await SharedPreferences.getInstance()).getString(_key);
    return string == null
        ? null
        : (json.decode(string) as List).map((it) => _create(it)).toList();
  }

  @override
  Future<bool> saveData(List<D> data) async {
    return await (await SharedPreferences.getInstance())
        .setString(_key, data == null ? null : json.encode(data));
  }
}

class PlayersStorage extends ListDataStorage<Player> {
  PlayersStorage() : super('player', (json) => Player.fromJson(json));
}

class EarningsStorage extends ListDataStorage<Earning> {
  EarningsStorage() : super('earning', (json) => Earning.fromJson(json));
}

class RemittancesStorage extends ListDataStorage<Remittance> {
  RemittancesStorage()
      : super('remittance', (json) => Remittance.fromJson(json));
}

class MoneyLossStorage extends ListDataStorage<DirtyTrick> {
  MoneyLossStorage() : super('moneyLoss', (json) => DirtyTrick.fromJson(json));
}

class ReputationLossStorage extends ListDataStorage<DirtyTrick> {
  ReputationLossStorage()
      : super('reputationLoss', (json) => DirtyTrick.fromJson(json));
}
