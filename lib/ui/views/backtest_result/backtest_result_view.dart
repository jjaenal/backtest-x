import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/widgets/equity_curve_chart.dart';
import 'package:backtestx/ui/widgets/common/candlestick_chart/candlestick_chart.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'backtest_result_viewmodel.dart';

class BacktestResultView extends StackedView<BacktestResultViewModel> {
  final BacktestResult result;

  const BacktestResultView({
    Key? key,
    required this.result,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    BacktestResultViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backtest Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () => viewModel.copySummaryToClipboard(),
            tooltip: 'Copy Summary',
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => viewModel.shareResults(),
            tooltip: 'Share Results',
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => viewModel.exportPdf(),
            tooltip: 'Export PDF',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => viewModel.exportResults(),
            tooltip: 'Export CSV',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                                  .surfaceVariant
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
                                  () =>
                                      viewModel.setChartMode(ChartMode.equity),
                                ),
                                _buildModeButton(
                                  context,
                                  'Drawdown',
                                  ChartMode.drawdown,
                                  viewModel.chartMode == ChartMode.drawdown,
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
                        child: EquityCurveChart(
                          equityCurve: result.equityCurve,
                          initialCapital: (result.equityCurve.isNotEmpty &&
                                  result.summary.totalPnl > 0)
                              ? result.equityCurve.first.equity
                              : 10000, // Fallback jika equityCurve kosong
                          showDrawdown:
                              viewModel.chartMode == ChartMode.drawdown,
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
                          child: CandlestickChart(
                            candles: viewModel.getCandles(),
                            trades: result.trades,
                            title: 'Price Action with Entry/Exit Points',
                            showVolume: false,
                          ),
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
                  _buildSectionTitle('Trade Statistics'),
                  const SizedBox(height: 12),
                  _buildTradeStatsCard(context, result.summary),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Risk Metrics'),
                  const SizedBox(height: 12),
                  _buildRiskMetricsCard(context, result.summary),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Trade History'),
                  const SizedBox(height: 12),
                  _buildTradeHistoryCard(context, result.trades),
                ],
              ),
            ),
          ],
        ),
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

  Widget _buildTradeHistoryCard(BuildContext context, List<Trade> trades) {
    final closedTrades =
        trades.where((t) => t.status == TradeStatus.closed).toList();

    if (closedTrades.isEmpty) {
      return Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: const Padding(
          padding: EdgeInsets.all(32),
          child: Center(
            child: Text('No closed trades'),
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
                  .surfaceVariant
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
                    .surfaceVariant
                    .withValues(alpha: 0.12),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: Text(
                  '+ ${closedTrades.length - 10} more trades',
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
          Text(label, style: const TextStyle(fontSize: 14)),
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
            color:
                Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
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
}
