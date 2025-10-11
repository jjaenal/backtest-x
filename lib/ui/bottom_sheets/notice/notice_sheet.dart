import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'notice_sheet_model.dart';

class NoticeSheet extends StackedView<NoticeSheetModel> {
  final Function(SheetResponse)? completer;
  final SheetRequest request;
  const NoticeSheet({Key? key, required this.completer, required this.request})
      : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    NoticeSheetModel viewModel,
    Widget? child,
  ) {
    final payload = request.data as Map<String, dynamic>? ?? {};
    final options = (payload['options'] as List?)
            ?.cast<Map>()
            .map((e) => {
                  'label': e['label']?.toString() ?? '',
                  'value': e['value']?.toString() ?? '',
                })
            .toList() ??
        const [];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline,
                  color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  request.title ?? 'Notice',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (request.description != null)
            Text(
              request.description!,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.7),
              ),
              softWrap: true,
            ),
          if (options.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              'Pilih salah satu opsi:',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: options.map((opt) {
                    final value = opt['value'] ?? '';
                    final label = opt['label'] ?? value;
                    return RadioListTile<String>(
                      value: value,
                      groupValue: viewModel.selectedValue,
                      onChanged: (v) => viewModel.setSelectedValue(v),
                      title: Text(label),
                      dense: true,
                      visualDensity: VisualDensity.compact,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          if (request.mainButtonTitle != null ||
              request.secondaryButtonTitle != null)
            Row(
              children: [
                if (request.secondaryButtonTitle != null)
                  OutlinedButton(
                    onPressed: () {
                      completer?.call(SheetResponse(confirmed: false));
                    },
                    child: Text(request.secondaryButtonTitle!),
                  ),
                const Spacer(),
                if (request.mainButtonTitle != null)
                  ElevatedButton(
                    onPressed: options.isNotEmpty &&
                            (viewModel.selectedValue == null ||
                                viewModel.selectedValue!.isEmpty)
                        ? null
                        : () {
                            completer?.call(SheetResponse(
                              confirmed: true,
                              data: options.isNotEmpty
                                  ? viewModel.selectedValue
                                  : null,
                            ));
                          },
                    child: Text(request.mainButtonTitle!),
                  ),
              ],
            ),
          if (request.mainButtonTitle == null &&
              request.secondaryButtonTitle == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).maybePop();
                },
                child: const Text('Tutup'),
              ),
            ),
        ],
      ),
    );
  }

  @override
  NoticeSheetModel viewModelBuilder(BuildContext context) => NoticeSheetModel();
}
