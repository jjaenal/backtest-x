@Tags(['golden'])
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/ui/views/home/home_view.dart';
import '../helpers/test_helpers.dart';

void main() {
  setUpAll(() async {
    await setupLocator();
    // Silence info/debug logs in tests
    silenceInfoLogsForTests();
  });
  tearDownAll(() => locator.reset());

  testGoldens('HomeView - default state', (tester) async {
    await loadAppFonts();

    // Set device pixel ratio and size
    await tester.binding.setSurfaceSize(const Size(393, 852));
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(
      const MediaQuery(
        data: MediaQueryData(size: Size(393, 852), devicePixelRatio: 1.0),
        child: MaterialApp(debugShowCheckedModeBanner: false, home: HomeView()),
      ),
    );

    // Hindari pumpAndSettle yang bisa timeout karena listener/animasi background.
    // Pump beberapa frame saja agar layout stabil.
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));
    await tester.pump(const Duration(milliseconds: 16));

    // Bandingkan widget HomeView langsung untuk menghindari pumpAndSettle internal GoldenToolkit.
    await expectLater(
      find.byType(HomeView),
      matchesGoldenFile('goldens/home_view_default.png'),
    );
  });
}
