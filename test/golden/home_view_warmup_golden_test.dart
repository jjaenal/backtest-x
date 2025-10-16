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

    // Mock path_provider to avoid MissingPluginException in tests
    mockPathProviderForTests();

    // Replace StorageService with mock and stub empty state
    final storage = getAndRegisterStorageService();
    when(storage.getAllStrategies()).thenAnswer((_) async => []);
    when(storage.getAllMarketDataInfo()).thenAnswer((_) async => []);
    when(storage.getTotalBacktestResultsCount()).thenAnswer((_) async => 0);
    when(storage.getLatestBacktestResult()).thenAnswer((_) async => null);

    // Disable background warm-up to avoid disk operations in tests
    DataManager().setBackgroundWarmupEnabled(false);
  });

  tearDownAll(() => locator.reset());

  testGoldens('HomeView - warm-up indicator visible', (tester) async {
    await loadAppFonts();

    // Deterministic surface size and DPR
    await tester.binding.setSurfaceSize(const Size(393, 852));
    tester.view.devicePixelRatio = 1.0;

    // Simulate warm-up in progress without triggering background tasks
    DataManager().warmupNotifier.value = true;

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(393, 852), devicePixelRatio: 1.0),
        child: MaterialApp(debugShowCheckedModeBanner: false, home: HomeView()),
      ),
    );

    // Pump a few frames to stabilize layout; avoid pumpAndSettle
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    await expectLater(
      find.byType(HomeView),
      matchesGoldenFile('goldens/home_view_warmup.png'),
    );
  });
}
