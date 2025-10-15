import 'package:flutter/material.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'strategy_builder_viewmodel.dart';
import 'rule_card_builder.dart';
import 'strategy_builder_constants.dart';

class EntryRulesCard extends StatelessWidget {
  final StrategyBuilderViewModel viewModel;
  const EntryRulesCard({Key? key, required this.viewModel}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(StrategyBuilderConstants.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.sbEntryRulesHeader,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add_circle),
                      onPressed: viewModel.addEntryRule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: StrategyBuilderConstants.smallSpacing),
            if (viewModel.appliedTemplateDescription != null)
              Container(
                margin: const EdgeInsets.only(
                    bottom: StrategyBuilderConstants.smallSpacing),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                    const SizedBox(
                        width: StrategyBuilderConstants.smallSpacing),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (viewModel.appliedTemplateName != null)
                            Text(
                              viewModel.appliedTemplateName!,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSecondaryContainer,
                                  ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            viewModel.appliedTemplateDescription!,
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSecondaryContainer
                                          .withValues(alpha: 0.9),
                                    ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            if (viewModel.entryRules.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.add_box,
                        size: 48,
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.sbNoEntryRulesYet,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.sbTapToAddRule,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...viewModel.entryRules.asMap().entries.map((entry) {
                return RuleCardBuilder.build(
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
    );
  }
}
