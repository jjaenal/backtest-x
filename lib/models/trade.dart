import 'package:freezed_annotation/freezed_annotation.dart';

part 'trade.freezed.dart';
part 'trade.g.dart';

@freezed
class Trade with _$Trade {
  const factory Trade({
    required String id,
    required TradeDirection direction,
    required DateTime entryTime,
    required double entryPrice,
    required double lotSize,
    DateTime? exitTime,
    double? exitPrice,
    double? stopLoss,
    double? takeProfit,
    TradeStatus? status,
    double? pnl,
    double? pnlPercentage,
    String? exitReason, // "TP Hit", "SL Hit", "Exit Signal", "End of Data"
  }) = _Trade;

  factory Trade.fromJson(Map<String, dynamic> json) => _$TradeFromJson(json);
}

enum TradeDirection {
  buy,
  sell,
}

enum TradeStatus {
  open,
  closed,
}

@freezed
class BacktestResult with _$BacktestResult {
  const factory BacktestResult({
    required String id,
    required String strategyId,
    required DateTime executedAt,
    required List<Trade> trades,
    required BacktestSummary summary,
    required List<EquityPoint> equityCurve,
  }) = _BacktestResult;

  factory BacktestResult.fromJson(Map<String, dynamic> json) =>
      _$BacktestResultFromJson(json);
}

@freezed
class BacktestSummary with _$BacktestSummary {
  const factory BacktestSummary({
    required int totalTrades,
    required int winningTrades,
    required int losingTrades,
    required double winRate,
    required double totalPnl,
    required double totalPnlPercentage,
    required double profitFactor,
    required double maxDrawdown,
    required double maxDrawdownPercentage,
    required double sharpeRatio,
    required double averageWin,
    required double averageLoss,
    required double largestWin,
    required double largestLoss,
    required double expectancy,
  }) = _BacktestSummary;

  factory BacktestSummary.fromJson(Map<String, dynamic> json) =>
      _$BacktestSummaryFromJson(json);
}

@freezed
class EquityPoint with _$EquityPoint {
  const factory EquityPoint({
    required DateTime timestamp,
    required double equity,
    required double drawdown,
  }) = _EquityPoint;

  factory EquityPoint.fromJson(Map<String, dynamic> json) =>
      _$EquityPointFromJson(json);
}
