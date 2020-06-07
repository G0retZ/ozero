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
      final player = Player(name: 'a', image: 'b', money: 5, reputation: 2);

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

    test('merge empty with other empty', () {
      // Given:
      final original = Earning(
        playerTurn: null,
        money: null,
        reputation: null,
      );
      final other = Earning(
        playerTurn: null,
        money: null,
        reputation: null,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.playerTurn, null);
      expect(result.money, null);
      expect(result.reputation, null);
    });

    test('merge empty with other filled', () {
      // Given:
      final original = Earning(
        playerTurn: null,
        money: null,
        reputation: null,
      );
      final other = Earning(
        playerTurn: 3,
        money: 4,
        reputation: 5,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.playerTurn, 3);
      expect(result.money, 4);
      expect(result.reputation, 5);
    });

    test('merge filled with other empty', () {
      // Given:
      final original = Earning(
        playerTurn: 0,
        money: 1,
        reputation: 2,
      );
      final other = Earning(
        playerTurn: null,
        money: null,
        reputation: null,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.playerTurn, 0);
      expect(result.money, 1);
      expect(result.reputation, 2);
    });

    test('merge filled with other filled', () {
      // Given:
      final original = Earning(
        playerTurn: 0,
        money: 1,
        reputation: 2,
      );
      final other = Earning(
        playerTurn: 3,
        money: 4,
        reputation: 5,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.playerTurn, 3);
      expect(result.money, 4);
      expect(result.reputation, 5);
    });

    test('assert composed failed without playerTurn', () {
      // Given:
      final earning = Earning(
        playerTurn: null,
        money: 1,
        reputation: 2,
      );

      // When and Then:
      expect(
          earning.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without money', () {
      // Given:
      final earning = Earning(
        playerTurn: 0,
        money: null,
        reputation: 2,
      );

      // When and Then:
      expect(
          earning.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without reputation', () {
      // Given:
      final earning = Earning(
        playerTurn: 0,
        money: 1,
        reputation: null,
      );

      // When and Then:
      expect(
          earning.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed success', () {
      // Given:
      final earning = Earning(
        playerTurn: 0,
        money: 1,
        reputation: 2,
      );

      // When:
      final result = earning.assertComposed();

      // Then:
      expect(result.playerTurn, 0);
      expect(result.money, 1);
      expect(result.reputation, 2);
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

    test('merge empty with other empty', () {
      // Given:
      final original = Remittance(
        senderTurn: null,
        receiver: null,
        money: null,
      );
      final other = Remittance(
        senderTurn: null,
        receiver: null,
        money: null,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.senderTurn, null);
      expect(result.receiver, null);
      expect(result.money, null);
    });

    test('merge empty with other filled', () {
      // Given:
      final original = Remittance(
        senderTurn: null,
        receiver: null,
        money: null,
      );
      final other = Remittance(
        senderTurn: 3,
        receiver: 4,
        money: 5,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.senderTurn, 3);
      expect(result.receiver, 4);
      expect(result.money, 5);
    });

    test('merge filled with other empty', () {
      // Given:
      final original = Remittance(
        senderTurn: 0,
        receiver: 1,
        money: 2,
      );
      final other = Remittance(
        senderTurn: null,
        receiver: null,
        money: null,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.senderTurn, 0);
      expect(result.receiver, 1);
      expect(result.money, 2);
    });

    test('merge filled with other filled', () {
      // Given:
      final original = Remittance(
        senderTurn: 0,
        receiver: 1,
        money: 2,
      );
      final other = Remittance(
        senderTurn: 3,
        receiver: 4,
        money: 5,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.senderTurn, 3);
      expect(result.receiver, 4);
      expect(result.money, 5);
    });

    test('assert composed failed without senderTurn', () {
      // Given:
      final remittance = Remittance(
        senderTurn: null,
        receiver: 1,
        money: 2,
      );

      // When and Then:
      expect(
          remittance.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without receiver', () {
      // Given:
      final remittance = Remittance(
        senderTurn: 0,
        receiver: null,
        money: 2,
      );

      // When and Then:
      expect(
          remittance.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without money', () {
      // Given:
      final remittance = Remittance(
        senderTurn: 0,
        receiver: 1,
        money: null,
      );

      // When and Then:
      expect(
          remittance.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed success', () {
      // Given:
      final remittance = Remittance(
        senderTurn: 0,
        receiver: 1,
        money: 2,
      );

      // When:
      final result = remittance.assertComposed();

      // Then:
      expect(result.senderTurn, 0);
      expect(result.receiver, 1);
      expect(result.money, 2);
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

    test('merge empty with other empty', () {
      // Given:
      final original = DirtyTrick(
        victimTurn: null,
        scum: null,
        fee: null,
        loss: null,
      );
      final other = DirtyTrick(
        victimTurn: null,
        scum: null,
        fee: null,
        loss: null,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.victimTurn, null);
      expect(result.scum, null);
      expect(result.fee, null);
      expect(result.loss, null);
    });

    test('merge empty with other filled', () {
      // Given:
      final original = DirtyTrick(
        victimTurn: null,
        scum: null,
        fee: null,
        loss: null,
      );
      final other = DirtyTrick(
        victimTurn: 3,
        scum: 4,
        fee: 5,
        loss: 6,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.victimTurn, 3);
      expect(result.scum, 4);
      expect(result.fee, 5);
      expect(result.loss, 6);
    });

    test('merge filled with other empty', () {
      // Given:
      final original = DirtyTrick(
        victimTurn: 0,
        scum: 1,
        fee: 2,
        loss: 3,
      );
      final other = DirtyTrick(
        victimTurn: null,
        scum: null,
        fee: null,
        loss: null,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.victimTurn, 0);
      expect(result.scum, 1);
      expect(result.fee, 2);
      expect(result.loss, 3);
    });

    test('merge filled with other filled', () {
      // Given:
      final original = DirtyTrick(
        victimTurn: 0,
        scum: 1,
        fee: 2,
        loss: 3,
      );
      final other = DirtyTrick(
        victimTurn: 3,
        scum: 4,
        fee: 5,
        loss: 6,
      );

      // When:
      final result = original.mergeWith(other);

      // Then:
      expect(result.victimTurn, 3);
      expect(result.scum, 4);
      expect(result.fee, 5);
      expect(result.loss, 6);
    });

    test('assert composed failed without victimTurn', () {
      // Given:
      final dirtyTrick = DirtyTrick(
        victimTurn: null,
        scum: 1,
        fee: 2,
        loss: 3,
      );

      // When and Then:
      expect(
          dirtyTrick.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without scum', () {
      // Given:
      final dirtyTrick = DirtyTrick(
        victimTurn: 0,
        scum: null,
        fee: 2,
        loss: 3,
      );

      // When and Then:
      expect(
          dirtyTrick.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without fee', () {
      // Given:
      final dirtyTrick = DirtyTrick(
        victimTurn: 0,
        scum: 1,
        fee: null,
        loss: 3,
      );

      // When and Then:
      expect(
          dirtyTrick.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed failed without loss', () {
      // Given:
      final dirtyTrick = DirtyTrick(
        victimTurn: 0,
        scum: 1,
        fee: 2,
        loss: null,
      );

      // When and Then:
      expect(
          dirtyTrick.assertComposed,
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
    });

    test('assert composed success', () {
      // Given:
      final dirtyTrick = DirtyTrick(
        victimTurn: 0,
        scum: 1,
        fee: 2,
        loss: 3,
      );

      // When:
      final result = dirtyTrick.assertComposed();

      // Then:
      expect(result.victimTurn, 0);
      expect(result.scum, 1);
      expect(result.fee, 2);
      expect(result.loss, 3);
    });
  });
}
