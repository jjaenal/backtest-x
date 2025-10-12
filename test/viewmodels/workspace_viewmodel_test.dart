import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/ui/views/workspace/workspace_viewmodel.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late MockStorageService storageService;
  // Simplify: focus on refresh behavior, avoid stream subscription complexity

  setUp(() async {
    registerServices();
    mockPathProviderForTests();
    storageService = locator<StorageService>() as MockStorageService;

    // No stream stubs required for this test focus

    when(storageService.getAllStrategies()).thenAnswer((_) async => []);
    when(storageService.getBacktestResultsByStrategy(any))
        .thenAnswer((_) async => []);
    when(storageService.clearCache()).thenReturn(null);
  });

  tearDown(() async {});

  test('Manual refresh notifies listeners', () async {
    final model = WorkspaceViewModel();

    int notifyCount = 0;
    model.addListener(() => notifyCount++);

    // Trigger refresh directly
    await model.refresh();

    expect(notifyCount, greaterThan(0));
  });
}
