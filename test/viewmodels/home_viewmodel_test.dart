import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/ui/views/home/home_viewmodel.dart';
import '../helpers/test_helpers.dart';
import '../helpers/test_helpers.mocks.dart';

void main() {
  late MockStorageService storageService;
  // We avoid stream subscription complexity by focusing on refresh behavior

  setUp(() async {
    registerServices();
    mockPathProviderForTests();
    storageService = locator<StorageService>() as MockStorageService;

    // No stream stubbing; tests will directly call refresh paths

    // Stub data queries used by HomeViewModel._loadStats()
    when(storageService.getAllStrategies()).thenAnswer((_) async => []);
    when(storageService.getAllMarketDataInfo()).thenAnswer((_) async => []);
    when(storageService.getTotalBacktestResultsCount())
        .thenAnswer((_) async => 0);
    when(storageService.getLatestBacktestResult())
        .thenAnswer((_) async => null);
  });

  tearDown(() async {});

  test('Manual refresh notifies listeners', () async {
    final model = HomeViewModel();

    int notifyCount = 0;
    model.addListener(() => notifyCount++);

    // Trigger refresh directly
    await model.refresh();

    expect(notifyCount, greaterThan(0));
  });

  test('didPopNext triggers refresh and notifies listeners', () async {
    final model = HomeViewModel();

    int notifyCount = 0;
    model.addListener(() => notifyCount++);

    // didPopNext calls refresh(); wait briefly for async to complete
    model.didPopNext();
    await Future.delayed(const Duration(milliseconds: 50));

    expect(notifyCount, greaterThan(0));
  });
}
