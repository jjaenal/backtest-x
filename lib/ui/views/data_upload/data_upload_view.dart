import 'package:flutter/material.dart';
import 'package:backtestx/ui/widgets/error_banner.dart';
import 'package:backtestx/ui/widgets/common/empty_state.dart';
import 'package:stacked/stacked.dart';
import 'package:backtestx/l10n/app_localizations.dart';
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
        title: Text(AppLocalizations.of(context)!.dataUploadTitle),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
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
                                AppLocalizations.of(context)!
                                    .coachTimeframeHeader,
                                style:
                                    Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                AppLocalizations.of(context)!
                                    .coachTimeframeBody,
                                style: const TextStyle(fontSize: 12),
                              ),
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton(
                                  onPressed: viewModel.showTimeframeCoach,
                                  child: Text(AppLocalizations.of(context)!
                                      .coachTimeframeLearn),
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
                          viewModel.selectedFileName ??
                              AppLocalizations.of(context)!
                                  .uploadNoFileSelected,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!
                              .uploadCsvFormatHint,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              viewModel.isBusy ? null : viewModel.pickFile,
                          icon: const Icon(Icons.file_open),
                          label: Text(AppLocalizations.of(context)!
                              .uploadSelectCsvFile),
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
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.inputSymbolLabel,
                      hintText:
                          AppLocalizations.of(context)!.inputSymbolHint,
                      prefixIcon: const Icon(Icons.trending_up),
                    ),
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: viewModel.selectedTimeframe,
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)!.inputTimeframeLabel,
                      prefixIcon: const Icon(Icons.schedule),
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
                          : Text(
                              AppLocalizations.of(context)!
                                  .uploadActionProcess,
                              style: const TextStyle(fontSize: 16),
                            ),
                    ),
                  ),
                ],

                if (viewModel.selectedFileName != null)
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
                                    ? AppLocalizations.of(context)!
                                        .validationPassed
                                    : AppLocalizations.of(context)!
                                        .validationFailed,
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
                            Text(AppLocalizations.of(context)!
                                .validationTotalCandles(viewModel
                                    .validationResult!.totalCandles!)),
                          ],
                          if (viewModel
                              .validationResult!.errors.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              AppLocalizations.of(context)!
                                  .validationErrorsLabel,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
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
                  Text(
                    AppLocalizations.of(context)!.recentUploads,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ListView.builder(
                    itemCount: viewModel.recentUploads.length,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      final data = viewModel.recentUploads[index];
                      return Card(
                        child: ListTile(
                          leading: const Icon(Icons.dataset),
                          title: Text('${data.symbol} - ${data.timeframe}'),
                          subtitle: Text(
                            '${AppLocalizations.of(context)!.candlesCountLabel(data.candlesCount)} • ${_formatDate(data.uploadedAt)}',
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
                ] else ...[
                  const SizedBox(height: 12),
                  // Quick action: activate bundled sample data on demand
                  Card(
                    color: Theme.of(context)
                        .colorScheme
                        .secondaryContainer
                        .withOpacity(0.12),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppLocalizations.of(context)!.noMarketDataInfo,
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ElevatedButton.icon(
                              onPressed: viewModel.isBusy
                                  ? null
                                  : viewModel.activateSampleData,
                              icon: const Icon(Icons.play_circle_outline),
                              label: Text(AppLocalizations.of(context)!
                                  .activateSampleDataLabel('EURUSD H1')),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  EmptyState(
                    icon: Icons.cloud_upload_outlined,
                    title: AppLocalizations.of(context)!.emptyNoUploads,
                    message: AppLocalizations.of(context)!.emptyUploadMessage,
                    primaryLabel:
                        AppLocalizations.of(context)!.uploadSelectCsvFile,
                    onPrimary: viewModel.isBusy ? null : viewModel.pickFile,
                  ),
                ],
              ],
            ),
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
