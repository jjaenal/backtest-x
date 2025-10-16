import 'package:flutter/material.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'indicator_formatter.dart';
import 'strategy_builder_viewmodel.dart';
import 'strategy_builder_constants.dart';

class RiskManagementCard extends StatelessWidget {
  final StrategyBuilderViewModel viewModel;
  const RiskManagementCard({Key? key, required this.viewModel})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(StrategyBuilderConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.sbRiskManagementTitle,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: StrategyBuilderConstants.itemSpacing),

            // Risk Type
            DropdownButtonFormField<RiskType>(
              value: viewModel.riskType,
              decoration: InputDecoration(
                labelText: l10n.sbRiskTypeLabel,
                prefixIcon: const Icon(Icons.trending_up),
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: StrategyBuilderConstants.mediumSpacing,
                  horizontal: StrategyBuilderConstants.mediumSpacing,
                ),
              ),
              items: RiskType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(IndicatorFormatter.formatRiskType(type)),
                );
              }).toList(),
              onChanged: viewModel.setRiskType,
            ),

            const SizedBox(height: StrategyBuilderConstants.itemSpacing),

            // Risk Value
            TextField(
              controller: viewModel.riskValueController,
              decoration: InputDecoration(
                labelText: viewModel.riskType == RiskType.fixedLot
                    ? l10n.sbLotSizeLabel
                    : (viewModel.riskType == RiskType.atrBased
                        ? l10n.sbAtrMultipleLabel
                        : l10n.sbRiskPercentageLabel),
                hintText: viewModel.riskType == RiskType.fixedLot
                    ? '0.1'
                    : (viewModel.riskType == RiskType.atrBased ? '2.0' : '2.0'),
                prefixIcon: const Icon(Icons.percent),
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: StrategyBuilderConstants.mediumSpacing,
                  horizontal: StrategyBuilderConstants.mediumSpacing,
                ),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: StrategyBuilderConstants.itemSpacing),

            // Stop Loss & Take Profit
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: viewModel.stopLossController,
                    decoration: InputDecoration(
                      labelText: viewModel.riskType == RiskType.atrBased
                          ? 'ATR Multiple'
                          : 'Stop Loss (points)',
                      hintText: viewModel.riskType == RiskType.atrBased
                          ? '2.0'
                          : '100',
                      prefixIcon: const Icon(Icons.arrow_downward),
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: StrategyBuilderConstants.mediumSpacing,
                        horizontal: StrategyBuilderConstants.mediumSpacing,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: StrategyBuilderConstants.itemSpacing),
                Expanded(
                  child: TextField(
                    controller: viewModel.takeProfitController,
                    decoration: InputDecoration(
                      labelText: l10n.sbTakeProfitPoints,
                      hintText: '200',
                      prefixIcon: const Icon(Icons.arrow_upward),
                      isDense: false,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: StrategyBuilderConstants.mediumSpacing,
                        horizontal: StrategyBuilderConstants.mediumSpacing,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
