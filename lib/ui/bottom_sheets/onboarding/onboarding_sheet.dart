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
    final steps = [
      (
        icon: Icons.upload_file,
        title: 'Upload Data Pasar',
        desc:
            'Unggah file CSV OHLC dan pilih timeframe. Data akan di-cache di memori untuk backtest cepat.',
      ),
      (
        icon: Icons.psychology,
        title: 'Buat Strategi',
        desc:
            'Rancang entry/exit rules dan parameter indikator. Simpan strategi untuk digunakan kembali.',
      ),
      (
        icon: Icons.play_arrow,
        title: 'Jalankan Backtest',
        desc:
            'Gunakan Quick Test untuk dataset terpilih atau jalankan batch untuk beberapa dataset sekaligus.',
      ),
      (
        icon: Icons.insights,
        title: 'Tinjau Hasil',
        desc:
            'Lihat metrik utama, equity curve, dan daftar trade. Ekspor CSV jika diperlukan.',
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
              color: Theme.of(context)
                  .colorScheme
                  .onSurface
                  .withValues(alpha: 0.75),
            ),
          ),
          const SizedBox(height: 16),
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
              label: Text(
                  'Langkah ${viewModel.step + 1} dari ${steps.length}'),
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
