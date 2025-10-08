// import 'package:backtestx/ui/widgets/equity_curve_chart.dart';
// import 'package:flutter/material.dart';
// import 'package:stacked/stacked.dart';
// import 'package:fl_chart/fl_chart.dart';
// import 'backtest_result_viewmodel.dart';
// import 'package:backtestx/models/trade.dart';

// class BacktestResultView extends StackedView<BacktestResultViewModel> {
//   final String? resultId;

//   const BacktestResultView({Key? key, this.resultId}) : super(key: key);

//   @override
//   Widget builder(
//     BuildContext context,
//     BacktestResultViewModel viewModel,
//     Widget? child,
//   ) {
//     if (viewModel.isBusy) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Backtest Results')),
//         body: const Center(child: CircularProgressIndicator()),
//       );
//     }

//     if (viewModel.result == null) {
//       return Scaffold(
//         appBar: AppBar(title: const Text('Backtest Results')),
//         body: const Center(
//           child: Text('No results to display'),
//         ),
//       );
//     }

//     final result = viewModel.result!;
//     final summary = result.summary;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Backtest Results'),
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.share),
//             onPressed: viewModel.shareResults,
//           ),
//           IconButton(
//             icon: const Icon(Icons.file_download),
//             onPressed: viewModel.exportResults,
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.stretch,
//           children: [
//             // Summary Stats Cards
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     viewModel.strategyName,
//                     style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                           fontWeight: FontWeight.bold,
//                         ),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     'Executed: ${_formatDateTime(result.executedAt)}',
//                     style: Theme.of(context).textTheme.bodyMedium?.copyWith(
//                           color: Colors.grey[600],
//                         ),
//                   ),
//                 ],
//               ),
//             ),

