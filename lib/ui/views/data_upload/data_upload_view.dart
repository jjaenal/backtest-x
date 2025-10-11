import 'package:flutter/material.dart';
import 'package:backtestx/ui/widgets/error_banner.dart';
import 'package:backtestx/ui/widgets/common/empty_state.dart';
import 'package:stacked/stacked.dart';
import 'data_upload_viewmodel.dart';

class DataUploadView extends StackedView<DataUploadViewModel> {
  const DataUploadView({Key? key}) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    DataUploadViewModel viewModel,
    Widget? child,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upload Market Data'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Coach Marks: Timeframe impact banner
              Card(
                color: Theme.of(context)
                    .colorScheme
                    .primaryContainer
                    .withOpacity(0.12),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Coach Marks — Timeframe Impact',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Timeframe mempengaruhi indikator (EMA/RSI/VWAP, dll). Data 1H vs 4H dapat menghasilkan sinyal berbeda. Gunakan timeframe yang konsisten.',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 8),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton(
                                onPressed: viewModel.showTimeframeCoach,
                                child: const Text('Pelajari timeframe'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // File Upload Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 64,
                        color: Colors.blue.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        viewModel.selectedFileName ?? 'No file selected',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'CSV format: Date, Open, High, Low, Close, Volume',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: viewModel.isBusy ? null : viewModel.pickFile,
                        icon: const Icon(Icons.file_open),
                        label: const Text('Select CSV File'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Parser Error Info
              if (viewModel.parserErrorMessage != null) ...[
                ErrorBanner(
                  message: viewModel.parserErrorMessage!,
                  onRetry: () {
                    if (viewModel.canUpload && !viewModel.isBusy) {
                      viewModel.uploadData();
                    } else {
                      viewModel.pickFile();
                    }
                  },
                  onClose: () {
                    // Clear by resetting message and notifying
                    viewModel.parserErrorMessage = null;
                    viewModel.notifyListeners();
                  },
                ),
              ],

              // Symbol & Timeframe Input
              if (viewModel.selectedFileName != null) ...[
                TextField(
                  controller: viewModel.symbolController,
                  decoration: const InputDecoration(
                    labelText: 'Symbol',
                    hintText: 'e.g. EURUSD, BTCUSDT',
                    prefixIcon: Icon(Icons.trending_up),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: viewModel.selectedTimeframe,
                  decoration: const InputDecoration(
                    labelText: 'Timeframe',
                    prefixIcon: Icon(Icons.schedule),
                  ),
                  items: viewModel.timeframes.map((tf) {
                    return DropdownMenuItem(
                      value: tf,
                      child: Text(tf),
                    );
                  }).toList(),
                  onChanged: viewModel.setTimeframe,
                ),
                const SizedBox(height: 24),

                // Upload Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: viewModel.canUpload && !viewModel.isBusy
                        ? viewModel.uploadData
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                    child: viewModel.isBusy
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Upload & Process',
                            style: TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Validation Info
              if (viewModel.validationResult != null) ...[
                Card(
                  color: viewModel.validationResult!.isValid
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              viewModel.validationResult!.isValid
                                  ? Icons.check_circle
                                  : Icons.error,
                              color: viewModel.validationResult!.isValid
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              viewModel.validationResult!.isValid
                                  ? 'Validation Passed'
                                  : 'Validation Failed',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (viewModel.validationResult!.totalCandles !=
                            null) ...[
                          const SizedBox(height: 8),
                          Text(
                              'Total Candles: ${viewModel.validationResult!.totalCandles}'),
                        ],
                        if (viewModel.validationResult!.errors.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          const Text(
                            'Errors:',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          ...viewModel.validationResult!.errors.map(
                            (error) => Padding(
                              padding: const EdgeInsets.only(left: 8, top: 4),
                              child: Text('• $error'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Recent Uploads List
              if (viewModel.recentUploads.isNotEmpty) ...[
                const Text(
                  'Recent Uploads',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewModel.recentUploads.length,
                    itemBuilder: (context, index) {
                      final data = viewModel.recentUploads[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.dataset),
                          title: Text('${data.symbol} - ${data.timeframe}'),
                          subtitle: Text(
                            '${data.candlesCount} candles • ${_formatDate(data.uploadedAt)}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () =>
                                viewModel.deleteMarketData(data.id),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ] else ...[
                const SizedBox(height: 12),
                Expanded(
                  child: EmptyState(
                    icon: Icons.cloud_upload_outlined,
                    title: 'Belum ada upload data',
                    message:
                        'Pilih file CSV dan isi simbol untuk mengunggah market data.',
                    primaryLabel: 'Pilih File CSV',
                    onPrimary: viewModel.isBusy ? null : viewModel.pickFile,
                  ),
                ),
              ],
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
  DataUploadViewModel viewModelBuilder(BuildContext context) =>
      DataUploadViewModel();

  @override
  void onViewModelReady(DataUploadViewModel viewModel) =>
      viewModel.initialize();
}
