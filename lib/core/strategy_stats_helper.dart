// Helper class for workspace view (calculated on-the-fly from results)
// This is NOT stored in database, computed dynamically

import 'package:backtestx/models/trade.dart';

class StrategyStatsData {
  final String strategyId;
  final int totalBacktests;
  final double avgPnl;
  final double avgPnlPercent;
  final double avgWinRate;
  final double bestPnl;
  final double worstPnl;
  final DateTime? lastRunDate;

  const StrategyStatsData({
    required this.strategyId,
    required this.totalBacktests,
    required this.avgPnl,
    required this.avgPnlPercent,
    required this.avgWinRate,
    required this.bestPnl,
    required this.worstPnl,
    this.lastRunDate,
  });

  factory StrategyStatsData.empty(String strategyId) {
    return StrategyStatsData(
      strategyId: strategyId,
      totalBacktests: 0,
      avgPnl: 0,
      avgPnlPercent: 0,
      avgWinRate: 0,
      bestPnl: 0,
      worstPnl: 0,
    );
  }

  // Factory from results list
  factory StrategyStatsData.fromResults(
    String strategyId,
    List<BacktestResult> results,
  ) {
    if (results.isEmpty) {
      return StrategyStatsData.empty(strategyId);
    }

    try {
      final totalPnl =
          results.map((r) => r.summary.totalPnl).reduce((a, b) => a + b);

      final totalPnlPercent = results
          .map((r) => r.summary.totalPnlPercentage)
          .reduce((a, b) => a + b);

      final totalWinRate =
          results.map((r) => r.summary.winRate).reduce((a, b) => a + b);

      final bestResult = results
          .reduce((a, b) => a.summary.totalPnl > b.summary.totalPnl ? a : b);

      final worstResult = results
          .reduce((a, b) => a.summary.totalPnl < b.summary.totalPnl ? a : b);

      return StrategyStatsData(
        strategyId: strategyId,
        totalBacktests: results.length,
        avgPnl: totalPnl / results.length,
        avgPnlPercent: totalPnlPercent / results.length,
        avgWinRate: totalWinRate / results.length,
        bestPnl: bestResult.summary.totalPnl,
        worstPnl: worstResult.summary.totalPnl,
        lastRunDate: results.first.executedAt,
      );
    } catch (e) {
      print('Error calculating stats from results: $e');
      return StrategyStatsData.empty(strategyId);
    }
  }

  // Getters
  bool get hasResults => totalBacktests > 0;
  bool get isProfitable => avgPnl > 0;

  String get performanceLabel {
    if (!hasResults) return 'No Data';
    if (avgPnlPercent > 20) return 'Excellent';
    if (avgPnlPercent > 10) return 'Good';
    if (avgPnlPercent > 0) return 'Profitable';
    return 'Unprofitable';
  }

  String get performanceEmoji {
    if (!hasResults) return '📊';
    if (avgPnlPercent > 20) return '🚀';
    if (avgPnlPercent > 10) return '📈';
    if (avgPnlPercent > 0) return '✅';
    return '📉';
  }

  // Formatting helpers
  String formatAvgPnl() {
    final sign = avgPnl >= 0 ? '+' : '';
    return '$sign\$${avgPnl.toStringAsFixed(2)}';
  }

  String formatAvgPnlPercent() {
    final sign = avgPnlPercent >= 0 ? '+' : '';
    return '$sign${avgPnlPercent.toStringAsFixed(2)}%';
  }

  String formatWinRate() {
    return '${avgWinRate.toStringAsFixed(1)}%';
  }

  String formatBestPnl() {
    final sign = bestPnl >= 0 ? '+' : '';
    return '$sign\$${bestPnl.toStringAsFixed(2)}';
  }

  String formatWorstPnl() {
    final sign = worstPnl >= 0 ? '+' : '';
    return '$sign\$${worstPnl.toStringAsFixed(2)}';
  }

  // Risk assessment
  String get riskAssessment {
    if (!hasResults) return 'Unknown';

    // final pnlRange = bestPnl - worstPnl;
    final avgDrawback = worstPnl.abs();

    if (avgDrawback < avgPnl * 0.5) return 'Low Risk';
    if (avgDrawback < avgPnl * 1.5) return 'Medium Risk';
    return 'High Risk';
  }

  // Consistency score (0-100)
  double get consistencyScore {
    if (!hasResults || totalBacktests < 2) return 0;

    // Calculate how consistent the results are
    final pnlRange = bestPnl - worstPnl;
    if (pnlRange == 0) return 100;

    final avgDeviation = pnlRange / avgPnl.abs();
    final score = 100 - (avgDeviation.clamp(0, 100));

    return score.clamp(0, 100).toDouble();
  }

