import 'dart:async';

import 'package:ozero/storage/common.dart';

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
      ArgumentError.checkNotNull(_transactions, "_transactions");
      result = await tryToSave(null);
    } else if (action.index == null && action.transaction == null) {
      throw StateError('Illegal action (null, null)');
    } else if (action.index == null && action.transaction != null) {
      result = await tryToSave(
          (_transactions?.toList() ?? [])..add(action.transaction));
    } else if (action.index != null && action.transaction == null) {
      final index = RangeError.checkValidIndex(
        action.index,
        ArgumentError.checkNotNull(_transactions, "_transactions"),
      );
      result = await tryToSave(_transactions.toList()..removeAt(index));
    } else if (action.index != null && action.transaction != null) {
      final index = RangeError.checkValidIndex(
        action.index,
        ArgumentError.checkNotNull(_transactions, "_transactions"),
      );
      result = await tryToSave(_transactions.toList()
        ..replaceRange(index, index + 1, [action.transaction]));
    }
    return result;
  }

  Future<bool> tryToSave(List<D> data) async {
    final result = await _transactionsStorage.saveData(data);
    if (result) {
      iSink.add(_transactions = data);
    }
    return result;
  }
}
