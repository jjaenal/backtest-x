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
import 'package:flutter/services.dart';

class ComparisonViewModel extends BaseViewModel {
  final List<BacktestResult> results;

  ComparisonViewModel(this.results);

  final _storageService = locator<StorageService>();
  final Map<String, String> _strategyNames = {};

  // Global timeframe filters for per‑TF comparison section
  final Set<String> _selectedTimeframeFilters = {};
  Set<String> get selectedTimeframeFilters => _selectedTimeframeFilters;

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

  // Union of all timeframes available across compared results
  List<String> getAllAvailableTimeframes() {
    final set = <String>{};
    for (final r in results) {
      final stats = r.summary.tfStats ?? {};
      set.addAll(stats.keys);
    }
    final list = set.toList()..sort();
    return list;
  }

  // Counts of presence per timeframe across results (how many results have this TF)
  Map<String, int> getTimeframeCountsAcrossResults() {
    final counts = <String, int>{};
    for (final r in results) {
      final stats = r.summary.tfStats ?? {};
      for (final tf in stats.keys) {
        counts[tf] = (counts[tf] ?? 0) + 1;
      }
    }
    return counts;
  }

  // Toggle a timeframe filter
  void toggleTimeframeFilter(String tf) {
    if (_selectedTimeframeFilters.contains(tf)) {
      _selectedTimeframeFilters.remove(tf);
    } else {
      _selectedTimeframeFilters.add(tf);
    }
    notifyListeners();
  }

  void clearTimeframeFilters() {
    _selectedTimeframeFilters.clear();
    notifyListeners();
  }

  // Filter a specific result's tfStats by selected TFs (if any)
  Map<String, Map<String, num>> getFilteredTfStatsFor(BacktestResult r) {
    final tfStats = r.summary.tfStats ?? {};
    if (_selectedTimeframeFilters.isEmpty) return tfStats;
    final filtered = <String, Map<String, num>>{};
    for (final e in tfStats.entries) {
      if (_selectedTimeframeFilters.contains(e.key)) {
        filtered[e.key] = e.value;
      }
    }
    return filtered;
  }

  Future<bool> copySummaryToClipboard() async {
    try {
      final buffer = StringBuffer();
      buffer.writeln('Backtest Comparison Summary');
      buffer.writeln('============================');
      for (int i = 0; i < results.length; i++) {
        final r = results[i];
        final name = strategyLabelFor(r.strategyId);
        buffer.writeln(
            'R${i + 1} • $name • PnL: ${r.summary.totalPnl.toStringAsFixed(2)} (${r.summary.totalPnlPercentage.toStringAsFixed(2)}%) • WinRate: ${r.summary.winRate.toStringAsFixed(1)}% • PF: ${r.summary.profitFactor.toStringAsFixed(2)} • MaxDD: ${r.summary.maxDrawdownPercentage.toStringAsFixed(2)}% • ${r.executedAt.toIso8601String()}');
        final stats = r.summary.tfStats;
        if (stats != null && stats.isNotEmpty) {
          buffer.writeln('  Per‑Timeframe Stats:');
          final sorted = stats.entries.toList()
            ..sort((a, b) => a.key.compareTo(b.key));
          for (final e in sorted) {
            final tf = e.key;
            final s = e.value;
            final signals = (s['signals'] ?? 0).toInt();
            final trades = (s['trades'] ?? 0).toInt();
            final wins = (s['wins'] ?? 0).toInt();
            final wr = (s['winRate'] ?? 0).toDouble();
            buffer.writeln(
                '    • $tf → Signals: $signals, Trades: $trades, Wins: $wins, WinRate: ${wr.toStringAsFixed(1)}%');
          }
        }
      }
      await Clipboard.setData(ClipboardData(text: buffer.toString()));
      return true;
    } catch (_) {
      return false;
    }
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
    const fileName = 'comparison_backtest_results.csv';

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

  // Export per‑timeframe stats across compared results (respects selected TF filters)
  Future<bool> exportComparisonTfStats({String format = 'csv'}) async {
    try {
      final rows = <List<String>>[
        [
          'Result',
          'Strategy',
          'Timeframe',
          'Signals',
          'Trades',
          'Wins',
          'Win Rate',
          'Profit Factor',
          'Expectancy',
          'Avg Win',
          'Avg Loss',
          'R/R',
        ],
      ];

      for (int i = 0; i < results.length; i++) {
        final r = results[i];
        final name = strategyLabelFor(r.strategyId);
        final stats = getFilteredTfStatsFor(r);
        final entries = stats.entries.toList()
          ..sort((a, b) => a.key.compareTo(b.key));
        for (final e in entries) {
          final m = e.value;
          rows.add([
            'R${i + 1}',
            name,
            e.key,
            (m['signals'] ?? 0).toString(),
            (m['trades'] ?? 0).toString(),
            (m['wins'] ?? 0).toString(),
            ((m['winRate'] ?? 0)).toString(),
            ((m['profitFactor'] ?? 0)).toString(),
            ((m['expectancy'] ?? 0)).toString(),
            ((m['avgWin'] ?? 0)).toString(),
            ((m['avgLoss'] ?? 0)).toString(),
            ((m['rr'] ?? 0)).toString(),
          ]);
        }
      }

      // If only header present, no data
      if (rows.length == 1) {
        return false;
      }

      final isCsv = format.toLowerCase() == 'csv';
      final content = isCsv
          ? const ListToCsvConverter().convert(rows)
          : rows.map((r) => r.join('\t')).join('\n');
      final mime = isCsv ? 'text/csv' : 'text/tab-separated-values';
      final ext = isCsv ? 'csv' : 'tsv';
      final fileName = 'comparison_tfstats.$ext';

      if (kIsWeb) {
        final blob = html.Blob([content], mime);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if ((anchor.href ?? '').isNotEmpty) {
          html.Url.revokeObjectUrl(url);
        }
        return true;
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(content);
        await Share.shareXFiles([XFile(path)],
            text: 'BacktestX Comparison Per‑TF Stats');
        return true;
      }
    } catch (_) {
      return false;
    }
  }
}
