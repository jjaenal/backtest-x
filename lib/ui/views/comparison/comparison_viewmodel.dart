import 'package:backtestx/models/trade.dart';
import 'package:stacked/stacked.dart';

class ComparisonViewModel extends BaseViewModel {
  final List<BacktestResult> results;

  ComparisonViewModel(this.results);

  BacktestResult get bestByPnL =>
      results.reduce((a, b) => a.summary.totalPnl > b.summary.totalPnl ? a : b);

  BacktestResult get bestByWinRate =>
      results.reduce((a, b) => a.summary.winRate > b.summary.winRate ? a : b);

  BacktestResult get bestByProfitFactor => results.reduce(
      (a, b) => a.summary.profitFactor > b.summary.profitFactor ? a : b);

  BacktestResult get lowestDrawdown => results.reduce((a, b) =>
      a.summary.maxDrawdownPercentage < b.summary.maxDrawdownPercentage
          ? a
          : b);
}
