import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'indicator_settings_sheet_model.dart';

class IndicatorSettingsSheet extends StackedView<IndicatorSettingsSheetModel> {
  final Function(SheetResponse response)? completer;
  final SheetRequest request;
  const IndicatorSettingsSheet({
    Key? key,
    required this.completer,
    required this.request,
  }) : super(key: key);

  @override
  Widget builder(
    BuildContext context,
    IndicatorSettingsSheetModel viewModel,
    Widget? child,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chart Indicators',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Text('• SMA 20 (Blue line)'),
          const Text('• EMA 50 (Orange line)'),
          const Text('• Bollinger Bands (Purple)'),
          const Text('• RSI (14 period)'),
          const Text('• MACD (12, 26, 9)'),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  IndicatorSettingsSheetModel viewModelBuilder(BuildContext context) =>
      IndicatorSettingsSheetModel();
}
