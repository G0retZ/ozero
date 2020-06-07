import 'package:flutter/foundation.dart';

/// Interface for merging fields of [D]
abstract class Composable<D> {
  /// returns new immutable instance that has non null fields of [other] instance
  D mergeWith(D other);

  D assertComposed();
}

class JsonEmptyChecker {
  JsonEmptyChecker.fromJson(Map<String, dynamic> json) {
    if (json.keys.length > 0) {
      throw UnsupportedError('unknonw fields ${json.keys}');
    }
  }
}

class Player extends JsonEmptyChecker {
  final String name;
  final String image;
  final int money;
  final int reputation;

  Player({
    @required this.name,
    @required this.image,
    @required this.money,
    @required this.reputation,
  }) : super.fromJson({});

  Player.fromJson(Map<String, dynamic> json)
      : name = ArgumentError.checkNotNull(json.remove('name'), 'name'),
        image = ArgumentError.checkNotNull(json.remove('image'), 'image'),
        money = ArgumentError.checkNotNull(json.remove('money'), 'money'),
        reputation =
            ArgumentError.checkNotNull(json.remove('reputation'), 'reputation'),
        super.fromJson(json);

  Map<String, dynamic> toJson() => {
        'name': name,
        'image': image,
        'money': money,
        'reputation': reputation,
      };
}

class Earning extends JsonEmptyChecker implements Composable<Earning> {
  final int playerTurn;
  final int money;
  final int reputation;

  Earning({this.playerTurn, this.money, this.reputation}) : super.fromJson({});

  Earning.fromJson(Map<String, dynamic> json)
      : playerTurn =
            ArgumentError.checkNotNull(json.remove('playerTurn'), 'playerTurn'),
        money = ArgumentError.checkNotNull(json.remove('money'), 'money'),
        reputation =
            ArgumentError.checkNotNull(json.remove('reputation'), 'reputation'),
        super.fromJson(json);

  Map<String, dynamic> toJson() => {
        'playerTurn': playerTurn,
        'money': money,
        'reputation': reputation,
      };

  @override
  Earning mergeWith(Earning other) {
    return Earning(
      playerTurn: other.playerTurn ?? playerTurn,
      money: other.money ?? money,
      reputation: other.reputation ?? reputation,
    );
  }

  @override
  Earning assertComposed() {
    ArgumentError.checkNotNull(playerTurn, 'playerTurn');
    ArgumentError.checkNotNull(money, 'money');
    ArgumentError.checkNotNull(reputation, 'reputation');
    return this;
  }
}

class Remittance extends JsonEmptyChecker implements Composable<Remittance> {
  final int senderTurn;
  final int receiver;
  final int money;

  Remittance({this.senderTurn, this.receiver, this.money}) : super.fromJson({});

  Remittance.fromJson(Map<String, dynamic> json)
      : senderTurn =
            ArgumentError.checkNotNull(json.remove('senderTurn'), 'senderTurn'),
        receiver =
            ArgumentError.checkNotNull(json.remove('receiver'), 'senderTurn'),
        money = ArgumentError.checkNotNull(json.remove('money'), 'senderTurn'),
        super.fromJson(json);

  Map<String, dynamic> toJson() => {
        'senderTurn': senderTurn,
        'receiver': receiver,
        'money': money,
      };

  @override
  Remittance mergeWith(Remittance other) {
    return Remittance(
      senderTurn: other.senderTurn ?? senderTurn,
      receiver: other.receiver ?? receiver,
      money: other.money ?? money,
    );
  }

  @override
  Remittance assertComposed() {
    ArgumentError.checkNotNull(senderTurn, 'senderTurn');
    ArgumentError.checkNotNull(receiver, 'receiver');
    ArgumentError.checkNotNull(money, 'money');
    return this;
  }
}

class DirtyTrick extends JsonEmptyChecker implements Composable<DirtyTrick> {
  final int victimTurn;
  final int scum;
  final int fee;
  final int loss;

  DirtyTrick({this.victimTurn, this.scum, this.fee, this.loss})
      : super.fromJson({});

  DirtyTrick.fromJson(Map<String, dynamic> json)
      : victimTurn =
            ArgumentError.checkNotNull(json.remove('victimTurn'), 'victimTurn'),
        scum = ArgumentError.checkNotNull(json.remove('scum'), 'scum'),
        fee = ArgumentError.checkNotNull(json.remove('fee'), 'fee'),
        loss = ArgumentError.checkNotNull(json.remove('loss'), 'loss'),
        super.fromJson(json);

  Map<String, dynamic> toJson() => {
        'victimTurn': victimTurn,
        'scum': scum,
        'fee': fee,
        'loss': loss,
      };

  @override
  DirtyTrick mergeWith(DirtyTrick other) {
    return DirtyTrick(
      victimTurn: other.victimTurn ?? victimTurn,
      scum: other.scum ?? scum,
      fee: other.fee ?? fee,
      loss: other.loss ?? loss,
    );
  }

  @override
  DirtyTrick assertComposed() {
    ArgumentError.checkNotNull(victimTurn, 'victimTurn');
    ArgumentError.checkNotNull(scum, 'scum');
    ArgumentError.checkNotNull(fee, 'fee');
    ArgumentError.checkNotNull(loss, 'loss');
    return this;
  }
}
