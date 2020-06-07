import 'dart:async';

import 'package:async/async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:ozero/bloc/transactions.dart';
import 'package:ozero/storage/common.dart';

class MockTransactionsStorage extends Mock
    implements DataStorage<List<String>> {}

void main() {
  /// Test Transactions bloc
  group('Transactions control logic', () {
    test('Interact with storage at creation time', () {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));

      // When
      TransactionsBloc<String>(transactionsStorage);

      // Then
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Error wrong action', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      final TransactionsBloc<String> transactionsBloc =
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

    test('Answer failed to clear with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<String> transactionsBloc =
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

    test('Answer success to clear without saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      final action = await transactionsBloc.perform(null);
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(null),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(queue, emitsInOrder([null, null, emitsDone]));
      expect(action, true);
    });

    test('Answer success to clear with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<String> transactionsBloc =
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
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: 'val1'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val2'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val3'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val4'));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val2']),
        transactionsStorage.saveData(['val3']),
        transactionsStorage.saveData(['val4']),
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
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: 'val1'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val2'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val3'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val4'));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val2']),
        transactionsStorage.saveData(['val3']),
        transactionsStorage.saveData(['val4']),
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
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: 'val1'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val2'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val3'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val4'));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val1', 'val2']),
        transactionsStorage.saveData(['val1', 'val2', 'val3']),
        transactionsStorage.saveData(['val1', 'val2', 'val3', 'val4']),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            null,
            ['val1'],
            ['val1', 'val2'],
            ['val1', 'val2', 'val3'],
            ['val1', 'val2', 'val3', 'val4'],
            emitsDone
          ]));
    });

    test('Add transactions with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc.perform(TransactionsAction(transaction: 'val1'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val2'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val3'));
      await transactionsBloc.perform(TransactionsAction(transaction: 'val4'));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val1', 'val2']),
        transactionsStorage.saveData(['val1', 'val2', 'val3']),
        transactionsStorage.saveData(['val1', 'val2', 'val3', 'val4']),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            [],
            ['val1'],
            ['val1', 'val2'],
            ['val1', 'val2', 'val3'],
            ['val1', 'val2', 'val3', 'val4'],
            emitsDone
          ]));
    });

    test('Error failed to remove by index without saved transactions',
        () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(null));
      final TransactionsBloc<String> transactionsBloc =
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
      final TransactionsBloc<String> transactionsBloc =
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
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(['val']));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<String> transactionsBloc =
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
            ['val'],
            emitsDone
          ]));
    });

    test('Remove transactions by index', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) =>
          Future.value([
            'val1',
            'val2',
            'val3',
            'val4',
          ]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<String> transactionsBloc =
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
        transactionsStorage.saveData(['val1', 'val2', 'val3']),
        transactionsStorage.saveData(['val1', 'val3']),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            ['val1', 'val2', 'val3', 'val4'],
            ['val1', 'val2', 'val3'],
            ['val1', 'val3'],
            emitsDone
          ]));
    });

    test('Error failed to replace by index without saved transactions',
        () async {
          // Given
          final transactionsStorage = MockTransactionsStorage();
          when(transactionsStorage.loadData())
              .thenAnswer((_) => Future.value(null));
          final TransactionsBloc<String> transactionsBloc =
          TransactionsBloc(transactionsStorage);

          // When
          await Future.value();

          // Then
          expect(
              transactionsBloc
                  .perform(TransactionsAction(index: -1, transaction: 'val')),
              throwsA(
                      (e) =>
                  e is ArgumentError && e.message == 'Must not be null'));
          expect(
              transactionsBloc
                  .perform(TransactionsAction(index: 0, transaction: 'val')),
              throwsA(
                      (e) =>
                  e is ArgumentError && e.message == 'Must not be null'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 1, transaction: 'val')),
          throwsA(
                  (e) => e is ArgumentError && e.message == 'Must not be null'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Error failed to replace by wrong index', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) => Future.value([]));
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);

      // When
      await Future.value();

      // Then
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: -1, transaction: 'val')),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 0, transaction: 'val')),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      expect(
          transactionsBloc
              .perform(TransactionsAction(index: 1, transaction: 'val')),
          throwsA((e) => e is RangeError && e.message == 'Index out of range'));
      verify(transactionsStorage.loadData());
      verifyNoMoreInteractions(transactionsStorage);
    });

    test('Answer failed to replace by index with saved transactions', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData())
          .thenAnswer((_) => Future.value(['val']));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(false));
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: 'val1'));
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: 'val1'));
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: 'val1'));
      await transactionsBloc
          .perform(TransactionsAction(index: 0, transaction: 'val1'));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val1']),
        transactionsStorage.saveData(['val1']),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            ['val'],
            emitsDone
          ]));
    });

    test('Replace transactions by index', () async {
      // Given
      final transactionsStorage = MockTransactionsStorage();
      when(transactionsStorage.loadData()).thenAnswer((_) =>
          Future.value([
            'val1',
            'val2',
            'val3',
            'val4',
          ]));
      when(transactionsStorage.saveData(argThat(anything)))
          .thenAnswer((_) => Future.value(true));
      final TransactionsBloc<String> transactionsBloc =
      TransactionsBloc(transactionsStorage);
      final queue = StreamQueue(transactionsBloc.data);
      queue.lookAhead(1); //subscribe to broadcast

      // When
      await Future.value();
      await transactionsBloc
          .perform(TransactionsAction(index: 1, transaction: 'val5'));
      await transactionsBloc
          .perform(TransactionsAction(index: 3, transaction: 'val5'));
      transactionsBloc.dispose();

      // Then
      verifyInOrder([
        transactionsStorage.loadData(),
        transactionsStorage.saveData(['val1', 'val5', 'val3', 'val4']),
        transactionsStorage.saveData(['val1', 'val5', 'val3', 'val5']),
      ]);
      verifyNoMoreInteractions(transactionsStorage);
      expect(
          queue,
          emitsInOrder([
            ['val1', 'val2', 'val3', 'val4'],
            ['val1', 'val5', 'val3', 'val4'],
            ['val1', 'val5', 'val3', 'val5'],
            emitsDone
          ]));
    });
  });
}
