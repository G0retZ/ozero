import 'dart:async';

import 'package:ozero/storage/common.dart';

import '../models.dart';
import 'common.dart';

/// Transaction action.
/// [index] - index of removal or replacement (if [transaction] not null)
/// [transaction] - transaction [D] to append or replace with (if [index] not null)
class TransactionsAction<D> {
  final int index;
  final D transaction;

  TransactionsAction({this.index, this.transaction});
}

/// Controls the game transactions.
/// Input - Action on transactions or null to clear all.
/// Output - all transactions
class TransactionsBloc<D> extends Bloc<TransactionsAction<D>, List<D>> {
  final DataStorage<List<D>> _transactionsStorage;
  List<D> _transactions;

  TransactionsBloc(this._transactionsStorage) {
    _transactionsStorage.loadData().then((value) {
      iSink.add(_transactions = value);
    });
  }

  @override
  Stream<List<D>> get data =>
      _transactions != null ? super.data.startWith(_transactions) : super.data;

  @override
  Future<bool> perform(TransactionsAction<D> action) async {
    var result = false;
    if (action == null) {
      result = await _tryToSave(null);
    } else if (action.index == null && action.transaction == null) {
      throw StateError('Illegal action (null, null)');
    } else if (action.index == null && action.transaction != null) {
      result = await _tryToSave(
          (_transactions?.toList() ?? [])..add(action.transaction));
    } else if (action.index != null && action.transaction == null) {
      final index = RangeError.checkValidIndex(
        action.index,
        ArgumentError.checkNotNull(_transactions, '_transactions'),
      );
      result = await _tryToSave(_transactions.toList()
        ..removeAt(index));
    } else if (action.index != null && action.transaction != null) {
      final index = RangeError.checkValidIndex(
        action.index,
        ArgumentError.checkNotNull(_transactions, '_transactions'),
      );
      result = await _tryToSave(_transactions.toList()
        ..replaceRange(index, index + 1, [action.transaction]));
    }
    return result;
  }

  Future<bool> _tryToSave(List<D> data) async {
    final result = await _transactionsStorage.saveData(data);
    if (result) {
      iSink.add(_transactions = data);
    }
    return result;
  }
}

/// Controls the Transaction input.
/// Input - Transaction to update the cached data or null to save it
/// Output - updated Transaction
class TransactionInputBloc<D extends Composable<D>> extends Bloc<D, D> {
  final Bloc<TransactionsAction<D>, dynamic> _transactionsBloc;
  final D _initValue;
  D _data;

  TransactionInputBloc(this._transactionsBloc, this._initValue)
      : _data = _initValue;

  @override
  Future<bool> perform(D action) async {
    if (action == null) {
      final tmp = _data;
      _data = _initValue;
      return _transactionsBloc.perform(
        TransactionsAction(
          transaction: tmp.assertComposed(),
        ),
      );
    } else if (_data == null) {
      iSink.add(_data = action);
    } else {
      iSink.add(_data = _data.mergeWith(action));
    }
    return true;
  }
}
