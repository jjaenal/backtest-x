@Tags(['golden'])
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/ui/views/home/home_view.dart';
import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await setupGoldenTest();
    setupPopulatedStorageService();
  });

  tearDownAll(() => locator.reset());

  testWidgets('HomeView - populated + warm-up indicator', (tester) async {
    await loadAppFonts();
    await setupGoldenViewport(tester);
    
    // Simulate warm-up in progress
    DataManager().warmupNotifier.value = true;
    
    await pumpWidgetForGolden(tester, const HomeView());
    await verifyGolden(tester, find.byType(HomeView), 'home_view_populated_warmup');
  });
}
