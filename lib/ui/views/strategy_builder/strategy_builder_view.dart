import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'strategy_builder_viewmodel.dart';
import 'package:backtestx/helpers/timeframe_helper.dart' as tfHelper;
import 'package:backtestx/models/strategy.dart';

class StrategyBuilderView extends StackedView<StrategyBuilderViewModel> {
  final String? strategyId;

  const StrategyBuilderView({Key? key, this.strategyId}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    Widget? child,
  ) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title:
              Text(viewModel.isEditing ? 'Edit Strategy' : 'Create Strategy'),
          actions: [
            Row(spacing: 4, children: [
              Text(
                'Autosave',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              Switch(
                value: viewModel.autosaveEnabled,
                onChanged: viewModel.toggleAutosave,
              ),
            ]),
            if (viewModel.isEditing)
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => viewModel.deleteStrategy(context),
              ),
          ],
        ),
        body: viewModel.isBusy
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Strategy Name
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Strategy Details',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: viewModel.nameController,
                                decoration: const InputDecoration(
                                  labelText: 'Strategy Name',
                                  hintText: 'e.g. RSI Mean Reversion',
                                  prefixIcon: Icon(Icons.label),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: viewModel.initialCapitalController,
                                decoration: const InputDecoration(
                                  labelText: 'Initial Capital',
                                  hintText: '10000',
                                  prefixIcon: Icon(Icons.attach_money),
                                ),
                                keyboardType: TextInputType.number,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Risk Management
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Risk Management',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),

                              // Risk Type
                              DropdownButtonFormField<RiskType>(
                                value: viewModel.riskType,
                                decoration: const InputDecoration(
                                  labelText: 'Risk Type',
                                  prefixIcon: Icon(Icons.trending_up),
                                ),
                                items: RiskType.values.map((type) {
                                  return DropdownMenuItem(
                                    value: type,
                                    child: Text(_formatRiskType(type)),
                                  );
                                }).toList(),
                                onChanged: viewModel.setRiskType,
                              ),

                              const SizedBox(height: 16),

                              TextField(
                                controller: viewModel.riskValueController,
                                decoration: InputDecoration(
                                  labelText:
                                      viewModel.riskType == RiskType.fixedLot
                                          ? 'Lot Size'
                                          : 'Risk Percentage',
                                  hintText:
                                      viewModel.riskType == RiskType.fixedLot
                                          ? '0.1'
                                          : '2.0',
                                  prefixIcon: const Icon(Icons.percent),
                                ),
                                keyboardType: TextInputType.number,
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: viewModel.stopLossController,
                                      decoration: const InputDecoration(
                                        labelText: 'Stop Loss (points)',
                                        hintText: '100',
                                        prefixIcon: Icon(Icons.arrow_downward),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: TextField(
                                      controller:
                                          viewModel.takeProfitController,
                                      decoration: const InputDecoration(
                                        labelText: 'Take Profit (points)',
                                        hintText: '200',
                                        prefixIcon: Icon(Icons.arrow_upward),
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Entry Rules
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Entry Rules',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: viewModel.addEntryRule,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (viewModel.entryRules.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.add_box,
                                            size: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.4)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No entry rules yet',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap + to add a rule',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.5),
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...viewModel.entryRules
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return _buildRuleCard(
                                    context,
                                    viewModel,
                                    entry.key,
                                    entry.value,
                                    true,
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Exit Rules
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Exit Rules',
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add_circle),
                                    onPressed: viewModel.addExitRule,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              if (viewModel.exitRules.isEmpty)
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.all(32.0),
                                    child: Column(
                                      children: [
                                        Icon(Icons.add_box,
                                            size: 48,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.4)),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No exit rules yet',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.6)),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Tap + to add a rule',
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.5),
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              else
                                ...viewModel.exitRules
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return _buildRuleCard(
                                    context,
                                    viewModel,
                                    entry.key,
                                    entry.value,
                                    false,
                                  );
                                }).toList(),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Quick Backtest Preview Card
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Quick Backtest Preview',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 16),

                              // Load available data on first build
                              Builder(builder: (context) {
                                if (viewModel.availableData.isEmpty) {
                                  viewModel.loadAvailableData();
                                }

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Data selection dropdown
                                    DropdownButtonFormField<String>(
                                      value: viewModel.selectedDataId,
                                      decoration: const InputDecoration(
                                        labelText: 'Select Market Data',
                                        prefixIcon: Icon(Icons.bar_chart),
                                      ),
                                      items:
                                          viewModel.availableData.map((data) {
                                        return DropdownMenuItem(
                                          value: data.id,
                                          child: Text(
                                              '${data.symbol} ${data.timeframe} (${data.candles.length} candles)'),
                                        );
                                      }).toList(),
                                      onChanged: viewModel.setSelectedData,
                                    ),

                                    const SizedBox(height: 16),

                                    // Test button
                                    SizedBox(
                                      width: double.infinity,
                                      child: Tooltip(
                                        message: (() {
                                          if (viewModel.hasFatalErrors) {
                                            final errs =
                                                viewModel.getAllFatalErrors();
                                            final shown =
                                                errs.take(2).join('\n• ');
                                            return 'Perbaiki error sebelum testing:\n• ' +
                                                shown +
                                                (errs.length > 2 ? '...' : '');
                                          }
                                          if (viewModel.isRunningPreview) {
                                            return 'Preview sedang berjalan';
                                          }
                                          return 'Jalankan quick test';
                                        })(),
                                        child: ElevatedButton.icon(
                                          onPressed: (viewModel
                                                      .isRunningPreview ||
                                                  viewModel.hasFatalErrors)
                                              ? null
                                              : viewModel.quickPreviewBacktest,
                                          icon: viewModel.isRunningPreview
                                              ? const SizedBox(
                                                  width: 20,
                                                  height: 20,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                  ),
                                                )
                                              : const Icon(Icons.play_arrow),
                                          label: Text(viewModel.isRunningPreview
                                              ? 'Running...'
                                              : 'Test Strategy'),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ),

                                    // Preview results
                                    if (viewModel.previewResult != null) ...[
                                      const SizedBox(height: 16),
                                      const Divider(),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Preview Results',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 8),

                                      // Base TF vs Rule TF badges
                                      Builder(builder: (context) {
                                        final baseData = viewModel.availableData
                                            .where((d) =>
                                                d.id ==
                                                viewModel.selectedDataId)
                                            .toList();
                                        final String? baseTf =
                                            baseData.isNotEmpty
                                                ? baseData.first.timeframe
                                                : null;

                                        final entryRuleTfs = viewModel
                                            .entryRules
                                            .asMap()
                                            .entries
                                            .where((e) =>
                                                e.value.timeframe != null)
                                            .map((e) => (
                                                  tf: e.value.timeframe!,
                                                  warn: viewModel
                                                      .getRuleWarningsFor(
                                                          e.key, true)
                                                      .any((w) => w.contains(
                                                          'Timeframe rule lebih kecil')),
                                                ))
                                            .toList();
                                        final exitRuleTfs = viewModel.exitRules
                                            .asMap()
                                            .entries
                                            .where((e) =>
                                                e.value.timeframe != null)
                                            .map((e) => (
                                                  tf: e.value.timeframe!,
                                                  warn: viewModel
                                                      .getRuleWarningsFor(
                                                          e.key, false)
                                                      .any((w) => w.contains(
                                                          'Timeframe rule lebih kecil')),
                                                ))
                                            .toList();

                                        final chips = <Widget>[];
                                        if (baseTf != null) {
                                          chips.add(_buildTfChip(
                                              context, 'Base: $baseTf', false));
                                        }
                                        for (final r in entryRuleTfs) {
                                          chips.add(_buildTfChip(context,
                                              'Entry TF: ${r.tf}', r.warn));
                                        }
                                        for (final r in exitRuleTfs) {
                                          chips.add(_buildTfChip(context,
                                              'Exit TF: ${r.tf}', r.warn));
                                        }

                                        if (chips.isEmpty)
                                          return const SizedBox();
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0),
                                          child: Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: chips,
                                          ),
                                        );
                                      }),

                                      // Per‑timeframe counts (entry vs exit rules per TF)
                                      Builder(builder: (context) {
                                        String _resolveBaseTf() {
                                          final baseData = viewModel
                                              .availableData
                                              .where((d) =>
                                                  d.id ==
                                                  viewModel.selectedDataId)
                                              .toList();
                                          return baseData.isNotEmpty
                                              ? baseData.first.timeframe
                                              : '';
                                        }

                                        String _resolveRuleTf(
                                            String? tfRaw, String baseTf) {
                                          return (tfRaw == null ||
                                                  tfRaw.isEmpty)
                                              ? baseTf
                                              : tfRaw;
                                        }

                                        final baseTf = _resolveBaseTf();
                                        final entryTfCounts = <String, int>{};
                                        final exitTfCounts = <String, int>{};

                                        for (final r in viewModel.entryRules) {
                                          final tf = _resolveRuleTf(
                                              r.timeframe, baseTf);
                                          if (tf.isNotEmpty) {
                                            entryTfCounts[tf] =
                                                (entryTfCounts[tf] ?? 0) + 1;
                                          }
                                        }
                                        for (final r in viewModel.exitRules) {
                                          final tf = _resolveRuleTf(
                                              r.timeframe, baseTf);
                                          if (tf.isNotEmpty) {
                                            exitTfCounts[tf] =
                                                (exitTfCounts[tf] ?? 0) + 1;
                                          }
                                        }

                                        if (entryTfCounts.isEmpty &&
                                            exitTfCounts.isEmpty) {
                                          return const SizedBox.shrink();
                                        }

                                        Chip _tfChip(String tf, int count) {
                                          bool warn = false;
                                          if (baseTf.isNotEmpty) {
                                            final baseMin = tfHelper
                                                .parseTimeframeToMinutes(
                                                    baseTf);
                                            final tfMin = tfHelper
                                                .parseTimeframeToMinutes(tf);
                                            warn = tfMin < baseMin;
                                          }
                                          final bg = warn
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .errorContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .secondaryContainer;
                                          final fg = warn
                                              ? Theme.of(context)
                                                  .colorScheme
                                                  .onErrorContainer
                                              : Theme.of(context)
                                                  .colorScheme
                                                  .onSecondaryContainer;
                                          return Chip(
                                            backgroundColor: bg,
                                            label: Text(
                                              '$tf • ${count} rule${count > 1 ? 's' : ''}',
                                              style: TextStyle(color: fg),
                                            ),
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 8),
                                            Text(
                                              'Per‑Timeframe Rule Counts',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            const SizedBox(height: 6),
                                            if (entryTfCounts.isNotEmpty) ...[
                                              Text('Entry Rules',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: entryTfCounts.entries
                                                    .map((e) =>
                                                        _tfChip(e.key, e.value))
                                                    .toList(),
                                              ),
                                            ],
                                            if (exitTfCounts.isNotEmpty) ...[
                                              const SizedBox(height: 8),
                                              Text('Exit Rules',
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodySmall),
                                              const SizedBox(height: 4),
                                              Wrap(
                                                spacing: 8,
                                                runSpacing: 8,
                                                children: exitTfCounts.entries
                                                    .map((e) =>
                                                        _tfChip(e.key, e.value))
                                                    .toList(),
                                              ),
                                            ],
                                          ],
                                        );
                                      }),

                                      // Summary stats
                                      Row(
                                        children: [
                                          _buildStatCard(
                                            context,
                                            'Win Rate',
                                            '${viewModel.previewResult!.summary.winRate.toStringAsFixed(1)}%',
                                            viewModel.previewResult!.summary.winRate >=
                                                    50
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                          ),
                                          _buildStatCard(
                                            context,
                                            'PnL',
                                            '\$${viewModel.previewResult!.summary.totalPnl.toStringAsFixed(2)}',
                                            viewModel.previewResult!.summary
                                                        .totalPnl >=
                                                    0
                                                ? Theme.of(context)
                                                    .colorScheme
                                                    .primary
                                                : Theme.of(context)
                                                    .colorScheme
                                                    .error,
                                          ),
                                          _buildStatCard(
                                            context,
                                            'Trades',
                                            '${viewModel.previewResult!.summary.totalTrades}',
                                            Theme.of(context)
                                                .colorScheme
                                                .secondary,
                                          ),
                                        ],
                                      ),

                                      // Per‑TF signals & performance (from preview)
                                      Builder(builder: (context) {
                                        final stats = viewModel.previewTfStats;
                                        if (stats.isEmpty)
                                          return const SizedBox.shrink();

                                        Widget _statChip(
                                            String tf, Map<String, num> s) {
                                          final bg = Theme.of(context)
                                              .colorScheme
                                              .surfaceVariant;
                                          final fg = Theme.of(context)
                                              .colorScheme
                                              .onSurfaceVariant;
                                          final winRate =
                                              (s['winRate'] ?? 0).toDouble();
                                          return Card(
                                            color: bg,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 8,
                                                      horizontal: 12),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(tf,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: fg,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600)),
                                                  const SizedBox(height: 4),
                                                  Wrap(
                                                    spacing: 8,
                                                    runSpacing: 6,
                                                    crossAxisAlignment:
                                                        WrapCrossAlignment
                                                            .center,
                                                    children: [
                                                      Text(
                                                          'Signals: ${s['signals'] ?? 0}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                          'Trades: ${s['trades'] ?? 0}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                          'Wins: ${s['wins'] ?? 0}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall),
                                                      const SizedBox(width: 12),
                                                      Text(
                                                          'WinRate: ${winRate.toStringAsFixed(1)}%',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodySmall!
                                                                  .copyWith(
                                                                    color: winRate >=
                                                                            50
                                                                        ? Theme.of(context)
                                                                            .colorScheme
                                                                            .primary
                                                                        : Theme.of(context)
                                                                            .colorScheme
                                                                            .error,
                                                                  )),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        }

                                        return Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(height: 12),
                                            Text(
                                                'Per‑Timeframe Signals & Performance',
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium),
                                            const SizedBox(height: 6),
                                            Wrap(
                                              spacing: 8,
                                              runSpacing: 8,
                                              children: stats.entries
                                                  .map((e) =>
                                                      _statChip(e.key, e.value))
                                                  .toList(),
                                            ),
                                          ],
                                        );
                                      }),

                                      const SizedBox(height: 16),

                                      // View full results button
                                      SizedBox(
                                        width: double.infinity,
                                        child: OutlinedButton.icon(
                                          onPressed: viewModel.viewFullResults,
                                          icon: const Icon(Icons.analytics),
                                          label:
                                              const Text('View Full Results'),
                                          style: OutlinedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
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
                      ),

                      const SizedBox(height: 24),

                      // Save Button
                      Tooltip(
                        message: (() {
                          if (viewModel.hasFatalErrors) {
                            final errs = viewModel.getAllFatalErrors();
                            final shown = errs.take(2).join('\n• ');
                            return 'Perbaiki error sebelum menyimpan:\n• ' +
                                shown +
                                (errs.length > 2 ? '...' : '');
                          }
                          if (!viewModel.canSave) {
                            return 'Lengkapi nama, modal awal, dan entry rules';
                          }
                          if (viewModel.isBusy) {
                            return 'Sedang menyimpan...';
                          }
                          return 'Simpan strategi';
                        })(),
                        child: ElevatedButton(
                          onPressed: (viewModel.canSave &&
                                  !viewModel.isBusy &&
                                  !viewModel.hasFatalErrors)
                              ? () => viewModel.saveStrategy(context)
                              : null,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
                          child: viewModel.isBusy
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  viewModel.isEditing
                                      ? 'Update Strategy'
                                      : 'Save Strategy',
                                  style: const TextStyle(fontSize: 16),
                                ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      if (viewModel.autosaveStatus.isNotEmpty)
                        Center(
                          child: Text(
                            viewModel.autosaveStatus,
                            style: TextStyle(
                              fontSize: 12,
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withValues(alpha: 0.8),
                            ),
                          ),
                        ),

                      const SizedBox(height: 8),
                      Center(
                        child: TextButton.icon(
                          onPressed: viewModel.discardDraft,
                          icon: const Icon(Icons.delete_forever),
                          label: const Text('Discard Draft'),
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildRuleCard(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    int index,
    RuleBuilder rule,
    bool isEntry,
  ) {
    final hasRuleErrors = viewModel.getRuleErrorsFor(index, isEntry).isNotEmpty;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).colorScheme.surface,
      shape: hasRuleErrors
          ? RoundedRectangleBorder(
              side: BorderSide(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.25),
              ),
              borderRadius: BorderRadius.circular(8),
            )
          : null,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Rule ${index + 1}',
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
            const SizedBox(height: 12),

            // Indicator dropdown
            DropdownButtonFormField<IndicatorType>(
              value: rule.indicator,
              decoration: const InputDecoration(
                labelText: 'Indicator',
                isDense: true,
              ),
              items: IndicatorType.values.map((indicator) {
                return DropdownMenuItem(
                  value: indicator,
                  child: Text(_formatIndicator(indicator)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateRuleIndicator(index, value, isEntry);
                }
              },
            ),

            const SizedBox(height: 12),

            // Timeframe (optional)
            Builder(builder: (context) {
              final warnings = viewModel.getRuleWarningsFor(index, isEntry);
              final tfWarning = warnings.firstWhere(
                (w) => w.contains('Timeframe rule lebih kecil'),
                orElse: () => '',
              );
              return Tooltip(
                message: tfWarning.isNotEmpty
                    ? tfWarning
                    : 'Opsional: gunakan timeframe >= data dasar untuk menghindari resampling otomatis.',
                child: DropdownButtonFormField<String?>(
                  value: rule.timeframe,
                  decoration: const InputDecoration(
                    labelText: 'Timeframe (opsional)',
                    isDense: true,
                  ),
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('Gunakan timeframe dasar'),
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

            const SizedBox(height: 12),

            // Operator dropdown
            DropdownButtonFormField<ComparisonOperator>(
              value: rule.operator,
              decoration: const InputDecoration(
                labelText: 'Operator',
                isDense: true,
              ),
              items: ComparisonOperator.values.map((op) {
                return DropdownMenuItem(
                  value: op,
                  child: Text(_formatOperator(op)),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  viewModel.updateRuleOperator(index, value, isEntry);
                }
              },
            ),

            const SizedBox(height: 12),

            // Value type toggle
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: [
                      ButtonSegment(
                        value: true,
                        label: const Text('Number'),
                        enabled:
                            !(rule.operator == ComparisonOperator.crossAbove ||
                                rule.operator == ComparisonOperator.crossBelow),
                      ),
                      const ButtonSegment(
                        value: false,
                        label: Text('Indicator'),
                      ),
                    ],
                    selected: {rule.isNumberValue},
                    onSelectionChanged: (Set<bool> selection) {
                      viewModel.updateRuleValueType(
                          index, selection.first, isEntry);
                    },
                  ),
                ),
              ],
            ),
            if (rule.operator == ComparisonOperator.crossAbove ||
                rule.operator == ComparisonOperator.crossBelow) ...[
              const SizedBox(height: 6),
              Text(
                'Untuk operator cross, Value Number dimatikan. Gunakan indikator pembanding.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                    ),
              ),
            ],

            const SizedBox(height: 12),

            // Value input
            if (rule.isNumberValue)
              TextField(
                controller: rule.numberController,
                decoration: InputDecoration(
                  labelText: 'Value',
                  hintText: 'e.g. 30, 70, 50',
                  isDense: true,
                  errorText: rule.numberValue == null ? 'Wajib diisi' : null,
                ),
                keyboardType: TextInputType.number,
                onChanged: (value) =>
                    viewModel.updateRuleNumberValue(index, value, isEntry),
              )
            else
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<IndicatorType>(
                      value: rule.compareIndicator,
                      decoration: InputDecoration(
                        labelText: 'Compare With',
                        isDense: true,
                        errorText: rule.compareIndicator == null
                            ? 'Wajib pilih'
                            : null,
                      ),
                      items: IndicatorType.values.map((indicator) {
                        return DropdownMenuItem(
                          value: indicator,
                          child: Text(_formatIndicator(indicator)),
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
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: rule.periodController,
                      decoration: InputDecoration(
                        labelText: 'Period',
                        hintText: '14',
                        isDense: true,
                        errorText:
                            (rule.period == null || (rule.period ?? 0) <= 0)
                                ? 'Harus > 0'
                                : null,
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) =>
                          viewModel.updateRulePeriod(index, value, isEntry),
                    ),
                  ),
                ],
              ),

            // Logical operator (for chaining rules)
            if (isEntry && index < viewModel.entryRules.length - 1 ||
                !isEntry && index < viewModel.exitRules.length - 1) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<LogicalOperator?>(
                value: rule.logicalOperator,
                decoration: const InputDecoration(
                  labelText: 'Then (Logic)',
                  isDense: true,
                ),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...LogicalOperator.values.map((op) {
                    return DropdownMenuItem(
                      value: op,
                      child: Text(op.name.toUpperCase()),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  viewModel.updateRuleLogicalOperator(index, value, isEntry);
                },
              ),
            ],

            // Validation messages
            Builder(builder: (context) {
              final warnings = viewModel.getRuleWarningsFor(index, isEntry);
              final errors = viewModel.getRuleErrorsFor(index, isEntry);
              if (warnings.isEmpty && errors.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (warnings.isNotEmpty) ...[
                      Text(
                        'Peringatan:',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.tertiary),
                      ),
                      const SizedBox(height: 6),
                      ...warnings.map((w) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline,
                                  size: 16,
                                  color:
                                      Theme.of(context).colorScheme.tertiary),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  w,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        Theme.of(context).colorScheme.tertiary,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ],
                    if (errors.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Error:',
                        style: Theme.of(context)
                            .textTheme
                            .labelMedium!
                            .copyWith(
                                color: Theme.of(context).colorScheme.error),
                      ),
                      const SizedBox(height: 6),
                      ...errors.map((e) => Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.error_outline,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.error),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  e,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          )),
                    ]
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _formatRiskType(RiskType type) {
    switch (type) {
      case RiskType.fixedLot:
        return 'Fixed Lot Size';
      case RiskType.percentageRisk:
        return 'Percentage Risk';
    }
  }

  String _formatIndicator(IndicatorType indicator) {
    final map = {
      IndicatorType.close: 'Close',
      IndicatorType.open: 'Open',
      IndicatorType.high: 'High',
      IndicatorType.low: 'Low',
      IndicatorType.rsi: 'RSI',
      IndicatorType.sma: 'SMA',
      IndicatorType.ema: 'EMA',
      IndicatorType.macd: 'MACD',
      IndicatorType.atr: 'ATR',
      IndicatorType.bollingerBands: 'Bollinger Bands',
    };
    return map[indicator] ?? indicator.name;
  }

  String _formatOperator(ComparisonOperator op) {
    final map = {
      ComparisonOperator.greaterThan: 'Greater Than (>)',
      ComparisonOperator.lessThan: 'Less Than (<)',
      ComparisonOperator.greaterThanOrEqual: 'Greater or Equal (>=)',
      ComparisonOperator.lessThanOrEqual: 'Less or Equal (<=)',
      ComparisonOperator.equals: 'Equals (=)',
      ComparisonOperator.crossAbove: 'Cross Above',
      ComparisonOperator.crossBelow: 'Cross Below',
    };
    return map[op] ?? op.name;
  }

  // Helper method to build stat cards for preview results
  Widget _buildStatCard(
    BuildContext context,
    String label,
    String value,
    Color valueColor,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium!
                    .copyWith(color: valueColor, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper: timeframe chip used in preview badges
  Widget _buildTfChip(BuildContext context, String label, bool isWarn) {
    final bg = isWarn
        ? Theme.of(context).colorScheme.error.withValues(alpha: 0.12)
        : Theme.of(context)
            .colorScheme
            .secondaryContainer
            .withValues(alpha: 0.18);
    final border = isWarn
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.outline;
    final textColor = isWarn
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        border: Border.all(color: border),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isWarn ? Icons.warning_amber : Icons.schedule,
              size: 14, color: textColor.withValues(alpha: 0.9)),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelSmall
                ?.copyWith(color: textColor),
          ),
        ],
      ),
    );
  }

  @override
  StrategyBuilderViewModel viewModelBuilder(BuildContext context) =>
      StrategyBuilderViewModel(strategyId);

  @override
  void onViewModelReady(StrategyBuilderViewModel viewModel) =>
      viewModel.initialize();
}
