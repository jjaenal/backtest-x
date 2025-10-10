import 'package:backtestx/models/trade.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/services/pdf_export_service.dart';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:backtestx/services/prefs_service.dart';
import 'package:backtestx/debug/perf_monitor.dart';
import 'package:backtestx/helpers/filename_helper.dart';
import 'package:backtestx/services/share_service.dart';

class ComparisonViewModel extends BaseViewModel {
  final List<BacktestResult> results;

  ComparisonViewModel(this.results);

  final _storageService = locator<StorageService>();
  final _pdfExportService = locator<PdfExportService>();
  final _prefs = PrefsService();
  final Map<String, String> _strategyNames = {};

  // Lightweight notify throttle to avoid spam renders during rapid interactions
  Timer? _notifyTimer;
  void _throttleNotify() {
    _notifyTimer?.cancel();
    _notifyTimer = Timer(const Duration(milliseconds: 30), () {
      notifyListeners();
    });
  }

  // Memoization cache for grouped per‑TF metric series
  Map<String, Map<String, double>>? _groupedCache;
  String? _groupedCacheKey;
  void _invalidateGroupedCache() {
    _groupedCache = null;
    _groupedCacheKey = null;
  }

  String _computeGroupedCacheKey() {
    final buf = StringBuffer();
    buf.write(_selectedTfMetric);
    buf.write('|');
    final filters = _selectedTimeframeFilters.toList()..sort();
    buf.write(filters.join(','));
    buf.write('|');
    buf.write('len=${results.length}');
    for (final r in results) {
      final tfLen = (r.summary.tfStats ?? {}).length;
      buf.write(';');
      buf.write(r.id);
      buf.write(':');
      buf.write(tfLen);
    }
    return buf.toString();
  }

  // Global timeframe filters for per‑TF comparison section
  final Set<String> _selectedTimeframeFilters = {};
  Set<String> get selectedTimeframeFilters => _selectedTimeframeFilters;

  // Per‑TF comparison: selectable metric
  static const List<String> availableTfMetrics = [
    'winRate',
    'profitFactor',
    'expectancy',
    'rr',
    'trades',
    'signals',
    'wins',
    'avgWin',
    'avgLoss',
  ];

  String _selectedTfMetric = 'winRate';
  String get selectedTfMetric => _selectedTfMetric;
  void setSelectedTfMetric(String metric) {
    _selectedTfMetric = metric;
    _invalidateGroupedCache();
    _throttleNotify();
  }

  // Grouped chart sorting mode
  static const List<String> groupedSortOptions = [
    'timeframe',
    'valueAsc',
    'valueDesc',
  ];
  String _groupedTfSort = 'timeframe';
  String get groupedTfSort => _groupedTfSort;
  void setGroupedTfSort(String mode) {
    if (groupedSortOptions.contains(mode)) {
      _groupedTfSort = mode;
      // Persist preference
      _prefs.setString('compare.groupedTfSort', mode);
      _throttleNotify();
    }
  }

