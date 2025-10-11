import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/helpers/strategy_templates.dart';
import 'quick_start_templates_sheet_model.dart';

class QuickStartTemplatesSheet
    extends StackedView<QuickStartTemplatesSheetModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;
  const QuickStartTemplatesSheet(
      {Key? key, required this.completer, required this.request})
      : super(key: key);

  @override
  Widget builder(BuildContext context, QuickStartTemplatesSheetModel viewModel,
      Widget? child) {
    final curatedKeys = [
      'mean_reversion_rsi',
      'trend_ema_cross',
      'anchored_vwap_pullback_cross',
    ];
    final entries = curatedKeys
        .map((k) => StrategyTemplates.all[k] != null
            ? MapEntry(k, StrategyTemplates.all[k]!)
            : null)
        .whereType<MapEntry<String, StrategyTemplate>>()
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bolt, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Quick‑Start Templates',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Mulai cepat dengan template terkurasi. Setelah memilih, buka Strategy Builder untuk meninjau dan menjalankan preview.',
            style: TextStyle(
                color:
                    Theme.of(context).colorScheme.onSurface.withOpacity(0.75)),
          ),
          const SizedBox(height: 12),
          ...entries.map((e) {
            final tpl = e.value;
            final selected = viewModel.selectedKey == e.key;
            return Card(
              elevation: selected ? 3 : 1,
              child: InkWell(
                onTap: () => viewModel.select(e.key),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              tpl.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                          ),
                          if (selected)
                            Icon(Icons.check_circle,
                                color: Theme.of(context).colorScheme.secondary),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(tpl.description,
                          style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () {
                            // Pilih template lalu kembalikan ke Onboarding untuk meng-handle navigasi
                            viewModel.select(e.key);
                            completer?.call(
                              SheetResponse(confirmed: true, data: e.key),
                            );
                          },
                          icon: const Icon(Icons.psychology),
                          label: const Text('Buka di Builder'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => completer?.call(SheetResponse(confirmed: false)),
              child: const Text('Tutup'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  QuickStartTemplatesSheetModel viewModelBuilder(BuildContext context) =>
      QuickStartTemplatesSheetModel();
}
