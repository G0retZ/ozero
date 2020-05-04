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

  Player(this.name, this.image, this.money, this.reputation)
      : super.fromJson({});

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

class Earning extends JsonEmptyChecker {
  final int playerTurn;
  final int money;
  final int reputation;

  Earning(this.playerTurn, this.money, this.reputation) : super.fromJson({});

  Earning.fromJson(Map<String, dynamic> json)
      : playerTurn =
            ArgumentError.checkNotNull(json.remove('playerTurn'), 'playerTurn'),
        money = ArgumentError.checkNotNull(json.remove('money'), 'money'),
        reputation =
            ArgumentError.checkNotNull(json.remove('reputation'), 'reputation'),
        super.fromJson(json);

  Map<String, dynamic> toJson() => {
        'senderTurn': playerTurn,
        'money': money,
        'reputation': reputation,
      };
}

class Remittance extends JsonEmptyChecker {
  final int senderTurn;
  final int receiver;
  final int money;

  Remittance(this.senderTurn, this.receiver, this.money) : super.fromJson({});

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
}

class DirtyTrick extends JsonEmptyChecker {
  final int victimTurn;
  final int scum;
  final int fee;
  final int loss;

  DirtyTrick(this.victimTurn, this.scum, this.fee, this.loss)
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
}
