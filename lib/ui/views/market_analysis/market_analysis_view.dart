import 'package:backtestx/models/candle.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/ui/widgets/common/candlestick_chart/candlestick_chart.dart';
import 'package:backtestx/ui/widgets/common/indicator_panel/indicator_panel.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.marketAnalysisTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: viewModel.refresh,
            tooltip: AppLocalizations.of(context)!.maRefreshTooltip,
          ),
          if (viewModel.selectedMarketData != null)
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () => viewModel.showIndicatorSettings(),
              tooltip: AppLocalizations.of(context)!.maChartSettingsTooltip,
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
      color:
          Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.maSelectMarketLabel,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          if (model.marketDataList.isEmpty)
            Text(AppLocalizations.of(context)!.maNoMarketData)
          else
            DropdownButtonFormField<MarketDataInfo>(
              value: (model.selectedMarketData != null &&
                      model.marketDataList
                          .toSet()
                          .contains(model.selectedMarketData))
                  ? model.selectedMarketData
                  : null,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              hint: Text(AppLocalizations.of(context)!.maSelectMarketHint),
              items: model.marketDataList
                  .toSet()
                  .map((data) {
                    return DropdownMenuItem<MarketDataInfo>(
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
          Icon(
            Icons.analytics_outlined,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.maEmptySelectMarket,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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

    return RefreshIndicator(
      onRefresh: model.refresh,
      child: SingleChildScrollView(
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
                    bollingerBands: model.bb,
                    showVolume: model.marketData!.hasVolumeData,
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
          _buildSectionTitle(AppLocalizations.of(context)!.maPriceStatistics),
          const SizedBox(height: 12),
          _buildPriceStats(context, data),
          const SizedBox(height: 16),

          // Trend analysis
          _buildSectionTitle(AppLocalizations.of(context)!.maTrendAnalysis),
          const SizedBox(height: 12),
          _buildTrendAnalysis(context, data),
          const SizedBox(height: 16),

          // Volatility
          _buildSectionTitle(AppLocalizations.of(context)!.maVolatility),
          const SizedBox(height: 12),
          _buildVolatilityCard(context, data),
          const SizedBox(height: 16),

          // Volume (if available)
          if (data.hasVolumeData) ...[
            _buildSectionTitle(AppLocalizations.of(context)!.maVolume),
            const SizedBox(height: 12),
            _buildVolumeCard(context, data),
            const SizedBox(height: 16),
          ],

          // Data quality
          _buildSectionTitle(AppLocalizations.of(context)!.maDataQuality),
          const SizedBox(height: 12),
          _buildQualityCard(context, data),
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
              style: TextStyle(
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildOverviewStat(
                    AppLocalizations.of(context)!.maOverviewCurrentLabel,
                    data.currentPrice.toStringAsFixed(4),
                    Icons.attach_money,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildOverviewStat(
                    AppLocalizations.of(context)!.maOverviewChangeLabel,
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
            _buildStatRow(AppLocalizations.of(context)!.maPriceHighest, data.highestPrice.toStringAsFixed(4)),
            const Divider(),
            _buildStatRow(AppLocalizations.of(context)!.maPriceLowest, data.lowestPrice.toStringAsFixed(4)),
            const Divider(),
            _buildStatRow(AppLocalizations.of(context)!.maPriceAverage, data.averagePrice.toStringAsFixed(4)),
            const Divider(),
            _buildStatRow(AppLocalizations.of(context)!.maPriceRange, data.priceRange.toStringAsFixed(4)),
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
                    _localizedTrend(context, data.trend),
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: trendColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${AppLocalizations.of(context)!.maTrendStrengthLabel}: ${_localizedTrendStrength(context, data.trendStrength)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.7),
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
            _buildStatRow(AppLocalizations.of(context)!.maVolatilityAtrLabel, data.atr.toStringAsFixed(4)),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppLocalizations.of(context)!.maVolatilityLevelLabel,
                  style: const TextStyle(fontSize: 14),
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
                    _localizedVolatility(context, data.volatility),
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
            _buildStatRow(AppLocalizations.of(context)!.maVolumeTotal, data.totalVolume.toStringAsFixed(0)),
            const Divider(),
            _buildStatRow(AppLocalizations.of(context)!.maVolumeAverage, data.averageVolume.toStringAsFixed(0)),
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
            _buildQualityRow(AppLocalizations.of(context)!.maQualityValidData, data.isValid),
            const Divider(),
            _buildQualityRow(AppLocalizations.of(context)!.maQualityCompleteNoGaps, !data.hasGaps),
            const Divider(),
            _buildStatRow(AppLocalizations.of(context)!.maQualityCandles, data.candlesCount.toString()),
          ],
        ),
      ),
    );
  }

  String _localizedTrend(BuildContext context, String trend) {
    final loc = AppLocalizations.of(context)!;
    if (trend == 'Uptrend') return loc.maTrendUptrend;
    if (trend == 'Downtrend') return loc.maTrendDowntrend;
    return loc.maTrendSideways;
  }

  String _localizedTrendStrength(BuildContext context, String s) {
    final loc = AppLocalizations.of(context)!;
    if (s == 'Strong') return loc.psStrengthStrong;
    if (s == 'Medium') return loc.psStrengthMedium;
    if (s == 'Weak') return loc.psStrengthWeak;
    return loc.maStrengthUnknown;
  }

  String _localizedVolatility(BuildContext context, String v) {
    final loc = AppLocalizations.of(context)!;
    if (v == 'High') return loc.maVolatilityHigh;
    if (v == 'Medium') return loc.maVolatilityMedium;
    if (v == 'Low') return loc.maVolatilityLow;
    return loc.maVolatilityUnknown;
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
