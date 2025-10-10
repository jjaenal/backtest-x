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
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Chart Indicators',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Reset ke default',
                  icon: const Icon(Icons.restore),
                  onPressed: viewModel.resetDefaults,
                ),
                IconButton(
                  tooltip: 'Tutup',
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Overlays Section
            _SectionTitle('Overlays'),
            const SizedBox(height: 8),
            _SwitchTile(
              context: context,
              title: 'SMA',
              subtitle: 'Simple Moving Average',
              value: viewModel.showSMA,
              onChanged: (v) {
                viewModel.showSMA = v;
                viewModel.notifyListeners();
              },
              trailing: _PeriodSlider(
                label: 'Period',
                value: viewModel.smaPeriod.toDouble(),
                min: 5,
                max: 200,
                onChanged: (val) {
                  viewModel.smaPeriod = val.round();
                  viewModel.notifyListeners();
                },
                color: viewModel.smaColor,
              ),
            ),
            _SwitchTile(
              context: context,
              title: 'EMA',
              subtitle: 'Exponential Moving Average',
              value: viewModel.showEMA,
              onChanged: (v) {
                viewModel.showEMA = v;
                viewModel.notifyListeners();
              },
              trailing: _PeriodSlider(
                label: 'Period',
                value: viewModel.emaPeriod.toDouble(),
                min: 5,
                max: 200,
                onChanged: (val) {
                  viewModel.emaPeriod = val.round();
                  viewModel.notifyListeners();
                },
                color: viewModel.emaColor,
              ),
            ),
            _SwitchTile(
              context: context,
              title: 'Bollinger Bands',
              subtitle: 'Volatility bands',
              value: viewModel.showBB,
              onChanged: (v) {
                viewModel.showBB = v;
                viewModel.notifyListeners();
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NumberChip(
                    context: context,
                    label: 'Period',
                    value: viewModel.bbPeriod.toString(),
                    onTap: () async {
                      final newVal = await _showNumberDialog(
                        context,
                        'BB Period',
                        viewModel.bbPeriod,
                        5,
                        200,
                      );
                      if (newVal != null) {
                        viewModel.bbPeriod = newVal;
                        viewModel.notifyListeners();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _NumberChip(
                    context: context,
                    label: 'StdDev',
                    value: viewModel.bbStdDev.toStringAsFixed(1),
                    onTap: () async {
                      final newVal = await _showDoubleDialog(
                        context,
                        'BB StdDev',
                        viewModel.bbStdDev,
                        1.0,
                        4.0,
                      );
                      if (newVal != null) {
                        viewModel.bbStdDev = newVal;
                        viewModel.notifyListeners();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _SectionDivider(context),
            const SizedBox(height: 12),

            // Oscillators Section
            _SectionTitle('Oscillators'),
            const SizedBox(height: 8),
            _SwitchTile(
              context: context,
              title: 'RSI',
              subtitle: 'Relative Strength Index',
              value: viewModel.showRSI,
              onChanged: (v) {
                viewModel.showRSI = v;
                viewModel.notifyListeners();
              },
              trailing: _PeriodSlider(
                label: 'Period',
                value: viewModel.rsiPeriod.toDouble(),
                min: 5,
                max: 50,
                onChanged: (val) {
                  viewModel.rsiPeriod = val.round();
                  viewModel.notifyListeners();
                },
                color: Colors.purple,
              ),
            ),
            _SwitchTile(
              context: context,
              title: 'MACD',
              subtitle: '12 / 26 / 9',
              value: viewModel.showMACD,
              onChanged: (v) {
                viewModel.showMACD = v;
                viewModel.notifyListeners();
              },
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NumberChip(
                    context: context,
                    label: 'Fast',
                    value: viewModel.macdFast.toString(),
                    onTap: () async {
                      final n = await _showNumberDialog(
                          context, 'MACD Fast', viewModel.macdFast, 2, 50);
                      if (n != null) {
                        viewModel.macdFast = n;
                        viewModel.notifyListeners();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _NumberChip(
                    context: context,
                    label: 'Slow',
                    value: viewModel.macdSlow.toString(),
                    onTap: () async {
                      final n = await _showNumberDialog(
                          context, 'MACD Slow', viewModel.macdSlow, 5, 200);
                      if (n != null) {
                        viewModel.macdSlow = n;
                        viewModel.notifyListeners();
                      }
                    },
                  ),
                  const SizedBox(width: 8),
                  _NumberChip(
                    context: context,
                    label: 'Signal',
                    value: viewModel.macdSignal.toString(),
                    onTap: () async {
                      final n = await _showNumberDialog(
                          context, 'MACD Signal', viewModel.macdSignal, 2, 50);
                      if (n != null) {
                        viewModel.macdSignal = n;
                        viewModel.notifyListeners();
                      }
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            _SectionDivider(context),
            const SizedBox(height: 12),

            // Chart Options Section
            _SectionTitle('Chart Options'),
            const SizedBox(height: 8),
            _SwitchTile(
              context: context,
              title: 'High Quality Rendering',
              subtitle: 'Detail maksimal, performa lebih rendah',
              value: viewModel.highQuality,
              onChanged: (v) {
                viewModel.highQuality = v;
                viewModel.notifyListeners();
              },
            ),
            _SwitchTile(
              context: context,
              title: 'Show Volume (if available)',
              subtitle: 'Tampilkan panel volume di bawah chart',
              value: viewModel.showVolume,
              onChanged: (v) {
                viewModel.showVolume = v;
                viewModel.notifyListeners();
              },
            ),

            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear'),
                    onPressed: viewModel.resetDefaults,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Apply'),
                    onPressed: () {
                      completer?.call(SheetResponse(
                        confirmed: true,
                        data: {
                          'showSMA': viewModel.showSMA,
                          'showEMA': viewModel.showEMA,
                          'showBB': viewModel.showBB,
                          'showRSI': viewModel.showRSI,
                          'showMACD': viewModel.showMACD,
                          'smaPeriod': viewModel.smaPeriod,
                          'emaPeriod': viewModel.emaPeriod,
                          'bbPeriod': viewModel.bbPeriod,
                          'bbStdDev': viewModel.bbStdDev,
                          'rsiPeriod': viewModel.rsiPeriod,
                          'macdFast': viewModel.macdFast,
                          'macdSlow': viewModel.macdSlow,
                          'macdSignal': viewModel.macdSignal,
                          'highQuality': viewModel.highQuality,
                          'showVolume': viewModel.showVolume,
                        },
                      ));
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  IndicatorSettingsSheetModel viewModelBuilder(BuildContext context) =>
      IndicatorSettingsSheetModel();

  // Helper Widgets
  Widget _SectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
    );
  }

  Widget _SectionDivider(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
    );
  }

  Widget _SwitchTile({
    required BuildContext context,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color:
            Theme.of(context).colorScheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
            const SizedBox(width: 8),
          ],
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }

  Widget _PeriodSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    required Color color,
  }) {
    return SizedBox(
      width: 210,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 10,
                  height: 10,
                  decoration:
                      BoxDecoration(color: color, shape: BoxShape.circle)),
              const SizedBox(width: 6),
              Text('$label: ${value.round()}'),
            ],
          ),
          Slider(
            value: value.clamp(min, max),
            min: min,
            max: max,
            divisions: (max - min).round(),
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _NumberChip({
    required BuildContext context,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Theme.of(context)
              .colorScheme
              .surfaceVariant
              .withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            const SizedBox(width: 6),
            Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<int?> _showNumberDialog(
    BuildContext context,
    String title,
    int current,
    int min,
    int max,
  ) async {
    final controller = TextEditingController(text: current.toString());
    return showDialog<int>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(helperText: 'Range: $min - $max'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final val = int.tryParse(controller.text);
                if (val != null && val >= min && val <= max) {
                  Navigator.pop(ctx, val);
                } else {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<double?> _showDoubleDialog(
    BuildContext context,
    String title,
    double current,
    double min,
    double max,
  ) async {
    final controller = TextEditingController(text: current.toStringAsFixed(1));
    return showDialog<double>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(helperText: 'Range: $min - $max'),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                final val = double.tryParse(controller.text);
                if (val != null && val >= min && val <= max) {
                  Navigator.pop(ctx, val);
                } else {
                  Navigator.pop(ctx);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
