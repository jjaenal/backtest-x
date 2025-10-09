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
                    onPressed: () {
                      completer?.call(SheetResponse(confirmed: true));
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
