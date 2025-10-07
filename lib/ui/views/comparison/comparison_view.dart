import 'package:backtestx/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';

import 'comparison_viewmodel.dart';

class ComparisonView extends StatelessWidget {
  final List<BacktestResult> results;

  const ComparisonView({
    Key? key,
    required this.results,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<ComparisonViewModel>.reactive(
      viewModelBuilder: () => ComparisonViewModel(results),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Compare Results'),
          actions: [
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
              ],
              onSelected: (value) {
                if (value == 'export') {
                  // TODO: Implement export
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
      ),
    );
  }

  Widget _buildSummaryCards(BuildContext context, ComparisonViewModel model) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(16),
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _buildSummaryCard(context, result, index);
        },
      ),
    );
  }

  Widget _buildSummaryCard(
      BuildContext context, BacktestResult result, int index) {
    final colors = [Colors.blue, Colors.purple, Colors.orange, Colors.teal];
    final color = colors[index % colors.length];

    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
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
                  color: Colors.white.withOpacity(0.3),
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
              color: Colors.white.withOpacity(0.9),
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
                    color: Colors.white.withOpacity(0.9),
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
                    color: Colors.grey[100],
                  ),
                  children: [
                    _buildTableHeader('Metric'),
                    for (int i = 0; i < results.length; i++)
                      _buildTableHeader('R${i + 1}'),
                  ],
                ),

                // Total P&L
                _buildMetricRow(
                  'Total P&L',
                  results.map((r) => _formatPnL(r.summary.totalPnl)).toList(),
                  results.map((r) => r.summary.totalPnl >= 0).toList(),
                ),

                // P&L %
                _buildMetricRow(
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
                  'Win Rate',
                  results
                      .map((r) => '${r.summary.winRate.toStringAsFixed(1)}%')
                      .toList(),
                  null,
                ),

                // Total Trades
                _buildMetricRow(
                  'Total Trades',
                  results.map((r) => '${r.summary.totalTrades}').toList(),
                  null,
                ),

                // Profit Factor
                _buildMetricRow(
                  'Profit Factor',
                  results
                      .map((r) => r.summary.profitFactor.toStringAsFixed(2))
                      .toList(),
                  results.map((r) => r.summary.profitFactor > 1).toList(),
                ),

                // Max Drawdown
                _buildMetricRow(
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
                  'Sharpe Ratio',
                  results
                      .map((r) => r.summary.sharpeRatio.toStringAsFixed(2))
                      .toList(),
                  results.map((r) => r.summary.sharpeRatio > 1).toList(),
                ),

                // Average Win
                _buildMetricRow(
                  'Avg Win',
                  results
                      .map(
                          (r) => '\$${r.summary.averageWin.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Average Loss
                _buildMetricRow(
                  'Avg Loss',
                  results
                      .map((r) =>
                          '\$${r.summary.averageLoss.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Largest Win
                _buildMetricRow(
                  'Largest Win',
                  results
                      .map(
                          (r) => '\$${r.summary.largestWin.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Largest Loss
                _buildMetricRow(
                  'Largest Loss',
                  results
                      .map((r) =>
                          '\$${r.summary.largestLoss.toStringAsFixed(2)}')
                      .toList(),
                  null,
                ),

                // Expectancy
                _buildMetricRow(
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

  Widget _buildTableHeader(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
        textAlign: text == 'Metric' ? TextAlign.left : TextAlign.center,
      ),
    );
  }

  TableRow _buildMetricRow(
    String label,
    List<String> values,
    List<bool>? isPositive,
  ) {
    return TableRow(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
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
                    ? (isPositive[i] ? Colors.green : Colors.red)
                    : Colors.black87,
              ),
            ),
          ),
      ],
    );
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
              'Highest P&L',
              'Result ${results.indexOf(bestByPnL) + 1}',
              _formatPnL(bestByPnL.summary.totalPnl),
              Colors.green,
              Icons.trending_up,
            ),
            const SizedBox(height: 12),
            _buildPerformerCard(
              'Best Win Rate',
              'Result ${results.indexOf(bestByWinRate) + 1}',
              '${bestByWinRate.summary.winRate.toStringAsFixed(1)}%',
              Colors.orange,
              Icons.check_circle,
            ),
            const SizedBox(height: 12),
            _buildPerformerCard(
              'Best Profit Factor',
              'Result ${results.indexOf(bestByProfitFactor) + 1}',
              bestByProfitFactor.summary.profitFactor.toStringAsFixed(2),
              Colors.blue,
              Icons.bar_chart,
            ),
            const SizedBox(height: 12),
            _buildPerformerCard(
              'Lowest Drawdown',
              'Result ${results.indexOf(lowestDrawdown) + 1}',
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
    String title,
    String subtitle,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
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
                    color: Colors.grey[600],
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
              color: color,
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
}
