import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/helpers/strategy_templates.dart';
import 'package:backtestx/l10n/app_localizations.dart';
import 'package:backtestx/ui/views/strategy_builder/strategy_builder_viewmodel.dart';
import 'template_picker_sheet_model.dart';

/// Bottom sheet terpisah untuk memilih dan menerapkan Strategy Template.
class TemplatePickerSheet extends StackedView<TemplatePickerSheetModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;

  const TemplatePickerSheet(
      {super.key, required this.completer, required this.request});

  String _categorizeTemplate(String key, StrategyTemplate template) {
    // Simple categorization based on template name
    if (key.contains('breakout')) return 'Breakout';
    if (key.contains('mean_reversion')) return 'Mean Reversion';
    if (key.contains('trend')) return 'Trend Following';
    if (key.contains('scalping')) return 'Scalping';
    if (key.contains('swing')) return 'Swing Trading';
    return 'Other';
  }

  @override
  Widget builder(
      BuildContext context, TemplatePickerSheetModel viewModel, Widget? child) {
    // Get StrategyBuilderViewModel from request data
    final strategyBuilderViewModel = request.data as StrategyBuilderViewModel?;
    if (strategyBuilderViewModel != null) {
      viewModel.initialize(strategyBuilderViewModel);
    }

    final l10n = AppLocalizations.of(context)!;
    final entries = StrategyTemplates.all.entries.toList();
    final localized = StrategyTemplates.localized(l10n);

    // Stabilize sheet height to avoid jumpy resize during search
    final sheetHeight = MediaQuery.of(context).size.height * 0.85;
    final query = viewModel.selectedTemplateQuery;
    final selectedCats = viewModel.selectedTemplateCategories;

    final filtered = query.isEmpty
        ? entries
        : entries.where((e) {
            final tpl = localized[e.key] ?? e.value;
            final name = tpl.name.toLowerCase();
            final desc = tpl.description.toLowerCase();
            final q = query.toLowerCase();
            return name.contains(q) || desc.contains(q);
          }).toList();

    final filteredByCat = selectedCats.isEmpty
        ? filtered
        : filtered.where((e) {
            final category = _categorizeTemplate(e.key, e.value);
            return selectedCats.contains(category);
          }).toList();

    // Group by category
    final grouped = <String, List<MapEntry<String, StrategyTemplate>>>{};
    for (final entry in filteredByCat) {
      final category = _categorizeTemplate(entry.key, entry.value);
      grouped.putIfAbsent(category, () => []).add(entry);
    }

    // All categories from all templates
    final allCats = entries
        .map((e) => _categorizeTemplate(e.key, e.value))
        .toSet()
        .toList()
      ..sort();

    return Container(
      height: sheetHeight,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(Icons.auto_awesome,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                l10n.sbPickTemplateTooltip,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: viewModel.closeSheet,
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Search field
          TextField(
            onChanged: viewModel.updateTemplateQuery,
            decoration: InputDecoration(
              hintText: l10n.sbSearchTemplateHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Category filters
          if (allCats.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Categories',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                if (selectedCats.isNotEmpty)
                  TextButton(
                    onPressed: () => viewModel.updateTemplateCategories({}),
                    child: const Text('Clear Filters'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: allCats.map((cat) {
                final isSelected = selectedCats.contains(cat);
                final count = entries
                    .where((e) => _categorizeTemplate(e.key, e.value) == cat)
                    .length;
                return FilterChip(
                  label: Text('$cat ($count)'),
                  selected: isSelected,
                  onSelected: (selected) {
                    final newCats = Set<String>.from(selectedCats);
                    if (selected) {
                      newCats.add(cat);
                    } else {
                      newCats.remove(cat);
                    }
                    viewModel.updateTemplateCategories(newCats);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
          ],

          // Recently Applied section
          if (viewModel.recentTemplateKeys.isNotEmpty) ...[
            Row(
              children: [
                Text(
                  'Recently Applied',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const Spacer(),
                TextButton(
                  onPressed: viewModel.clearRecentTemplates,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 80,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: viewModel.recentTemplateKeys.length,
                itemBuilder: (context, index) {
                  final key = viewModel.recentTemplateKeys[index];
                  final tpl = localized[key] ?? StrategyTemplates.all[key];
                  if (tpl == null) return const SizedBox.shrink();

                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 8),
                    child: Card(
                      child: InkWell(
                        onTap: () => viewModel.applyTemplate(key),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tpl.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                tpl.description,
                                style: Theme.of(context).textTheme.bodySmall,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Templates list
          Expanded(
            child: grouped.isEmpty
                ? Center(
                    child: Text(
                      'No templates found',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  )
                : ListView.builder(
                    itemCount: grouped.keys.length,
                    itemBuilder: (context, index) {
                      final category = grouped.keys.elementAt(index);
                      final templates = grouped[category]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              category,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          ...templates.map((entry) {
                            final tpl = localized[entry.key] ?? entry.value;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                title: _buildHighlightedText(
                                    tpl.name, query, context),
                                subtitle: _buildHighlightedText(
                                    tpl.description, query, context),
                                trailing: ElevatedButton(
                                  onPressed: () =>
                                      viewModel.applyTemplate(entry.key),
                                  child: const Text('Apply'),
                                ),
                                onTap: () => viewModel.applyTemplate(entry.key),
                              ),
                            );
                          }).toList(),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedText(
      String text, String query, BuildContext context) {
    if (query.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final lowerQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;

    while (true) {
      final index = lowerText.indexOf(lowerQuery, start);
      if (index == -1) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }

      if (index > start) {
        spans.add(TextSpan(text: text.substring(start, index)));
      }

      spans.add(TextSpan(
        text: text.substring(index, index + query.length),
        style: TextStyle(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
          fontWeight: FontWeight.bold,
        ),
      ));

      start = index + query.length;
    }

    return RichText(
        text: TextSpan(
            children: spans, style: DefaultTextStyle.of(context).style));
  }

  @override
  TemplatePickerSheetModel viewModelBuilder(BuildContext context) =>
      TemplatePickerSheetModel();
}
