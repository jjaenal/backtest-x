import 'package:backtestx/models/trade.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'dart:typed_data';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;
import 'package:backtestx/services/pdf_export_service.dart';

enum ChartMode { equity, drawdown }
enum TfChartSort { timeframe, valueAsc, valueDesc }

class BacktestResultViewModel extends BaseViewModel {
  final BacktestResult result;
  final _snackbarService = locator<SnackbarService>();
  final _dataManager = DataManager();
  final _pdfExportService = PdfExportService();

  // Chart mode state
  ChartMode _chartMode = ChartMode.equity;
  ChartMode get chartMode => _chartMode;

  BacktestResultViewModel(this.result);

  // Method untuk mengubah chart mode
  void setChartMode(ChartMode mode) {
    _chartMode = mode;
    notifyListeners();
  }

  // Toggle chart mode
  void toggleChartMode() {
    _chartMode =
        _chartMode == ChartMode.equity ? ChartMode.drawdown : ChartMode.equity;
    notifyListeners();
  }

  // Properti tambahan untuk data yang tidak ada di BacktestResult
  String get strategyName => 'Strategy ${result.strategyId}';

  // Get market data info from DataManager
  MarketData? get marketData => _dataManager.getData(result.marketDataId);
  String get symbol => marketData?.symbol ?? 'Unknown';
  String get timeframe => marketData?.timeframe ?? 'Unknown';
  String get startDate =>
      marketData?.candles.first.timestamp.toString().split(' ')[0] ??
      result.executedAt.toString().split(' ')[0];
  String get endDate =>
      marketData?.candles.last.timestamp.toString().split(' ')[0] ??
      result.executedAt.toString().split(' ')[0];

  // State untuk range chart (visible window)
  int _chartStartIndex = 0;
  int _chartEndIndex = 0;
  int get chartStartIndex => _chartStartIndex;
  int get chartEndIndex => _chartEndIndex;
  int get totalCandlesCount => marketData?.candles.length ?? 0;

  // Windowed candles state (subset loaded into chart)
  int _windowStartIndex = 0;
  int _windowEndIndex = 0;
  bool _windowInitialized = false;
  int get windowStartIndex => _windowStartIndex;
  int get windowEndIndex => _windowEndIndex;

  // Tuning konfigurasi (mutable) & throttling
  int _baseBuffer = 400; // default buffer around viewport
  int _minWindowSize = 300; // minimum window span
  int _movementThreshold = 100; // candles threshold before window update
  double _edgePrefetchRatio = 0.2; // prefetch when within 20% from edge
  int _minWindowUpdateIntervalMs = 100; // throttle window updates
  int _minNotifyIntervalMs = 80; // throttle UI notify for label updates
  DateTime? _lastWindowUpdate;
  DateTime? _lastNotify;
  Timer? _prefetchTimer;

  // Timeframe filter state for tfStats panel
  final Set<String> _selectedTimeframeFilters = {};
  Set<String> get selectedTimeframeFilters => _selectedTimeframeFilters;

  void toggleTimeframeFilter(String timeframe) {
    if (_selectedTimeframeFilters.contains(timeframe)) {
      _selectedTimeframeFilters.remove(timeframe);
    } else {
      _selectedTimeframeFilters.add(timeframe);
    }
    notifyListeners();
  }

  void clearTimeframeFilters() {
    _selectedTimeframeFilters.clear();
    notifyListeners();
  }

  // Per-timeframe chart sort mode
  TfChartSort _tfChartSort = TfChartSort.timeframe;
  TfChartSort get tfChartSort => _tfChartSort;
  void setTfChartSort(TfChartSort mode) {
    _tfChartSort = mode;
    notifyListeners();
  }