  String get consistencyLabel {
    final score = consistencyScore;
    if (score >= 80) return 'Very Consistent';
    if (score >= 60) return 'Consistent';
    if (score >= 40) return 'Moderate';
    if (score >= 20) return 'Inconsistent';
    return 'Very Inconsistent';
  }

  // Overall rating (composite score)
  double get overallRating {
    if (!hasResults) return 0;

    int score = 0;

    // Profitability (40 points)
    if (isProfitable) {
      if (avgPnlPercent > 20)
        score += 40;
      else if (avgPnlPercent > 10)
        score += 30;
      else if (avgPnlPercent > 5)
        score += 20;
      else
        score += 10;
    }

    // Win rate (30 points)
    if (avgWinRate >= 60)
      score += 30;
    else if (avgWinRate >= 50)
      score += 20;
    else if (avgWinRate >= 40) score += 10;

    // Consistency (30 points)
    final consistency = consistencyScore;
    if (consistency >= 80)
      score += 30;
    else if (consistency >= 60)
      score += 20;
    else if (consistency >= 40) score += 10;

    return score.toDouble();
  }

  String get overallRatingLabel {
    final rating = overallRating;
    if (rating >= 80) return 'Excellent ⭐⭐⭐⭐⭐';
    if (rating >= 60) return 'Good ⭐⭐⭐⭐';
    if (rating >= 40) return 'Fair ⭐⭐⭐';
    if (rating >= 20) return 'Poor ⭐⭐';
    return 'Bad ⭐';
  }

  // Convert to map for export
  Map<String, dynamic> toMap() {
    return {
      'strategyId': strategyId,
      'totalBacktests': totalBacktests,
      'avgPnl': avgPnl,
      'avgPnlPercent': avgPnlPercent,
      'avgWinRate': avgWinRate,
      'bestPnl': bestPnl,
      'worstPnl': worstPnl,
      'lastRunDate': lastRunDate?.toIso8601String(),
      'performanceLabel': performanceLabel,
      'riskAssessment': riskAssessment,
      'consistencyScore': consistencyScore,
      'consistencyLabel': consistencyLabel,
      'overallRating': overallRating,
      'overallRatingLabel': overallRatingLabel,
    };
  }

  @override
  String toString() {
    return 'StrategyStats(tests: $totalBacktests, avgPnL: ${formatAvgPnl()}, '
        'winRate: ${formatWinRate()}, rating: $overallRatingLabel)';
  }
}

// Extension untuk List<BacktestResult> agar lebih mudah
extension BacktestResultListX on List<BacktestResult> {
  StrategyStatsData toStats(String strategyId) {
    return StrategyStatsData.fromResults(strategyId, this);
  }

  // Get best/worst results
  BacktestResult? get bestByPnL {
    if (isEmpty) return null;
    return reduce((a, b) => a.summary.totalPnl > b.summary.totalPnl ? a : b);
  }

  BacktestResult? get worstByPnL {
    if (isEmpty) return null;
    return reduce((a, b) => a.summary.totalPnl < b.summary.totalPnl ? a : b);
  }

  BacktestResult? get bestByWinRate {
    if (isEmpty) return null;
    return reduce((a, b) => a.summary.winRate > b.summary.winRate ? a : b);
  }

  BacktestResult? get bestByProfitFactor {
    if (isEmpty) return null;
    return reduce(
        (a, b) => a.summary.profitFactor > b.summary.profitFactor ? a : b);
  }

  BacktestResult? get lowestDrawdown {
    if (isEmpty) return null;
    return reduce((a, b) =>
        a.summary.maxDrawdownPercentage < b.summary.maxDrawdownPercentage
            ? a
            : b);
  }

  // Filter methods
  List<BacktestResult> get profitableOnly {
    return where((r) => r.summary.totalPnl > 0).toList();
  }

  List<BacktestResult> get unprofitableOnly {
    return where((r) => r.summary.totalPnl <= 0).toList();
  }

  List<BacktestResult> filterByDateRange(DateTime start, DateTime end) {
    return where(
            (r) => r.executedAt.isAfter(start) && r.executedAt.isBefore(end))
        .toList();
  }

  List<BacktestResult> get recentResults {
    final sorted = List<BacktestResult>.from(this);
    sorted.sort((a, b) => b.executedAt.compareTo(a.executedAt));
    return sorted;
  }
}
