import 'package:flutter/material.dart';
import 'dart:ui' show FontFeature;

class GroupedTfBarChart extends StatelessWidget {
  final Map<String, Map<String, double>>
      data; // timeframe -> {seriesLabel -> value}
  final List<String> seriesOrder; // order of series labels (e.g., R1, R2, ...)
  final List<String>? timeframeOrder; // optional order of timeframe categories
  final String metricLabel;
  final bool isPercent;
  final GlobalKey? repaintKey;
  final String? overlayWatermark;
  final int? maxRows; // cap number of timeframe rows rendered

  const GroupedTfBarChart({
    super.key,
    required this.data,
    required this.seriesOrder,
    this.timeframeOrder,
    required this.metricLabel,
    this.isPercent = false,
    this.repaintKey,
    this.overlayWatermark,
    this.maxRows,
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    final theme = Theme.of(context);

    // Determine timeframe order: use provided order if present, otherwise sort alphabetically
    final tfsAll = timeframeOrder != null && timeframeOrder!.isNotEmpty
        ? timeframeOrder!.where((tf) => data.containsKey(tf)).toList()
        : (data.keys.toList()..sort());
    final totalCount = tfsAll.length;
    final tfs = (maxRows != null && totalCount > (maxRows ?? 0))
        ? tfsAll.sublist(0, maxRows!)
        : tfsAll;

    // Determine max absolute value across all series for scaling
    double maxVal = 0.0;
    for (final tf in tfs) {
      final series = data[tf] ?? {};
      for (final v in series.values) {
        final abs = v.abs();
        if (abs > maxVal) maxVal = abs;
      }
    }
    if (maxVal == 0) maxVal = 1.0; // avoid divide by zero

    final colors = _buildSeriesColors(theme, seriesOrder.length);

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Per‑Timeframe Comparison: $metricLabel',
            style: theme.textTheme.titleSmall,
          ),
        ),
        // Legend
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            for (int i = 0; i < seriesOrder.length; i++)
              _legendItem(context, colors[i], seriesOrder[i]),
          ],
        ),
        if (maxRows != null && totalCount > (maxRows ?? 0))
          Padding(
            padding: const EdgeInsets.only(top: 6.0),
            child: Text(
              'Showing ${tfs.length} of $totalCount timeframes',
              style: theme.textTheme.bodySmall,
            ),
          ),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final fullWidth = constraints.maxWidth;
            return ListView.builder(
              itemCount: tfs.length,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (context, index) {
                final tf = tfs[index];
                return _groupRow(
                  context,
                  tf,
                  data[tf] ?? {},
                  seriesOrder,
                  colors,
                  fullWidth,
                  maxVal,
                );
              },
            );
          },
        ),
      ],
    );

    Widget wrapped = content;
    if (overlayWatermark != null && overlayWatermark!.isNotEmpty) {
      wrapped = Stack(
        children: [
          content,
          Positioned(
            right: 8,
            bottom: 4,
            child: Opacity(
              opacity: 0.35,
              child: Text(
                overlayWatermark!,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ),
        ],
      );
    }

    if (repaintKey != null) {
      wrapped = RepaintBoundary(key: repaintKey, child: wrapped);
    }

    return wrapped;
  }

  Widget _legendItem(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 6),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _groupRow(
    BuildContext context,
    String tf,
    Map<String, double> series,
    List<String> order,
    List<Color> colors,
    double fullWidth,
    double maxVal,
  ) {
    final theme = Theme.of(context);
    final groupPadding = 6.0;
    final barHeight = 14.0;
    final bgColor = theme.colorScheme.surfaceContainerHighest;
    final borderColor = theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 72,
            child: Text(tf, style: theme.textTheme.bodySmall),
          ),
          Expanded(
            child: Container(
              padding:
                  EdgeInsets.symmetric(vertical: groupPadding, horizontal: 8),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  for (int i = 0; i < order.length; i++)
                    Builder(builder: (context) {
                      final label = order[i];
                      final val = series[label] ?? 0.0;
                      final ratio = (val.abs() / maxVal).clamp(0.0, 1.0);
                      final barWidth =
                          (fullWidth - 100) * ratio; // subtract label/spacing
                      final color = val < 0
                          ? theme.colorScheme.error.withValues(alpha: 0.70)
                          : colors[i];
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: barHeight,
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.surface,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(color: borderColor),
                                    ),
                                  ),
                                  Tooltip(
                                    message:
                                        '$label: ${_formatVal(val, isPercent)}',
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      height: barHeight,
                                      width: barWidth,
                                      decoration: BoxDecoration(
                                        color: color,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 56,
                              child: Text(
                                _formatVal(val, isPercent),
                                textAlign: TextAlign.right,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontFeatures: const [
                                    FontFeature.tabularFigures()
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Color> _buildSeriesColors(ThemeData theme, int count) {
    final base = [
      theme.colorScheme.primary.withValues(alpha: 0.85),
      theme.colorScheme.tertiary.withValues(alpha: 0.85),
      theme.colorScheme.secondary.withValues(alpha: 0.85),
      Colors.teal.withValues(alpha: 0.85),
      Colors.indigo.withValues(alpha: 0.85),
      Colors.orange.withValues(alpha: 0.85),
      Colors.pink.withValues(alpha: 0.85),
    ];
    final colors = <Color>[];
    for (int i = 0; i < count; i++) {
      colors.add(base[i % base.length]);
    }
    return colors;
  }

  static String _formatVal(double v, bool isPercent) {
    if (isPercent) {
      return '${v.toStringAsFixed(1)}%';
    }
    return v.abs() >= 100
        ? v.toStringAsFixed(0)
        : v.abs() >= 10
            ? v.toStringAsFixed(1)
            : v.toStringAsFixed(2);
  }
}
