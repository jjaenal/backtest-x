import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/theme_service.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backtest-X'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              locator<ThemeService>().toggleTheme();
            },
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: const Icon(Icons.workspace_premium),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quick Stats Card
                    _buildStatsCard(context, viewModel),
                    const SizedBox(height: 24),

                    // Last Result quick summary (styled)
                    if (viewModel.lastResult != null) ...[
                      _buildLastResultCard(context, viewModel),
                      const SizedBox(height: 24),
                    ],

                    // Empty state CTA
                    if (viewModel.dataSetsCount == 0 ||
                        viewModel.strategiesCount == 0) ...[
                      _buildEmptyState(context, viewModel),
                      const SizedBox(height: 24),
                    ],

                    // Actions in responsive grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final width = constraints.maxWidth;
                        int crossAxisCount = 1;
                        if (width >= 1000) {
                          crossAxisCount = 3;
                        } else if (width >= 700) {
                          crossAxisCount = 2;
                        }
                        final actions = [
                          _buildActionButton(
                            context,
                            icon: Icons.upload_file,
                            title: 'Upload Data',
                            subtitle: 'Import historical market data',
                            onTap: viewModel.navigateToDataUpload,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.candlestick_chart,
                            title: 'Pattern Scanner',
                            subtitle: 'Detect candlestick patterns',
                            onTap: viewModel.navigateToPatternScanner,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.psychology,
                            title: 'Create Strategy',
                            subtitle: 'Build your trading strategy',
                            onTap: viewModel.navigateToStrategyBuilder,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.show_chart_outlined,
                            title: 'Market Analysis',
                            subtitle: 'Analyze market data',
                            onTap: viewModel.navigateToMarketAnalysis,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.folder_open,
                            title: 'Workspace',
                            subtitle: 'Manage strategies',
                            onTap: viewModel.navigateToWorkspace,
                          ),
                        ];

                        return GridView.builder(
                          itemCount: actions.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            childAspectRatio: width >= 700 ? 3.5 : 2.8,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemBuilder: (context, index) => actions[index],
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // Recent Activity
                    if (viewModel.recentStrategies.isNotEmpty) ...[
                      const Text(
                        'Recent Strategies',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ListView.builder(
                        itemCount: viewModel.recentStrategies.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final strategy = viewModel.recentStrategies[index];
                          return Card(
                            child: ListTile(
                              title: Text(strategy.name),
                              subtitle: Text(
                                'Created: ${_formatDate(strategy.createdAt)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        viewModel.editStrategy(strategy.id),
                                    tooltip: 'Edit',
                                  ),
                                  InkWell(
                                    child:
                                        const Icon(Icons.play_arrow, size: 20),
                                    onTap: () => viewModel.runStrategy(
                                        strategy.id, index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Global progress overlay when running backtest
            if (viewModel.isRunningBacktest) ...[
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Container(
                    color: Colors.black.withOpacity(0.2),
                    child: const Center(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              ),
                              SizedBox(width: 12),
                              Text('Running backtest...'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatsCard(BuildContext context, HomeViewModel viewModel) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  context,
                  'Strategies',
                  '${viewModel.strategiesCount}',
                  Icons.psychology,
                ),
                _buildStatItem(
                  context,
                  'Data Sets',
                  '${viewModel.dataSetsCount}',
                  Icons.storage,
                ),
                _buildStatItem(
                  context,
                  'Tests Run',
                  '${viewModel.testsCount}',
                  Icons.speed,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastResultCard(BuildContext context, HomeViewModel viewModel) {
    final result = viewModel.lastResult!;
    final summary = result.summary;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.25),
                    ),
                  ),
                  child: Icon(
                    Icons.analytics_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Last Result',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        [
                          viewModel.lastResultStrategyLabel,
                          if (viewModel.lastResultSymbol != null &&
                              viewModel.lastResultTimeframe != null)
                            '${viewModel.lastResultSymbol} · ${viewModel.lastResultTimeframe}',
                        ].where((e) => (e).isNotEmpty).join(' • '),
                        style: TextStyle(
                          fontSize: 13,
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatDate(result.executedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Metrics chips
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 700;
                final children = [
                  _buildMetricChip(
                    context,
                    icon: Icons.swap_vert,
                    label: 'Trades',
                    value: '${summary.totalTrades}',
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.percent,
                    label: 'Win Rate',
                    value: '${summary.winRate.toStringAsFixed(2)}%',
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.attach_money,
                    label: 'PnL',
                    value: '\$${summary.totalPnl.toStringAsFixed(2)}',
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.insights,
                    label: 'Profit Factor',
                    value: summary.profitFactor.toStringAsFixed(2),
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.trending_down,
                    label: 'Max Drawdown',
                    value:
                        '${summary.maxDrawdownPercentage.toStringAsFixed(2)}%',
                  ),
                ];

                if (isWide) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: children,
                  );
                }
                return Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: children,
                );
              },
            ),

            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: viewModel.viewLastResult,
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('View Details'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceVariant
            .withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              size: 18,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.7,
                  )),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, HomeViewModel viewModel) {
    final noData = viewModel.dataSetsCount == 0;
    final noStrategy = viewModel.strategiesCount == 0;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Getting Started',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              noData && noStrategy
                  ? 'Belum ada data dan strategi. Mulai dengan upload data dan buat strategi pertama.'
                  : noData
                      ? 'Belum ada data market. Upload CSV untuk mulai backtest.'
                      : 'Belum ada strategi. Buat strategi pertama untuk memulai.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              children: [
                if (noData)
                  ElevatedButton.icon(
                    onPressed: viewModel.navigateToDataUpload,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload Data'),
                  ),
                if (noStrategy)
                  OutlinedButton.icon(
                    onPressed: viewModel.navigateToStrategyBuilder,
                    icon: const Icon(Icons.psychology),
                    label: const Text('Create Strategy'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ) ??
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withValues(alpha: 0.7),
                  ) ??
              const TextStyle(fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool enabled = true,
  }) {
    return Card(
      elevation: enabled ? 2 : 0,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: enabled
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.12)
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: enabled
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: enabled
                            ? Theme.of(context).textTheme.titleMedium?.color
                            : Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: (Theme.of(context).textTheme.bodySmall?.color ??
                                Theme.of(context).colorScheme.onSurface)
                            .withValues(alpha: enabled ? 0.7 : 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: enabled ? 0.6 : 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.initialize();
}
