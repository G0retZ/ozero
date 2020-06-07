import 'dart:async';

import 'package:ozero/bloc/transactions.dart';
import 'package:ozero/models.dart';

import 'common.dart';

/// Controls the Transaction input.
/// Input - Transaction to update the cached data or null to save it
/// Output - updated Transaction
class TransactionInputBloc<D extends Composable<D>> extends Bloc<D, D> {
  final TransactionsBloc<D> _transactionsBloc;
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
