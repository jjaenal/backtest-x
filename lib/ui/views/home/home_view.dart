import 'package:backtestx/ui/widgets/error_banner.dart';
import 'package:flutter/material.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/services/theme_service.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/app/route_observer.dart';
import 'package:intl/intl.dart';
import 'home_viewmodel.dart';

class HomeView extends StackedView<HomeViewModel> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    HomeViewModel viewModel,
    Widget? child,
  ) {
    // Subscribe to RouteObserver to detect navigation back
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!viewModel.routeAwareSubscribed) {
        final route = ModalRoute.of(context);
        if (route != null) {
          appRouteObserver.subscribe(viewModel, route);
          viewModel.markRouteAwareSubscribed();
        }
      }
    });
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.homeTitle ?? 'Backtest‑X'),
        centerTitle: true,
        actions: [
          // Cache status indicator
          // IconButton(
          //   tooltip: viewModel.isWarmingUp
          //       ? (AppLocalizations.of(context)?.homeCacheWarming ??
          //           'Cache: warming up')
          //       : (viewModel.dataSetsCount > 0
          //           ? (AppLocalizations.of(context)?.homeCacheReady ??
          //               'Cache: ready')
          //           : (AppLocalizations.of(context)?.homeCacheEmpty ??
          //               'Cache: empty')),
          //   icon: Icon(
          //     viewModel.isWarmingUp
          //         ? Icons.downloading
          //         : (viewModel.dataSetsCount > 0
          //             ? Icons.offline_pin
          //             : Icons.cloud_off),
          //     color: viewModel.isWarmingUp
          //         ? Colors.orange
          //         : (viewModel.dataSetsCount > 0 ? Colors.green : null),
          //   ),
          //   onPressed: viewModel.showCacheInfo,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.help_outline),
          //   tooltip: AppLocalizations.of(context)?.homeTooltipOnboarding ??
          //       'Onboarding',
          //   onPressed: viewModel.showOnboarding,
          // ),
          // IconButton(
          //   icon: const Icon(Icons.brightness_6),
          //   onPressed: () {
          //     locator<ThemeService>().toggleTheme();
          //   },
          //   tooltip: 'Toggle Theme',
          // ),
          // IconButton(
          //   icon: const Icon(Icons.workspace_premium),
          //   onPressed: () {},
          // ),
          PopupMenuButton<int>(
            tooltip:
                AppLocalizations.of(context)?.homeTooltipOptions ?? 'Options',
            onSelected: (value) {
              switch (value) {
                case 1:
                  viewModel.toggleBackgroundWarmup();
                  break;
                case 2:
                  viewModel.warmUpCacheNow();
                  break;
                case 100:
                  locator<ThemeService>().setLocaleCode(null);
                  break;
                case 101:
                  locator<ThemeService>().setLocaleCode('en');
                  break;
                case 102:
                  locator<ThemeService>().setLocaleCode('id');
                  break;
                case 103:
                  viewModel.showOnboarding();
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem<int>(
                value: 1,
                child: Row(
                  children: [
                    Icon(
                      viewModel.backgroundWarmupEnabled
                          ? Icons.pause_circle_outline
                          : Icons.play_circle_outline,
                    ),
                    const SizedBox(width: 8),
                    Text(viewModel.backgroundWarmupEnabled
                        ? (AppLocalizations.of(context)?.homeOptionPauseBg ??
                            'Pause Background Loading')
                        : (AppLocalizations.of(context)?.homeOptionEnableBg ??
                            'Enable Background Loading')),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 2,
                child: Row(
                  children: [
                    Icon(Icons.download_for_offline_outlined),
                    SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.homeOptionLoadCache ??
                        'Load Cache Now'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 100,
                child: Row(
                  children: [
                    const Icon(Icons.language),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.languageMenuSystem ??
                        'Use System Language'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 101,
                child: Row(
                  children: [
                    const Icon(Icons.translate),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.languageMenuEnglish ??
                        'English'),
                  ],
                ),
              ),
              PopupMenuItem<int>(
                value: 102,
                child: Row(
                  children: [
                    const Icon(Icons.translate),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.languageMenuIndonesian ??
                        'Indonesian'),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<int>(
                value: 103,
                child: Row(
                  children: [
                    const Icon(Icons.help_outline),
                    const SizedBox(width: 8),
                    Text(AppLocalizations.of(context)?.homeHelpOptions ??
                        'Help'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            // Error banner surface
            if (viewModel.uiErrorMessage != null)
              Positioned(
                left: 16,
                right: 16,
                top: 8,
                child: ErrorBanner(
                  message: viewModel.uiErrorMessage!,
                  onRetry: viewModel.refresh,
                  onClose: viewModel.clearUiError,
                ),
              ),
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
                            title: AppLocalizations.of(context)
                                    ?.homeActionUploadTitle ??
                                'Upload Data',
                            subtitle: AppLocalizations.of(context)
                                    ?.homeActionUploadSubtitle ??
                                'Import historical market data',
                            onTap: viewModel.navigateToDataUpload,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.candlestick_chart,
                            title: AppLocalizations.of(context)
                                    ?.homeActionScannerTitle ??
                                'Pattern Scanner',
                            subtitle: AppLocalizations.of(context)
                                    ?.homeActionScannerSubtitle ??
                                'Detect candlestick patterns',
                            onTap: viewModel.navigateToPatternScanner,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.psychology,
                            title: AppLocalizations.of(context)
                                    ?.homeActionStrategyTitle ??
                                'Create Strategy',
                            subtitle: AppLocalizations.of(context)
                                    ?.homeActionStrategySubtitle ??
                                'Build your trading strategy',
                            onTap: viewModel.navigateToStrategyBuilder,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.show_chart_outlined,
                            title: AppLocalizations.of(context)
                                    ?.homeActionAnalysisTitle ??
                                'Market Analysis',
                            subtitle: AppLocalizations.of(context)
                                    ?.homeActionAnalysisSubtitle ??
                                'Analyze market data',
                            onTap: viewModel.navigateToMarketAnalysis,
                          ),
                          _buildActionButton(
                            context,
                            icon: Icons.folder_open,
                            title: AppLocalizations.of(context)
                                    ?.homeActionWorkspaceTitle ??
                                'Workspace',
                            subtitle: AppLocalizations.of(context)
                                    ?.homeActionWorkspaceSubtitle ??
                                'Manage strategies',
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
                      Text(
                        AppLocalizations.of(context)?.homeRecentStrategies ??
                            'Recent Strategies',
                        style: const TextStyle(
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
                                AppLocalizations.of(context)?.createdLabel(
                                        _formatDate(
                                            context, strategy.createdAt)) ??
                                    'Created: ${_formatDate(context, strategy.createdAt)}',
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, size: 20),
                                    onPressed: () =>
                                        viewModel.editStrategy(strategy.id),
                                    tooltip: AppLocalizations.of(context)
                                            ?.editLabel ??
                                        'Edit',
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

            // Warm-up indicator banner
            if (viewModel.isWarmingUp) ...[
              Positioned(
                left: 16,
                bottom: 16,
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          AppLocalizations.of(context)?.homeLoadingCache ??
                              'Loading cache…',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],

            // Global progress overlay when running backtest
            if (viewModel.isRunningBacktest) ...[
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.2),
                    child: Center(
                      child: Card(
                        elevation: 4,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(),
                              ),
                              const SizedBox(width: 12),
                              Text(AppLocalizations.of(context)
                                      ?.homeRunningBacktest ??
                                  'Running backtest...'),
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
                  AppLocalizations.of(context)?.statsStrategies ?? 'Strategies',
                  '${viewModel.strategiesCount}',
                  Icons.psychology,
                  isLoading: viewModel.isBusy,
                ),
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)?.statsDataSets ?? 'Data Sets',
                  '${viewModel.dataSetsCount}',
                  Icons.storage,
                  isLoading: viewModel.isBusy,
                ),
                _buildStatItem(
                  context,
                  AppLocalizations.of(context)?.statsTestsRun ?? 'Tests Run',
                  '${viewModel.testsCount}',
                  Icons.speed,
                  isLoading: viewModel.isBusy,
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
                      Text(
                        AppLocalizations.of(context)?.lastResultHeader ??
                            'Last Result',
                        style: const TextStyle(
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
                  _formatDate(context, result.executedAt),
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
                    label:
                        AppLocalizations.of(context)?.metricsTrades ?? 'Trades',
                    value: '${summary.totalTrades}',
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.percent,
                    label: AppLocalizations.of(context)?.metricsWinRate ??
                        'Win Rate',
                    value: '${summary.winRate.toStringAsFixed(2)}%',
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.attach_money,
                    label: AppLocalizations.of(context)?.metricsPnl ?? 'PnL',
                    value: '\$${summary.totalPnl.toStringAsFixed(2)}',
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.insights,
                    label: AppLocalizations.of(context)?.metricsProfitFactor ??
                        'Profit Factor',
                    value: summary.profitFactor.toStringAsFixed(2),
                  ),
                  _buildMetricChip(
                    context,
                    icon: Icons.trending_down,
                    label: AppLocalizations.of(context)?.metricsMaxDrawdown ??
                        'Max Drawdown',
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
                  label: Text(AppLocalizations.of(context)?.viewDetails ??
                      'View Details'),
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
              AppLocalizations.of(context)?.gettingStartedTitle ??
                  'Getting Started',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              noData && noStrategy
                  ? (AppLocalizations.of(context)?.emptyBoth ??
                      'No data and strategies yet. Upload data and create your first strategy.')
                  : noData
                      ? (AppLocalizations.of(context)?.emptyNoData ??
                          'No market data yet. Upload CSV to start backtesting.')
                      : (AppLocalizations.of(context)?.emptyNoStrategy ??
                          'No strategies yet. Create your first strategy to get started.'),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (noData)
                  ElevatedButton.icon(
                    onPressed: viewModel.navigateToDataUpload,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                        AppLocalizations.of(context)?.homeActionUploadTitle ??
                            'Upload Data'),
                  ),
                if (noStrategy)
                  OutlinedButton.icon(
                    onPressed: viewModel.navigateToStrategyBuilder,
                    icon: const Icon(Icons.psychology),
                    label: Text(
                        AppLocalizations.of(context)?.homeActionStrategyTitle ??
                            'Create Strategy'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
      BuildContext context, String label, String value, IconData icon,
      {bool isLoading = false}) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: isLoading
              ? Container(
                  key: const ValueKey('loading'),
                  width: 48,
                  height: 20,
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .surfaceVariant
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                )
              : Text(
                  value,
                  key: const ValueKey('value'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ) ??
                      const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                ),
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

  String _formatDate(BuildContext context, DateTime date) {
    final locale = Localizations.localeOf(context).toString();
    return DateFormat.yMMMd(locale).format(date);
  }

  @override
  HomeViewModel viewModelBuilder(BuildContext context) => HomeViewModel();

  @override
  void onViewModelReady(HomeViewModel viewModel) => viewModel.initialize();
}
