import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import 'candlestick_pattern_guide_sheet_model.dart';

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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(10),
          topRight: Radius.circular(10),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Wrap(
              spacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Icon(Icons.candlestick_chart, size: 24, color: Colors.blue),
                Text(
                  'Candlestick Patterns Guide',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildPatternGuideItem(
              'Hammer',
              'Bullish reversal pattern with long lower wick and small body at top. '
                  'Forms at bottom of downtrend.',
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              'Shooting Star',
              'Bearish reversal pattern with long upper wick and small body at bottom. '
                  'Forms at top of uptrend.',
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              'Doji',
              'Indecision pattern where open and close are nearly equal. '
                  'Indicates potential reversal or continuation.',
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              'Marubozu',
              'Strong momentum pattern with little to no wicks. '
                  'Indicates continuation of current trend.',
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildPatternGuideItem(
              'Spinning Top',
              'Indecision pattern with small body and long wicks. '
                  'Indicates uncertainty in market direction.',
              Colors.purple,
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPatternGuideItem(String title, String description, Color color) {
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
              color: Colors.grey[700],
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