//             // Main Stats Grid
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: GridView.count(
//                 crossAxisCount: 2,
//                 shrinkWrap: true,
//                 physics: const NeverScrollableScrollPhysics(),
//                 mainAxisSpacing: 12,
//                 crossAxisSpacing: 12,
//                 childAspectRatio: 1.5,
//                 children: [
//                   _buildStatCard(
//                     context,
//                     'Total PnL',
//                     '\$${summary.totalPnl.toStringAsFixed(2)}',
//                     '${summary.totalPnlPercentage >= 0 ? '+' : ''}${summary.totalPnlPercentage.toStringAsFixed(2)}%',
//                     summary.totalPnl >= 0 ? Colors.green : Colors.red,
//                     Icons.attach_money,
//                   ),
//                   _buildStatCard(
//                     context,
//                     'Win Rate',
//                     '${summary.winRate.toStringAsFixed(1)}%',
//                     '${summary.winningTrades}/${summary.totalTrades}',
//                     summary.winRate >= 50 ? Colors.green : Colors.orange,
//                     Icons.trending_up,
//                   ),
//                   _buildStatCard(
//                     context,
//                     'Profit Factor',
//                     summary.profitFactor.toStringAsFixed(2),
//                     summary.profitFactor >= 1 ? 'Profitable' : 'Losing',
//                     summary.profitFactor >= 1 ? Colors.green : Colors.red,
//                     Icons.analytics,
//                   ),
//                   _buildStatCard(
//                     context,
//                     'Max Drawdown',
//                     '${summary.maxDrawdownPercentage.toStringAsFixed(1)}%',
//                     '\$${summary.maxDrawdown.toStringAsFixed(2)}',
//                     summary.maxDrawdownPercentage < 20
//                         ? Colors.green
//                         : Colors.orange,
//                     Icons.trending_down,
//                   ),
//                 ],
//               ),
//             ),

//             // Equity Curve Chart
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                         children: [
//                           Text(
//                             'Equity Curve',
//                             style: Theme.of(context).textTheme.titleLarge,
//                           ),
//                           IconButton(
//                             icon: Icon(
//                               viewModel.showDrawdown
//                                   ? Icons.show_chart
//                                   : Icons.area_chart,
//                               size: 20,
//                             ),
//                             onPressed: viewModel.toggleDrawdown,
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       SizedBox(
//                         height: 200,
//                         child: viewModel.showDrawdown
//                             ? _buildDrawdownChart(context, result.equityCurve)
//                             : _buildEquityChart(context, result.equityCurve),
//                       ),
//                       // SizedBox(
//                       //   height: 900,
//                       //   child: EquityCurveChart(
//                       //     equityCurve: result.equityCurve,
//                       //     initialCapital: result.summary.totalPnl > 0
//                       //         ? result.equityCurve.first.equity
//                       //         : 10000, // Default initial capital
//                       //     showDrawdown: true,
//                       //   ),
//                       // ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             // Additional Stats
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Card(
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Detailed Statistics',
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                       const SizedBox(height: 16),
//                       _buildStatRow('Total Trades', '${summary.totalTrades}'),
//                       _buildStatRow(
//                           'Winning Trades', '${summary.winningTrades}'),
//                       _buildStatRow('Losing Trades', '${summary.losingTrades}'),
//                       const Divider(),
//                       _buildStatRow('Average Win',
//                           '\$${summary.averageWin.toStringAsFixed(2)}'),
//                       _buildStatRow('Average Loss',
//                           '\$${summary.averageLoss.toStringAsFixed(2)}'),
//                       _buildStatRow('Largest Win',
//                           '\$${summary.largestWin.toStringAsFixed(2)}'),
//                       _buildStatRow('Largest Loss',
//                           '\$${summary.largestLoss.toStringAsFixed(2)}'),
//                       const Divider(),
//                       _buildStatRow('Expectancy',
//                           '\$${summary.expectancy.toStringAsFixed(2)}'),
//                       _buildStatRow('Sharpe Ratio',
//                           summary.sharpeRatio.toStringAsFixed(2)),
//                     ],
//                   ),
//                 ),
//               ),
//             ),

//             const SizedBox(height: 16),

//             // Trade List
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Card(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             'Trade History',
//                             style: Theme.of(context).textTheme.titleLarge,
//                           ),
//                           Row(
//                             children: [
//                               FilterChip(
//                                 label: const Text('All'),
//                                 selected:
//                                     viewModel.tradeFilter == TradeFilter.all,
//                                 onSelected: (_) =>
//                                     viewModel.setTradeFilter(TradeFilter.all),
//                               ),
//                               const SizedBox(width: 8),
//                               FilterChip(
//                                 label: const Text('Wins'),
//                                 selected:
//                                     viewModel.tradeFilter == TradeFilter.wins,
//                                 onSelected: (_) =>
//                                     viewModel.setTradeFilter(TradeFilter.wins),
//                               ),
//                               const SizedBox(width: 8),
//                               FilterChip(
//                                 label: const Text('Losses'),
//                                 selected:
//                                     viewModel.tradeFilter == TradeFilter.losses,
//                                 onSelected: (_) => viewModel
//                                     .setTradeFilter(TradeFilter.losses),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                     ListView.separated(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: viewModel.filteredTrades.length > 50
//                           ? 50
//                           : viewModel.filteredTrades.length,
//                       separatorBuilder: (_, __) => const Divider(height: 1),
//                       itemBuilder: (context, index) {
//                         final trade = viewModel.filteredTrades[index];
//                         return _buildTradeListItem(context, trade, index + 1);
//                       },
//                     ),
//                     if (viewModel.filteredTrades.length > 50)
//                       Padding(
//                         padding: const EdgeInsets.all(16.0),
//                         child: Center(
//                           child: Text(
//                             'Showing first 50 of ${viewModel.filteredTrades.length} trades',
//                             style: TextStyle(color: Colors.grey[600]),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),

//             const SizedBox(height: 24),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatCard(
//     BuildContext context,
//     String label,
//     String value,
//     String subtitle,
//     Color color,
//     IconData icon,
//   ) {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   label,
//                   style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                         color: Colors.grey[600],
//                       ),
//                 ),
//                 Icon(icon, size: 20, color: color.withValues(alpha: 0.7)),
//               ],
//             ),
//             const Spacer(),
//             Text(
//               value,
//               style: Theme.of(context).textTheme.headlineSmall?.copyWith(
//                     fontWeight: FontWeight.bold,
//                     color: color,
//                   ),
//             ),
//             Text(
//               subtitle,
//               style: Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Colors.grey[600],
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(label, style: const TextStyle(fontSize: 14)),
//           Text(
//             value,
//             style: const TextStyle(
//               fontSize: 14,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildEquityChart(BuildContext context, List<EquityPoint> equity) {
//     if (equity.isEmpty) return const SizedBox();

//     final spots = equity.asMap().entries.map((entry) {
//       return FlSpot(entry.key.toDouble(), entry.value.equity);
//     }).toList();

//     return LineChart(
//       LineChartData(
//         gridData: const FlGridData(
//           show: true,
//           drawVerticalLine: false,
//           horizontalInterval: 1000,
//         ),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 60,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   '\$${(value / 1000).toStringAsFixed(0)}k',
//                   style: const TextStyle(fontSize: 10),
//                 );
//               },
//             ),
//           ),
//           bottomTitles: const AxisTitles(
//             sideTitles: SideTitles(showTitles: false),
//           ),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             color: Colors.blue,
//             barWidth: 2,
//             dotData: const FlDotData(show: false),
//             belowBarData: BarAreaData(
//               show: true,
//               color: Colors.blue.withValues(alpha: 0.1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildDrawdownChart(BuildContext context, List<EquityPoint> equity) {
//     if (equity.isEmpty) return const SizedBox();

//     final spots = equity.asMap().entries.map((entry) {
//       return FlSpot(entry.key.toDouble(), -entry.value.drawdown);
//     }).toList();

//     return LineChart(
//       LineChartData(
//         gridData: const FlGridData(show: true, drawVerticalLine: false),
//         titlesData: FlTitlesData(
//           leftTitles: AxisTitles(
//             sideTitles: SideTitles(
//               showTitles: true,
//               reservedSize: 50,
//               getTitlesWidget: (value, meta) {
//                 return Text(
//                   '\$${(-value).toStringAsFixed(0)}',
//                   style: const TextStyle(fontSize: 10),
//                 );
//               },
//             ),
//           ),
//           bottomTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           topTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//           rightTitles:
//               const AxisTitles(sideTitles: SideTitles(showTitles: false)),
//         ),
//         borderData: FlBorderData(show: false),
//         lineBarsData: [
//           LineChartBarData(
//             spots: spots,
//             isCurved: true,
//             color: Colors.red,
//             barWidth: 2,
//             dotData: const FlDotData(show: false),
//             belowBarData: BarAreaData(
//               show: true,
//               color: Colors.red.withValues(alpha: 0.1),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTradeListItem(BuildContext context, Trade trade, int number) {
//     final isProfitable = (trade.pnl ?? 0) >= 0;

//     return ListTile(
//       leading: CircleAvatar(
//         backgroundColor: isProfitable
//             ? Colors.green.withValues(alpha: 0.2)
//             : Colors.red.withValues(alpha: 0.2),
//         child: Text(
//           '#$number',
//           style: TextStyle(
//             fontSize: 12,
//             color: isProfitable ? Colors.green : Colors.red,
//             fontWeight: FontWeight.bold,
//           ),
//         ),
//       ),
//       title: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//             decoration: BoxDecoration(
//               color: trade.direction == TradeDirection.buy
//                   ? Colors.blue.withValues(alpha: 0.2)
//                   : Colors.orange.withValues(alpha: 0.2),
//               borderRadius: BorderRadius.circular(4),
//             ),
//             child: Text(
//               trade.direction.name.toUpperCase(),
//               style: TextStyle(
//                 fontSize: 12,
//                 fontWeight: FontWeight.bold,
//                 color: trade.direction == TradeDirection.buy
//                     ? Colors.blue
//                     : Colors.orange,
//               ),
//             ),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             '\$${trade.entryPrice.toStringAsFixed(2)} → \$${trade.exitPrice?.toStringAsFixed(2) ?? '---'}',
//             style: const TextStyle(fontSize: 14),
//           ),
//         ],
//       ),
//       subtitle: Text(
//         '${_formatDateTime(trade.entryTime)} • ${trade.exitReason ?? 'Open'}',
//         style: const TextStyle(fontSize: 12),
//       ),
//       trailing: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         crossAxisAlignment: CrossAxisAlignment.end,
//         children: [
//           Text(
//             '\$${trade.pnl?.toStringAsFixed(2) ?? '0.00'}',
//             style: TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.bold,
//               color: isProfitable ? Colors.green : Colors.red,
//             ),
//           ),
//           Text(
//             '${isProfitable ? '+' : ''}${trade.pnlPercentage?.toStringAsFixed(1) ?? '0.0'}%',
//             style: TextStyle(
//               fontSize: 12,
//               color: isProfitable ? Colors.green : Colors.red,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDateTime(DateTime dateTime) {
//     return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
//   }

//   @override
//   BacktestResultViewModel viewModelBuilder(BuildContext context) =>
//       BacktestResultViewModel(resultId);

//   @override
//   void onViewModelReady(BacktestResultViewModel viewModel) =>
//       viewModel.initialize();
// }
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/widgets/equity_curve_chart.dart';
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
            icon: const Icon(Icons.share),
            onPressed: () => viewModel.shareResults(),
            tooltip: 'Share Results',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () => viewModel.exportResults(),
            tooltip: 'Export Results',
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
                      const Text(
                        'Equity Curve',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: EquityCurveChart(
                          equityCurve: result.equityCurve,
                          initialCapital: result.summary.totalPnl > 0
                              ? result.equityCurve.first.equity
                              : 10000, // Default initial capital
                          showDrawdown: true,
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
              color.withOpacity(0.1),
              color.withOpacity(0.05),
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
                      color: Colors.grey[700],
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
                color: Colors.grey[600],
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
              color: Colors.grey[100],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                const Expanded(
                    flex: 2,
                    child: Text('Entry',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                const Expanded(
                    flex: 2,
                    child: Text('Exit',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                const Expanded(
                    flex: 1,
                    child: Text('Type',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 12))),
                const Expanded(
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
                                  fontSize: 10, color: Colors.grey[600]),
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
                                  fontSize: 10, color: Colors.grey[600]),
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
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
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
                                  ? Colors.green
                                  : Colors.red,
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
                color: Colors.grey[50],
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
                    color: Colors.grey[600],
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
                    Text(
                      'Trade Details',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Trade info
                    _buildDetailRow('Direction',
                        trade.direction == TradeDirection.buy ? 'BUY' : 'SELL'),
                    _buildDetailRow('Entry Time', '${trade.entryTime}'),
                    _buildDetailRow(
                        'Entry Price', trade.entryPrice.toStringAsFixed(4)),
                    _buildDetailRow(
                        'Exit Time', '${trade.exitTime ?? "Still Open"}'),
                    _buildDetailRow('Exit Price',
                        trade.exitPrice?.toStringAsFixed(4) ?? '-'),
                    _buildDetailRow(
                        'Lot Size', trade.lotSize.toStringAsFixed(2)),
                    _buildDetailRow(
                        'Stop Loss', trade.stopLoss?.toStringAsFixed(4) ?? '-'),
                    _buildDetailRow('Take Profit',
                        trade.takeProfit?.toStringAsFixed(4) ?? '-'),
                    _buildDetailRow(
                        'P&L', '\$${(trade.pnl ?? 0).toStringAsFixed(2)}'),
                    _buildDetailRow('P&L %',
                        '${(trade.pnlPercentage ?? 0).toStringAsFixed(2)}%'),
                    _buildDetailRow('Exit Reason', trade.exitReason ?? '-'),

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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
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

  @override
  BacktestResultViewModel viewModelBuilder(BuildContext context) =>
      BacktestResultViewModel(result);
}
