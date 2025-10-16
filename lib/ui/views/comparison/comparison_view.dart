import 'package:backtestx/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter/rendering.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'comparison_viewmodel.dart';
import '../../widgets/grouped_tf_bar_chart.dart';

// Global repaint key for grouped per‑TF chart capture
final GlobalKey _groupedTfChartKey = GlobalKey();

class ComparisonView extends StackedView<ComparisonViewModel> {
  final List<BacktestResult> results;

  const ComparisonView({
    Key? key,
    required this.results,
  }) : super(key: key);

  @override
  void onViewModelReady(ComparisonViewModel viewModel) =>
      viewModel.initialize();

  Widget _buildSummaryCards(BuildContext context, ComparisonViewModel model) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _buildSummaryCard(context, model, result, index);
        },
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, ComparisonViewModel model,
      BacktestResult result, int index) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal];
    final color = colors[index % colors.length];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Result ${index + 1}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Strategy name
          Text(
            model.strategyLabelFor(result.strategyId),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _formatPnL(result.summary.totalPnl),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            _formatPnLPercent(result.summary.totalPnlPercentage),
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 16,
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.calendar_today, color: Colors.white, size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormat('MMM dd, yyyy').format(result.executedAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonTable(
      BuildContext context, ComparisonViewModel model) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Detailed Metrics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Table
            Table(
              border: TableBorder(
                horizontalInside: BorderSide(color: Colors.grey[300]!),
              ),
              columnWidths: const {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(1),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceContainerHighest
                        .withValues(alpha: 0.2),
                  ),
                  children: [
                    _buildTableHeader(context, 'Metric'),
                    for (int i = 0; i < results.length; i++)
                      _buildTableHeader(
                        context,
                        'R${i + 1}: ${model.strategyLabelFor(results[i].strategyId)}',
                      ),
                  ],
                ),

                // Total P&L
                _buildMetricRow(
                  context,
                  'Total P&L',
                  results.map((r) => _formatPnL(r.summary.totalPnl)).toList(),
                  results.map((r) => r.summary.totalPnl >= 0).toList(),
                ),

                // P&L %
                _buildMetricRow(
                  context,
                  'Return %',
                  results
                      .map((r) =>
                          _formatPnLPercent(r.summary.totalPnlPercentage))
                      .toList(),
                  results
                      .map((r) => r.summary.totalPnlPercentage >= 0)
                      .toList(),
                ),

                // Win Rate
                _buildMetricRow(
                  context,
                  'Win Rate',
                  results
                      .map((r) => '${r.summary.winRate.toStringAsFixed(1)}%')
                      .toList(),
                  null,
                ),

                // Total Trades
                _buildMetricRow(
                  context,
                  'Total Trades',
                  results.map((r) => '${r.summary.totalTrades}').toList(),
                  null,
                ),

                // Profit Factor
                _buildMetricRow(
                  context,
                  'Profit Factor',
                  results
                      .map((r) => r.summary.profitFactor.toStringAsFixed(2))
                      .toList(),
                  results.map((r) => r.summary.profitFactor > 1).toList(),
                ),

                // Max Drawdown
                _buildMetricRow(
                  context,
                  'Max Drawdown',
                  results
                      .map((r) =>
                          '${r.summary.maxDrawdownPercentage.toStringAsFixed(2)}%')
                      .toList(),
                  results
                      .map((r) => r.summary.maxDrawdownPercentage < 20)
                      .toList(),
                ),

                // Sharpe Ratio
                _buildMetricRow(
                  context,
                  'Sharpe Ratio',
                  results
                      .map((r) => r.summary.sharpeRatio.toStringAsFixed(2))
                      .toList(),
                  results.map((r) => r.summary.sharpeRatio > 1).toList(),
                ),

                // Average Win
                _buildMetricRow(
                  context,
                  'Avg Win',
                  results
                      .map(
                          (r) => '\$${r.summary.averageWin.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Average Loss
                _buildMetricRow(
                  context,
                  'Avg Loss',
                  results
                      .map((r) =>
                          '\$${r.summary.averageLoss.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Largest Win
                _buildMetricRow(
                  context,
                  'Largest Win',
                  results
                      .map(
                          (r) => '\$${r.summary.largestWin.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Largest Loss
                _buildMetricRow(
                  context,
                  'Largest Loss',
                  results
                      .map((r) =>
                          '\$${r.summary.largestLoss.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Expectancy
                _buildMetricRow(
                  context,
                  'Expectancy',
                  results
                      .map(
                          (r) => '\$${r.summary.expectancy.toStringAsFixed(2)}')
                      .toList(),
                  results.map((r) => r.summary.expectancy > 0).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        textAlign: text == 'Metric' ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  TableRow _buildMetricRow(
    BuildContext context,
    String label,
    List<String> values,
    List<bool>? isPositive,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Tooltip(
            message: _metricTooltip(label),
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
        ),
        for (int i = 0; i < values.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Text(
              values[i],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isPositive != null
                    ? (isPositive[i]
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.error)
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ),
      ],
    );
  }

  String _metricTooltip(String label) {
    switch (label) {
      case 'Total P&L':
        return 'Net profit/loss in currency from all closed trades.';
      case 'Return %':
        return 'Total P&L expressed as a percentage of initial capital.';
      case 'Win Rate':
        return 'Percentage of winning trades out of total closed trades.';
      case 'Total Trades':
        return 'Number of closed trades included in the summary.';
      case 'Profit Factor':
        return 'Gross profit divided by gross loss; > 1 indicates profitability.';
      case 'Max Drawdown':
        return 'Largest peak-to-trough decline during the backtest (percentage shown).';
      case 'Sharpe Ratio':
        return 'Risk-adjusted return; higher values indicate better risk efficiency.';
      case 'Avg Win':
        return 'Average profit per winning trade.';
      case 'Avg Loss':
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

  Widget _buildBestPerformer(BuildContext context, ComparisonViewModel model) {
    final bestByPnL = model.bestByPnL;
    final bestByWinRate = model.bestByWinRate;
    final bestByProfitFactor = model.bestByProfitFactor;
    final lowestDrawdown = model.lowestDrawdown;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Best Performers',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildPerformerCard(
              context,
              'Highest P&L',
              model.strategyLabelFor(bestByPnL.strategyId),
              _formatPnL(bestByPnL.summary.totalPnl),
              Colors.green,
              Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _buildPerformerCard(
              context,
              'Best Win Rate',
              model.strategyLabelFor(bestByWinRate.strategyId),
              '${bestByWinRate.summary.winRate.toStringAsFixed(1)}%',
              Colors.orange,
              Icons.check_circle,
            ),
            const SizedBox(height: 12),
            _buildPerformerCard(
              context,
              'Best Profit Factor',
              model.strategyLabelFor(bestByProfitFactor.strategyId),
              bestByProfitFactor.summary.profitFactor.toStringAsFixed(2),
              Colors.blue,
              Icons.bar_chart,
            ),
            const SizedBox(height: 12),
            _buildPerformerCard(
              context,
              'Lowest Drawdown',
              model.strategyLabelFor(lowestDrawdown.strategyId),
              '${lowestDrawdown.summary.maxDrawdownPercentage.toStringAsFixed(2)}%',
              Colors.purple,
              Icons.trending_down,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformerCard(
    BuildContext context,
    String title,
    String subtitle,
    String value,
    Color color,
    IconData icon,
  ) {
    final derivedColor = icon == Icons.trending_down
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: derivedColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: derivedColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: derivedColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: derivedColor, size: 24),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: derivedColor,
            ),
          ),
        ],
      ),
    );
  }

  String _formatPnL(double pnl) {
    final sign = pnl >= 0 ? '+' : '';
    return '$sign\$${pnl.toStringAsFixed(2)}';
  }

  String _formatPnLPercent(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  @override
  Widget builder(
      BuildContext context, ComparisonViewModel model, Widget? child) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compare Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export Comparison CSV',
            onPressed: () async {
              final ok = await model.exportComparisonCsv();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Ekspor comparison CSV berhasil'
                        : 'Ekspor comparison CSV gagal',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy Comparison Summary',
            onPressed: () async {
              final ok = await model.copySummaryToClipboard();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Ringkasan comparison disalin ke clipboard'
                        : 'Gagal menyalin ringkasan ke clipboard',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'export',
                child: Row(
                  children: [
                    Icon(Icons.download, size: 20),
                    SizedBox(width: 12),
                    Text('Export Comparison'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'copy',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 20),
                    SizedBox(width: 12),
                    Text('Copy Summary'),
                  ],
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'export') {
                final ok = await model.exportComparisonCsv();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Ekspor comparison CSV berhasil'
                          : 'Ekspor comparison CSV gagal',
                    ),
                  ),
                );
              } else if (value == 'copy') {
                final ok = await model.copySummaryToClipboard();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      ok
                          ? 'Ringkasan comparison disalin ke clipboard'
                          : 'Gagal menyalin ringkasan ke clipboard',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Summary cards
            _buildSummaryCards(context, model),

            const SizedBox(height: 16),

            // Detailed comparison table
            _buildComparisonTable(context, model),

            const SizedBox(height: 16),

            // Best performer highlight
            _buildBestPerformer(context, model),

            const SizedBox(height: 16),
            // Per‑Timeframe Stats for each result
            _buildPerTfStats(context, model),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  ComparisonViewModel viewModelBuilder(BuildContext context) =>
      ComparisonViewModel(results);

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildPerTfStats(BuildContext context, ComparisonViewModel model) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Per-Timeframe Stats'),
          const SizedBox(height: 12),
          // Global TF filter chips and actions
          Builder(builder: (context) {
            final tfs = model.getAllAvailableTimeframes();
            if (tfs.isEmpty) return const SizedBox.shrink();
            final counts = model.getTimeframeCountsAcrossResults();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    ...tfs.map((tf) {
                      final isSelected =
                          model.selectedTimeframeFilters.contains(tf);
                      return FilterChip(
                        selected: isSelected,
                        showCheckmark: true,
                        label: Text(
                          '$tf (${counts[tf] ?? 0})',
                          style: TextStyle(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                        ),
                        onSelected: (_) => model.toggleTimeframeFilter(tf),
                        selectedColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.12),
                        checkmarkColor: Theme.of(context).colorScheme.primary,
                      );
                    }),
                    if (model.selectedTimeframeFilters.isNotEmpty)
                      TextButton.icon(
                        onPressed: model.clearTimeframeFilters,
                        icon: const Icon(Icons.clear),
                        label: const Text('Clear filters'),
                      ),
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () =>
                          model.exportComparisonTfStats(format: 'csv'),
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                    ),
                    OutlinedButton(
                      onPressed: () =>
                          model.exportComparisonTfStats(format: 'tsv'),
                      child: const Text('Export TSV'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Metric selector and grouped per‑TF chart
                Row(
                  children: [
                    Tooltip(
                      message: _metricTooltip(model.selectedTfMetric),
                      child: Text('Chart Metric:',
                          style: Theme.of(context).textTheme.bodyMedium),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<String>(
                      value: model.selectedTfMetric,
                      items: ComparisonViewModel.availableTfMetrics
                          .map((m) => DropdownMenuItem(
                                value: m,
                                child: Text(m),
                              ))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) model.setSelectedTfMetric(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Builder(builder: (context) {
                  final grouped = model.getGroupedTfMetricSeries();
                  final labels = model.getSeriesLabels();
                  final tfOrder = model.getTimeframeOrderForGrouped();
                  if (grouped.isEmpty || tfOrder.isEmpty) {
                    return _emptyGroupedState(context, model);
                  }
                  return GroupedTfBarChart(
                    data: grouped,
                    seriesOrder: labels,
                    timeframeOrder: tfOrder,
                    metricLabel: model.selectedTfMetric,
                    isPercent: model.selectedTfMetric == 'winRate',
                    repaintKey: _groupedTfChartKey,
                    overlayWatermark:
                        'BacktestX • ${model.selectedTfMetric} • ${DateTime.now().toIso8601String().replaceFirst('T', ' ').substring(0, 16)}',
                    maxRows: 24,
                  );
                }),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    // Sorting dropdown
                    DropdownButton<String>(
                      value: model.groupedTfSort,
                      items: const [
                        DropdownMenuItem(
                            value: 'timeframe', child: Text('Sort: TF')),
                        DropdownMenuItem(
                            value: 'valueAsc', child: Text('Sort: Value ↑')),
                        DropdownMenuItem(
                            value: 'valueDesc', child: Text('Sort: Value ↓')),
                      ],
                      onChanged: (v) =>
                          v != null ? model.setGroupedTfSort(v) : null,
                    ),
                    // Aggregation dropdown (Avg vs Max)
                    DropdownButton<String>(
                      value: model.groupedTfAgg,
                      items: const [
                        DropdownMenuItem(value: 'avg', child: Text('Agg: Avg')),
                        DropdownMenuItem(value: 'max', child: Text('Agg: Max')),
                      ],
                      onChanged: (v) =>
                          v != null ? model.setGroupedTfAgg(v) : null,
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _exportGroupedChartPng(
                        context,
                        model,
                        pixelRatio: 2.0,
                      ),
                      icon: const Icon(Icons.image),
                      label: const Text('Export Chart PNG'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _exportGroupedChartPdf(
                        context,
                        model,
                        pixelRatio: 2.0,
                      ),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text('Export Chart PDF'),
                    ),
                    OutlinedButton.icon(
                      onPressed: () => _exportGroupedChartCsv(
                        context,
                        model,
                      ),
                      icon: const Icon(Icons.table_chart),
                      label: const Text('Export Chart CSV'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            );
          }),
          Column(
            children: List.generate(results.length, (index) {
              final r = results[index];
              final stats = model.getFilteredTfStatsFor(r);
              if (stats.isEmpty) {
                return const SizedBox.shrink();
              }
              final entries = stats.entries.toList()
                ..sort((a, b) => a.key.compareTo(b.key));
              return Card(
                elevation: 1,
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'R${index + 1}: ${model.strategyLabelFor(r.strategyId)}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: entries.map((e) {
                          final tf = e.key;
                          final s = e.value;
                          final signals = (s['signals'] ?? 0).toInt();
                          final trades = (s['trades'] ?? 0).toInt();
                          final wins = (s['wins'] ?? 0).toInt();
                          final wr = (s['winRate'] ?? 0).toDouble();
                          final pf = (s['profitFactor'] ?? 0).toDouble();
                          final ex = (s['expectancy'] ?? 0).toDouble();
                          final avgW = (s['avgWin'] ?? 0).toDouble();
                          final avgL = (s['avgLoss'] ?? 0).toDouble();
                          final rr = (s['rr'] ?? 0).toDouble();
                          return _tfStatChip(
                            context,
                            tf,
                            signals,
                            trades,
                            wins,
                            wr,
                            pf,
                            ex,
                            avgW,
                            avgL,
                            rr,
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _tfStatChip(
    BuildContext context,
    String tf,
    int signals,
    int trades,
    int wins,
    double winRate,
    double profitFactor,
    double expectancy,
    double avgWin,
    double avgLoss,
    double rr,
  ) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.3)),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Text(
            tf,
            style: theme.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
          _statChip(context, 'Signals', signals.toString()),
          _statChip(context, 'Trades', trades.toString()),
          _statChip(context, 'Wins', wins.toString()),
          _statChip(context, 'WinRate', '${winRate.toStringAsFixed(1)}%'),
          _statChip(context, 'PF', profitFactor.toStringAsFixed(2)),
          _statChip(context, 'Expectancy', expectancy.toStringAsFixed(2)),
          _statChip(context, 'AvgWin', avgWin.toStringAsFixed(2)),
          _statChip(context, 'AvgLoss', avgLoss.toStringAsFixed(2)),
          _statChip(context, 'R/R', rr.toStringAsFixed(2)),
        ],
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

  Future<void> _exportGroupedChartPng(
    BuildContext context,
    ComparisonViewModel model, {
    double pixelRatio = 2.0,
  }) async {
    try {
      final bytes = await _captureWidgetPng(_groupedTfChartKey, pixelRatio);
      if (bytes == null) return;
      final composed = await _composeOpaquePng(context, bytes);
      final fileName = model.generateExportFilename(
        baseLabel: 'grouped_${model.selectedTfMetric}',
        ext: 'png',
      );
      if (kIsWeb) {
        final blob = html.Blob([composed], 'image/png');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if ((anchor.href ?? '').isNotEmpty) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/$fileName';
        final file = File(path);
        await file.writeAsBytes(composed);
        await Share.shareXFiles([XFile(path)], text: 'BacktestX Grouped Chart');
      }
    } catch (_) {}
  }

  Future<void> _exportGroupedChartPdf(
    BuildContext context,
    ComparisonViewModel model, {
    double pixelRatio = 2.0,
  }) async {
    try {
      final bytes = await _captureWidgetPng(_groupedTfChartKey, pixelRatio);
      if (bytes == null) return;
      final composed = await _composeOpaquePng(context, bytes);
      final fileName = model.generateExportFilename(
        baseLabel: 'grouped_${model.selectedTfMetric}',
        ext: 'pdf',
      );
      await model.exportImagePdf(
        composed,
        fileName,
        title: 'Grouped Per‑TF: ${model.selectedTfMetric}',
      );
    } catch (_) {}
  }

  Future<void> _exportGroupedChartCsv(
    BuildContext context,
    ComparisonViewModel model,
  ) async {
    try {
      final grouped = model.getGroupedTfMetricSeries();
      final labels = model.getSeriesLabels();
      // Respect the current timeframe ordering used in the chart
      final tfs = model.getTimeframeOrderForGrouped();
      final rows = <List<String>>[];
      rows.add(['Timeframe', ...labels]);
      for (final tf in tfs) {
        final m = grouped[tf] ?? {};
        final row = <String>[tf];
        for (final label in labels) {
          final v = m[label];
          row.add(v == null ? '' : v.toString());
        }
        rows.add(row);
      }
      final csvContent = rows.map((r) => r.join(',')).join('\n');
      final fileName = model.generateExportFilename(
        baseLabel: 'grouped_${model.selectedTfMetric}',
        ext: 'csv',
      );
      if (kIsWeb) {
        final blob = html.Blob([csvContent], 'text/csv');
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..setAttribute('download', fileName)
          ..click();
        if ((anchor.href ?? '').isNotEmpty) {
          html.Url.revokeObjectUrl(url);
        }
      } else {
        final dir = await getApplicationDocumentsDirectory();
        final path = '${dir.path}/$fileName';
        final file = File(path);
        await file.writeAsString(csvContent);
        await Share.shareXFiles([XFile(path)],
            text: 'BacktestX Grouped TF Chart CSV');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export CSV gagal: $e')),
        );
      }
    }
  }

  Widget _emptyGroupedState(BuildContext context, ComparisonViewModel model) {
    final theme = Theme.of(context);
    final hasFilter = model.selectedTimeframeFilters.isNotEmpty;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.insights,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              const SizedBox(width: 8),
              Text(
                'No grouped data to display',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            hasFilter
                ? 'Adjust the timeframe filters above or change metric.'
                : 'Run comparison with results that include per‑TF stats, or change metric.',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _captureWidgetPng(GlobalKey key, double pixelRatio) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (_) {
      return null;
    }
  }

  Future<Uint8List> _composeOpaquePng(
      BuildContext context, Uint8List rawPngBytes) async {
    final uiImage = await decodeImageFromList(rawPngBytes);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final paint = Paint()..color = Theme.of(context).colorScheme.surface;
    canvas.drawRect(
      Rect.fromLTWH(0, 0, uiImage.width.toDouble(), uiImage.height.toDouble()),
      paint,
    );
    canvas.drawImage(uiImage, const Offset(0, 0), Paint());
    final picture = recorder.endRecording();
    final composedImage = await picture.toImage(uiImage.width, uiImage.height);
    final byteData =
        await composedImage.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }
}
