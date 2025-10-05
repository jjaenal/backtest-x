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
            icon: const Icon(Icons.workspace_premium),
            onPressed: viewModel.navigateToWorkspace,
          ),
        ],
      ),
      body: viewModel.isBusy
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Quick Stats Card
                      _buildStatsCard(viewModel),
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
                        icon: Icons.psychology,
                        title: 'Create Strategy',
                        subtitle: 'Build your trading strategy',
                        onTap: viewModel.navigateToStrategyBuilder,
                      ),
                      const SizedBox(height: 16),
                      _buildActionButton(
                        context,
                        icon: Icons.assessment,
                        title: 'View Results',
                        subtitle: 'Analyze backtest performance',
                        onTap: viewModel.hasResults
                            ? viewModel.navigateToBacktestResult
                            : null,
                        enabled: viewModel.hasResults,
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
                                    IconButton(
                                      icon: const Icon(Icons.play_arrow,
                                          size: 20),
                                      onPressed: () =>
                                          viewModel.runStrategy(strategy.id),
                                      tooltip: 'Run',
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
            ),
    );
  }

  Widget _buildStatsCard(HomeViewModel viewModel) {
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
                  'Strategies',
                  '${viewModel.strategiesCount}',
                  Icons.psychology,
                ),
                _buildStatItem(
                  'Data Sets',
                  '${viewModel.dataSetsCount}',
                  Icons.storage,
                ),
                _buildStatItem(
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

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
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
                      ? Colors.blue.withOpacity(0.1)
                      : Colors.grey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 32,
                  color: enabled ? Colors.blue : Colors.grey,
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
                        color: enabled ? Colors.black : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: enabled ? Colors.grey[600] : Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: enabled ? Colors.grey : Colors.grey[300],
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
