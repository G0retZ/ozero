import 'dart:async';
import 'dart:convert';

import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ozero/bloc/players.dart';
import 'package:ozero/config.dart';
import 'package:ozero/models.dart';
import 'package:ozero/storage/common.dart';

class MockPlayersStorage extends Mock implements DataStorage<List<Player>> {}

void main() {
  /// Test Players bloc
  group('Players control logic', () {
    test('Interact with storage at creation time', () {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value(null));

      // When
      PlayersBloc(playersStorage);

      // Then
      verify(playersStorage.loadData());
      verifyNoMoreInteractions(playersStorage);
    });

    test('Error if create with less than minimum', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value(null));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);

      // When:
      await Future.value();

      //Then:
      expect(playersBloc.perform(MIN_PLAYERS - 1),
          throwsA((e) => e is RangeError && e.message == 'Invalid value'));
      verify(playersStorage.loadData());
      verifyNoMoreInteractions(playersStorage);
    });

    test('Error if create with more than available', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value(null));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);

      // When:
      await Future.value();

      //Then:
      expect(playersBloc.perform(availablePlayers.length + 1),
          throwsA((e) => e is RangeError && e.message == 'Invalid value'));
      verify(playersStorage.loadData());
      verifyNoMoreInteractions(playersStorage);
    });

    test('Answer failed to create without saved players', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value(null));
      when(playersStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);
      final queue = StreamQueue(playersBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await playersBloc.perform(MIN_PLAYERS);
      final action2 = await playersBloc.perform(MIN_PLAYERS);
      final action3 = await playersBloc.perform(MIN_PLAYERS);
      final action4 = await playersBloc.perform(MIN_PLAYERS);
      playersBloc.dispose();

      // Then
      verifyInOrder([
        playersStorage.loadData(),
        playersStorage.saveData(argThat(anything)),
        playersStorage.saveData(argThat(anything)),
        playersStorage.saveData(argThat(anything)),
        playersStorage.saveData(argThat(anything)),
      ]);
      verifyNoMoreInteractions(playersStorage);
      expect(queue, emitsInOrder([null, emitsDone]));
      expect(action1, false);
      expect(action2, false);
      expect(action3, false);
      expect(action4, false);
    });

    test('Error create with saved players', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value([]));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);

      // When:
      await Future.value();

      // Then:
      expect(
          playersBloc.perform(availablePlayers.length),
          throwsA((e) =>
              e is StateError && e.message == 'Finish current game first!'));
      verify(playersStorage.loadData());
      verifyNoMoreInteractions(playersStorage);
    });

    test('Answer success to create without saved players', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value(null));
      when(playersStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);
      final queue = StreamQueue(playersBloc.data);
      queue.lookAhead(1); //subscribe to broadcast
      final result = StreamQueue(playersBloc.data);
      result.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action = await playersBloc.perform(MIN_PLAYERS);
      playersBloc.dispose();

      // Then
      verifyInOrder([
        playersStorage.loadData(),
        playersStorage.saveData(argThat(anything)),
      ]);
      verifyNoMoreInteractions(playersStorage);
      expect(queue, emitsInOrder([null, anything, emitsDone]));
      await result.next;
      (await result.next)
          .map((e) => json.encode(e))
          .forEach((it) => print('$it'));
      expect(action, true);
    });

    test('Error clear without saved players', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value(null));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);

      // When:
      await Future.value();

      //Then:
      expect(
          playersBloc.perform(null),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(playersStorage.loadData());
      verifyNoMoreInteractions(playersStorage);
    });

    test('Answer failed to clear with saved players', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(playersStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);
      final queue = StreamQueue(playersBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await playersBloc.perform(null);
      final action2 = await playersBloc.perform(null);
      final action3 = await playersBloc.perform(null);
      final action4 = await playersBloc.perform(null);
      playersBloc.dispose();

      // Then
      verifyInOrder([
        playersStorage.loadData(),
        playersStorage.saveData(null),
        playersStorage.saveData(null),
        playersStorage.saveData(null),
        playersStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(playersStorage);
      expect(queue, emitsInOrder([[], emitsDone]));
      expect(action1, false);
      expect(action2, false);
      expect(action3, false);
      expect(action4, false);
    });

    test('Answer success to clear with saved players', () async {
      // Given
      final playersStorage = MockPlayersStorage();
      when(playersStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(playersStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final PlayersBloc playersBloc = PlayersBloc(playersStorage);
      final queue = StreamQueue(playersBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action = await playersBloc.perform(null);
      playersBloc.dispose();

      // Then
      verifyInOrder([
        playersStorage.loadData(),
        playersStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(playersStorage);
      expect(queue, emitsInOrder([[], null, emitsDone]));
      expect(action, true);
    });
  });
}
