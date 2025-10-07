import 'dart:math';
import 'package:backtestx/models/trade.dart';

/// Helper class for comparing multiple backtest results
class ResultComparison {
  final List<BacktestResult> results;

  ResultComparison(this.results) {
    if (results.length < 2) {
      throw ArgumentError('At least 2 results required for comparison');
    }
    if (results.length > 4) {
      throw ArgumentError('Maximum 4 results can be compared');
    }
  }

  // Best performers
  BacktestResult get bestByPnL =>
      results.reduce((a, b) => a.summary.totalPnl > b.summary.totalPnl ? a : b);

  BacktestResult get worstByPnL =>
      results.reduce((a, b) => a.summary.totalPnl < b.summary.totalPnl ? a : b);

  BacktestResult get bestByWinRate =>
      results.reduce((a, b) => a.summary.winRate > b.summary.winRate ? a : b);

  BacktestResult get bestByProfitFactor => results.reduce(
      (a, b) => a.summary.profitFactor > b.summary.profitFactor ? a : b);

  BacktestResult get lowestDrawdown => results.reduce((a, b) =>
      a.summary.maxDrawdownPercentage < b.summary.maxDrawdownPercentage
          ? a
          : b);

  BacktestResult get bestSharpeRatio => results
      .reduce((a, b) => a.summary.sharpeRatio > b.summary.sharpeRatio ? a : b);

  BacktestResult get mostTrades => results
      .reduce((a, b) => a.summary.totalTrades > b.summary.totalTrades ? a : b);

  BacktestResult get fewestTrades => results
      .reduce((a, b) => a.summary.totalTrades < b.summary.totalTrades ? a : b);

  // Aggregate statistics
  double get avgPnL {
    final total =
        results.map((r) => r.summary.totalPnl).reduce((a, b) => a + b);
    return total / results.length;
  }

  double get avgPnLPercent {
    final total = results
        .map((r) => r.summary.totalPnlPercentage)
        .reduce((a, b) => a + b);
    return total / results.length;
  }

  double get avgWinRate {
    final total = results.map((r) => r.summary.winRate).reduce((a, b) => a + b);
    return total / results.length;
  }

  double get avgProfitFactor {
    final total =
        results.map((r) => r.summary.profitFactor).reduce((a, b) => a + b);
    return total / results.length;
  }

  double get avgDrawdown {
    final total = results
        .map((r) => r.summary.maxDrawdownPercentage)
        .reduce((a, b) => a + b);
    return total / results.length;
  }

  int get totalTrades {
    return results.map((r) => r.summary.totalTrades).reduce((a, b) => a + b);
  }

  // Variance & standard deviation
  double get pnlStandardDeviation {
    if (results.length < 2) return 0;

    final mean = avgPnL;
    final variance = results.map((r) {
          final diff = r.summary.totalPnl - mean;
          return diff * diff;
        }).reduce((a, b) => a + b) /
        results.length;

    return sqrt(variance);
  }

  double get winRateStandardDeviation {
    if (results.length < 2) return 0;

    final mean = avgWinRate;
    final variance = results.map((r) {
          final diff = r.summary.winRate - mean;
          return diff * diff;
        }).reduce((a, b) => a + b) /
        results.length;

    return sqrt(variance);
  }

  // Consistency analysis
  bool get isConsistent {
    return pnlStandardDeviation < (avgPnL.abs() * 0.5);
  }

  String get consistencyLabel {
    final stdDev = pnlStandardDeviation;
    final avgAbs = avgPnL.abs();

    if (avgAbs == 0) return 'No Data';

    final coefficient = stdDev / avgAbs;

    if (coefficient < 0.2) return 'Very Consistent';
    if (coefficient < 0.5) return 'Consistent';
    if (coefficient < 1.0) return 'Moderate';
    if (coefficient < 2.0) return 'Inconsistent';
    return 'Very Inconsistent';
  }

  // Winner determination
  BacktestResult get overallWinner {
    // Composite scoring
    final scores = results.map((result) {
      double score = 0;

      // PnL score (40%)
      final pnlRank = _rankByPnL(result);
      score += (results.length - pnlRank) * 40 / results.length;

      // Win rate score (30%)
      final winRateRank = _rankByWinRate(result);
      score += (results.length - winRateRank) * 30 / results.length;

      // Drawdown score (30% - lower is better)
      final drawdownRank = _rankByDrawdown(result);
      score += drawdownRank * 30 / results.length;

      return MapEntry(result, score);
    }).toList();

    scores.sort((a, b) => b.value.compareTo(a.value));
    return scores.first.key;
  }

