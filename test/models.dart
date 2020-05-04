import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:ozero/models.dart';

void main() {
  group('test Player model', () {
    final _playerJson = () => json.decode('{'
        '"name": "a",'
        '"image": "b",'
        '"money": 5,'
        '"reputation":2'
        '}');

    test('create JSON from instance', () {
      // Given and When:
      final player = Player('a', 'b', 5, 2);

      // Then:
      expect(player.toJson(), _playerJson());
    });

    test('create from correct JSON', () {
      // Given and When:
      final player = Player.fromJson(_playerJson());

      // Then:
      expect(player.name, 'a');
      expect(player.image, 'b');
      expect(player.money, 5);
      expect(player.reputation, 2);
    });

    _playerJson().keys.forEach((key) {
      test('create from JSON without $key', () {
        // Given:
        final player =
            () => Player.fromJson(new Map.from(_playerJson())..remove(key));

        // When and Then:
        expect(
            player,
            throwsA(
                (e) => e is ArgumentError && e.message == 'Must not be null'));
      });
    });

    test('create from JSON with excessive values', () {
      // Given:
      final player = () => Player.fromJson(new Map.from(_playerJson())
        ..['a'] = 'b'
        ..['c'] = 'd'
        ..['e'] = 'f');

      // When and Then:
      expect(
          player,
          throwsA((e) =>
              e is UnsupportedError &&
              e.message == 'unknonw fields (a, c, e)'));
    });
  });

  group('test Earning model', () {
    final _earningJson = () => json.decode('{'
        '"playerTurn": 12,'
        '"money": 327,'
        '"reputation": 3'
        '}') as Map<String, dynamic>;

    test('create from correct JSON', () {
      // Given and When:
      final earning = Earning.fromJson(_earningJson());

      // Then:
      expect(earning.playerTurn, 12);
      expect(earning.money, 327);
      expect(earning.reputation, 3);
    });

    _earningJson().keys.forEach((key) {
      test('create from JSON without $key', () {
        // Given:
        final earning =
            () => Earning.fromJson(new Map.from(_earningJson())..remove(key));

        // When and Then:
        expect(
            earning,
            throwsA(
                (e) => e is ArgumentError && e.message == 'Must not be null'));
      });
    });

    test('create from JSON with excessive values', () {
      // Given:
      final earning = () => Earning.fromJson(new Map.from(_earningJson())
        ..['a'] = 'b'
        ..['c'] = 'd'
        ..['e'] = 'f');

      // When and Then:
      expect(
          earning,
          throwsA((e) =>
              e is UnsupportedError &&
              e.message == 'unknonw fields (a, c, e)'));
    });
  });

  group('test Remittance model', () {
    final _remittanceJson = () => json.decode('{'
        '"senderTurn": 12,'
        '"receiver": 3,'
        '"money": 327'
        '}') as Map<String, dynamic>;

    test('create from correct JSON', () {
      // Given and When:
      final remittance = Remittance.fromJson(_remittanceJson());

      // Then:
      expect(remittance.senderTurn, 12);
      expect(remittance.receiver, 3);
      expect(remittance.money, 327);
    });

    _remittanceJson().keys.forEach((key) {
      test('create from JSON without $key', () {
        // Given:
        final remittance = () =>
            Remittance.fromJson(new Map.from(_remittanceJson())..remove(key));

        // When and Then:
        expect(
            remittance,
            throwsA(
                (e) => e is ArgumentError && e.message == 'Must not be null'));
      });
    });

    test('create from JSON with excessive values', () {
      // Given:
      final remittance =
          () => Remittance.fromJson(new Map.from(_remittanceJson())
            ..['a'] = 'b'
            ..['c'] = 'd'
            ..['e'] = 'f');

      // When and Then:
      expect(
          remittance,
          throwsA((e) =>
              e is UnsupportedError &&
              e.message == 'unknonw fields (a, c, e)'));
    });
  });

  group('test DirtyTrick model', () {
    final _dirtyTrick = () => json.decode('{'
        '"victimTurn": 12,'
        '"scum": 3,'
        '"fee": 327,'
        '"loss": 14132'
        '}') as Map<String, dynamic>;

    test('create from correct JSON', () {
      // Given and When:
      final moneyLoss = DirtyTrick.fromJson(_dirtyTrick());

      // Then:
      expect(moneyLoss.victimTurn, 12);
      expect(moneyLoss.scum, 3);
      expect(moneyLoss.fee, 327);
      expect(moneyLoss.loss, 14132);
    });

    _dirtyTrick().keys.forEach((key) {
      test('create from JSON without $key', () {
        // Given:
        final moneyLoss =
            () => DirtyTrick.fromJson(new Map.from(_dirtyTrick())..remove(key));

        // When and Then:
        expect(
            moneyLoss,
            throwsA(
                (e) => e is ArgumentError && e.message == 'Must not be null'));
      });
    });

    test('create from JSON with excessive values', () {
      // Given:
      final moneyLoss = () => DirtyTrick.fromJson(new Map.from(_dirtyTrick())
        ..['a'] = 'b'
        ..['c'] = 'd'
        ..['e'] = 'f');

      // When and Then:
      expect(
          moneyLoss,
          throwsA((e) =>
              e is UnsupportedError &&
              e.message == 'unknonw fields (a, c, e)'));
    });
  });
}
