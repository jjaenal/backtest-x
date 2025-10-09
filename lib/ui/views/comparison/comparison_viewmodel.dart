import 'package:backtestx/models/trade.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class ComparisonViewModel extends BaseViewModel {
  final List<BacktestResult> results;

  ComparisonViewModel(this.results);

  final _storageService = locator<StorageService>();
  final Map<String, String> _strategyNames = {};

  Future<void> initialize() async {
    // Load human-readable strategy names for all result.strategyId
    for (final r in results) {
      final sid = r.strategyId;
      if (_strategyNames.containsKey(sid)) continue;
      try {
        final s = await _storageService.getStrategy(sid);
        if (s != null) {
          _strategyNames[sid] = s.name;
        }
      } catch (_) {}
    }
    notifyListeners();
  }

  String strategyLabelFor(String strategyId) {
    return _strategyNames[strategyId] ?? strategyId;
  }

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

  Future<bool> exportComparisonCsv() async {
    // Build CSV with summary metrics per result
    final List<List<dynamic>> rows = [];
    rows.add([
      'Strategy',
      'Symbol',
      'Timeframe',
      'Total Trades',
      'Win Rate %',
      'Profit Factor',
      'Total PnL',
      'Total PnL %',
      'Max DD',
      'Max DD %',
      'Sharpe',
      'Executed At',
    ]);

    for (final r in results) {
      final marketDataId = r.marketDataId;
      // We don't have DataManager here; include minimal fields available.
      rows.add([
        r.strategyId,
        marketDataId,
        '-',
        r.summary.totalTrades,
        r.summary.winRate.toStringAsFixed(2),
        r.summary.profitFactor.toStringAsFixed(2),
        r.summary.totalPnl.toStringAsFixed(2),
        r.summary.totalPnlPercentage.toStringAsFixed(2),
        r.summary.maxDrawdown.toStringAsFixed(2),
        r.summary.maxDrawdownPercentage.toStringAsFixed(2),
        r.summary.sharpeRatio.toStringAsFixed(2),
        r.executedAt.toIso8601String(),
      ]);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final fileName = 'comparison_backtest_results.csv';

    try {
      if (kIsWeb) {
        final blob = html.Blob([csv], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href!.isNotEmpty) {
          html.Url.revokeObjectUrl(url);
        }
        return true;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csv);
        await Share.shareXFiles([XFile(path)], text: 'BacktestX Comparison');
        return true;
      }
    } catch (_) {
      return false;
    }
  }
}