  int _rankByPnL(BacktestResult result) {
    final sorted = List<BacktestResult>.from(results);
    sorted.sort((a, b) => b.summary.totalPnl.compareTo(a.summary.totalPnl));
    return sorted.indexOf(result);
  }

  int _rankByWinRate(BacktestResult result) {
    final sorted = List<BacktestResult>.from(results);
    sorted.sort((a, b) => b.summary.winRate.compareTo(a.summary.winRate));
    return sorted.indexOf(result);
  }

  int _rankByDrawdown(BacktestResult result) {
    final sorted = List<BacktestResult>.from(results);
    sorted.sort((a, b) => a.summary.maxDrawdownPercentage
        .compareTo(b.summary.maxDrawdownPercentage));
    return sorted.indexOf(result);
  }

  // Comparison matrix (for table display)
  Map<String, List<dynamic>> get comparisonMatrix {
    return {
      'Total P&L': results.map((r) => r.summary.totalPnl).toList(),
      'Return %': results.map((r) => r.summary.totalPnlPercentage).toList(),
      'Win Rate': results.map((r) => r.summary.winRate).toList(),
      'Total Trades': results.map((r) => r.summary.totalTrades).toList(),
      'Winning Trades': results.map((r) => r.summary.winningTrades).toList(),
      'Losing Trades': results.map((r) => r.summary.losingTrades).toList(),
      'Profit Factor': results.map((r) => r.summary.profitFactor).toList(),
      'Max Drawdown': results.map((r) => r.summary.maxDrawdown).toList(),
      'Max Drawdown %':
          results.map((r) => r.summary.maxDrawdownPercentage).toList(),
      'Sharpe Ratio': results.map((r) => r.summary.sharpeRatio).toList(),
      'Average Win': results.map((r) => r.summary.averageWin).toList(),
      'Average Loss': results.map((r) => r.summary.averageLoss).toList(),
      'Largest Win': results.map((r) => r.summary.largestWin).toList(),
      'Largest Loss': results.map((r) => r.summary.largestLoss).toList(),
      'Expectancy': results.map((r) => r.summary.expectancy).toList(),
    };
  }

  // Export to CSV format
  String toCsv() {
    final buffer = StringBuffer();

    // Header
    buffer.write('Metric');
    for (int i = 0; i < results.length; i++) {
      buffer.write(',Result ${i + 1}');
    }
    buffer.writeln();

    // Data rows
    comparisonMatrix.forEach((metric, values) {
      buffer.write(metric);
      for (var value in values) {
        buffer.write(',$value');
      }
      buffer.writeln();
    });

    return buffer.toString();
  }

  // Summary text
  String get summaryText {
    final buffer = StringBuffer();
    buffer.writeln('Comparison Summary:');
    buffer.writeln('─' * 50);
    buffer.writeln('Number of Results: ${results.length}');
    buffer.writeln('');

    buffer.writeln('Best Performers:');
    buffer.writeln('  • Highest P&L: Result ${results.indexOf(bestByPnL) + 1} '
        '(\$${bestByPnL.summary.totalPnl.toStringAsFixed(2)})');
    buffer.writeln(
        '  • Best Win Rate: Result ${results.indexOf(bestByWinRate) + 1} '
        '(${bestByWinRate.summary.winRate.toStringAsFixed(1)}%)');
    buffer.writeln(
        '  • Best Profit Factor: Result ${results.indexOf(bestByProfitFactor) + 1} '
        '(${bestByProfitFactor.summary.profitFactor.toStringAsFixed(2)})');
    buffer.writeln(
        '  • Lowest Drawdown: Result ${results.indexOf(lowestDrawdown) + 1} '
        '(${lowestDrawdown.summary.maxDrawdownPercentage.toStringAsFixed(2)}%)');
    buffer.writeln('');

    buffer.writeln('Averages:');
    buffer.writeln('  • Avg P&L: \$${avgPnL.toStringAsFixed(2)}');
    buffer.writeln('  • Avg Win Rate: ${avgWinRate.toStringAsFixed(1)}%');
    buffer.writeln(
        '  • Avg Profit Factor: ${avgProfitFactor.toStringAsFixed(2)}');
    buffer.writeln('  • Avg Drawdown: ${avgDrawdown.toStringAsFixed(2)}%');
    buffer.writeln('');

    buffer.writeln(
        'Overall Winner: Result ${results.indexOf(overallWinner) + 1}');
    buffer.writeln('Consistency: $consistencyLabel');

    return buffer.toString();
  }
}

// Extension untuk MapEntry sorting
extension on List<MapEntry<BacktestResult, double>> {}
