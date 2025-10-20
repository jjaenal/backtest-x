import 'package:flutter/material.dart';

class PerTfBarChart extends StatelessWidget {
  final Map<String, double> series; // timeframe -> value
  final String metricLabel;
  final int? maxItems; // optional cap
  final bool sortByValue;
  final bool descending;
  final bool isPercent;
  final GlobalKey? repaintKey;
  final String? overlayWatermark;

  const PerTfBarChart({
    super.key,
    required this.series,
    required this.metricLabel,
    this.maxItems,
    this.sortByValue = false,
    this.descending = false,
    this.isPercent = false,
    this.repaintKey,
    this.overlayWatermark,
  });

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    // Preserve insertion order of provided series (ViewModel already sorted)
    final entries = series.entries.toList();
    final capped = maxItems != null && entries.length > (maxItems ?? 0)
        ? entries.sublist(0, maxItems!)
        : entries;
    final maxVal = entries
        .map((e) => e.value.abs())
        .fold<double>(0.0, (p, c) => c > p ? c : p);

    final chartContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Per‑Timeframe Chart: $metricLabel',
            style: theme.textTheme.titleSmall,
          ),
        ),
        LayoutBuilder(
          builder: (context, constraints) {
            final fullWidth = constraints.maxWidth;
            return Column(
              children: capped.map((e) {
                final tf = e.key;
                final val = e.value;
                final ratio =
                    maxVal == 0 ? 0.0 : (val.abs() / maxVal).clamp(0.0, 1.0);
                final barWidth = fullWidth * ratio;
                final isNegative = val < 0;
                final color = isNegative
                    ? theme.colorScheme.error.withValues(alpha: 0.70)
                    : theme.colorScheme.primary.withValues(alpha: 0.85);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 72,
                        child: Text(
                          tf,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 18,
                              decoration: BoxDecoration(
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: theme.colorScheme.outlineVariant
                                      .withValues(alpha: 0.5),
                                ),
                              ),
                            ),
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                              height: 18,
                              width: barWidth,
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 72,
                        child: Text(
                          _formatVal(val, isPercent),
                          textAlign: TextAlign.right,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isNegative ? theme.colorScheme.error : null,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );

    // Tambahkan watermark overlay bila tersedia, lalu bungkus dengan RepaintBoundary.
    final withOverlay = Stack(
      children: [
        chartContent,
        if (overlayWatermark != null && overlayWatermark!.isNotEmpty)
          Positioned(
            right: 8,
            top: 0,
            child: Opacity(
              opacity: 0.6,
              child: Text(
                overlayWatermark!,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
      ],
    );

    if (repaintKey != null) {
      return RepaintBoundary(key: repaintKey, child: withOverlay);
    }
    return withOverlay;
  }

  static String _formatVal(double v, bool isPercent) {
    if (isPercent) {
      return '${v.toStringAsFixed(0)}%';
    }
    return v >= 100
        ? v.toStringAsFixed(0)
        : v.abs() >= 10
            ? v.toStringAsFixed(1)
            : v.toStringAsFixed(2);
  }
}
