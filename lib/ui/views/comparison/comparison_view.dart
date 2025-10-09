import 'package:backtestx/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'comparison_viewmodel.dart';

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
                        .surfaceVariant
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

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  @override
  ComparisonViewModel viewModelBuilder(BuildContext context) =>
      ComparisonViewModel(results);
}
