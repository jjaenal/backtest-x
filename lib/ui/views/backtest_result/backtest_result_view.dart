import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/widgets/equity_curve_chart.dart';
import 'package:backtestx/ui/widgets/common/candlestick_chart/candlestick_chart.dart';
import 'package:backtestx/ui/widgets/per_tf_bar_chart.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' if (dart.library.html) 'dart:html'
    as html;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'dart:io' as io;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:backtestx/ui/widgets/skeleton_loader.dart' as x_skeleton;
import 'package:stacked/stacked.dart';
import 'backtest_result_viewmodel.dart';

class BacktestResultView extends StackedView<BacktestResultViewModel> {
  final BacktestResult result;
  // GlobalKey untuk menangkap tampilan chart per‑timeframe (PNG export)
  final GlobalKey _tfChartKey = GlobalKey();
  // GlobalKey untuk menangkap seluruh panel Per‑Timeframe sebagai PNG
  final GlobalKey _tfPanelKey = GlobalKey();

  BacktestResultView({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BacktestResultViewModel viewModel,
    Widget? child,
  ) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => viewModel.refresh(),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.link),
            onPressed: () => viewModel.copyResultLinkToClipboard(),
            tooltip: 'Copy Link',
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => viewModel.copySummaryToClipboard(),
            tooltip: t.copySummary,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart),
            onPressed: () => viewModel.copyTradesCsvToClipboard(),
            tooltip: t.copyTradesCsv,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => viewModel.shareResults(),
            tooltip: 'Share Results',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => viewModel.exportPdf(),
            tooltip: t.menuExportBacktestPdf,
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => viewModel.exportResults(),
            tooltip: t.exportCsv,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? _buildResultSkeleton(context)
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Text(t.backtestResultsTitle,
                        style: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                  // Top info section: symbol, timeframe, date range
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.timeline, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${viewModel.symbol} · ${viewModel.timeframe} • ${viewModel.startDate} – ${viewModel.endDate}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Equity Curve Chart
                  SizedBox(
                    height: 450,
                    child: Card(
                      margin: const EdgeInsets.all(16),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  viewModel.chartMode == ChartMode.equity
                                      ? 'Equity Curve'
                                      : 'Drawdown Chart',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .surfaceContainerHighest
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .outline
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      _buildModeButton(
                                        context,
                                        'Equity',
                                        ChartMode.equity,
                                        viewModel.chartMode == ChartMode.equity,
                                        () => viewModel
                                            .setChartMode(ChartMode.equity),
                                      ),
                                      _buildModeButton(
                                        context,
                                        'Drawdown',
                                        ChartMode.drawdown,
                                        viewModel.chartMode ==
                                            ChartMode.drawdown,
                                        () => viewModel
                                            .setChartMode(ChartMode.drawdown),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: result.equityCurve.isEmpty
                                  ? _buildEmptyChartState(context)
                                  : EquityCurveChart(
                                      equityCurve: result.equityCurve,
                                      initialCapital:
                                          (result.equityCurve.isNotEmpty &&
                                                  result.summary.totalPnl > 0)
                                              ? result.equityCurve.first.equity
                                              : 10000,
                                      showDrawdown: viewModel.chartMode ==
                                          ChartMode.drawdown,
                                      chartMode: viewModel.chartMode,
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Price Chart with Entry/Exit Markers
                  if (result.trades.isNotEmpty)
                    SizedBox(
                      height: 450,
                      child: Card(
                        margin: const EdgeInsets.all(16),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Wrap(
                              //   alignment: WrapAlignment.start,
                              //   runSpacing: 8,
                              //   children: [
                              //     const Text(
                              //       'Price Chart with Trade Markers',
                              //       style: TextStyle(
                              //         fontSize: 18,
                              //         fontWeight: FontWeight.bold,
                              //       ),
                              //     ),
                              //     const Spacer(),
                              //     Container(
                              //       padding: const EdgeInsets.symmetric(
                              //           horizontal: 12, vertical: 6),
                              //       decoration: BoxDecoration(
                              //         color: Colors.blue[50],
                              //         borderRadius: BorderRadius.circular(20),
                              //         border: Border.all(color: Colors.blue[200]!),
                              //       ),
                              //       child: Row(
                              //         mainAxisSize: MainAxisSize.min,
                              //         children: [
                              //           Icon(Icons.info_outline,
                              //               size: 16, color: Colors.blue[700]),
                              //           const SizedBox(width: 4),
                              //           Text(
                              //             '${result.trades.length} trades',
                              //             style: TextStyle(
                              //               fontSize: 12,
                              //               color: Colors.blue[700],
                              //               fontWeight: FontWeight.w500,
                              //             ),
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              // const SizedBox(height: 8),
                              Expanded(
                                child: AnimatedSwitcher(
                                  duration: const Duration(milliseconds: 200),
                                  child: viewModel.isBusy
                                      ? x_skeleton.SkeletonLoader.box(
                                          context,
                                          height: double.infinity,
                                        )
                                      : CandlestickChart(
                                          candles: viewModel.getWindowCandles(),
                                          trades: result.trades,
                                          title:
                                              'Price Action with Entry/Exit Points',
                                          showVolume: false,
                                          onRangeChanged: (start, end) =>
                                              viewModel.updateChartRange(
                                                  viewModel.windowStartIndex +
                                                      start,
                                                  viewModel.windowStartIndex +
                                                      end),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              Builder(
                                builder: (context) {
                                  return Text(
                                    'Menampilkan ${viewModel.chartStartIndex + 1}–${viewModel.chartEndIndex} dari ${viewModel.totalCandlesCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.6),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  // Performance Summary
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Performance Summary'),
                        const SizedBox(height: 12),
                        _buildPerformanceCards(context, result.summary),
                        const SizedBox(height: 24),
                        if (result.summary.tfStats != null &&
                            result.summary.tfStats!.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _buildSectionTitle('Per-Timeframe Stats'),
                              PopupMenuButton<String>(
                                tooltip: 'Export per-timeframe stats',
                                onSelected: (value) async {
                                  if (value == 'png_chart_dialog') {
                                    await _promptExportChartPng(
                                        context, viewModel);
                                  } else if (value == 'png_panel_dialog') {
                                    await _promptExportPanelPng(
                                        context, viewModel);
                                  } else if (value == 'pdf_chart_dialog') {
                                    await _promptExportChartPdf(
                                        context, viewModel);
                                  } else if (value ==
                                      'pdf_chart_panel_dialog') {
                                    await _promptExportChartPanelPdf(
                                        context, viewModel);
                                  } else if (value == 'pdf_panel_dialog') {
                                    await _promptExportPanelPdf(
                                        context, viewModel);
                                  } else if (value == 'pdf_report') {
                                    await viewModel.exportPdf();
                                  } else {
                                    await viewModel.exportTfStats(
                                        format: value);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'csv',
                                    child: Row(
                                      children: [
                                        Icon(Icons.table_chart, size: 18),
                                        SizedBox(width: 8),
                                        Text('Export CSV'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'tsv',
                                    child: Row(
                                      children: [
                                        Icon(Icons.grid_on, size: 18),
                                        SizedBox(width: 8),
                                        Text('Export TSV'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'png_chart_dialog',
                                    child: Row(
                                      children: [
                                        Icon(Icons.bar_chart, size: 18),
                                        SizedBox(width: 8),
                                        Text('Export Chart PNG…'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'png_panel_dialog',
                                    child: Row(
                                      children: [
                                        Icon(Icons.dashboard_customize,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text('Export Panel PNG…'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'pdf_chart_dialog',
                                    child: Row(
                                      children: [
                                        Icon(Icons.bar_chart, size: 18),
                                        SizedBox(width: 8),
                                        Text('Export Chart PDF…'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'pdf_chart_panel_dialog',
                                    child: Row(
                                      children: [
                                        Icon(Icons.picture_as_pdf, size: 18),
                                        SizedBox(width: 8),
                                        Text('Export Chart + Panel PDF…'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'pdf_panel_dialog',
                                    child: Row(
                                      children: [
                                        Icon(Icons.dashboard_customize,
                                            size: 18),
                                        SizedBox(width: 8),
                                        Text('Export Panel PDF…'),
                                      ],
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'pdf_report',
                                    child: Row(
                                      children: [
                                        const Icon(Icons.picture_as_pdf,
                                            size: 18),
                                        const SizedBox(width: 8),
                                        Text(AppLocalizations.of(context)!
                                            .menuExportBacktestPdf),
                                      ],
                                    ),
                                  ),
                                ],
                                child: TextButton.icon(
                                  onPressed: null,
                                  icon: const Icon(Icons.download_rounded,
                                      size: 18),
                                  label: Text(t.exportLabel),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildTfStats(
                              context, viewModel, result.summary.tfStats!),
                          const SizedBox(height: 24),
                        ],
                        const SizedBox(height: 24),
                        _buildSectionTitle('Trade Statistics'),
                        const SizedBox(height: 12),
                        _buildTradeStatsCard(context, result.summary),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Risk Metrics'),
                        const SizedBox(height: 12),
                        _buildRiskMetricsCard(context, result.summary),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildSectionTitle('Trade History'),
                            PopupMenuButton<String>(
                              tooltip: t.exportTradeHistoryTooltip,
                              onSelected: (value) =>
                                  viewModel.exportTradeHistory(format: value),
                              itemBuilder: (context) => [
                                PopupMenuItem(
                                  value: 'csv',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.table_chart, size: 18),
                                      const SizedBox(width: 8),
                                      Text(t.exportCsv),
                                    ],
                                  ),
                                ),
                                PopupMenuItem(
                                  value: 'tsv',
                                  child: Row(
                                    children: [
                                      const Icon(Icons.grid_on, size: 18),
                                      const SizedBox(width: 8),
                                      Text(t.exportTsv),
                                    ],
                                  ),
                                ),
                              ],
                              child: TextButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.download_rounded,
                                    size: 18),
                                label: Text(t.exportLabel),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildTradeHistoryCard(context, viewModel),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  // Komposisi gambar dengan background solid saat ekspor (tanpa mengubah UI)
  Future<Uint8List> _composeOpaquePng(ui.Image image,
      {Color backgroundColor = Colors.white}) async {
    final w = image.width;
    final h = image.height;
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(
      recorder,
      ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()),
    );
    final bgPaint = ui.Paint()..color = backgroundColor;
    canvas.drawRect(
        ui.Rect.fromLTWH(0, 0, w.toDouble(), h.toDouble()), bgPaint);
    canvas.drawImage(image, ui.Offset.zero, ui.Paint());
    final picture = recorder.endRecording();
    final composed = await picture.toImage(w, h);
    final byteData = await composed.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  Future<void> _exportTfChartPng(BacktestResultViewModel viewModel,
      {double? pixelRatio}) async {
    try {
      final renderObject = _tfChartKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('PNG export failed: RenderRepaintBoundary not found');
        return;
      }
      final pr = pixelRatio ?? ui.window.devicePixelRatio;
      final image = await renderObject.toImage(pixelRatio: pr);
      // Gunakan warna theme sebagai background; fallback ke putih jika context null
      final ctx = _tfChartKey.currentContext;
      final themeBg =
          ctx != null ? Theme.of(ctx).colorScheme.surface : Colors.white;
      final bytes = await _composeOpaquePng(image, backgroundColor: themeBg);
      final fileName = viewModel.generateExportFilename(
        baseLabel: 'per_timeframe_chart',
        ext: 'png',
      );

      // Only perform download on web targets
      if (kIsWeb) {
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..download = fileName
          ..style.display = 'none';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile/Desktop: simpan file lalu buka share sheet
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = io.File(path);
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(path)], text: 'BacktestX Chart PNG');
      }
    } catch (e) {
      debugPrint('PNG export failed: $e');
    }
  }

  Future<void> _exportTfPanelPng(BacktestResultViewModel viewModel,
      {double? pixelRatio}) async {
    try {
      final renderObject = _tfPanelKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('PNG export failed: Panel RenderRepaintBoundary not found');
        return;
      }
      final pr = pixelRatio ?? ui.window.devicePixelRatio;
      final image = await renderObject.toImage(pixelRatio: pr);
      // Gunakan warna theme sebagai background; fallback ke putih jika context null
      final ctx = _tfPanelKey.currentContext;
      final themeBg =
          ctx != null ? Theme.of(ctx).colorScheme.surface : Colors.white;
      final bytes = await _composeOpaquePng(image, backgroundColor: themeBg);
      final fileName = viewModel.generateExportFilename(
        baseLabel: 'per_timeframe_panel',
        ext: 'png',
      );

      if (kIsWeb) {
        final blob = html.Blob([bytes], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..download = fileName
          ..style.display = 'none';
        html.document.body?.append(anchor);
        anchor.click();
        anchor.remove();
        html.Url.revokeObjectUrl(url);
      } else {
        // Mobile/Desktop: simpan file lalu buka share sheet
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/$fileName';
        final file = io.File(path);
        await file.writeAsBytes(bytes);
        await Share.shareXFiles([XFile(path)], text: 'BacktestX Panel PNG');
      }
    } catch (e) {
      debugPrint('PNG export failed: $e');
    }
  }

  Future<void> _promptExportChartPng(
      BuildContext context, BacktestResultViewModel viewModel) async {
    final ratio = await _promptPixelRatio(context, title: 'Export Chart PNG');
    if (ratio != null) {
      await _exportTfChartPng(viewModel, pixelRatio: ratio);
    }
  }

  Future<void> _promptExportPanelPng(
      BuildContext context, BacktestResultViewModel viewModel) async {
    final ratio = await _promptPixelRatio(context, title: 'Export Panel PNG');
    if (ratio != null) {
      await _exportTfPanelPng(viewModel, pixelRatio: ratio);
    }
  }

  // ==== Export Chart/Panel as PDF (single page) ====
  Future<void> _promptExportChartPdf(
      BuildContext context, BacktestResultViewModel viewModel) async {
    final ratio = await _promptPixelRatio(context, title: 'Export Chart PDF');
    if (ratio != null) {
      await _exportTfChartPdf(viewModel, pixelRatio: ratio);
    }
  }

  Future<void> _promptExportPanelPdf(
      BuildContext context, BacktestResultViewModel viewModel) async {
    final ratio = await _promptPixelRatio(context, title: 'Export Panel PDF');
    if (ratio != null) {
      await _exportTfPanelPdf(viewModel, pixelRatio: ratio);
    }
  }

  Future<void> _promptExportChartPanelPdf(
      BuildContext context, BacktestResultViewModel viewModel) async {
    final ratio =
        await _promptPixelRatio(context, title: 'Export Chart + Panel PDF');
    if (ratio != null) {
      await _exportTfChartPanelPdf(viewModel, pixelRatio: ratio);
    }
  }

  Future<void> _exportTfChartPdf(BacktestResultViewModel viewModel,
      {double? pixelRatio}) async {
    try {
      final renderObject = _tfChartKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('PDF export failed: RenderRepaintBoundary not found');
        return;
      }
      final pr = pixelRatio ?? ui.window.devicePixelRatio;
      final image = await renderObject.toImage(pixelRatio: pr);
      final ctx = _tfChartKey.currentContext;
      final themeBg =
          ctx != null ? Theme.of(ctx).colorScheme.surface : Colors.white;
      final pngBytes = await _composeOpaquePng(image, backgroundColor: themeBg);
      final fileName = viewModel.generateExportFilename(
        baseLabel: 'chart',
        ext: 'pdf',
      );
      await viewModel.exportImagePdf(
        pngBytes,
        fileName: fileName,
        title: 'Per‑Timeframe Chart',
      );
    } catch (e) {
      debugPrint('Chart PDF export failed: $e');
    }
  }

  Future<void> _exportTfPanelPdf(BacktestResultViewModel viewModel,
      {double? pixelRatio}) async {
    try {
      final renderObject = _tfPanelKey.currentContext?.findRenderObject();
      if (renderObject is! RenderRepaintBoundary) {
        debugPrint('PDF export failed: Panel RenderRepaintBoundary not found');
        return;
      }
      final pr = pixelRatio ?? ui.window.devicePixelRatio;
      final image = await renderObject.toImage(pixelRatio: pr);
      final ctx = _tfPanelKey.currentContext;
      final themeBg =
          ctx != null ? Theme.of(ctx).colorScheme.surface : Colors.white;
      final pngBytes = await _composeOpaquePng(image, backgroundColor: themeBg);
      final fileName = viewModel.generateExportFilename(
        baseLabel: 'panel',
        ext: 'pdf',
      );
      await viewModel.exportImagePdf(
        pngBytes,
        fileName: fileName,
        title: 'Per‑Timeframe Panel',
      );
    } catch (e) {
      debugPrint('Panel PDF export failed: $e');
    }
  }

  Future<void> _exportTfChartPanelPdf(BacktestResultViewModel viewModel,
      {double? pixelRatio}) async {
    try {
      // Capture Chart
      final chartObj = _tfChartKey.currentContext?.findRenderObject();
      if (chartObj is! RenderRepaintBoundary) {
        debugPrint('PDF export failed: Chart boundary not found');
        return;
      }
      final pr = pixelRatio ?? ui.window.devicePixelRatio;
      final chartImage = await chartObj.toImage(pixelRatio: pr);
      final chartCtx = _tfChartKey.currentContext;
      final themeBgChart = chartCtx != null
          ? Theme.of(chartCtx).colorScheme.surface
          : Colors.white;
      final chartPng =
          await _composeOpaquePng(chartImage, backgroundColor: themeBgChart);

      // Capture Panel
      final panelObj = _tfPanelKey.currentContext?.findRenderObject();
      if (panelObj is! RenderRepaintBoundary) {
        debugPrint('PDF export failed: Panel boundary not found');
        return;
      }
      final panelImage = await panelObj.toImage(pixelRatio: pr);
      final panelCtx = _tfPanelKey.currentContext;
      final themeBgPanel = panelCtx != null
          ? Theme.of(panelCtx).colorScheme.surface
          : Colors.white;
      final panelPng =
          await _composeOpaquePng(panelImage, backgroundColor: themeBgPanel);

      final fileName = viewModel.generateExportFilename(
        baseLabel: 'chart_panel',
        ext: 'pdf',
      );

      await viewModel.exportChartAndPanelPdf(
        chartPng,
        panelPng,
        fileName: fileName,
        chartTitle: 'Per‑Timeframe Chart',
        panelTitle: 'Per‑Timeframe Panel',
      );
    } catch (e) {
      debugPrint('Chart+Panel PDF export failed: $e');
    }
  }

  Future<double?> _promptPixelRatio(BuildContext context,
      {required String title}) async {
    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return SimpleDialog(
          title: Text(title),
          children: [
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 1.0),
              child: const Text('Quality 1x (smaller file)'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 2.0),
              child: const Text('Quality 2x (balanced)'),
            ),
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, 4.0),
              child: const Text('Quality 4x (sharp, larger file)'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildResultSkeleton(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Skeleton for Equity/Drawdown chart card
          SizedBox(
            height: 450,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        x_skeleton.SkeletonLoader.bar(context,
                            width: 140, height: 20),
                        Row(
                          children: [
                            x_skeleton.SkeletonLoader.bar(context,
                                width: 70,
                                height: 28,
                                radius: BorderRadius.circular(20)),
                            const SizedBox(width: 8),
                            x_skeleton.SkeletonLoader.bar(context,
                                width: 90,
                                height: 28,
                                radius: BorderRadius.circular(20)),
                          ],
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: x_skeleton.SkeletonLoader.box(context,
                          width: double.infinity,
                          height: double.infinity,
                          radius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Skeleton for Price Chart card
          SizedBox(
            height: 450,
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    x_skeleton.SkeletonLoader.bar(context,
                        width: 220, height: 20),
                    const SizedBox(height: 12),
                    Expanded(
                      child: x_skeleton.SkeletonLoader.box(context,
                          width: double.infinity,
                          height: double.infinity,
                          radius: BorderRadius.circular(12)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Skeleton for Performance Summary & Trade History
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Section title skeleton
                x_skeleton.SkeletonLoader.bar(context, width: 180, height: 22),
                const SizedBox(height: 12),
                // Metrics grid skeleton
                Row(
                  children: [
                    Expanded(
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 120, height: 16),
                              const SizedBox(height: 8),
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 160, height: 16),
                              const SizedBox(height: 8),
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 100, height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Card(
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 120, height: 16),
                              const SizedBox(height: 8),
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 160, height: 16),
                              const SizedBox(height: 8),
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 100, height: 16),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),
                // Trade History section skeleton
                x_skeleton.SkeletonLoader.bar(context, width: 160, height: 22),
                const SizedBox(height: 12),
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      children: List.generate(5, (index) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              x_skeleton.SkeletonLoader.circle(context,
                                  size: 28),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    x_skeleton.SkeletonLoader.bar(context,
                                        width: double.infinity, height: 12),
                                    const SizedBox(height: 6),
                                    x_skeleton.SkeletonLoader.bar(context,
                                        width: 180, height: 12),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              x_skeleton.SkeletonLoader.bar(context,
                                  width: 60, height: 16),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyChartState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.show_chart,
            size: 80,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
          ),
          const SizedBox(height: 12),
          const Text(
            'No equity data available',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            'Run backtest or adjust your strategy settings',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTfStats(BuildContext context, BacktestResultViewModel viewModel,
      Map<String, Map<String, num>> tfStats) {
    final theme = Theme.of(context);
    final allEntries = tfStats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    final selected = viewModel.selectedTimeframeFilters;
    final entries = selected.isEmpty
        ? allEntries
        : allEntries.where((e) => selected.contains(e.key)).toList();
    return RepaintBoundary(
      key: _tfPanelKey,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul panel + watermark kecil di pojok kanan atas
            Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _buildSectionTitle('Per-Timeframe Stats'),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Opacity(
                    opacity: 0.6,
                    child: Text(
                      'BacktestX • ${DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16)}',
                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 10),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Chart metric selector
            Wrap(
              spacing: 12,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Chart metric:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 180,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: viewModel.selectedTfChartMetric,
                        items: BacktestResultViewModel.availableTfChartMetrics
                            .map((m) => DropdownMenuItem<String>(
                                  value: m,
                                  child: Text(m),
                                ))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) viewModel.setSelectedTfChartMetric(v);
                        },
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Sort:',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 160,
                      child: DropdownButton<TfChartSort>(
                        isExpanded: true,
                        value: viewModel.tfChartSort,
                        items: const [
                          DropdownMenuItem(
                            value: TfChartSort.timeframe,
                            child: Text('Timeframe'),
                          ),
                          DropdownMenuItem(
                            value: TfChartSort.valueAsc,
                            child: Text('Value ↑'),
                          ),
                          DropdownMenuItem(
                            value: TfChartSort.valueDesc,
                            child: Text('Value ↓'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) viewModel.setTfChartSort(v);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Timeframe selector chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: allEntries.map((e) {
                final tf = e.key;
                final isSelected = selected.contains(tf);
                return FilterChip(
                  label: Text(
                    tf,
                    style: TextStyle(
                      color: isSelected ? theme.colorScheme.primary : null,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) => viewModel.toggleTimeframeFilter(tf),
                  selectedColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  checkmarkColor: theme.colorScheme.primary,
                  showCheckmark: true,
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            // Per-timeframe bar chart visualization for selected metric
            PerTfBarChart(
              series: viewModel.getTfMetricSeries(),
              metricLabel: viewModel.selectedTfChartMetric,
              maxItems: 12,
              sortByValue: viewModel.tfChartSort != TfChartSort.timeframe,
              descending: viewModel.tfChartSort == TfChartSort.valueDesc,
              isPercent: viewModel.selectedTfChartMetric == 'winRate',
              repaintKey: _tfChartKey,
              overlayWatermark:
                  'BacktestX • ${viewModel.selectedTfChartMetric} • ${DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16)}',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: entries.map((e) {
                final tf = e.key;
                final s = e.value;
                final signals = (s['signals'] ?? 0).toInt();
                final trades = (s['trades'] ?? 0).toInt();
                final wins = (s['wins'] ?? 0).toInt();
                final winRate = (s['winRate'] ?? 0).toDouble();
                final profitFactor = (s['profitFactor'] ?? 0).toDouble();
                final expectancy = (s['expectancy'] ?? 0).toDouble();
                final avgWin = (s['avgWin'] ?? 0).toDouble();
                final avgLoss = (s['avgLoss'] ?? 0).toDouble();
                final rr = (s['rr'] ?? 0).toDouble();
                final isSelected = selected.contains(tf);
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.primary.withValues(alpha: 0.4)
                          : theme.dividerColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        tf,
                        style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color:
                                isSelected ? theme.colorScheme.primary : null),
                      ),
                      _statChip(context, 'Signals', signals.toString()),
                      _statChip(context, 'Trades', trades.toString()),
                      _statChip(context, 'Wins', wins.toString()),
                      _statChip(
                          context, 'WinRate', '${winRate.toStringAsFixed(1)}%'),
                      _statChip(
                          context,
                          'ProfitFactor',
                          profitFactor.isFinite
                              ? profitFactor.toStringAsFixed(2)
                              : '0.00'),
                      _statChip(
                          context, 'Expectancy', expectancy.toStringAsFixed(2)),
                      _statChip(context, 'AvgWin', avgWin.toStringAsFixed(2)),
                      _statChip(context, 'AvgLoss', avgLoss.toStringAsFixed(2)),
                      _statChip(context, 'R/R',
                          rr.isFinite ? rr.toStringAsFixed(2) : '0.00'),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statChip(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(width: 6),
          Text(value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPerformanceCards(BuildContext context, BacktestSummary summary) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Total P&L',
                '\$${summary.totalPnl.toStringAsFixed(2)}',
                '${summary.totalPnlPercentage >= 0 ? '+' : ''}${summary.totalPnlPercentage.toStringAsFixed(2)}%',
                summary.totalPnl >= 0 ? Colors.green : Colors.red,
                summary.totalPnl >= 0 ? Icons.trending_up : Icons.trending_down,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Win Rate',
                '${summary.winRate.toStringAsFixed(1)}%',
                '${summary.winningTrades}/${summary.totalTrades} wins',
                summary.winRate >= 50 ? Colors.green : Colors.red,
                Icons.pie_chart,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricCard(
                context,
                'Profit Factor',
                summary.profitFactor.toStringAsFixed(2),
                summary.profitFactor >= 1 ? 'Good' : 'Poor',
                summary.profitFactor >= 1 ? Colors.green : Colors.red,
                Icons.analytics,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                context,
                'Sharpe Ratio',
                summary.sharpeRatio.toStringAsFixed(2),
                summary.sharpeRatio > 1 ? 'Excellent' : 'Fair',
                summary.sharpeRatio > 1 ? Colors.green : Colors.orange,
                Icons.show_chart,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    BuildContext context,
    String title,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0.1),
              color.withValues(alpha: 0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Tooltip(
                    message: _metricTooltip(title),
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeStatsCard(BuildContext context, BacktestSummary summary) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Trades', summary.totalTrades.toString()),
            const Divider(),
            _buildStatRow('Winning Trades', summary.winningTrades.toString(),
                valueColor: Colors.green),
            const Divider(),
            _buildStatRow('Losing Trades', summary.losingTrades.toString(),
                valueColor: Colors.red),
            const Divider(),
            _buildStatRow(
                'Average Win', '\$${summary.averageWin.toStringAsFixed(2)}',
                valueColor: Colors.green),
            const Divider(),
            _buildStatRow(
                'Average Loss', '\$${summary.averageLoss.toStringAsFixed(2)}',
                valueColor: Colors.red),
            const Divider(),
            _buildStatRow(
                'Largest Win', '\$${summary.largestWin.toStringAsFixed(2)}',
                valueColor: Colors.green),
            const Divider(),
            _buildStatRow(
                'Largest Loss', '\$${summary.largestLoss.toStringAsFixed(2)}',
                valueColor: Colors.red),
            const Divider(),
            _buildStatRow(
                'Expectancy', '\$${summary.expectancy.toStringAsFixed(2)}',
                valueColor:
                    summary.expectancy >= 0 ? Colors.green : Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskMetricsCard(BuildContext context, BacktestSummary summary) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow(
              'Max Drawdown',
              '\$${summary.maxDrawdown.toStringAsFixed(2)}',
              valueColor: Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              'Max Drawdown %',
              '${summary.maxDrawdownPercentage.toStringAsFixed(2)}%',
              valueColor: Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              'Profit Factor',
              summary.profitFactor.toStringAsFixed(2),
              valueColor: summary.profitFactor >= 1 ? Colors.green : Colors.red,
            ),
            const Divider(),
            _buildStatRow(
              'Sharpe Ratio',
              summary.sharpeRatio.toStringAsFixed(2),
              valueColor:
                  summary.sharpeRatio > 1 ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTradeHistoryCard(
      BuildContext context, BacktestResultViewModel viewModel) {
    final selected = viewModel.selectedTimeframeFilters;
    final trades = viewModel.result.trades;
    final closedTrades = trades
        .where((t) => t.status == TradeStatus.closed)
        .where((t) => selected.isEmpty
            ? true
            : (t.entryTimeframes?.any(selected.contains) ?? false))
        .toList();

    if (closedTrades.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 64,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.35),
                ),
                const SizedBox(height: 12),
                const Text(
                  'No closed trades yet',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  'Try different parameters or timeframe to generate trades',
                  style: TextStyle(
                    fontSize: 13,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context)
                  .colorScheme
                  .surfaceContainerHighest
                  .withValues(alpha: 0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: const Row(
              children: [
                Expanded(
                    flex: 2,
                    child: Text('Entry',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    flex: 2,
                    child: Text('Exit',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    flex: 1,
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                Expanded(
                    flex: 1,
                    child: Text('P&L',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
              ],
            ),
          ),
          // Trade list (show first 10)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: closedTrades.length > 10 ? 10 : closedTrades.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final trade = closedTrades[index];
              return InkWell(
                onTap: () => _showTradeDetails(context, trade),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${trade.entryTime.day}/${trade.entryTime.month}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              trade.entryPrice.toStringAsFixed(4),
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${trade.exitTime?.day}/${trade.exitTime?.month}',
                              style: const TextStyle(
                                  fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                            Text(
                              trade.exitPrice?.toStringAsFixed(4) ?? '-',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.7)),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: trade.direction == TradeDirection.buy
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                    .withValues(alpha: 0.2)
                                : Theme.of(context)
                                    .colorScheme
                                    .error
                                    .withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            trade.direction == TradeDirection.buy
                                ? 'BUY'
                                : 'SELL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: trade.direction == TradeDirection.buy
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text(
                          '\$${(trade.pnl ?? 0).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: (trade.pnl ?? 0) >= 0
                                ? Colors.green
                                : Colors.red,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          // Show more button
          if (closedTrades.length > 10)
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)!
                      .moreTrades(closedTrades.length - 10),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showTradeDetails(BuildContext context, Trade trade) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    const Text(
                      'Trade Details',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Trade info
                    _buildDetailRow(context, 'Direction',
                        trade.direction == TradeDirection.buy ? 'BUY' : 'SELL'),
                    _buildDetailRow(
                        context, 'Entry Time', '${trade.entryTime}'),
                    _buildDetailRow(
                        context,
                        'Entry Timeframes',
                        (trade.entryTimeframes == null ||
                                trade.entryTimeframes!.isEmpty)
                            ? '-'
                            : trade.entryTimeframes!.join(', ')),
                    _buildDetailRow(context, 'Entry Price',
                        trade.entryPrice.toStringAsFixed(4)),
                    _buildDetailRow(context, 'Exit Time',
                        '${trade.exitTime ?? "Still Open"}'),
                    _buildDetailRow(context, 'Exit Price',
                        trade.exitPrice?.toStringAsFixed(4) ?? '-'),
                    _buildDetailRow(
                        context, 'Lot Size', trade.lotSize.toStringAsFixed(2)),
                    _buildDetailRow(context, 'Stop Loss',
                        trade.stopLoss?.toStringAsFixed(4) ?? '-'),
                    _buildDetailRow(context, 'Take Profit',
                        trade.takeProfit?.toStringAsFixed(4) ?? '-'),
                    _buildDetailRow(context, 'P&L',
                        '\$${(trade.pnl ?? 0).toStringAsFixed(2)}'),
                    _buildDetailRow(context, 'P&L %',
                        '${(trade.pnlPercentage ?? 0).toStringAsFixed(2)}%'),
                    _buildDetailRow(
                        context, 'Exit Reason', trade.exitReason ?? '-'),

                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Tooltip(
            message: _metricTooltip(label),
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context,
    String label,
    ChartMode mode,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected
                ? Theme.of(context).colorScheme.onPrimary
                : Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }

  @override
  BacktestResultViewModel viewModelBuilder(BuildContext context) =>
      BacktestResultViewModel(result);

  @override
  void onViewModelReady(BacktestResultViewModel viewModel) {
    // Trigger a brief busy state on initial load so skeleton appears
    viewModel.runBusyFuture(
      Future<void>.delayed(const Duration(milliseconds: 200), () {
        // Touch candles to ensure any synchronous preparation happens
        viewModel.getCandles();
      }),
    );
    // Initialize subscriptions and realtime updates
    viewModel.initialize();
  }

  String _metricTooltip(String label) {
    switch (label) {
      case 'Total P&L':
        return 'Net profit/loss in currency from all closed trades.';
      case 'Win Rate':
        return 'Percentage of winning trades out of total closed trades.';
      case 'Profit Factor':
        return 'Gross profit divided by gross loss; > 1 indicates profitability.';
      case 'Sharpe Ratio':
        return 'Risk-adjusted return; higher values indicate better risk efficiency.';
      case 'Max Drawdown':
      case 'Max Drawdown %':
        return 'Largest peak-to-trough decline during the backtest.';
      case 'Total Trades':
        return 'Number of closed trades included in the summary.';
      case 'Winning Trades':
        return 'Count of trades with positive P&L.';
      case 'Losing Trades':
        return 'Count of trades with negative P&L.';
      case 'Average Win':
        return 'Average profit per winning trade.';
      case 'Average Loss':
        return 'Average loss per losing trade.';
      case 'Largest Win':
        return 'Biggest single-trade profit observed.';
      case 'Largest Loss':
        return 'Biggest single-trade loss observed.';
      case 'Expectancy':
        return 'Average expected profit per trade; positive indicates an edge.';
      default:
        return 'Metric description';
    }
  }
}
