import 'package:backtestx/helpers/strategy_stats_helper.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'package:backtestx/ui/widgets/skeleton_loader.dart' as x_skeleton;
import 'package:backtestx/ui/widgets/common/empty_state.dart';
import 'workspace_viewmodel.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WorkspaceViewModel>.reactive(
      viewModelBuilder: () => WorkspaceViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.homeActionWorkspaceTitle),
          actions: [
            // // Quick Run EMA Ribbon
            // IconButton(
            //   icon: const Icon(Icons.auto_graph),
            //   tooltip: 'Quick Run EMA Ribbon',
            //   onPressed: model.quickRunEmaRibbon,
            // ),
            // // Quick Run VWAP Pullback
            // IconButton(
            //   icon: const Icon(Icons.stacked_line_chart),
            //   tooltip: 'Quick Run VWAP Pullback',
            //   onPressed: model.quickRunVwapPullback,
            // ),
            // // Quick Run Anchored VWAP Pullback/Cross
            // IconButton(
            //   icon: const Icon(Icons.flag),
            //   tooltip: 'Quick Run Anchored VWAP',
            //   onPressed: model.quickRunAnchoredVwap,
            // ),
            // // Quick Run Stochastic K/D Cross
            // IconButton(
            //   icon: const Icon(Icons.tune),
            //   tooltip: 'Quick Run Stochastic K/D',
            //   onPressed: model.quickRunStochasticKdCross,
            // ),
            // // Quick Run Bollinger Squeeze
            // IconButton(
            //   icon: const Icon(Icons.data_usage),
            //   tooltip: 'Quick Run Bollinger Squeeze',
            //   onPressed: model.quickRunBollingerSqueeze,
            // ),
            // // Quick Run RSI Divergence Approx
            // IconButton(
            //   icon: const Icon(Icons.trending_up),
            //   tooltip: 'Quick Run RSI Divergence',
            //   onPressed: model.quickRunRsiDivergenceApprox,
            // ),
            // Compare mode toggle
            if (model.strategies.isNotEmpty)
              IconButton(
                icon: Icon(
                  model.isCompareMode ? Icons.close : Icons.compare_arrows,
                ),
                onPressed: model.toggleCompareMode,
                tooltip: model.isCompareMode
                    ? AppLocalizations.of(context)!.workspaceCompareExitTooltip
                    : AppLocalizations.of(context)!
                        .workspaceCompareEnterTooltip,
              ),

            // Sort menu
            PopupMenuButton<SortType>(
              icon: const Icon(Icons.sort),
              onSelected: model.setSortBy,
              itemBuilder: (context) => [
                for (var sortType in SortType.values)
                  PopupMenuItem(
                    value: sortType,
                    child: Row(
                      children: [
                        Icon(
                          sortType.icon,
                          size: 20,
                          color: model.sortBy == sortType
                              ? Theme.of(context).primaryColor
                              : null,
                        ),
                        const SizedBox(width: 12),
                        Text(sortType.label),
                      ],
                    ),
                  ),
              ],
            ),

            // Refresh
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: model.refresh,
            ),
          ],
        ),

        body: model.isBusy
            ? _buildWorkspaceSkeleton(context)
            : Column(
                children: [
                  // Search bar
                  _buildSearchBar(context, model),

                  // Compare mode banner
                  if (model.isCompareMode)
                    _buildCompareModeBanner(context, model),

                  // Strategies list
                  Expanded(
                    child: model.filteredStrategies.isEmpty
                        ? _buildEmptyState(context, model)
                        : RefreshIndicator(
                            onRefresh: model.refresh,
                            child: ListView.builder(
                              padding: const EdgeInsets.all(16),
                              itemCount: model.filteredStrategies.length,
                              itemBuilder: (context, index) {
                                final strategy =
                                    model.filteredStrategies[index];
                                return _buildStrategyCard(
                                  context,
                                  model,
                                  strategy,
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),

        // Floating action button
        floatingActionButton: model.isCompareMode && model.canCompare
            ? FloatingActionButton.extended(
                onPressed: model.compareSelected,
                icon: const Icon(Icons.compare),
                label: Text(AppLocalizations.of(context)!
                    .workspaceCompareCountLabel(model.selectedCount)),
              )
            : FloatingActionButton(
                onPressed: model.navigateToCreateStrategy,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Widget _buildWorkspaceSkeleton(BuildContext context) {
    return Column(
      children: [
        // Search bar skeleton
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).scaffoldBackgroundColor,
          child: x_skeleton.SkeletonLoader.bar(context,
              height: 44, radius: BorderRadius.circular(12)),
        ),

        // Optional compare banner skeleton space
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: x_skeleton.SkeletonLoader.bar(context,
              width: double.infinity,
              height: 36,
              radius: BorderRadius.circular(8)),
        ),
        const SizedBox(height: 8),

        // Strategies list skeleton
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 6,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title row
                        Row(
                          children: [
                            Expanded(
                              child: x_skeleton.SkeletonLoader.bar(context,
                                  height: 18),
                            ),
                            const SizedBox(width: 12),
                            x_skeleton.SkeletonLoader.circle(context, size: 24),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Stats row
                        Row(
                          children: [
                            Expanded(
                              child: x_skeleton.SkeletonLoader.bar(context,
                                  height: 12),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: x_skeleton.SkeletonLoader.bar(context,
                                  height: 12),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: x_skeleton.SkeletonLoader.bar(context,
                                  height: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Action buttons
                        Row(
                          children: [
                            x_skeleton.SkeletonLoader.bar(context,
                                width: 90,
                                height: 32,
                                radius: BorderRadius.circular(20)),
                            const SizedBox(width: 8),
                            x_skeleton.SkeletonLoader.bar(context,
                                width: 100,
                                height: 32,
                                radius: BorderRadius.circular(20)),
                            const Spacer(),
                            x_skeleton.SkeletonLoader.bar(context,
                                width: 80,
                                height: 32,
                                radius: BorderRadius.circular(20)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, WorkspaceViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        onChanged: model.searchStrategies,
        decoration: InputDecoration(
          hintText: AppLocalizations.of(context)!.workspaceSearchHint,
          prefixIcon: const Icon(Icons.search),
          suffixIcon: model.searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: model.clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Theme.of(context)
              .colorScheme
              .surfaceContainerHighest
              .withValues(alpha: 0.3),
        ),
      ),
    );
  }

  Widget _buildCompareModeBanner(
      BuildContext context, WorkspaceViewModel model) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Theme.of(context).colorScheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '${AppLocalizations.of(context)!.workspaceCompareBannerText} '
              '${AppLocalizations.of(context)!.workspaceCompareBannerSelectedSuffix(model.selectedCount)}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (model.selectedCount > 0)
            TextButton(
              onPressed: model.clearSelection,
              child: const Text('Clear'),
            ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WorkspaceViewModel model) {
    final isEmpty = model.strategies.isEmpty;
    return EmptyState(
      icon: isEmpty ? Icons.folder_open : Icons.search_off,
      title: isEmpty
          ? AppLocalizations.of(context)!.workspaceEmptyNoStrategies
          : AppLocalizations.of(context)!.workspaceEmptyNoStrategiesFound,
      message: isEmpty
          ? AppLocalizations.of(context)!.workspaceEmptyCreateFirstMessage
          : AppLocalizations.of(context)!.workspaceSearchNoResultsTip,
      primaryLabel: isEmpty
          ? AppLocalizations.of(context)!.homeActionStrategyTitle
          : null,
      onPrimary: isEmpty ? model.navigateToCreateStrategy : null,
    );
  }

  Widget _buildStrategyCard(
    BuildContext context,
    WorkspaceViewModel model,
    Strategy strategy,
  ) {
    final isExpanded = model.isExpanded(strategy.id);
    final stats = model.getStrategyStats(strategy.id);
    final hasResults = model.hasResults(strategy.id);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // Strategy header
          InkWell(
            onTap: hasResults ? () => model.toggleExpand(strategy.id) : null,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Strategy name and actions
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strategy.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              AppLocalizations.of(context)!.createdLabel(
                                  _formatRelativeDate(
                                      context, strategy.createdAt)),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Action buttons
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'export_trades_all',
                            child: Row(
                              children: [
                                Icon(Icons.table_view, size: 20),
                                SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!
                                    .exportAllTradesCsv),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'export_tfstats_csv',
                            child: Row(
                              children: [
                                Icon(Icons.stacked_line_chart, size: 20),
                                SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!
                                    .exportTfStatsCsv),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'export_results_csv',
                            child: Row(
                              children: [
                                Icon(Icons.file_download, size: 20),
                                SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!
                                    .exportResultsCsv),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'run_batch',
                            enabled:
                                !model.isRunningBatchQuickTest(strategy.id),
                            child: Row(
                              children: [
                                if (model.isRunningBatchQuickTest(strategy.id))
                                  const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  const Icon(Icons.playlist_play, size: 20),
                                const SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!
                                    .workspaceRunBatch),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!.editLabel),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.content_copy, size: 20),
                                SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!
                                    .duplicateLabel),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text(AppLocalizations.of(context)!.deleteLabel,
                                    style: const TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
                            case 'export_trades_all':
                              model.exportStrategyTradesCsv(strategy);
                              break;
                            case 'export_tfstats_csv':
                              model.exportFilteredStrategyTfStatsCsv(strategy);
                              break;
                            case 'export_results_csv':
                              model.exportFilteredStrategyResultsCsv(strategy);
                              break;
                            case 'run_batch':
                              model.quickRunBacktestBatch(strategy);
                              break;
                            case 'edit':
                              model.navigateToEditStrategy(strategy);
                              break;
                            case 'duplicate':
                              model.duplicateStrategy(strategy);
                              break;
                            case 'delete':
                              model.deleteStrategy(strategy);
                              break;
                          }
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Stats preview
                  if (hasResults)
                    _buildStatsPreview(context, stats)
                  else
                    _buildNoResultsIndicator(context),

                  const SizedBox(height: 12),

                  // Quick actions
                  Row(
                    children: [
                      // Market data dropdown for quick test
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              isExpanded: true,
                              value: model.selectedDataId,
                              hint: Text(AppLocalizations.of(context)!
                                  .sbSelectMarketData),
                              onChanged: (value) {
                                // Disable changing data while quick/batch test is running
                                final isDisabled = model
                                        .isRunningQuickTest(strategy.id) ||
                                    model.isRunningBatchQuickTest(strategy.id);
                                if (isDisabled) return;
                                if (value != null) {
                                  model.setSelectedData(value);
                                }
                              },
                              items: model.availableData.map((data) {
                                return DropdownMenuItem(
                                  value: data.id,
                                  child: Text(
                                    data.symbol,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Quick test button
                      ElevatedButton.icon(
                        onPressed: (model.isRunningQuickTest(strategy.id) ||
                                model.isRunningBatchQuickTest(strategy.id))
                            ? null
                            : () => model.quickRunBacktest(strategy),
                        icon: model.isRunningQuickTest(strategy.id)
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.flash_on, size: 18),
                        label: () {
                          final baseLabel = AppLocalizations.of(context)!
                              .workspaceQuickTestButton;
                          final p = model.getQuickProgress(strategy.id);
                          if (p == null) {
                            return Text(baseLabel);
                          }
                          final pct =
                              (p * 100).clamp(0, 100).toStringAsFixed(0);
                          return Text('$baseLabel ($pct%)');
                        }(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      // Run Batch moved to strategy action menu
                      if (hasResults) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () =>
                              model.copyStrategyLinkToClipboard(strategy),
                          icon: const Icon(Icons.link),
                          tooltip:
                              AppLocalizations.of(context)!.copyStrategyLink,
                        ),
                        const SizedBox(width: 4),
                        IconButton(
                          onPressed: () => model.toggleExpand(strategy.id),
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          tooltip: isExpanded
                              ? AppLocalizations.of(context)!.commonCollapse
                              : AppLocalizations.of(context)!.commonExpand,
                        ),
                      ],
                    ],
                  ),

                  // Quick result preview
                  if (model.getQuickResult(strategy.id) != null) ...[
                    const SizedBox(height: 12),
                    _buildQuickResultPreview(context, model, strategy.id),
                  ],
                ],
              ),
            ),
          ),

          // Results list (expandable)
          if (isExpanded && hasResults)
            _buildResultsList(context, model, strategy),
        ],
      ),
    );
  }

  Widget _buildStatsPreview(BuildContext context, StrategyStatsData stats) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              context,
              'Tests',
              '${stats.totalBacktests}',
              Icons.analytics_outlined,
              Colors.blue,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Avg P&L',
              stats.formatAvgPnlPercent(),
              Icons.trending_up,
              stats.isProfitable ? Colors.green : Colors.red,
            ),
          ),
          Expanded(
            child: _buildStatItem(
              context,
              'Win Rate',
              stats.formatWinRate(),
              Icons.check_circle_outline,
              Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value,
      IconData icon, Color color) {
    final t = AppLocalizations.of(context)!;
    String metricLabelLocalized(String key) {
      switch (key) {
        case 'Tests':
          return t.workspaceTestsLabel;
        case 'Avg P&L':
          return t.workspaceAvgPnlLabel;
        case 'Win Rate':
          return t.workspaceWinRateLabel;
        case 'P&L':
          return t.workspacePnlLabel;
        case 'PF':
          return t.workspacePfLabel;
        case 'Trades':
          return t.metricsTrades;
        default:
          return key;
      }
    }

    String metricTooltipLocalized(String key) {
      switch (key) {
        case 'Tests':
          return t.metricTooltipTests;
        case 'Avg P&L':
          return t.metricTooltipAvgPnl;
        case 'Win Rate':
          return t.metricTooltipWinRate;
        case 'P&L':
          return t.metricTooltipPnl;
        case 'PF':
          return t.metricTooltipPf;
        default:
          return t.metricTooltipDefault;
      }
    }

    return Column(
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
        Tooltip(
          message: metricTooltipLocalized(label),
          child: Text(
            metricLabelLocalized(label),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            AppLocalizations.of(context)!.workspaceNoResults,
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickResultPreview(
    BuildContext context,
    WorkspaceViewModel model,
    String strategyId,
  ) {
    final result = model.getQuickResult(strategyId);
    if (result == null) return const SizedBox.shrink();

    final summary = result.summary;
    final isProfitable = summary.totalPnl > 0;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isProfitable ? Colors.green.withValues(alpha: 0.6) : Colors.red,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.flash_on,
                size: 16,
                color: Colors.amber[700],
              ),
              const SizedBox(width: 6),
              Text(
                AppLocalizations.of(context)!.workspaceQuickTestResultTitle,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => model.viewQuickResult(strategyId),
                child: Text(AppLocalizations.of(context)!.sbViewFullResults),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  context,
                  'Win Rate',
                  '${(summary.winRate).toStringAsFixed(1)}%',
                  Icons.check_circle_outline,
                  Colors.blue,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'P&L',
                  summary.totalPnl.toStringAsFixed(2),
                  Icons.trending_up,
                  isProfitable
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  context,
                  'Trades',
                  '${summary.totalTrades}',
                  Icons.swap_horiz,
                  Colors.purple,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(
    BuildContext context,
    WorkspaceViewModel model,
    Strategy strategy,
  ) {
    final allCount = model.getFilteredResults(strategy.id).length;
    final results = model.getPagedFilteredResults(strategy.id);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Backtest Results (${model.getResultsShownCount(strategy.id)}/${allCount})',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    softWrap: true,
                  ),
                ),
                const SizedBox(width: 8),
                // Sort results
                DropdownButtonHideUnderline(
                  child: DropdownButton<ResultSortKey>(
                    value: model.getResultSortKey(strategy.id),
                    onChanged: (key) {
                      if (key != null) {
                        model.setResultSortKey(strategy.id, key);
                      }
                    },
                    items: ResultSortKey.values
                        .map(
                          (k) => DropdownMenuItem<ResultSortKey>(
                            value: k,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(k.icon, size: 18),
                                const SizedBox(width: 6),
                                Text(k.label),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
                Tooltip(
                  message: AppLocalizations.of(context)!
                      .workspaceExportFilteredResultsCsv,
                  child: IconButton(
                    icon: const Icon(Icons.download),
                    onPressed: results.isEmpty
                        ? null
                        : () =>
                            model.exportFilteredStrategyResultsCsv(strategy),
                  ),
                ),
              ],
            ),
          ),
          // Filters
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  selected: model.filterProfitOnly,
                  label: Text(
                    AppLocalizations.of(context)!.workspaceFilterProfitOnly,
                    style: TextStyle(
                      color: model.filterProfitOnly
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                  showCheckmark: true,
                  onSelected: (_) => model.toggleFilterProfitOnly(),
                ),
                FilterChip(
                  selected: model.filterPfPositive,
                  label: Text(
                    AppLocalizations.of(context)!.workspaceFilterPfPositive,
                    style: TextStyle(
                      color: model.filterPfPositive
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                  showCheckmark: true,
                  onSelected: (_) => model.toggleFilterPfPositive(),
                ),
                FilterChip(
                  selected: model.filterWinRateAbove50,
                  label: Text(
                    AppLocalizations.of(context)!.workspaceFilterWinRate50,
                    style: TextStyle(
                      color: model.filterWinRateAbove50
                          ? Theme.of(context).colorScheme.primary
                          : null,
                    ),
                  ),
                  selectedColor: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.15),
                  checkmarkColor: Theme.of(context).colorScheme.primary,
                  showCheckmark: true,
                  onSelected: (_) => model.toggleFilterWinRate50(),
                ),
                // Symbol dropdown
                Builder(
                  builder: (context) {
                    final symbols = model.getAvailableSymbols(strategy.id);
                    // Ensure current value exists exactly once in items; otherwise default to null
                    final current = model.selectedSymbolFilter;
                    final effectiveValue =
                        symbols.contains(current) ? current : null;
                    return DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: effectiveValue,
                        hint: Text(
                            AppLocalizations.of(context)!.commonAllSymbols),
                        items: [
                          DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                                AppLocalizations.of(context)!.commonAllSymbols),
                          ),
                          ...symbols.map(
                            (s) => DropdownMenuItem<String?>(
                              value: s,
                              child: Text(s),
                            ),
                          ),
                        ],
                        onChanged: (val) => model.setSelectedSymbolFilter(val),
                      ),
                    );
                  },
                ),
                // Timeframe multi-select chips with counts
                ...(() {
                  final counts = model.getTimeframeCounts(strategy.id);
                  return model.getAvailableTimeframes(strategy.id).map((tf) {
                    final isSelected =
                        model.selectedTimeframeFilters.contains(tf);
                    return FilterChip(
                      selected: isSelected,
                      label: Text(
                        '$tf (${counts[tf] ?? 0})',
                        style: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : null,
                        ),
                      ),
                      selectedColor: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.15),
                      checkmarkColor: Theme.of(context).colorScheme.primary,
                      showCheckmark: true,
                      onSelected: (_) => model.toggleTimeframeFilter(tf),
                    );
                  }).toList();
                })(),
                // Start date picker
                TextButton.icon(
                  onPressed: () async {
                    final initial = model.startDateFilter ?? DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      // Normalize to date-only
                      final d = DateTime(picked.year, picked.month, picked.day);
                      model.setStartDateFilter(d);
                    }
                  },
                  icon: const Icon(Icons.calendar_today),
                  label: Text(
                    model.startDateFilter != null
                        ? '${AppLocalizations.of(context)!.filterStartLabel} ${DateFormat('MMM dd, yyyy').format(model.startDateFilter!)}'
                        : AppLocalizations.of(context)!.filterStartDate,
                  ),
                ),
                // End date picker
                TextButton.icon(
                  onPressed: () async {
                    final baseInitial = model.startDateFilter ?? DateTime.now();
                    final initial = model.endDateFilter ?? baseInitial;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now().add(const Duration(days: 3650)),
                    );
                    if (picked != null) {
                      final d = DateTime(
                          picked.year, picked.month, picked.day, 23, 59, 59);
                      model.setEndDateFilter(d);
                    }
                  },
                  icon: const Icon(Icons.event),
                  label: Text(
                    model.endDateFilter != null
                        ? '${AppLocalizations.of(context)!.filterEndLabel} ${DateFormat('MMM dd, yyyy').format(model.endDateFilter!)}'
                        : AppLocalizations.of(context)!.filterEndDate,
                  ),
                ),
                if (model.filterProfitOnly ||
                    model.filterPfPositive ||
                    model.filterWinRateAbove50 ||
                    model.selectedSymbolFilter != null ||
                    model.selectedTimeframeFilters.isNotEmpty ||
                    model.startDateFilter != null ||
                    model.endDateFilter != null)
                  TextButton.icon(
                    onPressed: model.clearFilters,
                    icon: const Icon(Icons.clear),
                    label: Text(AppLocalizations.of(context)!.sbClearFilters),
                  ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: results.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final result = results[index];
              return _buildResultItem(context, model, result);
            },
          ),
          if (model.isMoreResultsAvailable(strategy.id))
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Align(
                alignment: Alignment.center,
                child: OutlinedButton.icon(
                  onPressed: () => model.loadMoreResults(strategy.id),
                  icon: const Icon(Icons.unfold_more),
                  label: Text(AppLocalizations.of(context)!.loadMore),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultItem(
    BuildContext context,
    WorkspaceViewModel model,
    BacktestResult result,
  ) {
    final isSelected = model.isResultSelected(result.id);
    final isCompareMode = model.isCompareMode;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
            : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).colorScheme.outline,
          width: isSelected ? 2 : 1,
        ),
      ),
      child: InkWell(
        onTap: isCompareMode
            ? () => model.toggleResultSelection(result.id)
            : () => model.viewResult(result),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Checkbox for compare mode
              if (isCompareMode)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: (_) => model.toggleResultSelection(result.id),
                  ),
                ),

              // Result info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatDateTime(result.executedAt),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (!isCompareMode)
                          SizedBox(
                            width: 84,
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: _buildResultActions(
                                context,
                                model,
                                result,
                                isCompareMode,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Symbol / Timeframe chips
                    _buildSymbolTfChips(context, model, result),
                    const SizedBox(height: 8),

                    // Performance metrics (responsive: wrap on small widths)
                    LayoutBuilder(
                      builder: (context, c) {
                        return Wrap(
                          spacing: 32,
                          runSpacing: 6,
                          alignment: WrapAlignment.start,
                          crossAxisAlignment: WrapCrossAlignment.start,
                          children: [
                            _buildResultMetric(
                              context,
                              'P&L',
                              _formatPnL(result.summary.totalPnl),
                              _formatPnLPercent(
                                  result.summary.totalPnlPercentage),
                              result.summary.totalPnl >= 0
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            _buildResultMetric(
                              context,
                              'Win Rate',
                              '${result.summary.winRate.toStringAsFixed(1)}%',
                              '${result.summary.winningTrades}/${result.summary.totalTrades}',
                              Theme.of(context).colorScheme.tertiary,
                            ),
                            _buildResultMetric(
                              context,
                              'PF',
                              result.summary.profitFactor.toStringAsFixed(2),
                              null,
                              result.summary.profitFactor > 1
                                  ? Theme.of(context).colorScheme.primary
                                  : Theme.of(context).colorScheme.error,
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    if ((result.summary.tfStats ?? {}).isNotEmpty)
                      _buildTfStatsPreview(context, model, result),
                  ],
                ),
              ),

              // Action buttons moved into header row above to align with date
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultMetric(
    BuildContext context,
    String label,
    String value,
    String? subtitle,
    Color color,
  ) {
    final t = AppLocalizations.of(context)!;
    String metricLabelLocalized(String key) {
      switch (key) {
        case 'Tests':
          return t.workspaceTestsLabel;
        case 'Avg P&L':
          return t.workspaceAvgPnlLabel;
        case 'Win Rate':
          return t.workspaceWinRateLabel;
        case 'P&L':
          return t.workspacePnlLabel;
        case 'PF':
          return t.workspacePfLabel;
        case 'Trades':
          return t.metricsTrades;
        default:
          return key;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Tooltip(
          message: _metricTooltip(context, label),
          child: Text(
            metricLabelLocalized(label),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.6),
            ),
          ),
      ],
    );
  }

  // Kept for compatibility if used elsewhere
  String _metricTooltip(BuildContext context, String label) {
    final t = AppLocalizations.of(context)!;
    return _metricTooltipLocalized(t, label);
  }

  // Localized tooltip mapping
  String _metricTooltipLocalized(AppLocalizations t, String label) {
    switch (label) {
      case 'P&L':
        return t.metricTooltipPnl;
      case 'Win Rate':
        return t.metricTooltipWinRate;
      case 'PF':
      case 'Profit Factor':
        return t.metricTooltipPf;
      case 'Tests':
        return t.metricTooltipTests;
      case 'Avg P&L':
        return t.metricTooltipAvgPnl;
      default:
        return t.metricTooltipDefault;
    }
  }

  String _formatRelativeDate(BuildContext context, DateTime date) {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return t.relativeToday;
    if (diff.inDays == 1) return t.relativeYesterday;
    if (diff.inDays < 7) return t.relativeDaysAgo(diff.inDays);
    if (diff.inDays < 30) return t.relativeWeeksAgo((diff.inDays / 7).floor());
    if (diff.inDays < 365) {
      return t.relativeMonthsAgo((diff.inDays / 30).floor());
    }
    return DateFormat('MMM dd, yyyy').format(date);
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('MMM dd, yyyy • HH:mm').format(date);
  }

  String _formatPnL(double pnl) {
    final sign = pnl >= 0 ? '+' : '';
    return '$sign\$${pnl.toStringAsFixed(2)}';
  }

  String _formatPnLPercent(double percent) {
    final sign = percent >= 0 ? '+' : '';
    return '$sign${percent.toStringAsFixed(2)}%';
  }

  // Symbol & timeframe chips per result item
  Widget _buildSymbolTfChips(
      BuildContext context, WorkspaceViewModel model, BacktestResult result) {
    final md = locator<DataManager>().getData(result.marketDataId);
    if (md == null) return const SizedBox.shrink();

    final symbol = md.symbol;
    final tf = md.timeframe;

    final bgColor =
        Theme.of(context).colorScheme.primary.withValues(alpha: 0.12);
    final fgColor = Theme.of(context).colorScheme.primary;

    return Wrap(
      spacing: 8,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Chip(
          label: Text(symbol),
          avatar: Icon(Icons.show_chart, size: 14, color: fgColor),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: bgColor,
          labelStyle: TextStyle(fontSize: 12, color: fgColor),
        ),
        Chip(
          label: Text(tf),
          avatar: Icon(Icons.schedule, size: 14, color: fgColor),
          visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          backgroundColor: bgColor,
          labelStyle: TextStyle(fontSize: 12, color: fgColor),
        ),
      ],
    );
  }

  // Compact per-timeframe stats chips for each result
  Widget _buildTfStatsPreview(
      BuildContext context, WorkspaceViewModel model, BacktestResult result) {
    final stats = result.summary.tfStats;
    if (stats == null || stats.isEmpty) return const SizedBox.shrink();

    final entries = stats.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: entries.map((e) {
        final tf = e.key;
        final m = e.value;
        final trades = (m['trades'] ?? 0).toInt();
        final wins = (m['wins'] ?? 0).toInt();
        final signals = (m['signals'] ?? 0).toInt();
        final winRate = ((m['winRate'] ?? 0)).toDouble();

        final pf = ((m['profitFactor'] ?? 0)).toDouble();
        final ex = ((m['expectancy'] ?? 0)).toDouble();
        final label =
            '$tf: ${trades}T • ${wins}W • ${winRate.toStringAsFixed(0)}% • PF ${pf.isFinite ? pf.toStringAsFixed(2) : '—'} • Ex ${ex.isFinite ? ex.toStringAsFixed(2) : '—'}';

        final isSelected = model.selectedTimeframeFilters.contains(tf);
        final tooltip =
            'TF $tf • Signals: $signals • Trades: $trades • Wins: $wins • Win Rate: ${winRate.toStringAsFixed(0)}% • PF: ${pf.isFinite ? pf.toStringAsFixed(2) : '—'} • Expectancy: ${ex.isFinite ? ex.toStringAsFixed(2) : '—'}';

        return Tooltip(
          message: tooltip,
          child: FilterChip(
            label: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color:
                    isSelected ? Theme.of(context).colorScheme.primary : null,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => model.toggleTimeframeFilter(tf),
            visualDensity: const VisualDensity(horizontal: -2, vertical: -2),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            selectedColor:
                Theme.of(context).colorScheme.primary.withValues(alpha: 0.15),
            checkmarkColor: Theme.of(context).colorScheme.primary,
            showCheckmark: true,
          ),
        );
      }).toList(),
    );
  }

  // Responsive actions for result item to avoid icon overflow on small screens
  Widget _buildResultActions(
    BuildContext context,
    WorkspaceViewModel model,
    BacktestResult result,
    bool isCompareMode,
  ) {
    return LayoutBuilder(builder: (context, constraints) {
      final isCompact = constraints.maxWidth < 400;
      if (isCompact) {
        // Compact: show View Details + overflow menu
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_right, size: 18),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints.tightFor(width: 36, height: 36),
              onPressed: () => model.viewResult(result),
              tooltip: AppLocalizations.of(context)!.viewDetails,
            ),
            SizedBox(
              width: 36,
              height: 36,
              child: PopupMenuButton<int>(
                icon: const Icon(Icons.more_horiz, size: 18),
                tooltip: AppLocalizations.of(context)!.moreLabel,
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 0,
                    child: Row(
                      children: [
                        Icon(Icons.table_chart, size: 18),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.copyTradesCsv),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 1,
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 18),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.copySummary),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 2,
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 18),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.exportCsv),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 3,
                    child: Row(
                      children: [
                        Icon(Icons.delete_outline, size: 18),
                        SizedBox(width: 8),
                        Text(AppLocalizations.of(context)!.deleteLabel),
                      ],
                    ),
                  ),
                ],
                onSelected: (value) {
                  switch (value) {
                    case 0:
                      model.copyTradesCsvToClipboard(result);
                      break;
                    case 1:
                      model.copyResultSummaryToClipboard(result);
                      break;
                    case 2:
                      model.exportResultCsv(result);
                      break;
                    case 3:
                      model.deleteResult(result);
                      break;
                  }
                },
              ),
            )
          ],
        );
      }
      // Default: use OverflowBar to wrap icons into 2 lines when needed
      return OverflowBar(
        alignment: MainAxisAlignment.end,
        overflowAlignment: OverflowBarAlignment.end,
        spacing: 2,
        overflowSpacing: 2,
        children: [
          IconButton(
            icon: const Icon(Icons.link, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () => model.copyResultLinkToClipboard(result),
            tooltip: AppLocalizations.of(context)!.copyResultLink,
          ),
          IconButton(
            icon: const Icon(Icons.table_chart, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () => model.copyTradesCsvToClipboard(result),
            tooltip: AppLocalizations.of(context)!.copyTradesCsv,
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () => model.copyResultSummaryToClipboard(result),
            tooltip: AppLocalizations.of(context)!.copySummary,
          ),
          IconButton(
            icon: const Icon(Icons.download, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () => model.exportResultCsv(result),
            tooltip: AppLocalizations.of(context)!.exportCsv,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            onPressed: () => model.viewResult(result),
            tooltip: AppLocalizations.of(context)!.viewDetails,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, size: 18),
            visualDensity: VisualDensity.compact,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints.tightFor(width: 36, height: 36),
            color: Theme.of(context).colorScheme.error,
            onPressed: () => model.deleteResult(result),
            tooltip: AppLocalizations.of(context)!.deleteLabel,
          ),
        ],
      );
    });
  }
}
