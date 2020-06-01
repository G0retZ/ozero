import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ozero/bloc/transactions.dart';
import 'package:ozero/models.dart';
import 'package:ozero/storage/common.dart';

class MockTransactionsStorage extends Mock
    implements DataStorage<List<Earning>> {}

void main() {
  /// Test Transactions bloc
  group('Transactions control logic', () {
    test('Interact with storage at creation time', () {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));

      // When
      TransactionsBloc<Earning>(transactionsStorage);

      // Then
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Error wrong action', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);

      // When
      await Future.value();

      // Then
      expect(
          transactionsBloc.perform(TransactionsAction()),
          throwsA((e) =>
              e is StateError && e.message == 'Illegal action (null, null)'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Error clear without saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);

      // When
      await Future.value();

      // Then
      expect(
          transactionsBloc.perform(null),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Answer failed to clear with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action1 = await transactionsBloc.perform(null);
      final action2 = await transactionsBloc.perform(null);
      final action3 = await transactionsBloc.perform(null);
      final action4 = await transactionsBloc.perform(null);
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(null),
        transactionsStorage.saveData(null),
        transactionsStorage.saveData(null),
        transactionsStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(queue, emitsInOrder([[], emitsDone]));
      expect(action1, false);
      expect(action2, false);
      expect(action3, false);
      expect(action4, false);
    });

    test('Answer success to clear with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      final action = await transactionsBloc.perform(null);
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(queue, emitsInOrder([[], null, emitsDone]));
      expect(action, true);
    });

    test('Answer failed to add transactions without saved transactions',
        () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast
      var earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      var earning2 = Earning(playerTurn: 0, money: 1, reputation: 2);
      var earning3 = Earning(playerTurn: 0, money: 2, reputation: 3);
      var earning4 = Earning(playerTurn: 0, money: 3, reputation: 4);

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: earning1));
      await transactionsBloc.perform(TransactionsAction(transaction: earning2));
      await transactionsBloc.perform(TransactionsAction(transaction: earning3));
      await transactionsBloc.perform(TransactionsAction(transaction: earning4));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning2]),
        transactionsStorage.saveData([earning3]),
        transactionsStorage.saveData([earning4]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(queue, emitsInOrder([null, emitsDone]));
    });

    test('Answer failed to add transactions with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<Earning> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast
      var earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      var earning2 = Earning(playerTurn: 0, money: 1, reputation: 2);
      var earning3 = Earning(playerTurn: 0, money: 2, reputation: 3);
      var earning4 = Earning(playerTurn: 0, money: 3, reputation: 4);

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: earning1));
      await transactionsBloc.perform(TransactionsAction(transaction: earning2));
      await transactionsBloc.perform(TransactionsAction(transaction: earning3));
      await transactionsBloc.perform(TransactionsAction(transaction: earning4));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning2]),
        transactionsStorage.saveData([earning3]),
        transactionsStorage.saveData([earning4]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(queue, emitsInOrder([[], emitsDone]));
    });

    test('Add transactions without saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<Earning> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast
      var earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      var earning2 = Earning(playerTurn: 0, money: 1, reputation: 2);
      var earning3 = Earning(playerTurn: 0, money: 2, reputation: 3);
      var earning4 = Earning(playerTurn: 0, money: 3, reputation: 4);

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: earning1));
      await transactionsBloc.perform(TransactionsAction(transaction: earning2));
      await transactionsBloc.perform(TransactionsAction(transaction: earning3));
      await transactionsBloc.perform(TransactionsAction(transaction: earning4));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning1, earning2]),
        transactionsStorage.saveData([earning1, earning2, earning3]),
        transactionsStorage.saveData([earning1, earning2, earning3, earning4]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            null,
            [earning1],
            [earning1, earning2],
            [earning1, earning2, earning3],
            [earning1, earning2, earning3, earning4],
            emitsDone
          ]));
    });

    test('Add transactions with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<Earning> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast
      var earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      var earning2 = Earning(playerTurn: 0, money: 1, reputation: 2);
      var earning3 = Earning(playerTurn: 0, money: 2, reputation: 3);
      var earning4 = Earning(playerTurn: 0, money: 3, reputation: 4);

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: earning1));
      await transactionsBloc.perform(TransactionsAction(transaction: earning2));
      await transactionsBloc.perform(TransactionsAction(transaction: earning3));
      await transactionsBloc.perform(TransactionsAction(transaction: earning4));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning1, earning2]),
        transactionsStorage.saveData([earning1, earning2, earning3]),
        transactionsStorage.saveData([earning1, earning2, earning3, earning4]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            [],
            [earning1],
            [earning1, earning2],
            [earning1, earning2, earning3],
            [earning1, earning2, earning3, earning4],
            emitsDone
          ]));
    });

    test('Error failed to remove by index without saved transactions',
        () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);

      // When
      await Future.value();

      // Then
      expect(
          transactionsBloc.perform(TransactionsAction(index: -1)),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      expect(
          transactionsBloc.perform(TransactionsAction(index: 0)),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      expect(
          transactionsBloc.perform(TransactionsAction(index: 1)),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Error failed to remove by wrong index', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);

      // When
      await Future.value();

      // Then
      expect(transactionsBloc.perform(TransactionsAction(index: -1)),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      expect(transactionsBloc.perform(TransactionsAction(index: 0)),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      expect(transactionsBloc.perform(TransactionsAction(index: 1)),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Answer failed to remove transaction by index', () async {
      // Given
      final earning = Earning(playerTurn: 0, money: 0, reputation: 0);
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value([earning]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<Earning> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(index: 0));
      await transactionsBloc.perform(TransactionsAction(index: 0));
      await transactionsBloc.perform(TransactionsAction(index: 0));
      await transactionsBloc.perform(TransactionsAction(index: 0));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([]),
        transactionsStorage.saveData([]),
        transactionsStorage.saveData([]),
        transactionsStorage.saveData([]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            [earning],
            emitsDone
          ]));
    });

    test('Remove transactions by index', () async {
      // Given
      var earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      var earning2 = Earning(playerTurn: 0, money: 1, reputation: 2);
      var earning3 = Earning(playerTurn: 0, money: 2, reputation: 3);
      var earning4 = Earning(playerTurn: 0, money: 3, reputation: 4);
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) =>
          Future.value([
            earning1,
            earning2,
            earning3,
            earning4,
          ]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(index: 3));
      await transactionsBloc.perform(TransactionsAction(index: 1));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1, earning2, earning3]),
        transactionsStorage.saveData([earning1, earning3]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            [earning1, earning2, earning3, earning4],
            [earning1, earning2, earning3],
            [earning1, earning3],
            emitsDone
          ]));
    });

    test('Error failed to replace by index without saved transactions',
        () async {
      // Given
          final earning = Earning(playerTurn: 0, money: 0, reputation: 0);
          final transactionsStorage = MockTransactionsStorage();
          when(transactionsStorage.loadData())
              .thenAnswer((_) => Future.value(null));
          final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);

          // When
          await Future.value();

          // Then
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: -1, transaction: earning)),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 0, transaction: earning)),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 1, transaction: earning)),
          throwsA(
              (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Error failed to replace by wrong index', () async {
      // Given
      final earning = Earning(playerTurn: 0, money: 0, reputation: 0);
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      final TransactionsBloc<Earning> transactionsBloc =
      TransactionsBloc(transactionsStorage);

      // When
      await Future.value();

      // Then
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: -1, transaction: earning)),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 0, transaction: earning)),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 1, transaction: earning)),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Answer failed to replace by index with saved transactions', () async {
      // Given
      final earning = Earning(playerTurn: 0, money: 0, reputation: 0);
      final earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value([earning]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<Earning> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: earning1));
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: earning1));
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: earning1));
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: earning1));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning1]),
        transactionsStorage.saveData([earning1]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            [earning],
            emitsDone
          ]));
    });

    test('Replace transactions by index', () async {
      // Given
      var earning1 = Earning(playerTurn: 0, money: 0, reputation: 0);
      var earning2 = Earning(playerTurn: 0, money: 1, reputation: 2);
      var earning3 = Earning(playerTurn: 0, money: 2, reputation: 3);
      var earning4 = Earning(playerTurn: 0, money: 3, reputation: 4);
      var earning5 = Earning(playerTurn: 0, money: 4, reputation: 5);
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) =>
          Future.value([
            earning1,
            earning2,
            earning3,
            earning4,
          ]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<Earning> transactionsBloc =
          TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc
          .perform(TransactionsAction(index: 1, transaction: earning5));
      await transactionsBloc
          .perform(TransactionsAction(index: 3, transaction: earning5));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData([earning1, earning5, earning3, earning4]),
        transactionsStorage.saveData([earning1, earning5, earning3, earning5]),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            [earning1, earning2, earning3, earning4],
            [earning1, earning5, earning3, earning4],
            [earning1, earning5, earning3, earning5],
            emitsDone
          ]));
    });
  });
}
