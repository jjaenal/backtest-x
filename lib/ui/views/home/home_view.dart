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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Quick Stats Card
                _buildStatsCard(context, viewModel),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButton(
                  context,
                  icon: Icons.upload_file,
                  title: 'Upload Data',
                  subtitle: 'Import historical market data',
                  onTap: viewModel.navigateToDataUpload,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  icon: Icons.candlestick_chart,
                  title: 'Pattern Scanner',
                  subtitle: 'Detect candlestick patterns',
                  onTap: viewModel.navigateToPatternScanner,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  icon: Icons.psychology,
                  title: 'Create Strategy',
                  subtitle: 'Build your trading strategy',
                  onTap: viewModel.navigateToStrategyBuilder,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  icon: Icons.show_chart_outlined,
                  title: 'Market Analysis',
                  subtitle: 'Analyze market data',
                  onTap: viewModel.navigateToMarketAnalysis,
                ),
                const SizedBox(height: 16),
                _buildActionButton(
                  context,
                  icon: Icons.folder_open,
                  title: 'Workspace',
                  subtitle: 'Manage strategies',
                  onTap: viewModel.navigateToWorkspace,
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
                              if (viewModel.isRunningBacktest &&
                                  index == viewModel.strategiesIndex) ...[
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.grey,
                                    strokeWidth: 3,
                                  ),
                                ),
                              ] else ...[
                                InkWell(
                                  child: const Icon(Icons.play_arrow, size: 20),
                                  onTap: () =>
                                      viewModel.runStrategy(strategy.id, index),
                                ),
                              ],
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
