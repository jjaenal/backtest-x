import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:fl_chart/fl_chart.dart';
import 'backtest_result_viewmodel.dart';
import 'package:backtestx/models/trade.dart';

class BacktestResultView extends StackedView<BacktestResultViewModel> {
  final String? resultId;

  const BacktestResultView({Key? key, this.resultId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BacktestResultViewModel viewModel,
    Widget? child,
  ) {
    if (viewModel.isBusy) {
      return Scaffold(
        appBar: AppBar(title: const Text('Backtest Results')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (viewModel.result == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Backtest Results')),
        body: const Center(
          child: Text('No results to display'),
        ),
      );
    }

    final result = viewModel.result!;
    final summary = result.summary;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Backtest Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: viewModel.shareResults,
          ),
          IconButton(
            icon: const Icon(Icons.file_download),
            onPressed: viewModel.exportResults,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary Stats Cards
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    viewModel.strategyName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Executed: ${_formatDateTime(result.executedAt)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
                ],
              ),
            ),

            // Main Stats Grid
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    context,
                    'Total PnL',
                    '\$${summary.totalPnl.toStringAsFixed(2)}',
                    '${summary.totalPnlPercentage >= 0 ? '+' : ''}${summary.totalPnlPercentage.toStringAsFixed(2)}%',
                    summary.totalPnl >= 0 ? Colors.green : Colors.red,
                    Icons.attach_money,
                  ),
                  _buildStatCard(
                    context,
                    'Win Rate',
                    '${summary.winRate.toStringAsFixed(1)}%',
                    '${summary.winningTrades}/${summary.totalTrades}',
                    summary.winRate >= 50 ? Colors.green : Colors.orange,
                    Icons.trending_up,
                  ),
                  _buildStatCard(
                    context,
                    'Profit Factor',
                    summary.profitFactor.toStringAsFixed(2),
                    summary.profitFactor >= 1 ? 'Profitable' : 'Losing',
                    summary.profitFactor >= 1 ? Colors.green : Colors.red,
                    Icons.analytics,
                  ),
                  _buildStatCard(
                    context,
                    'Max Drawdown',
                    '${summary.maxDrawdownPercentage.toStringAsFixed(1)}%',
                    '\$${summary.maxDrawdown.toStringAsFixed(2)}',
                    summary.maxDrawdownPercentage < 20
                        ? Colors.green
                        : Colors.orange,
                    Icons.trending_down,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Equity Curve Chart
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Equity Curve',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          IconButton(
                            icon: Icon(
                              viewModel.showDrawdown
                                  ? Icons.show_chart
                                  : Icons.area_chart,
                              size: 20,
                            ),
                            onPressed: viewModel.toggleDrawdown,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: viewModel.showDrawdown
                            ? _buildDrawdownChart(context, result.equityCurve)
                            : _buildEquityChart(context, result.equityCurve),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Additional Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detailed Statistics',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildStatRow('Total Trades', '${summary.totalTrades}'),
                      _buildStatRow(
                          'Winning Trades', '${summary.winningTrades}'),
                      _buildStatRow('Losing Trades', '${summary.losingTrades}'),
                      const Divider(),
                      _buildStatRow('Average Win',
                          '\$${summary.averageWin.toStringAsFixed(2)}'),
                      _buildStatRow('Average Loss',
                          '\$${summary.averageLoss.toStringAsFixed(2)}'),
                      _buildStatRow('Largest Win',
                          '\$${summary.largestWin.toStringAsFixed(2)}'),
                      _buildStatRow('Largest Loss',
                          '\$${summary.largestLoss.toStringAsFixed(2)}'),
                      const Divider(),
                      _buildStatRow('Expectancy',
                          '\$${summary.expectancy.toStringAsFixed(2)}'),
                      _buildStatRow('Sharpe Ratio',
                          summary.sharpeRatio.toStringAsFixed(2)),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Trade List
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Trade History',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          Row(
                            children: [
                              FilterChip(
                                label: const Text('All'),
                                selected:
                                    viewModel.tradeFilter == TradeFilter.all,
                                onSelected: (_) =>
                                    viewModel.setTradeFilter(TradeFilter.all),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Wins'),
                                selected:
                                    viewModel.tradeFilter == TradeFilter.wins,
                                onSelected: (_) =>
                                    viewModel.setTradeFilter(TradeFilter.wins),
                              ),
                              const SizedBox(width: 8),
                              FilterChip(
                                label: const Text('Losses'),
                                selected:
                                    viewModel.tradeFilter == TradeFilter.losses,
                                onSelected: (_) => viewModel
                                    .setTradeFilter(TradeFilter.losses),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: viewModel.filteredTrades.length > 50
                          ? 50
                          : viewModel.filteredTrades.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final trade = viewModel.filteredTrades[index];
                        return _buildTradeListItem(context, trade, index + 1);
                      },
                    ),
                    if (viewModel.filteredTrades.length > 50)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Center(
                          child: Text(
                            'Showing first 50 of ${viewModel.filteredTrades.length} trades',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    String subtitle,
    Color color,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                Icon(icon, size: 20, color: color.withOpacity(0.7)),
              ],
            ),
            const Spacer(),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquityChart(BuildContext context, List<EquityPoint> equity) {
    if (equity.isEmpty) return const SizedBox();

    final spots = equity.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.equity);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 1000,
        ),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 60,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(value / 1000).toStringAsFixed(0)}k',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.blue,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.blue.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawdownChart(BuildContext context, List<EquityPoint> equity) {
    if (equity.isEmpty) return const SizedBox();

    final spots = equity.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), -entry.value.drawdown);
    }).toList();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true, drawVerticalLine: false),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 50,
              getTitlesWidget: (value, meta) {
                return Text(
                  '\$${(-value).toStringAsFixed(0)}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Colors.red,
            barWidth: 2,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.red.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTradeListItem(BuildContext context, Trade trade, int number) {
    final isProfitable = (trade.pnl ?? 0) >= 0;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isProfitable
            ? Colors.green.withOpacity(0.2)
            : Colors.red.withOpacity(0.2),
        child: Text(
          '#$number',
          style: TextStyle(
            fontSize: 12,
            color: isProfitable ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: trade.direction == TradeDirection.buy
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.orange.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              trade.direction.name.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: trade.direction == TradeDirection.buy
                    ? Colors.blue
                    : Colors.orange,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '\$${trade.entryPrice.toStringAsFixed(2)} → \$${trade.exitPrice?.toStringAsFixed(2) ?? '---'}',
            style: const TextStyle(fontSize: 14),
          ),
        ],
      ),
      subtitle: Text(
        '${_formatDateTime(trade.entryTime)} • ${trade.exitReason ?? 'Open'}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            '\$${trade.pnl?.toStringAsFixed(2) ?? '0.00'}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isProfitable ? Colors.green : Colors.red,
            ),
          ),
          Text(
            '${isProfitable ? '+' : ''}${trade.pnlPercentage?.toStringAsFixed(1) ?? '0.0'}%',
            style: TextStyle(
              fontSize: 12,
              color: isProfitable ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  BacktestResultViewModel viewModelBuilder(BuildContext context) =>
      BacktestResultViewModel(resultId);

  @override
  void onViewModelReady(BacktestResultViewModel viewModel) =>
      viewModel.initialize();
}
