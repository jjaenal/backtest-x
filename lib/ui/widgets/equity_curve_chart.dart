import 'package:backtestx/models/trade.dart';
import 'package:backtestx/ui/views/backtest_result/backtest_result_viewmodel.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class EquityCurveChart extends StatelessWidget {
  final List<EquityPoint> equityCurve;
  final double initialCapital;
  final bool showDrawdown;
  final ChartMode? chartMode;

  const EquityCurveChart({
    Key? key,
    required this.equityCurve,
    required this.initialCapital,
    this.showDrawdown = true,
    this.chartMode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (equityCurve.isEmpty) {
      return const Center(child: Text('No equity data available'));
    }

    // Jika chartMode diset, gunakan mode tersebut untuk menentukan tampilan
    final bool shouldShowOnlyDrawdown = chartMode == ChartMode.drawdown;
    final bool shouldShowOnlyEquity = chartMode == ChartMode.equity;

    return Column(
      children: [
        if (!shouldShowOnlyDrawdown) _buildStatsRow(),
        if (!shouldShowOnlyDrawdown) const SizedBox(height: 16),

        // Tampilkan equity chart jika mode equity atau mode default dengan showDrawdown
        if (shouldShowOnlyEquity ||
            (!shouldShowOnlyDrawdown && !shouldShowOnlyEquity))
          Expanded(
            flex: (shouldShowOnlyEquity || !showDrawdown) ? 10 : 7,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, top: 8),
              child: LineChart(_buildEquityChartData()),
            ),
          ),

        // Tampilkan drawdown chart jika mode drawdown atau mode default dengan showDrawdown
        if (shouldShowOnlyDrawdown || (showDrawdown && !shouldShowOnlyEquity))
          Expanded(
            flex: shouldShowOnlyDrawdown ? 10 : 3,
            child: Padding(
              padding: EdgeInsets.only(
                  right: 16, top: shouldShowOnlyDrawdown ? 8 : 16),
              child: LineChart(_buildDrawdownChartData()),
            ),
          ),
      ],
    );
  }

  Widget _buildStatsRow() {
    final finalEquity = equityCurve.last.equity;
    final totalReturn = finalEquity - initialCapital;
    final returnPercent = (totalReturn / initialCapital) * 100;
    final maxDD =
        equityCurve.map((e) => e.drawdown).reduce((a, b) => a > b ? a : b);
    final maxDDPercent = (maxDD / initialCapital) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              'Initial Capital',
              '\$${initialCapital.toStringAsFixed(2)}',
              Icons.account_balance_wallet,
              Colors.blue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Final Equity',
              '\$${finalEquity.toStringAsFixed(2)}',
              Icons.trending_up,
              totalReturn >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Total Return',
              '${returnPercent >= 0 ? '+' : ''}${returnPercent.toStringAsFixed(2)}%',
              returnPercent >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
              returnPercent >= 0 ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatCard(
              'Max Drawdown',
              '${maxDDPercent.toStringAsFixed(2)}%',
              Icons.trending_down,
              Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  LineChartData _buildEquityChartData() {
    final spots = equityCurve
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.equity))
        .toList();

    final minEquity =
        equityCurve.map((e) => e.equity).reduce((a, b) => a < b ? a : b);
    final maxEquity =
        equityCurve.map((e) => e.equity).reduce((a, b) => a > b ? a : b);
    final padding = (maxEquity - minEquity) * 0.1;

    return LineChartData(
      minY: minEquity - padding,
      maxY: maxEquity + padding,
      minX: 0,
      maxX: equityCurve.length.toDouble() - 1,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: (maxEquity - minEquity) / 5,
        getDrawingHorizontalLine: (value) {
          if ((value - initialCapital).abs() < (maxEquity - minEquity) * 0.02) {
            return FlLine(
              color: Colors.blue.withValues(alpha: 0.5),
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          }
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 10),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 30,
            interval: (equityCurve.length / 5).ceilToDouble(),
            getTitlesWidget: (value, meta) {
              final index = value.toInt();
              if (index < 0 || index >= equityCurve.length) {
                return const SizedBox();
              }
              final point = equityCurve[index];
              return Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${point.timestamp.day}/${point.timestamp.month}',
                  style: const TextStyle(fontSize: 9),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.green,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.green.withValues(alpha: 0.3),
                Colors.green.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.black87,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.x.toInt();
              final point = equityCurve[index];
              return LineTooltipItem(
                'Equity: \$${spot.y.toStringAsFixed(2)}\n'
                'Date: ${point.timestamp.day}/${point.timestamp.month}/${point.timestamp.year}',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }

  LineChartData _buildDrawdownChartData() {
    final spots = equityCurve
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), -e.value.drawdown))
        .toList();

    final maxDD =
        equityCurve.map((e) => e.drawdown).reduce((a, b) => a > b ? a : b);

    return LineChartData(
      minY: -maxDD * 1.2,
      maxY: maxDD * 0.1,
      minX: 0,
      maxX: equityCurve.length.toDouble() - 1,
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: maxDD / 3,
        getDrawingHorizontalLine: (value) {
          if (value == 0) {
            return FlLine(
              color: Colors.grey[600]!,
              strokeWidth: 2,
            );
          }
          return FlLine(
            color: Colors.grey[300]!,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        rightTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 60,
            getTitlesWidget: (value, meta) {
              return Text(
                '\$${value.abs().toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 10, color: Colors.red),
              );
            },
          ),
        ),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles:
            const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      ),
      borderData: FlBorderData(
        show: true,
        border: Border.all(color: Colors.grey[300]!),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: true,
          color: Colors.red,
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                Colors.red.withValues(alpha: 0.0),
                Colors.red.withValues(alpha: 0.3),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          tooltipBgColor: Colors.red[900]!,
          getTooltipItems: (spots) {
            return spots.map((spot) {
              final index = spot.x.toInt();
              final point = equityCurve[index];
              return LineTooltipItem(
                'Drawdown: \$${point.drawdown.toStringAsFixed(2)}\n'
                '${((point.drawdown / initialCapital) * 100).toStringAsFixed(2)}%',
                const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              );
            }).toList();
          },
        ),
      ),
    );
  }
}
