import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'onboarding_sheet_model.dart';

class OnboardingSheet extends StackedView<OnboardingSheetModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;
  const OnboardingSheet(
      {Key? key, required this.completer, required this.request})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    OnboardingSheetModel viewModel,
    Widget? child,
  ) {
    // Ringkas menjadi 3 langkah inti sesuai rencana onboarding
    final steps = [
      (
        icon: Icons.upload_file,
        title: 'Pilih & Upload Data',
        desc:
            'Unggah file CSV OHLC dan pilih timeframe yang sesuai. Data akan di-cache untuk preview cepat.',
      ),
      (
        icon: Icons.psychology,
        title: 'Pilih Template / Indikator',
        desc:
            'Mulai dengan Template Quick‑Start atau pilih indikator untuk membentuk rules strategi.',
      ),
      (
        icon: Icons.play_arrow,
        title: 'Jalankan Preview',
        desc:
            'Gunakan Quick Preview untuk melihat ringkasan hasil instan sebelum menyimpan.',
      ),
    ];

    final current = steps[viewModel.step];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
              Icon(current.icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  current.title,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            current.desc,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 16),
          // Aksi langsung: Import Data, Quick‑Start Templates, dan Pelajari
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: viewModel.goToImportData,
                icon: const Icon(Icons.upload_file),
                label: const Text('Import Data'),
              ),
              OutlinedButton.icon(
                onPressed: viewModel.showQuickStartTemplates,
                icon: const Icon(Icons.bolt),
                label: const Text('Quick‑Start Templates'),
              ),
              TextButton.icon(
                onPressed: viewModel.openLearnPanel,
                icon: const Icon(Icons.school),
                label: const Text('Pelajari'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (viewModel.step == 0) ...[
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Data Onboarding',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Format CSV: Date, Open, High, Low, Close, Volume (opsional). Timeframe mempengaruhi indikator dan hasil backtest.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.8)),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        TextButton.icon(
                          onPressed: viewModel.showCsvNotice,
                          icon: const Icon(Icons.description),
                          label: const Text('Lihat Contoh CSV'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton.icon(
                          onPressed: viewModel.goToImportData,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Import Data'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (viewModel.step > 0)
                TextButton.icon(
                  onPressed: viewModel.back,
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('Kembali'),
                )
              else
                const SizedBox.shrink(),
              if (viewModel.step < steps.length - 1)
                FilledButton.icon(
                  onPressed: viewModel.next,
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('Lanjut'),
                )
              else
                FilledButton.icon(
                  onPressed: () =>
                      completer?.call(SheetResponse(confirmed: true)),
                  icon: const Icon(Icons.check),
                  label: const Text('Tandai Selesai'),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: Chip(
              label: Text('Langkah ${viewModel.step + 1} dari ${steps.length}'),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => completer?.call(SheetResponse(confirmed: false)),
              child: const Text('Nanti Saja'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  OnboardingSheetModel viewModelBuilder(BuildContext context) =>
      OnboardingSheetModel();
}
