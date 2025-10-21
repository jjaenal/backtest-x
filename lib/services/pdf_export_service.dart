import 'dart:typed_data';
import 'package:backtestx/core/data_manager.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/helpers/share_content_helper.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:stacked_services/stacked_services.dart';

class PdfExportService {
  Future<Uint8List> buildBacktestReport(BacktestResult result) async {
    // Fetch full strategy details if available
    final storage = locator<StorageService>();
    final Strategy? strategy = await storage.getStrategy(result.strategyId);
    // Fetch market data info (symbol/timeframe) from cache
    final dataManager = locator<DataManager>();
    final marketData = dataManager.getData(result.marketDataId);
    // Create document without network font dependencies for testability
    final pdf = pw.Document(compress: false);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    final summary = result.summary;
    final loc = AppLocalizations.of(StackedService.navigatorKey!.currentContext!)!;

    pdf.addPage(
      pw.MultiPage(
        footer: (context) => pw.Container(
          padding: const pw.EdgeInsets.symmetric(vertical: 8),
          alignment: pw.Alignment.center,
          child: pw.Text(
            loc.pdfPageOf(context.pageNumber, context.pagesCount),
            style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
          ),
        ),
        build: (context) {
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Header
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(loc.backtestReportFilenameLabel,
                              style: pw.TextStyle(
                                fontSize: 20,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.SizedBox(height: 4),
                          pw.Text(
                              'Strategy: ${ShareContentHelper.redactPII(strategy?.name ?? result.strategyId)}',
                              style: const pw.TextStyle(fontSize: 12)),
                          pw.SizedBox(height: 2),
                          pw.Text(
                              'Symbol: ${marketData?.symbol ?? result.marketDataId} | TF: ${marketData?.timeframe ?? ''}',
                              style: const pw.TextStyle(fontSize: 12)),
                        ],
                      ),
                      pw.Text(
                        'Generated: ${dateFormat.format(DateTime.now())}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                  pw.SizedBox(height: 16),

                  // Strategy Details (if available)
                  if (strategy != null) ...[
                    pw.Container(
                      decoration: pw.BoxDecoration(
                        border:
                            pw.Border.all(color: PdfColors.grey300, width: 0.5),
                        borderRadius: pw.BorderRadius.circular(8),
                      ),
                      padding: const pw.EdgeInsets.all(12),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Strategy Details',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          pw.SizedBox(height: 8),
                          _summaryRow('Name', strategy.name),
                          _summaryRow('Initial Capital',
                              _fmtCurrencyUsd(strategy.initialCapital)),
                          _summaryRow(
                              'Created', dateFormat.format(strategy.createdAt)),
                          _summaryRow(
                              'Updated',
                              strategy.updatedAt != null
                                  ? dateFormat.format(strategy.updatedAt!)
                                  : '-'),
                          pw.SizedBox(height: 8),
                          pw.Text('Risk Management',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          ..._riskRows(strategy.riskManagement),
                          pw.SizedBox(height: 8),
                          pw.Text('Entry Rules',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          ...strategy.entryRules
                              .map((r) => pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        vertical: 2),
                                    child: pw.Text('• ${_ruleLabel(r)}'),
                                  ))
                              .toList(),
                          pw.SizedBox(height: 8),
                          pw.Text('Exit Rules',
                              style: pw.TextStyle(
                                  fontSize: 12,
                                  fontWeight: pw.FontWeight.bold)),
                          ...strategy.exitRules
                              .map((r) => pw.Padding(
                                    padding: const pw.EdgeInsets.symmetric(
                                        vertical: 2),
                                    child: pw.Text('• ${_ruleLabel(r)}'),
                                  ))
                              .toList(),
                        ],
                      ),
                    ),
                    pw.SizedBox(height: 16),
                  ],

                  // Summary
                  pw.Container(
                    decoration: pw.BoxDecoration(
                      border:
                          pw.Border.all(color: PdfColors.grey300, width: 0.5),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    padding: const pw.EdgeInsets.all(12),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(loc.pdfPerformanceSummary,
                            style: pw.TextStyle(
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            )),
                        pw.SizedBox(height: 8),
                        _summaryRow(loc.pdfTotalTrades, summary.totalTrades.toString()),
                        _summaryRow(loc.pdfWinningTrades, summary.winningTrades.toString()),
                        _summaryRow(loc.pdfLosingTrades, summary.losingTrades.toString()),
                        _summaryRow(loc.pdfWinRate, '${summary.winRate.toStringAsFixed(1)}%'),
                        _summaryRow(loc.pdfTotalPnl, _fmtCurrencyUsd(summary.totalPnl)),
                        _summaryRow(loc.pdfTotalPnlPercent, '${summary.totalPnlPercentage.toStringAsFixed(2)}%'),
                        _summaryRow(loc.pdfProfitFactor, summary.profitFactor.toStringAsFixed(2)),
                        _summaryRow(loc.pdfMaxDrawdown, _fmtCurrencyUsd(summary.maxDrawdown)),
                        _summaryRow(loc.pdfMaxDrawdownPercent, '${summary.maxDrawdownPercentage.toStringAsFixed(2)}%'),
                        _summaryRow(loc.pdfSharpeRatio, summary.sharpeRatio.toStringAsFixed(2)),
                        _summaryRow(loc.pdfAvgWin, _fmtCurrencyUsd(summary.averageWin)),
                        _summaryRow(loc.pdfAvgLoss, _fmtCurrencyUsd(summary.averageLoss)),
                        _summaryRow(loc.pdfLargestWin, _fmtCurrencyUsd(summary.largestWin)),
                        _summaryRow(loc.pdfLargestLoss, _fmtCurrencyUsd(summary.largestLoss)),
                        _summaryRow(loc.pdfExpectancy, _fmtCurrencyUsd(summary.expectancy)),
                        if (summary.tfStats != null && summary.tfStats!.isNotEmpty) ...[
                          pw.SizedBox(height: 8),
                          pw.Text(loc.perTfStatsHeader,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              )),
                          ...summary.tfStats!.entries.map((e) {
                            final tf = e.key;
                            final s = e.value;
                            final signals = (s['signals'] ?? 0).toInt();
                            final trades = (s['trades'] ?? 0).toInt();
                            final wins = (s['wins'] ?? 0).toInt();
                            final wr = (s['winRate'] ?? 0).toDouble();
                            final pf = (s['profitFactor'] ?? 0).toDouble();
                            final ex = (s['expectancy'] ?? 0).toDouble();
                            final value =
                                '${loc.sbStatsSignals}: $signals, ${loc.sbStatsTrades}: $trades, ${loc.sbStatsWins}: $wins, ${loc.sbStatsWinRate}: ${wr.toStringAsFixed(1)}%, PF: ${pf.isFinite ? pf.toStringAsFixed(2) : '—'}, ${loc.pdfExpectancy}: ${_fmtCurrencyUsd(ex)}';
                            return _summaryRow('TF $tf', value);
                          }).toList(),
                        ],
                      ],
                    ),
                  ),
                  pw.SizedBox(height: 16),

                  // Charts (Equity & Drawdown)
                  ..._buildCharts(result),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _summaryRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label),
          pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
        ],
      ),
    );
  }

  // ignore: unused_element
  List<pw.Widget> _buildTradesTables(BacktestResult result) {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final trades =
        result.trades.where((t) => t.status == TradeStatus.closed).toList();
    // Limit total rows and split into multiple smaller tables so each fits a page
    const maxRows = 60; // total rows cap
    const rowsPerTable = 20; // rows per table chunk to avoid overflow

    final headers = [
      'Direction',
      'Entry Date',
      'Exit Date',
      'Entry Price',
      'Exit Price',
      'PnL',
      'PnL %',
    ];

    final allRows = trades.take(maxRows).map((t) {
      return [
        t.direction == TradeDirection.buy ? 'BUY' : 'SELL',
        dateFormat.format(t.entryTime),
        t.exitTime != null ? dateFormat.format(t.exitTime!) : '-',
        t.entryPrice.toStringAsFixed(4),
        t.exitPrice?.toStringAsFixed(4) ?? '-',
        (t.pnl ?? 0).toStringAsFixed(2),
        (t.pnlPercentage ?? 0).toStringAsFixed(2),
      ];
    }).toList();

    final widgets = <pw.Widget>[];
    for (int i = 0; i < allRows.length; i += rowsPerTable) {
      final chunk = allRows.sublist(
        i,
        i + rowsPerTable > allRows.length ? allRows.length : i + rowsPerTable,
      );
      widgets.add(
        pw.TableHelper.fromTextArray(
          headers: headers,
          data: chunk,
          headerDecoration: const pw.BoxDecoration(
            color: PdfColor.fromInt(0xFFF0F0F0),
          ),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellAlignment: pw.Alignment.centerLeft,
          cellPadding:
              const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.3),
        ),
      );
      if (i + rowsPerTable < allRows.length) {
        widgets.add(pw.SizedBox(height: 12));
      }
    }
    return widgets;
  }

  String _fmtCurrencyUsd(double value) {
    final f = NumberFormat.currency(symbol: '\$');
    return f.format(value);
  }

  // ===== Charts (PDF) =====
  List<pw.Widget> _buildCharts(BacktestResult result) {
    final eqPoints = result.equityCurve;
    if (eqPoints.isEmpty) {
      return [
        pw.Text('Charts',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text('No equity curve data available.'),
        pw.SizedBox(height: 16),
      ];
    }

    // Map to primitive series for plotting
    final equitySeries = eqPoints.map((p) => p.equity).toList();
    final drawdown = _computeDrawdownPercent(equitySeries);
    final minEq = equitySeries.reduce((a, b) => a < b ? a : b);
    final maxEq = equitySeries.reduce((a, b) => a > b ? a : b);
    final minDD = drawdown.reduce((a, b) => a < b ? a : b);
    final maxDD = drawdown.reduce((a, b) => a > b ? a : b);
    final fmtDate = DateFormat('yyyy-MM-dd');
    final startDate = fmtDate.format(eqPoints.first.timestamp);
    final endDate = fmtDate.format(eqPoints.last.timestamp);
    final nfEquity = NumberFormat('#,##0');
    final nfPercent = NumberFormat('0.0');

    return [
      pw.Text('Charts',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
      pw.SizedBox(height: 8),
      // Chart 1: Equity Curve (full width)
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Equity Curve',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 230,
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.all(10),
            child: pw.CustomPaint(
              painter: _lineChartPainter(
                equitySeries,
                PdfColors.blue,
                showZeroLine: false,
                showGrid: true,
                gridCount: 4,
                showVerticalGrid: true,
                vGridCount: 4,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Y Min: ${nfEquity.format(minEq)}',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Y Max: ${nfEquity.format(maxEq)}',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('X Min: $startDate',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('X Max: $endDate',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 12),
      // Chart 2: Drawdown % (full width)
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('Drawdown %',
              style:
                  pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 6),
          pw.Container(
            height: 230,
            width: double.infinity,
            decoration: pw.BoxDecoration(
              border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            padding: const pw.EdgeInsets.all(10),
            child: pw.CustomPaint(
              painter: _lineChartPainter(
                drawdown,
                PdfColors.red,
                invertY: true,
                showZeroLine: true,
                showGrid: true,
                gridCount: 4,
                showVerticalGrid: true,
                vGridCount: 4,
              ),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Y Min: ${nfPercent.format(minDD)}%',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('Y Max: ${nfPercent.format(maxDD)}%',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
          pw.SizedBox(height: 4),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('X Min: $startDate',
                  style: const pw.TextStyle(fontSize: 9)),
              pw.Text('X Max: $endDate',
                  style: const pw.TextStyle(fontSize: 9)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 16),
    ];
  }

  List<double> _computeDrawdownPercent(List<double> equity) {
    final result = <double>[];
    double peak = equity.first;
    for (final v in equity) {
      if (v > peak) peak = v;
      final dd = peak == 0 ? 0.0 : (peak - v) / peak * 100.0;
      result.add(dd);
    }
    return result;
  }

  List<pw.Widget> _riskRows(RiskManagement rm) {
    final riskTypeLabel = () {
      switch (rm.riskType) {
        case RiskType.fixedLot:
          return 'Fixed Lot';
        case RiskType.percentageRisk:
          return 'Percentage Risk';
        case RiskType.atrBased:
          return 'ATR-Based Sizing';
      }
    }();
    final riskValueLabel = () {
      switch (rm.riskType) {
        case RiskType.fixedLot:
          return rm.riskValue.toStringAsFixed(2);
        case RiskType.percentageRisk:
        case RiskType.atrBased:
          return '${rm.riskValue.toStringAsFixed(2)}%';
      }
    }();

    final rows = <pw.Widget>[
      _summaryRow('Risk Type', riskTypeLabel),
      _summaryRow('Risk Value', riskValueLabel),
      if (rm.stopLoss != null)
        _summaryRow(
            rm.riskType == RiskType.atrBased ? 'ATR Multiple' : 'Stop Loss',
            rm.stopLoss!.toStringAsFixed(2)),
      if (rm.takeProfit != null)
        _summaryRow('Take Profit', rm.takeProfit!.toStringAsFixed(2)),
      _summaryRow(
        'Trailing Stop',
        rm.useTrailingStop
            ? 'On${rm.trailingStopDistance != null ? ' (${rm.trailingStopDistance!.toStringAsFixed(2)})' : ''}'
            : 'Off',
      ),
    ];
    return rows;
  }

  String _ruleLabel(StrategyRule r) {
    final tf = r.timeframe != null ? '[${r.timeframe}] ' : '';
    final indicator = _indicatorLabel(r.indicator);
    final op = _operatorLabel(r.operator);
    final valueText = r.value.when(
      number: (v) => v.toStringAsFixed(2),
      indicator: (type, period, anchorMode, anchorDate) {
        final base = _indicatorLabel(type);
        if (type == IndicatorType.anchoredVwap) {
          final anchorLabel =
              (anchorMode == AnchorMode.byDate && anchorDate != null)
                  ? 'date ${anchorDate.toIso8601String().split('T').first}'
                  : 'start';
          return '$base($anchorLabel)';
        }
        return period != null ? '$base($period)' : base;
      },
    );
    final logic = r.logicalOperator != null
        ? ' ${_logicalLabel(r.logicalOperator!)}'
        : '';
    return '$tf$indicator $op $valueText$logic';
  }

  String _indicatorLabel(IndicatorType i) {
    switch (i) {
      case IndicatorType.sma:
        return 'SMA';
      case IndicatorType.ema:
        return 'EMA';
      case IndicatorType.rsi:
        return 'RSI';
      case IndicatorType.macd:
        return 'MACD';
      case IndicatorType.macdSignal:
        return 'MACD Signal';
      case IndicatorType.macdHistogram:
        return 'MACD Histogram';
      case IndicatorType.atr:
        return 'ATR';
      case IndicatorType.atrPct:
        return 'ATR%';
      case IndicatorType.adx:
        return 'ADX';
      case IndicatorType.bollingerBands:
        return 'Bollinger Bands';
      case IndicatorType.bollingerWidth:
        return 'Bollinger Width';
      case IndicatorType.close:
        return 'Close';
      case IndicatorType.open:
        return 'Open';
      case IndicatorType.high:
        return 'High';
      case IndicatorType.low:
        return 'Low';
      case IndicatorType.vwap:
        return 'VWAP';
      case IndicatorType.anchoredVwap:
        return 'Anchored VWAP';
      case IndicatorType.stochasticK:
        return 'Stochastic %K';
      case IndicatorType.stochasticD:
        return 'Stochastic %D';
    }
  }

  String _operatorLabel(ComparisonOperator o) {
    switch (o) {
      case ComparisonOperator.greaterThan:
        return '>';
      case ComparisonOperator.lessThan:
        return '<';
      case ComparisonOperator.greaterThanOrEqual:
        return '≥';
      case ComparisonOperator.lessThanOrEqual:
        return '≤';
      case ComparisonOperator.equals:
        return '=';
      case ComparisonOperator.crossAbove:
        return 'crosses above';
      case ComparisonOperator.crossBelow:
        return 'crosses below';
      case ComparisonOperator.rising:
        return 'rising';
      case ComparisonOperator.falling:
        return 'falling';
    }
  }

  String _logicalLabel(LogicalOperator l) {
    final loc = AppLocalizations.of(StackedService.navigatorKey!.currentContext!)!;
    switch (l) {
      case LogicalOperator.and:
        return loc.pdfOperatorAnd;
      case LogicalOperator.or:
        return loc.pdfOperatorOr;
    }
  }

  // Build a simple single-page PDF that embeds a PNG image
  // Optional title appears above the image.
  Future<Uint8List> buildImageDocument(Uint8List imageBytes,
      {String? title}) async {
    // Create document without network font dependencies for testability
    final pdf = pw.Document(compress: false);

    final img = pw.MemoryImage(imageBytes);

    pdf.addPage(
      pw.Page(
        margin: const pw.EdgeInsets.all(24),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (title != null && title.isNotEmpty) ...[
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 14, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 12),
              ],
              pw.Center(
                child: pw.Image(img, fit: pw.BoxFit.contain),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  // Build a multi-page PDF embedding multiple PNG images.
  // Each entry in images corresponds to a page; optional titles appear above images.
  Future<Uint8List> buildMultiImageDocument(
    List<Uint8List> images, {
    List<String?>? titles,
  }) async {
    // Create document without network font dependencies for testability
    final pdf = pw.Document();
    final loc = AppLocalizations.of(StackedService.navigatorKey!.currentContext!)!;

    // Older versions of the pdf package may not support PageBreak.
    // To ensure compatibility, render each image on its own Page
    // and add a consistent footer manually.
    for (var i = 0; i < images.length; i++) {
      final img = pw.MemoryImage(images[i]);
      final title = titles != null && i < (titles.length) ? titles[i] : null;
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                ],
                pw.Center(
                  child: pw.Container(
                    height: 400,
                    child: pw.Image(img, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    loc.pdfPageOf(i + 1, images.length),
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}

// Painter function (typedef) compatible with pdf package
pw.CustomPainter _lineChartPainter(
  List<double> series,
  PdfColor color, {
  bool invertY = false,
  bool showZeroLine = false,
  bool showGrid = true,
  int gridCount = 4,
  bool showVerticalGrid = false,
  int vGridCount = 4,
}) {
  return (PdfGraphics canvas, PdfPoint size) {
    final width = size.x;
    final height = size.y;

    // Border
    canvas
      ..setStrokeColor(PdfColors.grey300)
      ..setLineWidth(0.5)
      ..moveTo(0, 0)
      ..lineTo(width, 0)
      ..lineTo(width, height)
      ..lineTo(0, height)
      ..closePath()
      ..strokePath();

    if (series.length < 2) return;

    final minVal = series.reduce((a, b) => a < b ? a : b);
    final maxVal = series.reduce((a, b) => a > b ? a : b);
    final span = (maxVal - minVal).abs() < 1e-9 ? 1.0 : (maxVal - minVal);

    const left = 4.0;
    final right = width - 4.0;
    const top = 4.0;
    final bottom = height - 4.0;
    final chartW = right - left;
    final chartH = bottom - top;

    // Grid lines (horizontal)
    if (showGrid && gridCount > 1) {
      canvas
        ..setStrokeColor(PdfColors.grey200)
        ..setLineWidth(0.3);
      for (int i = 1; i < gridCount; i++) {
        final y = top + chartH * (i / gridCount);
        canvas
          ..moveTo(left, y)
          ..lineTo(right, y)
          ..strokePath();
      }
    }

    // Grid lines (vertical)
    if (showVerticalGrid && vGridCount > 1) {
      canvas
        ..setStrokeColor(PdfColors.grey200)
        ..setLineWidth(0.3);
      for (int i = 1; i < vGridCount; i++) {
        final x = left + chartW * (i / vGridCount);
        canvas
          ..moveTo(x, top)
          ..lineTo(x, bottom)
          ..strokePath();
      }
    }

    // Optional zero line (for drawdown)
    if (showZeroLine) {
      canvas
        ..setStrokeColor(PdfColors.grey400)
        ..setLineWidth(0.5)
        ..moveTo(left, bottom)
        ..lineTo(right, bottom)
        ..strokePath();
    }

    final stepX = chartW / (series.length - 1);

    // Draw polyline
    canvas
      ..setStrokeColor(color)
      ..setLineWidth(1.0);

    double x0 = left;
    double y0 = _mapY(series.first, minVal, span, top, chartH, invertY);
    canvas.moveTo(x0, y0);
    for (int i = 1; i < series.length; i++) {
      final x1 = left + stepX * i;
      final y1 = _mapY(series[i], minVal, span, top, chartH, invertY);
      canvas.lineTo(x1, y1);
    }
    canvas.strokePath();
  };
}

double _mapY(
  double v,
  double minVal,
  double span,
  double top,
  double height,
  bool invert,
) {
  final norm = (v - minVal) / span;
  final y = top + (invert ? norm : (1 - norm)) * height;
  return y;
}
