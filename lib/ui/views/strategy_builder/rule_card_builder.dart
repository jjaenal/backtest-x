import 'package:flutter/material.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'strategy_builder_viewmodel.dart';
import 'indicator_formatter.dart';
import 'strategy_builder_constants.dart';

class RuleCardBuilder {
  static Widget build(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    int index,
    RuleBuilder rule,
    bool isEntry,
  ) {
    final l10n = AppLocalizations.of(context)!;
    final hasRuleErrors = viewModel.getRuleErrorsFor(index, isEntry).isNotEmpty;
    return Card(
      margin:
          const EdgeInsets.only(bottom: StrategyBuilderConstants.itemSpacing),
      color: Theme.of(context).colorScheme.surface,
      shape: hasRuleErrors
          ? RoundedRectangleBorder(
              side: BorderSide(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(
                  StrategyBuilderConstants.cornerRadiusSmall),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(StrategyBuilderConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.sbRuleTitle(index + 1),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.delete, size: 20),
                  onPressed: () {
                    if (isEntry) {
                      viewModel.removeEntryRule(index);
                    } else {
                      viewModel.removeExitRule(index);
                    }
                  },
                  color: Theme.of(context).colorScheme.error,
                ),
              ],
            ),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            DropdownButtonFormField<IndicatorType>(
              value: rule.indicator,
              decoration: InputDecoration(
                labelText: l10n.sbIndicatorLabel,
                isDense: false,
                contentPadding: const EdgeInsets.symmetric(
                    vertical: StrategyBuilderConstants.mediumSpacing,
                    horizontal: StrategyBuilderConstants.mediumSpacing),
              ),
              items: IndicatorType.values.map((indicator) {
                return DropdownMenuItem(
                  value: indicator,
                  child: Text(IndicatorFormatter.format(indicator)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateRuleIndicator(index, value, isEntry);
                }
              },
            ),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            Builder(builder: (context) {
              final needsMainPeriod = {
                IndicatorType.rsi,
                IndicatorType.sma,
                IndicatorType.ema,
                IndicatorType.atr,
                IndicatorType.atrPct,
                IndicatorType.adx,
                IndicatorType.bollingerBands,
                IndicatorType.bollingerWidth,
                IndicatorType.vwap,
                IndicatorType.stochasticK,
                IndicatorType.stochasticD,
              }.contains(rule.indicator);
              if (!needsMainPeriod) return const SizedBox.shrink();
              return TextField(
                controller: rule.mainPeriodController,
                decoration: InputDecoration(
                  labelText: l10n.sbMainPeriodLabel,
                  hintText: l10n.sbMainPeriodHint,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: StrategyBuilderConstants.mediumSpacing,
                      horizontal: StrategyBuilderConstants.mediumSpacing),
                  errorText:
                      (rule.mainPeriod != null && (rule.mainPeriod ?? 0) <= 0)
                          ? l10n.sbErrorMustBeGreaterThanZero
                          : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    viewModel.updateRuleMainPeriod(index, value, isEntry),
              );
            }),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            Builder(builder: (context) {
              final warnings = viewModel.getRuleWarningsFor(index, isEntry);
              final tfWarning = warnings.isNotEmpty ? warnings.first : '';
              return Tooltip(
                message: tfWarning.isNotEmpty
                    ? tfWarning
                    : l10n.sbOptionalTimeframeTooltip,
                child: DropdownButtonFormField<String?>(
                  value: rule.timeframe,
                  decoration: InputDecoration(
                    labelText: l10n.sbTimeframeOptionalLabel,
                    isDense: false,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: StrategyBuilderConstants.mediumSpacing,
                        horizontal: StrategyBuilderConstants.mediumSpacing),
                  ),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.sbUseBaseTimeframe),
                    ),
                    ...['M1', 'M5', 'M15', 'M30', 'H1', 'H4', 'D1']
                        .map((tf) => DropdownMenuItem<String?>(
                              value: tf,
                              child: Text(tf),
                            ))
                        .toList(),
                  ],
                  onChanged: (value) {
                    viewModel.updateRuleTimeframe(index, value, isEntry);
                  },
                ),
              );
            }),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            Tooltip(
              message:
                  IndicatorFormatter.operatorTooltip(context, rule.operator),
              child: DropdownButtonFormField<ComparisonOperator>(
                value: rule.operator,
                decoration: InputDecoration(
                  labelText: l10n.sbOperatorLabel,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: StrategyBuilderConstants.mediumSpacing,
                      horizontal: StrategyBuilderConstants.mediumSpacing),
                ),
                items: ComparisonOperator.values.map((op) {
                  return DropdownMenuItem(
                    value: op,
                    child: Text(IndicatorFormatter.formatOperator(context, op)),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    viewModel.updateRuleOperator(index, value, isEntry);
                  }
                },
              ),
            ),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            Builder(builder: (context) {
              if (rule.operator == ComparisonOperator.rising ||
                  rule.operator == ComparisonOperator.falling) {
                return const SizedBox.shrink();
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: SwitchListTile(
                          title: Text(l10n.sbNumberLabel),
                          contentPadding: EdgeInsets.zero,
                          value: rule.isNumberValue,
                          onChanged: (val) {
                            viewModel.updateRuleValueType(index, val, isEntry);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: StrategyBuilderConstants.smallSpacing),
                  if (rule.isNumberValue) ...[
                    TextField(
                      controller: rule.numberController,
                      decoration: InputDecoration(
                        labelText: l10n.sbValueLabel,
                        hintText: '1.0',
                        isDense: false,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: StrategyBuilderConstants.mediumSpacing,
                            horizontal: StrategyBuilderConstants.mediumSpacing),
                        errorText: rule.numberValue == null
                            ? l10n.sbErrorValueMustBeSet
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) => viewModel.updateRuleNumberValue(
                          index, value, isEntry),
                    ),
                    const SizedBox(
                        height: StrategyBuilderConstants.smallSpacing),
                    Wrap(
                      spacing: StrategyBuilderConstants.smallSpacing,
                      runSpacing: StrategyBuilderConstants.smallSpacing,
                      children: [
                        _presetChip(context, '0.5%', () {
                          rule.numberController.text = '0.5';
                          viewModel.updateRuleNumberValue(
                              index, '0.5', isEntry);
                        }),
                        _presetChip(context, '1.0%', () {
                          rule.numberController.text = '1.0';
                          viewModel.updateRuleNumberValue(
                              index, '1.0', isEntry);
                        }),
                        _presetChip(context, '1.5%', () {
                          rule.numberController.text = '1.5';
                          viewModel.updateRuleNumberValue(
                              index, '1.5', isEntry);
                        }),
                        _presetChip(context, '2.0%', () {
                          rule.numberController.text = '2.0';
                          viewModel.updateRuleNumberValue(
                              index, '2.0', isEntry);
                        }),
                        _presetChip(context, '3.0%', () {
                          rule.numberController.text = '3.0';
                          viewModel.updateRuleNumberValue(
                              index, '3.0', isEntry);
                        }),
                      ],
                    ),
                  ] else ...[
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<IndicatorType>(
                            value: rule.compareIndicator,
                            decoration: InputDecoration(
                              labelText: l10n.sbCompareWithLabel,
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical:
                                      StrategyBuilderConstants.mediumSpacing,
                                  horizontal:
                                      StrategyBuilderConstants.mediumSpacing),
                              errorText: rule.compareIndicator == null
                                  ? l10n.sbRequiredSelection
                                  : null,
                            ),
                            items: IndicatorType.values.map((indicator) {
                              return DropdownMenuItem(
                                value: indicator,
                                child:
                                    Text(IndicatorFormatter.format(indicator)),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                viewModel.updateRuleCompareIndicator(
                                    index, value, isEntry);
                              }
                            },
                          ),
                        ),
                        const SizedBox(
                            width: StrategyBuilderConstants.itemSpacing),
                        Expanded(
                          child: TextField(
                            controller: rule.periodController,
                            decoration: InputDecoration(
                              labelText: l10n.sbPeriodLabel,
                              hintText: '14',
                              isDense: false,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical:
                                      StrategyBuilderConstants.mediumSpacing,
                                  horizontal:
                                      StrategyBuilderConstants.mediumSpacing),
                              errorText: (rule.compareIndicator != null &&
                                      (rule.period == null ||
                                          (rule.period ?? 0) <= 0))
                                  ? l10n.sbErrorMustBeGreaterThanZero
                                  : null,
                            ),
                            keyboardType: TextInputType.number,
                            onChanged: (value) => viewModel.updateRulePeriod(
                                index, value, isEntry),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              );
            }),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            Builder(builder: (context) {
              final showThenLogic = viewModel.entryRules.length > 1 ||
                  viewModel.exitRules.length > 1;
              final showAnchorMode = !rule.isNumberValue &&
                  rule.compareIndicator == IndicatorType.anchoredVwap;
              if (!showThenLogic && !showAnchorMode) {
                return const SizedBox.shrink();
              }
              return Row(
                children: [
                  if (showThenLogic)
                    Expanded(
                      child: DropdownButtonFormField<LogicalOperator?>(
                        value: rule.logicalOperator,
                        decoration: InputDecoration(
                          labelText: l10n.sbThenLogicLabel,
                          isDense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: StrategyBuilderConstants.mediumSpacing,
                              horizontal:
                                  StrategyBuilderConstants.mediumSpacing),
                        ),
                        items: [
                          DropdownMenuItem<LogicalOperator?>(
                            value: null,
                            child: Text(l10n.commonNone),
                          ),
                          ...LogicalOperator.values
                              .map((lo) => DropdownMenuItem(
                                    value: lo,
                                    child: Text(lo.name.toUpperCase()),
                                  )),
                        ],
                        onChanged: (value) {
                          viewModel.updateRuleLogicalOperator(
                              index, value, isEntry);
                        },
                      ),
                    ),
                  if (showThenLogic && showAnchorMode)
                    const SizedBox(width: StrategyBuilderConstants.itemSpacing),
                  if (showAnchorMode)
                    Expanded(
                      child: DropdownButtonFormField<AnchorMode?>(
                        value: rule.anchorMode,
                        decoration: InputDecoration(
                          labelText: l10n.sbAnchorModeLabel,
                          isDense: false,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: StrategyBuilderConstants.mediumSpacing,
                              horizontal:
                                  StrategyBuilderConstants.mediumSpacing),
                        ),
                        items: [
                          DropdownMenuItem<AnchorMode?>(
                            value: null,
                            child: Text(l10n.commonNone),
                          ),
                          ...AnchorMode.values.map((am) => DropdownMenuItem(
                                value: am,
                                child:
                                    Text(_translateAnchorMode(am.name, l10n)),
                              )),
                        ],
                        onChanged: (value) {
                          viewModel.updateRuleAnchorMode(index, value, isEntry);
                        },
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: StrategyBuilderConstants.mediumSpacing),
            Builder(builder: (context) {
              final usesAnchoring = rule.anchorMode != null &&
                  !rule.isNumberValue &&
                  rule.compareIndicator == IndicatorType.anchoredVwap;
              if (!usesAnchoring) return const SizedBox.shrink();
              return TextField(
                controller: rule.anchorDateController,
                decoration: InputDecoration(
                  labelText: l10n.sbAnchorDateLabel,
                  hintText: l10n.sbAnchorDateHint,
                  isDense: false,
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: StrategyBuilderConstants.mediumSpacing,
                      horizontal: StrategyBuilderConstants.mediumSpacing),
                  errorText: (rule.anchorDateController.text.isNotEmpty &&
                          rule.anchorDate == null)
                      ? l10n.sbInvalidDateFormat
                      : null,
                ),
                keyboardType: TextInputType.datetime,
                onChanged: (value) =>
                    viewModel.updateRuleAnchorDate(index, value, isEntry),
              );
            }),
          ],
        ),
      ),
    );
  }

  static Widget _presetChip(
      BuildContext context, String label, VoidCallback onTap) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      avatar: Icon(Icons.flash_on,
          size: 16, color: Theme.of(context).colorScheme.secondary),
    );
  }

  static String _translateAnchorMode(String name, AppLocalizations l10n) {
    switch (name) {
      case 'startOfBacktest':
        return l10n.sbStartOfBacktest;
      case 'byDate':
        return l10n.sbAnchorByDate;
      default:
        return name;
    }
  }
}