  // Aggregation mode for grouped chart sorting (Avg vs Max)
  static const List<String> groupedAggOptions = [
    'avg',
    'max',
  ];
  String _groupedTfAgg = 'avg';
  String get groupedTfAgg => _groupedTfAgg;
  void setGroupedTfAgg(String mode) {
    if (groupedAggOptions.contains(mode)) {
      _groupedTfAgg = mode;
      // Persist preference
      _prefs.setString('compare.groupedTfAgg', mode);
      _throttleNotify();
    }
  }

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
    // Load persisted preferences (if present)
    try {
      final savedSort = await _prefs.getString('compare.groupedTfSort');
      if (savedSort != null && groupedSortOptions.contains(savedSort)) {
        _groupedTfSort = savedSort;
      }
      final savedAgg = await _prefs.getString('compare.groupedTfAgg');
      if (savedAgg != null && groupedAggOptions.contains(savedAgg)) {
        _groupedTfAgg = savedAgg;
      }
    } catch (_) {}
    notifyListeners();
  }

  // Export a single image into a one‑page PDF
  Future<bool> exportImagePdf(Uint8List imageBytes, String fileName,
      {String? title}) async {
    try {
      final pdf = await _pdfExportService.buildImageDocument(
        imageBytes,
        title: title,
      );

      if (kIsWeb) {
        final blob = html.Blob([pdf], 'application/pdf');
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
        await file.writeAsBytes(pdf);
        final share = locator<ShareService>();
        await share.shareFilePath(
          path,
          text: 'BacktestX Comparison PDF',
          mimeType: 'application/pdf',
          filename: fileName,
        );
        return true;
      }
    } catch (_) {
      return false;
    }
  }

  // Generate sanitized filename for comparison exports with timestamp
  String generateExportFilename({
    required String baseLabel,
    String ext = 'pdf',
    DateTime? timestamp,
  }) {
    return FilenameHelper.build(['comparison', baseLabel],
        ext: ext, timestamp: timestamp);
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
    _invalidateGroupedCache();
    _throttleNotify();
  }

  void clearTimeframeFilters() {
    _selectedTimeframeFilters.clear();
    _invalidateGroupedCache();
    _throttleNotify();
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

  // Series labels per result, e.g., R1: StrategyName
  List<String> getSeriesLabels() {
    final labels = <String>[];
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final name = strategyLabelFor(r.strategyId);
      labels.add('R${i + 1}: $name');
    }
    return labels;
  }

  // Build grouped series: timeframe -> { seriesLabel -> metricValue }
  Map<String, Map<String, double>> getGroupedTfMetricSeries() {
    // Return cached result when inputs are unchanged
    final key = _computeGroupedCacheKey();
    if (_groupedCacheKey == key && _groupedCache != null) {
      return _groupedCache!;
    }

    PerfMonitor.start('groupedTfMetricSeries');
    final Map<String, Map<String, double>> grouped = {};
    for (int i = 0; i < results.length; i++) {
      final r = results[i];
      final label = 'R${i + 1}: ${strategyLabelFor(r.strategyId)}';
      final stats = getFilteredTfStatsFor(r);
      for (final e in stats.entries) {
        final tf = e.key;
        final m = e.value;
        final val = _resolveMetricValue(m, _selectedTfMetric);
        grouped[tf] ??= {};
        grouped[tf]![label] = val;
      }
    }
    PerfMonitor.end('groupedTfMetricSeries',
        context:
            'results=${results.length}, tfs=${grouped.length}, metric=$_selectedTfMetric');
    _groupedCache = grouped;
    _groupedCacheKey = key;
    return grouped;
  }

  // Compute timeframe order for grouped chart based on sorting mode
  List<String> getTimeframeOrderForGrouped() {
    final grouped = getGroupedTfMetricSeries();
    final tfs = grouped.keys.toList();
    if (tfs.isEmpty) return [];
    if (_groupedTfSort == 'timeframe') {
      tfs.sort();
      return tfs;
    }
    final scoreByTf = <String, double>{};
    for (final tf in tfs) {
      final m = grouped[tf] ?? {};
      if (m.isEmpty) {
        scoreByTf[tf] = double.nan; // empty treated as invalid and placed last
        continue;
      }
      // Use only finite values for aggregation; invalids (NaN/Infinity) cause tf to be placed last
      final values = m.values.where((v) => v.isFinite).toList();
      if (values.isEmpty) {
        scoreByTf[tf] = double.nan;
      } else {
        double score;
        if (_groupedTfAgg == 'max') {
          score = values.reduce((a, b) => a > b ? a : b);
        } else {
          // Default to average
          score = values.reduce((a, b) => a + b) / values.length;
        }
        scoreByTf[tf] = score;
      }
    }
    tfs.sort((a, b) {
      final va = scoreByTf[a] ?? double.nan;
      final vb = scoreByTf[b] ?? double.nan;
      final aInvalid = !(va.isFinite);
      final bInvalid = !(vb.isFinite);
      if (aInvalid && bInvalid) {
        // Tie-break by key for deterministic order
        return a.compareTo(b);
      }
      if (aInvalid) return 1; // a goes after b
      if (bInvalid) return -1; // b goes after a
      final cmp =
          _groupedTfSort == 'valueAsc' ? va.compareTo(vb) : vb.compareTo(va);
      if (cmp != 0) return cmp;
      // Stable tie-break by timeframe key (ascending)
      return a.compareTo(b);
    });
    return tfs;
  }

  double _resolveMetricValue(Map<String, num> m, String metric) {
    switch (metric) {
      case 'winRate':
        return (m['winRate'] ?? 0).toDouble();
      case 'profitFactor':
        return (m['profitFactor'] ?? 0).toDouble();
      case 'expectancy':
        return (m['expectancy'] ?? 0).toDouble();
      case 'rr':
        return (m['rr'] ?? 0).toDouble();
      case 'trades':
        return (m['trades'] ?? 0).toDouble();
      case 'signals':
        return (m['signals'] ?? 0).toDouble();
      case 'wins':
        return (m['wins'] ?? 0).toDouble();
      case 'avgWin':
        return (m['avgWin'] ?? 0).toDouble();
      case 'avgLoss':
        return (m['avgLoss'] ?? 0).toDouble();
      default:
        return 0.0;
    }
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
        final share = locator<ShareService>();
        await share.shareFilePath(
          path,
          text: 'BacktestX Comparison',
          mimeType: 'text/csv',
          filename: fileName,
        );
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
      final fileName = generateExportFilename(baseLabel: 'tfstats', ext: ext);

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
        final share = locator<ShareService>();
        await share.shareFilePath(
          path,
          text: 'BacktestX Comparison Per‑TF Stats',
          mimeType: mime,
          filename: fileName,
        );
        return true;
      }
    } catch (_) {
      return false;
    }
  }
}
