import 'package:backtestx/helpers/strategy_stats_helper.dart';
import 'package:backtestx/models/strategy.dart';
import 'package:backtestx/models/trade.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:intl/intl.dart';
import 'workspace_viewmodel.dart';

class WorkspaceView extends StatelessWidget {
  const WorkspaceView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WorkspaceViewModel>.reactive(
      viewModelBuilder: () => WorkspaceViewModel(),
      onViewModelReady: (model) => model.initialize(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: const Text('Workspace'),
          actions: [
            // Compare mode toggle
            if (model.strategies.isNotEmpty)
              IconButton(
                icon: Icon(
                  model.isCompareMode ? Icons.close : Icons.compare_arrows,
                ),
                onPressed: model.toggleCompareMode,
                tooltip:
                    model.isCompareMode ? 'Exit Compare' : 'Compare Results',
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
            ? const Center(child: CircularProgressIndicator())
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
                label: Text('Compare (${model.selectedCount})'),
              )
            : FloatingActionButton(
                onPressed: model.navigateToCreateStrategy,
                child: const Icon(Icons.add),
              ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, WorkspaceViewModel model) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: TextField(
        onChanged: model.searchStrategies,
        decoration: InputDecoration(
          hintText: 'Search strategies...',
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
              .surfaceVariant
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
              'Select 2-4 results to compare (${model.selectedCount}/4 selected)',
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

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isEmpty ? Icons.folder_open : Icons.search_off,
            size: 80,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            isEmpty ? 'No strategies yet' : 'No strategies found',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isEmpty
                ? 'Create your first trading strategy'
                : 'Try a different search term',
            style: TextStyle(
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
          if (isEmpty) ...[
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: model.navigateToCreateStrategy,
              icon: const Icon(Icons.add),
              label: const Text('Create Strategy'),
            ),
          ],
        ],
      ),
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
                              'Created ${_formatDate(strategy.createdAt)}',
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
                          const PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, size: 20),
                                SizedBox(width: 12),
                                Text('Edit'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'duplicate',
                            child: Row(
                              children: [
                                Icon(Icons.content_copy, size: 20),
                                SizedBox(width: 12),
                                Text('Duplicate'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, size: 20, color: Colors.red),
                                SizedBox(width: 12),
                                Text('Delete',
                                    style: TextStyle(color: Colors.red)),
                              ],
                            ),
                          ),
                        ],
                        onSelected: (value) {
                          switch (value) {
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
                              hint: const Text('Select market data'),
                              onChanged: (value) {
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
                        onPressed: model.isRunningQuickTest(strategy.id)
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
                        label: const Text('Quick Test'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (hasResults) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => model.toggleExpand(strategy.id),
                          icon: Icon(
                            isExpanded ? Icons.expand_less : Icons.expand_more,
                          ),
                          tooltip: isExpanded ? 'Collapse' : 'Expand',
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
        color:
            Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.2),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color:
                Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsIndicator(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.2),
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
            'No backtest results yet',
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
            .surfaceVariant
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
              const Text(
                'Quick Test Result',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => model.viewQuickResult(strategyId),
                child: const Text('View Full Results'),
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
                  isProfitable ? Colors.green : Colors.red,
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
    final results = model.getResults(strategy.id);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceVariant
            .withValues(alpha: 0.06),
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Backtest Results (${results.length})',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
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
                        Text(
                          _formatDateTime(result.executedAt),
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Performance metrics
                    Row(
                      children: [
                        _buildResultMetric(
                          context,
                          'P&L',
                          _formatPnL(result.summary.totalPnl),
                          _formatPnLPercent(result.summary.totalPnlPercentage),
                          result.summary.totalPnl >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 16),
                        _buildResultMetric(
                          context,
                          'Win Rate',
                          '${result.summary.winRate.toStringAsFixed(1)}%',
                          '${result.summary.winningTrades}/${result.summary.totalTrades}',
                          Colors.orange,
                        ),
                        const SizedBox(width: 16),
                        _buildResultMetric(
                          context,
                          'PF',
                          result.summary.profitFactor.toStringAsFixed(2),
                          null,
                          result.summary.profitFactor > 1
                              ? Colors.green
                              : Colors.red,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action buttons (only when not in compare mode)
              if (!isCompareMode) ...[
                IconButton(
                  icon: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () => model.viewResult(result),
                  tooltip: 'View Details',
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 20),
                  color: Colors.red,
                  onPressed: () => model.deleteResult(result),
                  tooltip: 'Delete',
                ),
              ],
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} weeks ago';
    if (diff.inDays < 365) return '${(diff.inDays / 30).floor()} months ago';

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
}