  // Per-timeframe charts: selectable metric state
  static const List<String> availableTfChartMetrics = [
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

  String _selectedTfChartMetric = 'winRate';
  String get selectedTfChartMetric => _selectedTfChartMetric;

  void setSelectedTfChartMetric(String metric) {
    if (!availableTfChartMetrics.contains(metric)) return;
    _selectedTfChartMetric = metric;
    notifyListeners();
  }

  /// Return tfStats filtered by selected timeframes; if none selected, return all
  Map<String, Map<String, num>> getFilteredTfStats() {
    final tfStats = result.summary.tfStats ?? {};
    if (_selectedTimeframeFilters.isEmpty) return tfStats;
    final filtered = <String, Map<String, num>>{};
    for (final e in tfStats.entries) {
      if (_selectedTimeframeFilters.contains(e.key)) {
        filtered[e.key] = e.value;
      }
    }
    return filtered;
  }

  /// Build a series (timeframe -> value) for the selected or provided metric
  Map<String, double> getTfMetricSeries({String? metric}) {
    final m = metric ?? _selectedTfChartMetric;
    final stats = getFilteredTfStats();
    // Build entries list first to allow sorting by value
    final entries = <MapEntry<String, double>>[];
    final keys = stats.keys.toList()..sort();
    for (final tf in keys) {
      final v = stats[tf]?[m];
      if (v == null) continue;
      entries.add(MapEntry(tf, v.toDouble()));
    }

    switch (_tfChartSort) {
      case TfChartSort.timeframe:
        entries.sort((a, b) => a.key.compareTo(b.key));
        break;
      case TfChartSort.valueAsc:
        entries.sort((a, b) {
          final av = a.value;
          final bv = b.value;
          final af = av.isFinite;
          final bf = bv.isFinite;
          if (af && bf) {
            final cmp = av.compareTo(bv);
            return cmp != 0 ? cmp : a.key.compareTo(b.key);
          }
          // Place non‑finite (NaN/Infinity) values at the end
          if (af && !bf) return -1;
          if (!af && bf) return 1;
          // Both non‑finite: tie‑break by key
          return a.key.compareTo(b.key);
        });
        break;
      case TfChartSort.valueDesc:
        entries.sort((a, b) {
          final av = a.value;
          final bv = b.value;
          final af = av.isFinite;
          final bf = bv.isFinite;
          if (af && bf) {
            final cmp = bv.compareTo(av);
            return cmp != 0 ? cmp : a.key.compareTo(b.key);
          }
          // Place non‑finite (NaN/Infinity) values at the end
          if (af && !bf) return -1;
          if (!af && bf) return 1;
          // Both non‑finite: tie‑break by key
          return a.key.compareTo(b.key);
        });
        break;
    }

    // Return as insertion-ordered map
    final out = <String, double>{};
    for (final e in entries) {
      out[e.key] = e.value;
    }
    return out;
  }

  /// Export current result's per-timeframe stats to CSV
  Future<void> exportTfStatsToCsv() async {
    await exportTfStats(format: 'csv');
  }

  /// Export current result's per-timeframe stats to CSV/TSV (respects selected TF filters)
  Future<void> exportTfStats({String format = 'csv'}) async {
    try {
      final stats = getFilteredTfStats();
      if (stats.isEmpty) {
        _snackbarService.showSnackbar(
          message: 'No per-timeframe stats to export',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final rows = <List<String>>[
        [
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
      // Respect the current chart order: use getTfMetricSeries() keys
      final orderedTfs = getTfMetricSeries().keys.toList();
      // Fallback to alphabetical if no metric series available
      final keys = orderedTfs.isNotEmpty
          ? orderedTfs
          : (stats.keys.toList()..sort());
      for (final tf in keys) {
        final m = stats[tf] ?? const {};
        final signals = (m['signals'] ?? 0).toString();
        final trades = (m['trades'] ?? 0).toString();
        final wins = (m['wins'] ?? 0).toString();
        final winRate = ((m['winRate'] ?? 0)).toString();
        final profitFactor = ((m['profitFactor'] ?? 0)).toString();
        final expectancy = ((m['expectancy'] ?? 0)).toString();
        final avgWin = ((m['avgWin'] ?? 0)).toString();
        final avgLoss = ((m['avgLoss'] ?? 0)).toString();
        final rr = ((m['rr'] ?? 0)).toString();
        rows.add([
          tf,
          signals,
          trades,
          wins,
          winRate,
          profitFactor,
          expectancy,
          avgWin,
          avgLoss,
          rr,
        ]);
      }

      final isCsv = format.toLowerCase() == 'csv';
      final mime = isCsv ? 'text/csv' : 'text/tab-separated-values';
      final ext = isCsv ? 'csv' : 'tsv';
      final fileName = 'backtest_${result.strategyId}_${result.marketDataId}_tfstats.$ext';
      final content = isCsv
          ? const ListToCsvConverter().convert(rows)
          : rows.map((r) => r.join('\t')).join('\n');

      if (kIsWeb) {
        final blob = html.Blob([content], mime);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(content);
        await Share.shareXFiles([XFile(path)],
            subject: 'Backtest per-timeframe stats',
            text:
                'Exported per-timeframe stats for strategy ${result.strategyId} on market ${result.marketDataId}',
        );
      }

      _snackbarService.showSnackbar(
        message: 'TF Stats exported',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  /// Return trades filtered by selected timeframe chips (intersection with entryTimeframes)
  List<Trade> getFilteredTradesBySelectedTF() {
    final selected = _selectedTimeframeFilters;
    final closed = result.trades
        .where((t) => t.status == TradeStatus.closed)
        .toList();
    if (selected.isEmpty) return closed;
    return closed.where((t) {
      final tfs = t.entryTimeframes ?? const [];
      if (tfs.isEmpty) return false;
      for (final tf in tfs) {
        if (selected.contains(tf)) return true;
      }
      return false;
    }).toList();
  }

  /// Export Trade History to CSV/TSV respecting selected timeframe filters
  Future<void> exportTradeHistory({String format = 'csv'}) async {
    try {
      final trades = getFilteredTradesBySelectedTF();
      if (trades.isEmpty) {
        _snackbarService.showSnackbar(
          message: 'No trades to export',
          duration: const Duration(seconds: 2),
        );
        return;
      }

      final rows = <List<String>>[
        [
          'Strategy',
          'Symbol',
          'Timeframe',
          'Direction',
          'Entry Date',
          'Exit Date',
          'Entry Price',
          'Exit Price',
          'PnL',
          'PnL %',
          'Duration',
          'Entry TFs',
        ],
      ];

      for (final trade in trades) {
        String duration = '-';
        if (trade.exitTime != null) {
          final diff = trade.exitTime!.difference(trade.entryTime).inHours;
          duration = '${diff ~/ 24}d ${diff % 24}h';
        }
        rows.add([
          strategyName,
          symbol,
          timeframe,
          trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
          trade.entryTime.toString(),
          trade.exitTime?.toString() ?? '-',
          trade.entryPrice.toStringAsFixed(4),
          trade.exitPrice?.toStringAsFixed(4) ?? '-',
          trade.pnl?.toStringAsFixed(2) ?? '-',
          trade.pnlPercentage?.toStringAsFixed(2) ?? '-',
          duration,
          (trade.entryTimeframes == null || trade.entryTimeframes!.isEmpty)
              ? '-'
              : trade.entryTimeframes!.join(', '),
        ]);
      }

      final isCsv = format.toLowerCase() == 'csv';
      final mime = isCsv ? 'text/csv' : 'text/tab-separated-values';
      final ext = isCsv ? 'csv' : 'tsv';
      final fileName =
          'backtest_${result.strategyId}_${result.marketDataId}_trades.$ext';
      final content = isCsv
          ? const ListToCsvConverter().convert(rows)
          : rows.map((r) => r.join('\t')).join('\n');

      if (kIsWeb) {
        final blob = html.Blob([content], mime);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsString(content);
        await Share.shareXFiles([XFile(path)],
            subject: 'Backtest trades',
            text:
                'Exported trades for strategy ${result.strategyId} on market ${result.marketDataId}');
      }

      _snackbarService.showSnackbar(
        message: 'Trades exported',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // API untuk tuning runtime
  void setTuning({
    int? baseBuffer,
    int? minWindowSize,
    int? movementThreshold,
    double? edgePrefetchRatio,
    int? minWindowUpdateIntervalMs,
    int? minNotifyIntervalMs,
  }) {
    if (baseBuffer != null) _baseBuffer = baseBuffer;
    if (minWindowSize != null) _minWindowSize = minWindowSize;
    if (movementThreshold != null) _movementThreshold = movementThreshold;
    if (edgePrefetchRatio != null) _edgePrefetchRatio = edgePrefetchRatio;
    if (minWindowUpdateIntervalMs != null) {
      _minWindowUpdateIntervalMs = minWindowUpdateIntervalMs;
    }
    if (minNotifyIntervalMs != null) _minNotifyIntervalMs = minNotifyIntervalMs;
    notifyListeners();
  }

  // Update range chart dari widget CandlestickChart
  void updateChartRange(int startIndex, int endIndex) {
    _chartStartIndex = startIndex;
    _chartEndIndex = endIndex;

    final total = totalCandlesCount;
    if (total == 0) return;

    // Initialize window on first update
    if (!_windowInitialized) {
      final desiredStart = (startIndex - _baseBuffer).clamp(0, total);
      final desiredEnd = (endIndex + _baseBuffer).clamp(0, total);
      _windowStartIndex = desiredStart;
      _windowEndIndex = desiredEnd;
      _windowInitialized = true;
      _lastWindowUpdate = DateTime.now();
      notifyListeners();
      return;
    }

    final now = DateTime.now();
    final windowSize = (_windowEndIndex - _windowStartIndex).clamp(1, total);
    final distToStartEdge = (_chartStartIndex - _windowStartIndex).clamp(0, windowSize);
    final distToEndEdge = (_windowEndIndex - _chartEndIndex).clamp(0, windowSize);

    final desiredStart = (startIndex - _baseBuffer).clamp(0, total);
    final desiredEnd = (endIndex + _baseBuffer).clamp(0, total);

    final movedStart = (desiredStart - _windowStartIndex).abs() > _movementThreshold;
    final movedEnd = (desiredEnd - _windowEndIndex).abs() > _movementThreshold;
    final nearStartEdge = distToStartEdge < windowSize * _edgePrefetchRatio;
    final nearEndEdge = distToEndEdge < windowSize * _edgePrefetchRatio;

    bool updatedWindow = false;

    // Throttle window update frequency
    if (_lastWindowUpdate == null || now.difference(_lastWindowUpdate!).inMilliseconds > _minWindowUpdateIntervalMs) {
      if (movedStart || movedEnd || nearStartEdge || nearEndEdge) {
        _windowStartIndex = desiredStart;
        _windowEndIndex = desiredEnd;

        // Enforce minimum window size
        if (_windowEndIndex - _windowStartIndex < _minWindowSize) {
          _windowEndIndex = (_windowStartIndex + _minWindowSize).clamp(0, total);
        }
        _lastWindowUpdate = now;
        updatedWindow = true;
      }
    }

    // Prefetch di background jika dekat tepi namun tidak update window karena throttle
    if (!updatedWindow && (nearStartEdge || nearEndEdge)) {
      _schedulePrefetch(nearStart: nearStartEdge, nearEnd: nearEndEdge, total: total);
    }

    // Notify UI: always when window updated; otherwise, throttle label updates.
    if (updatedWindow) {
      notifyListeners();
      _lastNotify = now;
    } else if (_lastNotify == null || now.difference(_lastNotify!).inMilliseconds > _minNotifyIntervalMs) {
      _lastNotify = now;
      notifyListeners();
    }
  }

  void _schedulePrefetch({required bool nearStart, required bool nearEnd, required int total}) {
    _prefetchTimer?.cancel();
    _prefetchTimer = Timer(Duration(milliseconds: (_minWindowUpdateIntervalMs / 2).round()), () {
      bool changed = false;
      final expandBy = _baseBuffer; // expand satu buffer

      if (nearStart) {
        final newStart = (_chartStartIndex - expandBy).clamp(0, total);
        if (newStart != _windowStartIndex) {
          _windowStartIndex = newStart;
          changed = true;
        }
      }
      if (nearEnd) {
        final newEnd = (_chartEndIndex + expandBy).clamp(0, total);
        if (newEnd != _windowEndIndex) {
          _windowEndIndex = newEnd;
          changed = true;
        }
      }

      // Enforce minimum window size
      if (_windowEndIndex - _windowStartIndex < _minWindowSize) {
        _windowEndIndex = (_windowStartIndex + _minWindowSize).clamp(0, total);
        changed = true;
      }

      if (changed) {
        _lastWindowUpdate = DateTime.now();
        notifyListeners();
      }
    });
  }

  /// Get windowed candles based on current loaded subset.
  /// Falls back to downsampled candles when market data is unavailable.
  List<Candle> getWindowCandles() {
    final actualMarketData = _dataManager.getData(result.marketDataId);
    if (actualMarketData == null || actualMarketData.candles.isEmpty) {
      return getCandles();
    }

    final total = actualMarketData.candles.length;
    if (!_windowInitialized) {
      // Initialize a reasonable window near the end (most recent candles)
      const visibleCount = 100;
      const buffer = 300;
      final end = total;
      final startVisible = (end - visibleCount).clamp(0, end);
      _windowStartIndex = (startVisible - buffer).clamp(0, end);
      _windowEndIndex = (startVisible + visibleCount + buffer).clamp(0, end);
      _windowInitialized = true;
    }

    final start = _windowStartIndex.clamp(0, total);
    final end = _windowEndIndex.clamp(0, total);
    return actualMarketData.candles.sublist(start, end);
  }

  // Membuat teks ringkasan untuk dibagikan
  String _generateSummaryText() {
    final summary = result.summary;

    return '''
📊 Backtest Results - $strategyName

💰 Total PnL: \$${summary.totalPnl.toStringAsFixed(2)} (${summary.totalPnlPercentage.toStringAsFixed(2)}%)
📈 Win Rate: ${summary.winRate.toStringAsFixed(1)}% (${summary.winningTrades}/${summary.totalTrades})
📉 Profit Factor: ${summary.profitFactor.toStringAsFixed(2)}
⚠️ Max Drawdown: ${summary.maxDrawdownPercentage.toStringAsFixed(1)}%
📆 Period: $startDate to $endDate
🔄 Total Trades: ${summary.totalTrades}

Generated by BacktestX
    ''';
  }

  // Fungsi untuk membagikan hasil backtest
  Future<void> shareResults() async {
    final text = _generateSummaryText();

    try {
      if (kIsWeb) {
        // Untuk web, gunakan clipboard sebagai fallback utama
        await Clipboard.setData(ClipboardData(text: text));
        _snackbarService.showSnackbar(
          message: 'Results copied to clipboard!',
          duration: const Duration(seconds: 2),
        );
      } else {
        // Untuk mobile/desktop, gunakan Share package
        await Share.share(
          text,
          subject: 'BacktestX Results',
        );
        debugPrint('Shared successfully');
      }
    } catch (e) {
      // Fallback: Copy ke clipboard
      await Clipboard.setData(ClipboardData(text: text));
      debugPrint('error: $e');
      _snackbarService.showSnackbar(
        message: 'Results copied to clipboard!',
        duration: const Duration(seconds: 2),
      );
    }
  }

  // Copy summary ke clipboard secara eksplisit (tanpa share)
  Future<void> copySummaryToClipboard() async {
    final text = _generateSummaryText();
    try {
      await Clipboard.setData(ClipboardData(text: text));
      _snackbarService.showSnackbar(
        message: 'Summary copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Copy failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Copy trades table as CSV to clipboard
  Future<void> copyTradesCsvToClipboard() async {
    try {
      final closedTrades =
          result.trades.where((t) => t.status == TradeStatus.closed).toList();

      final List<List<dynamic>> rows = [];
      rows.add([
        'Direction',
        'Entry Date',
        'Exit Date',
        'Entry Price',
        'Exit Price',
        'Lot Size',
        'Stop Loss',
        'Take Profit',
        'PnL',
        'PnL %',
        'Duration',
      ]);

      for (final trade in closedTrades) {
        String duration = '-';
        if (trade.exitTime != null) {
          final diff = trade.exitTime!.difference(trade.entryTime).inHours;
          duration = '${diff ~/ 24}d ${diff % 24}h';
        }

        rows.add([
          trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
          trade.entryTime.toIso8601String(),
          trade.exitTime?.toIso8601String() ?? '-',
          trade.entryPrice.toStringAsFixed(4),
          trade.exitPrice?.toStringAsFixed(4) ?? '-',
          trade.lotSize.toStringAsFixed(2),
          trade.stopLoss?.toStringAsFixed(4) ?? '-',
          trade.takeProfit?.toStringAsFixed(4) ?? '-',
          trade.pnl?.toStringAsFixed(2) ?? '-',
          trade.pnlPercentage?.toStringAsFixed(2) ?? '-',
          duration,
        ]);
      }

      final csv = const ListToCsvConverter().convert(rows);
      await Clipboard.setData(ClipboardData(text: csv));
      _snackbarService.showSnackbar(
        message: 'Trades CSV copied to clipboard',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Copy failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  // Fungsi untuk mengekspor hasil backtest ke CSV
  Future<void> exportResults() async {
    setBusy(true);

    try {
      // Membuat data untuk CSV
      final List<List<dynamic>> rows = [];

      // Header
      rows.add([
        'Strategy',
        'Symbol',
        'Timeframe',
        'Direction',
        'Entry Date',
        'Exit Date',
        'Entry Price',
        'Exit Price',
        'PnL',
        'PnL %',
        'Duration'
      ]);

      // Data trades
      for (final trade in result.trades) {
        // Hitung durasi dalam hari jika exitTime tersedia
        String duration = '-';
        if (trade.exitTime != null) {
          final diff = trade.exitTime!.difference(trade.entryTime).inHours;
          duration = '${diff ~/ 24}d ${diff % 24}h';
        }

        rows.add([
          strategyName,
          symbol,
          timeframe,
          trade.direction == TradeDirection.buy ? 'BUY' : 'SELL',
          trade.entryTime.toString(),
          trade.exitTime?.toString() ?? '-',
          trade.entryPrice.toStringAsFixed(2),
          trade.exitPrice?.toStringAsFixed(2) ?? '-',
          trade.pnl?.toStringAsFixed(2) ?? '-',
          trade.pnlPercentage?.toStringAsFixed(2) ?? '-',
          duration
        ]);
      }

      // Konversi ke CSV
      String csv = const ListToCsvConverter().convert(rows);

      // Simpan file CSV dan bagikan
      final fileName = '${strategyName}_backtest_results.csv';

      // Gunakan pendekatan yang berbeda berdasarkan platform
      try {
        // Untuk web, gunakan universal_html
        if (kIsWeb) {
          _saveFileForWeb(csv, fileName);
        } else {
          // Untuk mobile/desktop, gunakan path_provider dan share_plus
          await _saveFileForMobile(csv, fileName);
        }

        _snackbarService.showSnackbar(
          message: 'Results exported to CSV',
          duration: const Duration(seconds: 2),
        );
      } catch (e) {
        _snackbarService.showSnackbar(
          message: 'Export failed: $e',
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Export failed: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Ekspor hasil backtest ke PDF
  Future<void> exportPdf() async {
    setBusy(true);
    try {
      final bytes = await _pdfExportService.buildBacktestReport(result);
      final fileName = '${strategyName}_backtest_report.pdf';

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href!.isNotEmpty) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles([XFile(path)], text: 'BacktestX PDF Report');
      }

      _snackbarService.showSnackbar(
        message: 'PDF exported successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Export PDF failed: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  // Ekspor gambar (PNG bytes) sebagai PDF satu halaman
  Future<void> exportImagePdf(Uint8List imageBytes,
      {required String fileName, String? title}) async {
    setBusy(true);
    try {
      final bytes =
          await _pdfExportService.buildImageDocument(imageBytes, title: title);

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'application/pdf');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if (anchor.href != null && anchor.href!.isNotEmpty) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(bytes, flush: true);
        await Share.shareXFiles([XFile(path)], text: title ?? 'BacktestX PDF');
      }

      _snackbarService.showSnackbar(
        message: 'PDF exported successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Export PDF failed: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  void _saveFileForWeb(String csv, String fileName) {
    // Implementasi untuk web menggunakan universal_html
    final blob = html.Blob([csv], 'text/csv');
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    if (anchor.href != null) {
      html.Url.revokeObjectUrl(url);
    }
  }

  Future<void> _saveFileForMobile(String csv, String fileName) async {
    // Implementasi untuk mobile/desktop
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/$fileName';
    final file = File(path);
    await file.writeAsString(csv);
    await Share.shareXFiles([XFile(path)], text: 'BacktestX Results');
  }

  String getTradeDirectionLabel(TradeDirection direction) {
    return direction == TradeDirection.buy ? 'BUY' : 'SELL';
  }

  String formatPnL(double? pnl) {
    if (pnl == null) return '-';
    return '\$${pnl.toStringAsFixed(2)}';
  }

  String formatPercentage(double? percentage) {
    if (percentage == null) return '-';
    return '${percentage >= 0 ? '+' : ''}${percentage.toStringAsFixed(2)}%';
  }

  /// Generate demo candles for candlestick chart
  List<Candle> getCandles() {
    // Try to get actual market data first
    final actualMarketData = _dataManager.getData(result.marketDataId);
    if (actualMarketData != null && actualMarketData.candles.isNotEmpty) {
      // Optimize chart rendering for very large datasets by downsampling
      final candles = actualMarketData.candles;
      const targetPoints = 1500; // target render points for smooth performance
      if (candles.length <= targetPoints) {
        return candles;
      }
      final stride = (candles.length / targetPoints).ceil();
      final downsampled = <Candle>[];
      for (int i = 0; i < candles.length; i += stride) {
        downsampled.add(candles[i]);
      }
      // Ensure last candle is included for accurate last price/marker
      if (downsampled.isEmpty ||
          downsampled.last.timestamp != candles.last.timestamp) {
        downsampled.add(candles.last);
      }
      return downsampled;
    }

    // Fallback to demo data if market data not available
    final random = Random();
    final candles = <Candle>[];
    double price = 100.0;
    final now = DateTime.now();

    for (int i = 0; i < 100; i++) {
      final timestamp = now.subtract(Duration(days: 100 - i));
      final change = (random.nextDouble() - 0.5) * 4; // -2 to +2
      price += change;

      final high = price + random.nextDouble() * 2;
      final low = price - random.nextDouble() * 2;
      final open = low + random.nextDouble() * (high - low);
      final close = low + random.nextDouble() * (high - low);

      candles.add(Candle(
        timestamp: timestamp,
        open: open,
        high: high,
        low: low,
        close: close,
        volume: random.nextDouble() * 1000000,
      ));
    }

    return candles;
  }
}
