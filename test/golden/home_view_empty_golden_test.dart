@Tags(['golden'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/ui/views/home/home_view.dart';
import 'package:mockito/mockito.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupLocator();
    // Silence info/debug logs in tests
    silenceInfoLogsForTests();
    // Replace StorageService with mock
    final storage = getAndRegisterStorageService();
    // Stub empty state responses
    when(storage.getAllStrategies()).thenAnswer((_) async => []);
    when(storage.getAllMarketDataInfo()).thenAnswer((_) async => []);
    when(storage.getTotalBacktestResultsCount()).thenAnswer((_) async => 0);
    when(storage.getLatestBacktestResult()).thenAnswer((_) async => null);
    // Disable background warmup to avoid async churn
    DataManager().setBackgroundWarmupEnabled(false);
  });

  tearDownAll(() => locator.reset());

  testGoldens('HomeView - empty state', (tester) async {
    await loadAppFonts();

    // Deterministic surface size and DPR
    await tester.binding.setSurfaceSize(const Size(393, 852));
    tester.binding.window.devicePixelRatioTestValue = 1.0;

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(393, 852), devicePixelRatio: 1.0),
        child: MaterialApp(debugShowCheckedModeBanner: false, home: HomeView()),
      ),
    );

    // Pump a few frames to stabilize layout without waiting indefinitely
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    await expectLater(
      find.byType(HomeView),
      matchesGoldenFile('goldens/home_view_empty.png'),
    );
  });
}
