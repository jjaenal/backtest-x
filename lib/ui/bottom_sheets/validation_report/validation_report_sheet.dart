import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'validation_report_sheet_model.dart';

class ValidationReportSheet extends StackedView<ValidationReportSheetModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;
  const ValidationReportSheet({Key? key, required this.completer, required this.request})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    ValidationReportSheetModel viewModel,
    Widget? child,
  ) {
    final payload = request.data as Map<String, dynamic>? ?? {};
    final errors = (payload['errors'] as List?)?.cast<String>() ?? const [];
    final warningsIssues = (payload['warningsIssues'] as List?)?.cast<String>() ?? const [];
    final warningsText = (payload['warningsText'] as List?)?.cast<String>() ?? const [];

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  request.title ?? 'Data Validation Report',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              request.description ?? '',
              style: TextStyle(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 16),

            if (errors.isNotEmpty) ...[
              Text(
                'Errors (${errors.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade600,
                ),
              ),
              const SizedBox(height: 8),
              ...errors.map((msg) => _buildItem(context, msg, Colors.red.shade600)).toList(),
              const SizedBox(height: 16),
            ],

            if (warningsIssues.isNotEmpty || warningsText.isNotEmpty) ...[
              Text(
                'Warnings (${warningsIssues.length + warningsText.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange.shade700,
                ),
              ),
              const SizedBox(height: 8),
              ...warningsIssues
                  .map((msg) => _buildItem(context, msg, Colors.orange.shade700))
                  .toList(),
              ...warningsText
                  .map((msg) => _buildItem(context, msg, Colors.orange.shade700))
                  .toList(),
              const SizedBox(height: 16),
            ],

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      final textBuffer = StringBuffer();
                      textBuffer.writeln(request.title ?? 'Data Validation Report');
                      textBuffer.writeln(request.description ?? '');
                      if (errors.isNotEmpty) {
                        textBuffer.writeln('\nErrors:');
                        for (final e in errors) {
                          textBuffer.writeln('• $e');
                        }
                      }
                      final totalWarnings = warningsIssues.length + warningsText.length;
                      if (totalWarnings > 0) {
                        textBuffer.writeln('\nWarnings:');
                        for (final w in warningsIssues) {
                          textBuffer.writeln('• $w');
                        }
                        for (final w in warningsText) {
                          textBuffer.writeln('• $w');
                        }
                      }
                      Clipboard.setData(ClipboardData(text: textBuffer.toString()));
                    },
                    icon: const Icon(Icons.copy, size: 18),
                    label: const Text('Copy report'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String msg, Color color) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              msg,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.9),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  ValidationReportSheetModel viewModelBuilder(BuildContext context) =>
      ValidationReportSheetModel();
}