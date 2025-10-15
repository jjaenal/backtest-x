import 'package:flutter/material.dart';
import 'package:backtestx/models/candle.dart';
import 'package:intl/intl.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/ui/widgets/common/candlestick_chart/candlestick_chart.dart';
import 'package:backtestx/helpers/timeframe_helper.dart' as tf_helper;
import 'strategy_builder_viewmodel.dart';
import 'strategy_builder_constants.dart';

class QuickPreviewCard extends StatelessWidget {
  final StrategyBuilderViewModel viewModel;
  final VoidCallback? onPickTemplate;
  const QuickPreviewCard(
      {Key? key, required this.viewModel, this.onPickTemplate})
      : super(key: key);

  String _dateRangeLabel(MarketData md) {
    if (md.candles.isEmpty) return 'No data';
    final formatter = DateFormat('MMM dd, yyyy');
    return '${formatter.format(md.candles.first.timestamp)} - ${formatter.format(md.candles.last.timestamp)}';
  }

  double _totalPriceChangePercent(MarketData md) {
    if (md.candles.length < 2 || md.candles.first.close == 0) return 0;
    return ((md.candles.last.close - md.candles.first.close) /
            md.candles.first.close) *
        100;
  }

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
              l10n.sbQuickBacktestPreviewHeader,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: StrategyBuilderConstants.itemSpacing),
            Builder(builder: (context) {
              if (viewModel.availableData.isEmpty) {
                viewModel.loadAvailableData();
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Data selection dropdown
                  DropdownButtonFormField<String>(
                    value: viewModel.availableData
                            .any((d) => d.id == viewModel.selectedDataId)
                        ? viewModel.selectedDataId
                        : null,
                    decoration: InputDecoration(
                      labelText: l10n.sbSelectMarketData,
                      prefixIcon: const Icon(Icons.bar_chart),
                    ),
                    items: viewModel.availableData.map((data) {
                      return DropdownMenuItem(
                        value: data.id,
                        child: Text(
                            '${data.symbol} ${data.timeframe} (${data.candles.length} candles)'),
                      );
                    }).toList(),
                    onChanged: viewModel.setSelectedData,
                  ),
                  const SizedBox(height: StrategyBuilderConstants.itemSpacing),
                  // Test button
                  SizedBox(
                    width: double.infinity,
                    child: Tooltip(
                      message: (() {
                        if (viewModel.hasFatalErrors) {
                          final errs = viewModel.getAllFatalErrors();
                          final shown = errs.take(2).join('\n• ');
                          return 'Fix errors before testing:\n• $shown${errs.length > 2 ? '...' : ''}';
                        }
                        if (viewModel.isRunningPreview) {
                          return l10n.sbTestStrategyButtonIsRunningTooltip;
                        }
                        return l10n.sbTestStrategyButtonTooltip;
                      })(),
                      child: ElevatedButton.icon(
                        onPressed: (viewModel.isRunningPreview ||
                                viewModel.hasFatalErrors)
                            ? null
                            : viewModel.quickPreviewBacktest,
                        icon: viewModel.isRunningPreview
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.play_arrow),
                        label: Text(viewModel.isRunningPreview
                            ? 'Running...'
                            : (() {
                                final errs = viewModel.getAllFatalErrors();
                                if (errs.isNotEmpty) {
                                  return 'Fix ${errs.length} error';
                                }
                                return 'Test Strategy';
                              })()),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: StrategyBuilderConstants.mediumSpacing,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Lightweight data preview (recent candles)
                  Builder(builder: (context) {
                    if (viewModel.selectedDataId == null) {
                      return const SizedBox(height: 0);
                    }
                    final data = viewModel.availableData
                        .where((d) => d.id == viewModel.selectedDataId)
                        .toList();
                    if (data.isEmpty || data.first.candles.isEmpty) {
                      return Container(
                        margin: const EdgeInsets.only(
                            top: StrategyBuilderConstants.mediumSpacing),
                        padding: const EdgeInsets.all(
                            StrategyBuilderConstants.mediumSpacing),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.18),
                          borderRadius:
                              const BorderRadius.all(Radius.circular(12)),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Data selected not available for preview.',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      );
                    }
                    final md = data.first;
                    final baseMin =
                        tf_helper.parseTimeframeToMinutes(md.timeframe);
                    int recentCount;
                    if (baseMin <= 5) {
                      recentCount = StrategyBuilderConstants
                          .m5CandleCount; // ~30 hours of M5
                    } else if (baseMin <= 15) {
                      recentCount = StrategyBuilderConstants
                          .m15CandleCount; // ~2.5 days of M15
                    } else if (baseMin <= 60) {
                      recentCount = StrategyBuilderConstants
                          .h1CandleCount; // ~1 week of H1
                    } else {
                      recentCount = StrategyBuilderConstants
                          .defaultCandleCount; // reduce for higher TFs
                    }
                    final recent = md.getRecentCandles(recentCount);
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                            height: StrategyBuilderConstants.mediumSpacing),
                        Row(
                          children: [
                            Icon(
                              Icons.timeline,
                              size: 16,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                            ),
                            const SizedBox(
                                width: StrategyBuilderConstants.tinySpacing),
                            Text(
                              'Preview Price (${md.timeframe}) — ${_dateRangeLabel(md)}',
                              style: Theme.of(context).textTheme.labelMedium,
                            ),
                          ],
                        ),
                        const SizedBox(
                            height: StrategyBuilderConstants.smallSpacing),
                        SizedBox(
                          height: 200,
                          child: CandlestickChart(
                            candles: recent,
                            showVolume: false,
                            highQuality: baseMin > 60,
                            maxDrawCandles: 600,
                          ),
                        ),
                        const SizedBox(
                            height: StrategyBuilderConstants.smallSpacing),
                        Wrap(
                          spacing: StrategyBuilderConstants.mediumSpacing,
                          runSpacing: StrategyBuilderConstants.smallSpacing,
                          children: [
                            _buildStatChip(
                              context,
                              'Candles',
                              '${md.candles.length}',
                            ),
                            _buildStatChip(
                              context,
                              'Close (last)',
                              md.candles.isNotEmpty
                                  ? md.candles.last.close.toStringAsFixed(2)
                                  : '-',
                            ),
                            _buildStatChip(
                              context,
                              'Change %',
                              _totalPriceChangePercent(md).toStringAsFixed(2),
                            ),
                          ],
                        ),
                      ],
                    );
                  }),

                  // Preview results
                  if (viewModel.previewResult != null) ...[
                    const SizedBox(
                        height: StrategyBuilderConstants.itemSpacing),
                    const Divider(),
                    const SizedBox(
                        height: StrategyBuilderConstants.smallSpacing),
                    Text(
                      'Preview Results',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(
                        height: StrategyBuilderConstants.smallSpacing),
                    // Quick performance badges (Win Rate & Profit Factor)
                    Builder(builder: (context) {
                      final summary = viewModel.previewResult!.summary;
                      final winRate =
                          summary.winRate.isNaN ? 0 : summary.winRate;
                      final pf =
                          summary.profitFactor.isNaN ? 0 : summary.profitFactor;
                      final wrColor = winRate >= 50
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error;
                      final pfColor = pf >= 1.0
                          ? Theme.of(context).colorScheme.tertiary
                          : Theme.of(context).colorScheme.error;
                      return Wrap(
                        spacing: StrategyBuilderConstants.mediumSpacing,
                        runSpacing: StrategyBuilderConstants.smallSpacing,
                        children: [
                          _buildStatChip(
                            context,
                            'Win Rate',
                            '${winRate.toStringAsFixed(1)}%',
                            color: wrColor,
                            icon: Icons.percent,
                          ),
                          _buildStatChip(
                            context,
                            'Profit Factor',
                            pf.toStringAsFixed(2),
                            color: pfColor,
                            icon: Icons.trending_up,
                          ),
                        ],
                      );
                    }),
                    const SizedBox(height: 8),
                    // Actions: open full results & reset preview
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: viewModel.viewFullResults,
                          icon: const Icon(Icons.open_in_new),
                          label: Text(l10n.sbViewFullResults),
                        ),
                        const SizedBox(
                            width: StrategyBuilderConstants.mediumSpacing),
                        TextButton.icon(
                          onPressed: viewModel.resetPreview,
                          icon: const Icon(Icons.refresh),
                          label: Text(l10n.sbResetPreview),
                        ),
                      ],
                    ),
                    const SizedBox(
                        height: StrategyBuilderConstants.smallSpacing),

                    // Base TF vs Rule TF badges
                    Builder(builder: (context) {
                      final baseData = viewModel.availableData
                          .where((d) => d.id == viewModel.selectedDataId)
                          .toList();
                      final String? baseTf =
                          baseData.isNotEmpty ? baseData.first.timeframe : null;

                      final entryRuleTfs = viewModel.entryRules
                          .asMap()
                          .entries
                          .where((e) => e.value.timeframe != null)
                          .map((e) => (
                                tf: e.value.timeframe!,
                                warn: viewModel
                                    .getRuleWarningsFor(e.key, true)
                                    .any((w) => w
                                        .contains('Timeframe rule is smaller')),
                              ))
                          .toList();
                      final exitRuleTfs = viewModel.exitRules
                          .asMap()
                          .entries
                          .where((e) => e.value.timeframe != null)
                          .map((e) => (
                                tf: e.value.timeframe!,
                                warn: viewModel
                                    .getRuleWarningsFor(e.key, false)
                                    .any((w) => w
                                        .contains('Timeframe rule is smaller')),
                              ))
                          .toList();

                      final chips = <Widget>[];
                      if (baseTf != null) {
                        chips
                            .add(_buildTfChip(context, 'Base: $baseTf', false));
                      }
                      for (final r in entryRuleTfs) {
                        chips.add(
                            _buildTfChip(context, 'Entry TF: ${r.tf}', r.warn));
                      }
                      for (final r in exitRuleTfs) {
                        chips.add(
                            _buildTfChip(context, 'Exit TF: ${r.tf}', r.warn));
                      }

                      if (chips.isEmpty) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: chips,
                        ),
                      );
                    }),

                    // Per‑timeframe counts (entry vs exit rules per TF)
                    Builder(builder: (context) {
                      String resolveBaseTf() {
                        final baseData = viewModel.availableData
                            .where((d) => d.id == viewModel.selectedDataId)
                            .toList();
                        return baseData.isNotEmpty
                            ? baseData.first.timeframe
                            : '';
                      }

                      String resolveRuleTf(String? tfRaw, String baseTf) {
                        return (tfRaw == null || tfRaw.isEmpty)
                            ? baseTf
                            : tfRaw;
                      }

                      final baseTf = resolveBaseTf();
                      final entryTfCounts = <String, int>{};
                      final exitTfCounts = <String, int>{};

                      for (final r in viewModel.entryRules) {
                        final tf = resolveRuleTf(r.timeframe, baseTf);
                        if (tf.isNotEmpty) {
                          entryTfCounts[tf] = (entryTfCounts[tf] ?? 0) + 1;
                        }
                      }
                      for (final r in viewModel.exitRules) {
                        final tf = resolveRuleTf(r.timeframe, baseTf);
                        if (tf.isNotEmpty) {
                          exitTfCounts[tf] = (exitTfCounts[tf] ?? 0) + 1;
                        }
                      }

                      if (entryTfCounts.isEmpty && exitTfCounts.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      Chip tfChip(String tf, int count) {
                        bool warn = false;
                        if (baseTf.isNotEmpty) {
                          final baseMin =
                              tf_helper.parseTimeframeToMinutes(baseTf);
                          final tfMin = tf_helper.parseTimeframeToMinutes(tf);
                          warn = tfMin < baseMin;
                        }
                        final bg = warn
                            ? Theme.of(context).colorScheme.errorContainer
                            : Theme.of(context).colorScheme.secondaryContainer;
                        final fg = warn
                            ? Theme.of(context).colorScheme.onErrorContainer
                            : Theme.of(context)
                                .colorScheme
                                .onSecondaryContainer;
                        return Chip(
                          backgroundColor: bg,
                          label: Text(
                            '$tf • $count rule${count > 1 ? 's' : ''}',
                            style: TextStyle(color: fg),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            'Per‑Timeframe Rule Counts',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          if (entryTfCounts.isNotEmpty) ...[
                            Text('Entry Rules',
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: entryTfCounts.entries
                                  .map((e) => tfChip(e.key, e.value))
                                  .toList(),
                            ),
                          ],
                          if (exitTfCounts.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text('Exit Rules',
                                style: Theme.of(context).textTheme.bodySmall),
                            const SizedBox(height: 4),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: exitTfCounts.entries
                                  .map((e) => tfChip(e.key, e.value))
                                  .toList(),
                            ),
                          ],
                        ],
                      );
                    }),

                    // Summary stats
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatCard(
                          context,
                          'Win Rate',
                          '${viewModel.previewResult!.summary.winRate.toStringAsFixed(1)}%',
                          viewModel.previewResult!.summary.winRate >= 50
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        _buildStatCard(
                          context,
                          'PnL',
                          '\$${viewModel.previewResult!.summary.totalPnl.toStringAsFixed(2)}',
                          viewModel.previewResult!.summary.totalPnl >= 0
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        _buildStatCard(
                          context,
                          'Max DD',
                          '${viewModel.previewResult!.summary.maxDrawdownPercentage.toStringAsFixed(2)}%',
                          viewModel.previewResult!.summary
                                      .maxDrawdownPercentage <=
                                  20
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                        _buildStatCard(
                          context,
                          'Trades',
                          '${viewModel.previewResult!.summary.totalTrades}',
                          Theme.of(context).colorScheme.secondary,
                        ),
                        _buildStatCard(
                          context,
                          'PF',
                          viewModel.previewResult!.summary.profitFactor
                              .toStringAsFixed(2),
                          viewModel.previewResult!.summary.profitFactor > 1
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                      ],
                    ),

                    // Per‑TF signals & performance (from preview)
                    Builder(builder: (context) {
                      final stats = viewModel.previewTfStats;
                      if (stats.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      Widget statChip(String tf, Map<String, num> s) {
                        final bg = Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest;
                        final fg =
                            Theme.of(context).colorScheme.onSurfaceVariant;
                        final winRate = (s['winRate'] ?? 0).toDouble();
                        final pf = (s['profitFactor'] ?? 0).toDouble();
                        final ex = (s['expectancy'] ?? 0).toDouble();
                        return Card(
                          color: bg,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: StrategyBuilderConstants.smallSpacing,
                                horizontal:
                                    StrategyBuilderConstants.mediumSpacing),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tf,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: fg,
                                          fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(height: 4),
                                Wrap(
                                  spacing:
                                      StrategyBuilderConstants.smallSpacing,
                                  runSpacing:
                                      StrategyBuilderConstants.tinySpacing,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text('Signals: ${s['signals'] ?? 0}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(
                                        width: StrategyBuilderConstants
                                            .mediumSpacing),
                                    Text('Trades: ${s['trades'] ?? 0}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(
                                        width: StrategyBuilderConstants
                                            .mediumSpacing),
                                    Text('Wins: ${s['wins'] ?? 0}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall),
                                    const SizedBox(
                                        width: StrategyBuilderConstants
                                            .mediumSpacing),
                                    Text(
                                      'WinRate: ${winRate.toStringAsFixed(1)}%',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: winRate >= 50
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                          ),
                                    ),
                                    const SizedBox(
                                        width: StrategyBuilderConstants
                                            .mediumSpacing),
                                    Text(
                                      'PF: ${pf.isFinite ? pf.toStringAsFixed(2) : '—'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: pf > 1
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                          ),
                                    ),
                                    const SizedBox(
                                        width: StrategyBuilderConstants
                                            .mediumSpacing),
                                    Text(
                                      'Expectancy: ${ex.isFinite ? ex.toStringAsFixed(2) : '—'}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .copyWith(
                                            color: ex > 0
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                          ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                              height: StrategyBuilderConstants.mediumSpacing),
                          Text(
                            'Per‑Timeframe Signals & Performance',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: StrategyBuilderConstants.smallSpacing,
                            runSpacing: StrategyBuilderConstants.smallSpacing,
                            children: stats.entries
                                .map((e) => statChip(e.key, e.value))
                                .toList(),
                          ),
                        ],
                      );
                    }),

                    const SizedBox(
                        height: StrategyBuilderConstants.itemSpacing),

                    // Save as Template (exports/copies JSON)
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: viewModel.exportStrategyJson,
                        icon: const Icon(Icons.save_alt),
                        label: const Text('Simplify as Template'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: StrategyBuilderConstants.mediumSpacing,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: StrategyBuilderConstants.smallSpacing),

                    // Open Template Picker
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: onPickTemplate,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(l10n.sbPickTemplateTooltip),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: StrategyBuilderConstants.mediumSpacing,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(
                        height: StrategyBuilderConstants.smallSpacing),

                    // View full results button
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: viewModel.viewFullResults,
                        icon: const Icon(Icons.analytics),
                        label: const Text('View Full Results'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: StrategyBuilderConstants.mediumSpacing,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(
            horizontal: StrategyBuilderConstants.microSpacing),
        padding: const EdgeInsets.all(StrategyBuilderConstants.mediumSpacing),
        decoration: BoxDecoration(
          color: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.14),
          borderRadius:
              BorderRadius.circular(StrategyBuilderConstants.cornerRadiusSmall),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: StrategyBuilderConstants.tinySpacing),
            Text(
              value,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium!
                  .copyWith(color: valueColor, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    String label,
    String value, {
    Color? color,
    IconData? icon,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final bgColor = (color ?? scheme.secondary).withValues(alpha: 0.12);
    final fgColor = (color ?? scheme.onSecondaryContainer);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius:
            BorderRadius.circular(StrategyBuilderConstants.cornerRadiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: fgColor),
            const SizedBox(width: 6),
          ],
          Text(
            '$label: ',
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(color: fgColor),
          ),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: fgColor, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildTfChip(BuildContext context, String label, bool warn) {
    final bg = warn
        ? Theme.of(context).colorScheme.errorContainer
        : Theme.of(context).colorScheme.secondaryContainer;
    final fg = warn
        ? Theme.of(context).colorScheme.onErrorContainer
        : Theme.of(context).colorScheme.onSecondaryContainer;
    return Chip(
      backgroundColor: bg,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (warn) ...[
            Icon(Icons.warning, size: 16, color: fg),
            const SizedBox(width: 6),
          ],
          Text(label, style: TextStyle(color: fg)),
        ],
      ),
    );
  }
}
