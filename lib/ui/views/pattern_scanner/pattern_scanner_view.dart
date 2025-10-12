import 'package:backtestx/models/candle.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/l10n/app_localizations.dart';

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
        title: Text(AppLocalizations.of(context)!.patternScannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => viewModel
                .showPatternsGuide(AppLocalizations.of(context)!
                    .psPatternsGuideTitle),
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
      color:
          Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.psSelectMarketData,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          if (model.marketDataList.isEmpty)
            Text(AppLocalizations.of(context)!.psNoMarketData)
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
              hint:
                  Text(AppLocalizations.of(context)!.psSelectMarketHint),
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

  Widget _buildFilters(BuildContext context, PatternScannerViewModel model) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.psFiltersHeader,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          Row(
            children: [
              FilterChip(
                label: Text(AppLocalizations.of(context)!.psFilterBullish),
                selected: model.showBullish,
                onSelected: (_) => model.toggleBullishFilter(),
                selectedColor: Colors.green.withValues(alpha: 0.3),
                checkmarkColor: Colors.green,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(AppLocalizations.of(context)!.psFilterBearish),
                selected: model.showBearish,
                onSelected: (_) => model.toggleBearishFilter(),
                selectedColor: Colors.red.withValues(alpha: 0.3),
                checkmarkColor: Colors.red,
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(AppLocalizations.of(context)!.psFilterIndecision),
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
          Icon(
            Icons.search,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.psEmptySelectMarket,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.psEmptySelectHint,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
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
          Icon(
            Icons.check_circle_outline,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            AppLocalizations.of(context)!.psNoPatternsFound,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.psTryAdjustFilters,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatternList(
    BuildContext context,
    PatternScannerViewModel model,
  ) {
    return RefreshIndicator(
      onRefresh: model.refresh,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: model.filteredPatterns.length,
        itemBuilder: (context, index) {
          final pattern = model.filteredPatterns[index];
          return _buildPatternCard(context, pattern);
        },
      ),
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
                        _localizedPatternName(context, pattern.pattern),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _localizedSignal(context, pattern.signal),
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
                    _localizedStrength(context, pattern.strength),
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
                      context,
                      AppLocalizations.of(context)!.psCandleTime,
                      DateFormat('MMM dd, HH:mm')
                          .format(pattern.candle.timestamp)),
                ),
                Expanded(
                  child: _buildCandleDetail(context,
                      AppLocalizations.of(context)!.psCandleOpen,
                      pattern.candle.open.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildCandleDetail(context,
                      AppLocalizations.of(context)!.psCandleClose,
                      pattern.candle.close.toStringAsFixed(4)),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              children: [
                Expanded(
                  child: _buildCandleDetail(
                      context,
                      AppLocalizations.of(context)!.psCandleHigh,
                      pattern.candle.high.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildCandleDetail(
                      context,
                      AppLocalizations.of(context)!.psCandleLow,
                      pattern.candle.low.toStringAsFixed(4)),
                ),
                Expanded(
                  child: _buildCandleDetail(
                      context,
                      AppLocalizations.of(context)!.psCandleBody,
                      '${pattern.candle.bodyPercentage.toStringAsFixed(1)}%'),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .surfaceVariant
                    .withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _localizedDescription(context, pattern.description),
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.8),
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

  Widget _buildCandleDetail(BuildContext context, String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
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

  String _localizedStrength(BuildContext context, PatternStrength s) {
    final loc = AppLocalizations.of(context)!;
    switch (s) {
      case PatternStrength.weak:
        return loc.psStrengthWeak;
      case PatternStrength.medium:
        return loc.psStrengthMedium;
      case PatternStrength.strong:
        return loc.psStrengthStrong;
    }
  }

  String _localizedSignal(BuildContext context, String signal) {
    final loc = AppLocalizations.of(context)!;
    if (signal.contains('Bullish')) return loc.psSignalBullish;
    if (signal.contains('Bearish')) return loc.psSignalBearish;
    return loc.psSignalIndecision;
  }

  String _localizedPatternName(BuildContext context, String name) {
    final loc = AppLocalizations.of(context)!;
    if (name == 'Spinning Top') return loc.psPatternSpinningTop;
    if (name == 'Strong Bullish Continuation')
      return loc.psPatternStrongBullishCont;
    if (name == 'Strong Bearish Continuation')
      return loc.psPatternStrongBearishCont;
    return name;
  }

  String _localizedDescription(BuildContext context, String desc) {
    final loc = AppLocalizations.of(context)!;
    if (desc ==
        'Little to no wicks. Strong momentum in one direction. Indicates continuation of current trend.') {
      return loc.psDescStrongCont;
    }
    if (desc ==
        'Small body with long wicks on both sides. Indicates uncertainty and potential reversal.') {
      return loc.psDescSpinningTop;
    }
    return desc;
  }

  @override
  PatternScannerViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      PatternScannerViewModel();
}
