import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'strategy_builder_viewmodel.dart';

class StrategyBuilderView extends StackedView<StrategyBuilderViewModel> {
  const StrategyBuilderView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    StrategyBuilderViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Strategy Builder'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.construction,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Strategy Builder',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon!',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  @override
  StrategyBuilderViewModel viewModelBuilder(BuildContext context) =>
      StrategyBuilderViewModel();
}
