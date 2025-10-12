import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'candlestick_pattern_guide_sheet_model.dart';
import 'package:backtestx/l10n/app_localizations.dart';

class CandlestickPatternGuideSheet
    extends StackedView<CandlestickPatternGuideSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const CandlestickPatternGuideSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    CandlestickPatternGuideSheetModel viewModel,
    Widget? child,
  ) {
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.candlestick_chart,
                    size: 24, color: Theme.of(context).colorScheme.primary),
                Text(
                  l10n.psPatternsGuideTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPatternGuideItem(
              context,
              l10n.cpHammerTitle,
              l10n.cpHammerDesc,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              context,
              l10n.cpShootingStarTitle,
              l10n.cpShootingStarDesc,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              context,
              l10n.cpDojiTitle,
              l10n.cpDojiDesc,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              context,
              l10n.cpMarubozuTitle,
              l10n.cpMarubozuDesc,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              context,
              l10n.psPatternSpinningTop,
              l10n.psDescSpinningTop,
              Colors.purple,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternGuideItem(
      BuildContext context, String title, String description, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.8),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  @override
  CandlestickPatternGuideSheetModel viewModelBuilder(BuildContext context) =>
      CandlestickPatternGuideSheetModel();
}
