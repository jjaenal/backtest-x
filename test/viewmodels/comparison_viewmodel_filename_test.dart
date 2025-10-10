import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/ui/views/comparison/comparison_viewmodel.dart';
import 'package:backtestx/models/trade.dart';
import 'package:backtestx/app/app.locator.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupLocator();
    registerServices();
  });

  tearDownAll(() async {
    await locator.reset();
  });

  test('ComparisonViewModel.generateExportFilename formats and sanitizes properly', () async {
    final vm = ComparisonViewModel(const <BacktestResult>[]);
    final fixedTs = DateTime(2025, 1, 1, 12, 0, 0);

    final fname = vm.generateExportFilename(
      baseLabel: 'My:Metric?*',
      ext: 'pdf',
      timestamp: fixedTs,
    );
    expect(fname, 'comparison_My_Metric_20250101_120000.pdf');

    final fnameCsv = vm.generateExportFilename(
      baseLabel: 'tfstats',
      ext: 'csv',
      timestamp: fixedTs,
    );
    expect(fnameCsv, 'comparison_tfstats_20250101_120000.csv');

    final fnameTsv = vm.generateExportFilename(
      baseLabel: 'tfstats',
      ext: 'tsv',
      timestamp: fixedTs,
    );
    expect(fnameTsv, 'comparison_tfstats_20250101_120000.tsv');
  });
}