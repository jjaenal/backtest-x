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
      backgroundColor: Theme.of(context).colorScheme.background,
      body: Container(
        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
        child: const Center(child: Text("StrategyBuilderView")),
      ),
    );
  }

  @override
  StrategyBuilderViewModel viewModelBuilder(
    BuildContext context,
  ) =>
      StrategyBuilderViewModel();
}
