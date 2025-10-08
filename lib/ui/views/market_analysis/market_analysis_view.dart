import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/ui/widgets/common/candlestick_chart/candlestick_chart.dart';
import 'package:backtestx/ui/widgets/common/indicator_panel/indicator_panel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';

import 'market_analysis_viewmodel.dart';

class MarketAnalysisView extends StackedView<MarketAnalysisViewModel> {
  const MarketAnalysisView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(MarketAnalysisViewModel viewModel) =>
      viewModel.initialize();

  @override
  Widget builder(
    BuildContext context,
    MarketAnalysisViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Market Analysis'),
        actions: [
          if (viewModel.selectedMarketData != null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => viewModel.showIndicatorSettings(),
              tooltip: 'Chart Settings',
            ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Market selector
                _buildMarketSelector(context, viewModel),

                // Analysis content
                Expanded(
                  child: viewModel.selectedMarketData == null
                      ? _buildEmptyState(context)
                      : viewModel.analysisData == null
                          ? const Center(child: CircularProgressIndicator())
                          : _buildAnalysisContent(context, viewModel),
                ),
              ],
            ),
    );
  }

  Widget _buildMarketSelector(
    BuildContext context,
    MarketAnalysisViewModel model,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Market',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (model.marketDataList.isEmpty)
            const Text('No market data available')
          else
            DropdownButtonFormField<MarketDataInfo>(
              value: model.selectedMarketData,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              hint: const Text('Select market...'),
              items: model.marketDataList.map((data) {
                return DropdownMenuItem(
                  value: data,
                  child: Text(data.symbol),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  model.selectMarketData(value);
                }
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Select market to analyze',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisContent(
    BuildContext context,
    MarketAnalysisViewModel model,
  ) {
    final data = model.analysisData!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Price Chart with indicators
          SizedBox(
            height: 400,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: CandlestickChart(
                  candles: model.marketData!.candles,
                  sma: model.sma20,
                  ema: model.ema50,
                  // bollingerBands: model.bb,
                  showVolume: false, //model.marketData!.hasVolumeData,
                  title:
                      '${model.analysisData!.symbol} (${model.analysisData!.timeframe})',
                  onRangeChanged: (startIndex, endIndex) {
                    model.updateChartRange(startIndex, endIndex);
                  },
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // RSI Panel
          SizedBox(
            height: 180,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IndicatorPanel(
                  type: IndicatorType.rsi,
                  values: model.rsi!,
                  totalCandles: model.marketData!.candles.length,
                  startIndex: model.chartStartIndex,
                  endIndex: model.chartEndIndex,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // MACD Panel
          SizedBox(
            height: 180,
            child: Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: IndicatorPanel(
                  type: IndicatorType.macd,
                  values: model.macd!['macd']!,
                  additionalLine1: model.macd!['signal'],
                  additionalLine2: model.macd!['histogram'],
                  totalCandles: model.marketData!.candles.length,
                  startIndex: model.chartStartIndex,
                  endIndex: model.chartEndIndex,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Overview card
          _buildOverviewCard(context, data),
          const SizedBox(height: 16),

          // Price statistics
          _buildSectionTitle('Price Statistics'),
          const SizedBox(height: 12),
          _buildPriceStats(context, data),
          const SizedBox(height: 16),

          // Trend analysis
          _buildSectionTitle('Trend Analysis'),
          const SizedBox(height: 12),
          _buildTrendAnalysis(context, data),
          const SizedBox(height: 16),

          // Volatility
          _buildSectionTitle('Volatility'),
          const SizedBox(height: 12),
          _buildVolatilityCard(context, data),
          const SizedBox(height: 16),

          // Volume (if available)
          if (data.hasVolumeData) ...[
            _buildSectionTitle('Volume'),
            const SizedBox(height: 12),
            _buildVolumeCard(context, data),
            const SizedBox(height: 16),
          ],

          // Data quality
          _buildSectionTitle('Data Quality'),
          const SizedBox(height: 12),
          _buildQualityCard(context, data),
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

  Widget _buildOverviewCard(BuildContext context, MarketAnalysisData data) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              '${data.symbol} (${data.timeframe})',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.dateRange,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    'Current',
                    data.currentPrice.toStringAsFixed(4),
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    'Change',
                    '${data.totalChangePercent >= 0 ? '+' : ''}${data.totalChangePercent.toStringAsFixed(2)}%',
                    data.totalChangePercent >= 0
                        ? Icons.trending_up
                        : Icons.trending_down,
                    data.totalChangePercent >= 0 ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewStat(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceStats(BuildContext context, MarketAnalysisData data) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Highest', data.highestPrice.toStringAsFixed(4)),
            const Divider(),
            _buildStatRow('Lowest', data.lowestPrice.toStringAsFixed(4)),
            const Divider(),
            _buildStatRow('Average', data.averagePrice.toStringAsFixed(4)),
            const Divider(),
            _buildStatRow('Range', data.priceRange.toStringAsFixed(4)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendAnalysis(BuildContext context, MarketAnalysisData data) {
    final trendColor = data.trend == 'Uptrend'
        ? Colors.green
        : data.trend == 'Downtrend'
            ? Colors.red
            : Colors.grey;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: trendColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                data.trend == 'Uptrend'
                    ? Icons.trending_up
                    : data.trend == 'Downtrend'
                        ? Icons.trending_down
                        : Icons.remove,
                color: trendColor,
                size: 32,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    data.trend,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Strength: ${data.trendStrength}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolatilityCard(BuildContext context, MarketAnalysisData data) {
    final color = data.volatility == 'High'
        ? Colors.red
        : data.volatility == 'Medium'
            ? Colors.orange
            : Colors.green;

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('ATR', data.atr.toStringAsFixed(4)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Level',
                  style: TextStyle(fontSize: 14),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    data.volatility,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeCard(BuildContext context, MarketAnalysisData data) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildStatRow('Total Volume', data.totalVolume.toStringAsFixed(0)),
            const Divider(),
            _buildStatRow(
                'Average Volume', data.averageVolume.toStringAsFixed(0)),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityCard(BuildContext context, MarketAnalysisData data) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildQualityRow('Valid Data', data.isValid),
            const Divider(),
            _buildQualityRow('Complete (No Gaps)', !data.hasGaps),
            const Divider(),
            _buildStatRow('Candles', data.candlesCount.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
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

  Widget _buildQualityRow(String label, bool isGood) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Icon(
            isGood ? Icons.check_circle : Icons.warning,
            color: isGood ? Colors.green : Colors.orange,
            size: 20,
          ),
        ],
      ),
    );
  }

  @override
  MarketAnalysisViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      MarketAnalysisViewModel();
}
