import 'package:ozero/bloc/players.dart';
import 'package:ozero/bloc/transaction_input.dart';
import 'package:ozero/bloc/transactions.dart';
import 'package:ozero/bloc/turn.dart';
import 'package:ozero/models.dart';
import 'package:ozero/storage/preferences.dart';

class Providers {
  // Storage
  static final currentTurnStorage = CurrentTurnStorage();
  static final playersStorage = PlayersStorage();
  static final earningsStorage = EarningsStorage();
  static final remittancesStorage = RemittancesStorage();
  static final moneyLossStorage = MoneyLossStorage();
  static final reputationLossStorage = ReputationLossStorage();

  // primary BLoC
  static final turnBloc = TurnBloc(currentTurnStorage);

  static final playersBloc = PlayersBloc(playersStorage);

  static final earningsBloc = TransactionsBloc<Earning>(earningsStorage);

  static final remittancesBloc =
      TransactionsBloc<Remittance>(remittancesStorage);

  static final moneyLossBloc = TransactionsBloc<DirtyTrick>(moneyLossStorage);

  static final reputationLossBloc =
      TransactionsBloc<DirtyTrick>(reputationLossStorage);

  // secondary BLoC
  static final turnHistoryBloc = TurnHistoryBloc(turnBloc);

  static final earningInputBloc = TransactionInputBloc<Earning>(
      earningsBloc, Earning(money: 0, reputation: 0));
}
