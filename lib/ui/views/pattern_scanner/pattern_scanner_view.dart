import 'package:backtestx/models/candle.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';

import 'pattern_scanner_viewmodel.dart';

class PatternScannerView extends StackedView<PatternScannerViewModel> {
  const PatternScannerView({Key? key}) : super(key: key);

  @override
  void onViewModelReady(PatternScannerViewModel viewModel) =>
      viewModel.initialize();

  @override
  Widget builder(
    BuildContext context,
    PatternScannerViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pattern Scanner'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showPatternsGuide(context),
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Market data selector
                _buildMarketDataSelector(context, viewModel),

                // Filters
                if (viewModel.selectedMarketData != null)
                  _buildFilters(context, viewModel),

                // Pattern list
                Expanded(
                  child: viewModel.selectedMarketData == null
                      ? _buildEmptyState(context)
                      : viewModel.filteredPatterns.isEmpty
                          ? _buildNoPatterns(context)
                          : _buildPatternList(context, viewModel),
                ),
              ],
            ),
    );
  }

  Widget _buildMarketDataSelector(
    BuildContext context,
    PatternScannerViewModel model,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[100],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select Market Data',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (model.marketDataList.isEmpty)
            const Text('No market data available. Please upload data first.')
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
              hint: const Text('Select market data...'),
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

  Widget _buildFilters(BuildContext context, PatternScannerViewModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filters:',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              FilterChip(
                label: const Text('Bullish'),
                selected: model.showBullish,
                onSelected: (_) => model.toggleBullishFilter(),
                selectedColor: Colors.green.withValues(alpha: 0.3),
                checkmarkColor: Colors.green,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Bearish'),
                selected: model.showBearish,
                onSelected: (_) => model.toggleBearishFilter(),
                selectedColor: Colors.red.withValues(alpha: 0.3),
                checkmarkColor: Colors.red,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: const Text('Indecision'),
                selected: model.showIndecision,
                onSelected: (_) => model.toggleIndecisionFilter(),
                selectedColor: Colors.orange.withValues(alpha: 0.3),
                checkmarkColor: Colors.orange,
              ),
            ],
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
          Icon(Icons.search, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Select market data to scan',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose a market data from dropdown above',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildNoPatterns(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle_outline, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'No patterns found',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternList(
    BuildContext context,
    PatternScannerViewModel model,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: model.filteredPatterns.length,
      itemBuilder: (context, index) {
        final pattern = model.filteredPatterns[index];
        return _buildPatternCard(context, pattern);
      },
    );
  }

  Widget _buildPatternCard(BuildContext context, PatternMatch pattern) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: pattern.signalColor.withValues(alpha: 0.3)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: pattern.signalColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    pattern.signalIcon,
                    color: pattern.signalColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pattern.pattern,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        pattern.signal,
                        style: TextStyle(
                          fontSize: 14,
                          color: pattern.signalColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Strength indicator
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: pattern.strength.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    pattern.strength.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: pattern.strength.color,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),

            // Candle details
            Row(
              children: [
                Expanded(
                  child: _buildCandleDetail(
                      'Time',
                      DateFormat('MMM dd, HH:mm')
                          .format(pattern.candle.timestamp)),
                ),
                Expanded(
                  child: _buildCandleDetail(
                      'Open', pattern.candle.open.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildCandleDetail(
                      'Close', pattern.candle.close.toStringAsFixed(4)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildCandleDetail(
                      'High', pattern.candle.high.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildCandleDetail(
                      'Low', pattern.candle.low.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildCandleDetail('Body',
                      '${pattern.candle.bodyPercentage.toStringAsFixed(1)}%'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      pattern.description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.4,
                      ),
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

  Widget _buildCandleDetail(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  void _showPatternsGuide(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Candlestick Patterns Guide'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPatternGuideItem(
                'Hammer',
                'Bullish reversal pattern with long lower wick and small body at top. '
                    'Forms at bottom of downtrend.',
                Colors.green,
              ),
              const SizedBox(height: 12),
              _buildPatternGuideItem(
                'Shooting Star',
                'Bearish reversal pattern with long upper wick and small body at bottom. '
                    'Forms at top of uptrend.',
                Colors.red,
              ),
              const SizedBox(height: 12),
              _buildPatternGuideItem(
                'Doji',
                'Indecision pattern where open and close are nearly equal. '
                    'Indicates potential reversal or continuation.',
                Colors.orange,
              ),
              const SizedBox(height: 12),
              _buildPatternGuideItem(
                'Marubozu',
                'Strong momentum pattern with little to no wicks. '
                    'Indicates continuation of current trend.',
                Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildPatternGuideItem(
                'Spinning Top',
                'Indecision pattern with small body and long wicks. '
                    'Indicates uncertainty in market direction.',
                Colors.purple,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternGuideItem(String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  PatternScannerViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PatternScannerViewModel();
}
