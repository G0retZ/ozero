import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ozero/bloc/common.dart';
import 'package:ozero/bloc/turn.dart';
import 'package:ozero/storage/common.dart';

class MockTurnStorage extends Mock implements DataStorage<int> {}

class MockTurnBloc extends Mock implements Bloc<TurnAction, int> {}

void main() {
  /// Test Turn bloc
  group('Turn control logic', () {
    test('Interact with storage at creation time', () {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(null));

      // When
      TurnBloc(turnStorage);

      // Then
      verify(turnStorage.loadData());
      verifyNoMoreInteractions(turnStorage);
    });

    test('Answer failed to start without saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(null));
      when(turnStorage.saveData(0)).thenAnswer((_) => Future.value(false));
      final TurnBloc turnBloc = TurnBloc(turnStorage);
      final queue = StreamQueue(turnBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await turnBloc.perform(TurnAction.START_GAME);
      final action2 = await turnBloc.perform(TurnAction.START_GAME);
      final action3 = await turnBloc.perform(TurnAction.START_GAME);
      turnBloc.dispose();

      // Then
      verifyInOrder([
        turnStorage.loadData(),
        turnStorage.saveData(0),
        turnStorage.saveData(0),
        turnStorage.saveData(0),
      ]);
      verifyNoMoreInteractions(turnStorage);
      expect(queue, emitsInOrder([null, emitsDone]));
      expect(action1, false);
      expect(action2, false);
      expect(action3, false);
    });

    test('Error start with saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(15));
      when(turnStorage.saveData(0)).thenAnswer((_) => Future.value(true));
      final TurnBloc turnBloc = TurnBloc(turnStorage);

      // When
      await Future.value();

      // Then
      expect(
          turnBloc.perform(TurnAction.START_GAME),
          throwsA((e) =>
              e is StateError && e.message == 'Finish current game first!'));
      verifyInOrder([
        turnStorage.loadData(),
      ]);
      verifyNoMoreInteractions(turnStorage);
    });

    test('Error end without saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(null));
      final TurnBloc turnBloc = TurnBloc(turnStorage);

      // When
      await Future.value();

      // Then
      expect(
          turnBloc.perform(TurnAction.END_GAME),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verifyInOrder([
        turnStorage.loadData(),
      ]);
      verifyNoMoreInteractions(turnStorage);
    });

    test('Answer failed to end with saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(15));
      when(turnStorage.saveData(null)).thenAnswer((_) => Future.value(false));
      final TurnBloc turnBloc = TurnBloc(turnStorage);
      final queue = StreamQueue(turnBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await turnBloc.perform(TurnAction.END_GAME);
      final action2 = await turnBloc.perform(TurnAction.END_GAME);
      final action3 = await turnBloc.perform(TurnAction.END_GAME);
      turnBloc.dispose();

      // Then
      verifyInOrder([
        turnStorage.loadData(),
        turnStorage.saveData(null),
        turnStorage.saveData(null),
        turnStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(turnStorage);
      expect(queue, emitsInOrder([15, emitsDone]));
      expect(action1, false);
      expect(action2, false);
      expect(action3, false);
    });

    test('Error next without saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(null));
      final TurnBloc turnBloc = TurnBloc(turnStorage);

      // When
      await Future.value();

      // Then
      expect(
          turnBloc.perform(TurnAction.NEXT_TURN),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verifyInOrder([
        turnStorage.loadData(),
      ]);
      verifyNoMoreInteractions(turnStorage);
    });

    test('Answer success start, failed next and success end', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(null));
      when(turnStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      when(turnStorage.saveData(0)).thenAnswer((_) => Future.value(true));
      when(turnStorage.saveData(null)).thenAnswer((_) => Future.value(true));
      final TurnBloc turnBloc = TurnBloc(turnStorage);
      final queue = StreamQueue(turnBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await turnBloc.perform(TurnAction.START_GAME);
      final action2 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action3 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action4 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action5 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action6 = await turnBloc.perform(TurnAction.END_GAME);
      turnBloc.dispose();

      // Then
      verifyInOrder([
        turnStorage.loadData(),
        turnStorage.saveData(0),
        turnStorage.saveData(1),
        turnStorage.saveData(1),
        turnStorage.saveData(1),
        turnStorage.saveData(1),
        turnStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(turnStorage);
      expect(queue, emitsInOrder([null, 0, null, emitsDone]));
      expect(action1, true);
      expect(action2, false);
      expect(action3, false);
      expect(action4, false);
      expect(action5, false);
      expect(action6, true);
    });

    test('Answer failed next and success end with saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(15));
      when(turnStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      when(turnStorage.saveData(null)).thenAnswer((_) => Future.value(true));
      final TurnBloc turnBloc = TurnBloc(turnStorage);
      final queue = StreamQueue(turnBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action2 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action3 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action4 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action5 = await turnBloc.perform(TurnAction.END_GAME);
      turnBloc.dispose();

      // Then
      verifyInOrder([
        turnStorage.loadData(),
        turnStorage.saveData(16),
        turnStorage.saveData(16),
        turnStorage.saveData(16),
        turnStorage.saveData(16),
        turnStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(turnStorage);
      expect(queue, emitsInOrder([15, null, emitsDone]));
      expect(action1, false);
      expect(action2, false);
      expect(action3, false);
      expect(action4, false);
      expect(action5, true);
    });

    test('Success to start, to increment on next and to end', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(null));
      when(turnStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TurnBloc turnBloc = TurnBloc(turnStorage);
      final queue = StreamQueue(turnBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await turnBloc.perform(TurnAction.START_GAME);
      final action2 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action3 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action4 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action5 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action6 = await turnBloc.perform(TurnAction.END_GAME);
      turnBloc.dispose();

      // Then
      verifyInOrder([
        turnStorage.loadData(),
        turnStorage.saveData(0),
        turnStorage.saveData(1),
        turnStorage.saveData(2),
        turnStorage.saveData(3),
        turnStorage.saveData(4),
        turnStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(turnStorage);
      expect(queue, emitsInOrder([null, 0, 1, 2, 3, 4, null, emitsDone]));
      expect(action1, true);
      expect(action2, true);
      expect(action3, true);
      expect(action4, true);
      expect(action5, true);
      expect(action6, true);
    });

    test('Success to increment on next and to end with saved turn', () async {
      // Given
      final turnStorage = MockTurnStorage();
      when(turnStorage.loadData()).thenAnswer((_) => Future.value(15));
      when(turnStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TurnBloc turnBloc = TurnBloc(turnStorage);
      final queue = StreamQueue(turnBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action2 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action3 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action4 = await turnBloc.perform(TurnAction.NEXT_TURN);
      final action5 = await turnBloc.perform(TurnAction.NEXT_TURN);
      turnBloc.dispose();

      // Then
      verifyInOrder([
        turnStorage.loadData(),
        turnStorage.saveData(16),
        turnStorage.saveData(17),
        turnStorage.saveData(18),
        turnStorage.saveData(19),
        turnStorage.saveData(20),
      ]);
      verifyNoMoreInteractions(turnStorage);
      expect(queue, emitsInOrder([15, 16, 17, 18, 19, 20, emitsDone]));
      expect(action1, true);
      expect(action2, true);
      expect(action3, true);
      expect(action4, true);
      expect(action5, true);
    });
  });

  /// Test Turn History bloc
  group('Turn history control logic', () {
    test('Interact with turn bloc at creation time', () {
      // Given
      final turnBloc = MockTurnBloc();
      when(turnBloc.data).thenAnswer((_) => StreamController<int>().stream);

      // When
      TurnHistoryBloc(turnBloc);

      // Then
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
    });

    test('Error next without current turn', () async {
      // Given
      final turnBloc = MockTurnBloc();
      when(turnBloc.data).thenAnswer((_) => Stream.value(null));
      final TurnHistoryBloc turnHistoryBloc = TurnHistoryBloc(turnBloc);

      // When
      await Future.value();

      // Then
      expect(
          turnHistoryBloc.perform(TurnHistoryAction.NEXT_TURN),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
    });

    test('Error prev without current turn', () async {
      // Given
      final turnBloc = MockTurnBloc();
      when(turnBloc.data).thenAnswer((_) => Stream.value(null));
      final TurnHistoryBloc turnHistoryBloc = TurnHistoryBloc(turnBloc);

      // When
      await Future.value();

      // Then
      expect(
          turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
    });

    test('Error next with current turn', () async {
      // Given
      final turnBloc = MockTurnBloc();
      when(turnBloc.data).thenAnswer((_) => Stream.value(6));
      final TurnHistoryBloc turnHistoryBloc = TurnHistoryBloc(turnBloc);

      // When
      await Future.value();

      // Then
      expect(turnHistoryBloc.perform(TurnHistoryAction.NEXT_TURN),
          throwsA((e) => e is RangeError && e.message == 'Invalid value'));
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
    });

    test('Error prev with first turn', () async {
      // Given
      final turnBloc = MockTurnBloc();
      when(turnBloc.data).thenAnswer((_) => Stream.value(0));
      final TurnHistoryBloc turnHistoryBloc = TurnHistoryBloc(turnBloc);

      // When
      await Future.value();

      // Then
      expect(turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN),
          throwsA((e) => e is RangeError && e.message == 'Invalid value'));
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
    });

    test('Answer success to prev and next with current turn', () async {
      // Given
      final turnBloc = MockTurnBloc();
      when(turnBloc.data).thenAnswer((_) => Stream.value(6));
      final TurnHistoryBloc turnHistoryBloc = TurnHistoryBloc(turnBloc);
      final queue = StreamQueue(turnHistoryBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      final action2 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      final action3 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      final action4 =
          await turnHistoryBloc.perform(TurnHistoryAction.NEXT_TURN);
      final action5 =
          await turnHistoryBloc.perform(TurnHistoryAction.NEXT_TURN);
      final action6 =
          await turnHistoryBloc.perform(TurnHistoryAction.NEXT_TURN);
      turnHistoryBloc.dispose();

      // Then
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
      expect(
          queue,
          emitsInOrder([
            [6, 6],
            [5, 6],
            [4, 6],
            [3, 6],
            [4, 6],
            [5, 6],
            [6, 6],
            emitsDone
          ]));
      expect(action1, true);
      expect(action2, true);
      expect(action3, true);
      expect(action4, true);
      expect(action5, true);
      expect(action6, true);
    });

    test('Update selected success with next current turn', () async {
      // Given
      final turnBloc = MockTurnBloc();
      final streamController = StreamController<int>();
      when(turnBloc.data).thenAnswer((_) => streamController.stream);
      final TurnHistoryBloc turnHistoryBloc = TurnHistoryBloc(turnBloc);
      final queue = StreamQueue(turnHistoryBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      streamController.sink.add(6);
      await Future.value();
      final action1 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      final action2 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      final action3 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      streamController.sink.add(7);
      await Future.value();
      final action4 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      final action5 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      streamController.sink.add(2);
      await Future.value();
      final action6 =
          await turnHistoryBloc.perform(TurnHistoryAction.PREV_TURN);
      turnHistoryBloc.dispose();

      // Then
      verify(turnBloc.data);
      verifyNoMoreInteractions(turnBloc);
      expect(
          queue,
          emitsInOrder([
            [6, 6],
            [5, 6],
            [4, 6],
            [3, 6],
            [7, 7],
            [6, 7],
            [5, 7],
            [2, 2],
            [1, 2],
            emitsDone
          ]));
      expect(action1, true);
      expect(action2, true);
      expect(action3, true);
      expect(action4, true);
      expect(action5, true);
      expect(action6, true);
    });
  });
}
