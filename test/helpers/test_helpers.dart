import 'dart:math';
import '../config/temp_dir_stub.dart'
    if (dart.library.io) '../config/temp_dir_io.dart';
import 'package:backtestx/services/data_validation_service.dart';
import 'package:backtestx/services/share_service.dart';
import 'package:backtestx/services/deep_link_service.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:backtestx/app/app.locator.dart';
import 'package:stacked_services/stacked_services.dart';
import 'package:backtestx/services/data_parser_service.dart';
import 'package:backtestx/services/indicator_service.dart';
import 'package:backtestx/services/backtest_engine_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/services/clipboard_service.dart';
import 'package:backtestx/models/candle.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import 'package:backtestx/services/auth_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// @stacked-import

import 'test_helpers.mocks.dart';

@GenerateMocks(
  [],
  customMocks: [
    MockSpec<NavigationService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<BottomSheetService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DialogService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<DataParserService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<IndicatorService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<BacktestEngineService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<StorageService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<ShareService>(onMissingStub: OnMissingStub.returnDefault),
    MockSpec<SnackbarService>(onMissingStub: OnMissingStub.returnDefault),
// @stacked-mock-spec
  ],
)
void registerServices() {
  if (!locator.isRegistered<NavigationService>()) {
    getAndRegisterNavigationService();
  }
  // Respect any pre-registered BottomSheetService (with custom responses in tests)
  if (!locator.isRegistered<BottomSheetService>()) {
    getAndRegisterBottomSheetService();
  }
  if (!locator.isRegistered<DialogService>()) {
    getAndRegisterDialogService();
  }
  if (!locator.isRegistered<DataParserService>()) {
    getAndRegisterDataParserService();
  }
  if (!locator.isRegistered<IndicatorService>()) {
    getAndRegisterIndicatorService();
  }
  if (!locator.isRegistered<BacktestEngineService>()) {
    getAndRegisterBacktestEngineService();
  }
  // Ensure DataValidationService available for models that require it
  if (!locator.isRegistered<DataValidationService>()) {
    locator.registerSingleton<DataValidationService>(DataValidationService());
  }
  // Ensure DeepLinkService available for tests using deep link generation
  if (!locator.isRegistered<DeepLinkService>()) {
    locator.registerSingleton<DeepLinkService>(DeepLinkService());
  }
  // Always override StorageService with a mock for tests (setupLocator registers real one)
  getAndRegisterStorageService();
  // Override SnackbarService with a mock to prevent GetX UI calls in tests
  getAndRegisterSnackbarService();
  // Ensure DataManager is registered; HomeViewModel accesses it via locator
  if (!locator.isRegistered<DataManager>()) {
    locator.registerSingleton<DataManager>(DataManager());
  }
  // Always override AuthService with a safe fake to avoid Supabase dependency
  getAndRegisterFakeAuthService();
// @stacked-mock-register
}

MockNavigationService getAndRegisterNavigationService() {
  _removeRegistrationIfExists<NavigationService>();
  final service = MockNavigationService();
  locator.registerSingleton<NavigationService>(service);
  return service;
}

MockBottomSheetService getAndRegisterBottomSheetService<T>({
  SheetResponse<T>? showCustomSheetResponse,
}) {
  _removeRegistrationIfExists<BottomSheetService>();
  final service = MockBottomSheetService();

  when(
    service.showCustomSheet<T, T>(
      enableDrag: anyNamed('enableDrag'),
      enterBottomSheetDuration: anyNamed('enterBottomSheetDuration'),
      exitBottomSheetDuration: anyNamed('exitBottomSheetDuration'),
      ignoreSafeArea: anyNamed('ignoreSafeArea'),
      isScrollControlled: anyNamed('isScrollControlled'),
      barrierDismissible: anyNamed('barrierDismissible'),
      additionalButtonTitle: anyNamed('additionalButtonTitle'),
      variant: anyNamed('variant'),
      title: anyNamed('title'),
      hasImage: anyNamed('hasImage'),
      imageUrl: anyNamed('imageUrl'),
      showIconInMainButton: anyNamed('showIconInMainButton'),
      mainButtonTitle: anyNamed('mainButtonTitle'),
      showIconInSecondaryButton: anyNamed('showIconInSecondaryButton'),
      secondaryButtonTitle: anyNamed('secondaryButtonTitle'),
      showIconInAdditionalButton: anyNamed('showIconInAdditionalButton'),
      takesInput: anyNamed('takesInput'),
      barrierColor: anyNamed('barrierColor'),
      barrierLabel: anyNamed('barrierLabel'),
      customData: anyNamed('customData'),
      data: anyNamed('data'),
      description: anyNamed('description'),
    ),
  ).thenAnswer(
    (realInvocation) =>
        Future.value(showCustomSheetResponse ?? SheetResponse<T>()),
  );

  locator.registerSingleton<BottomSheetService>(service);
  return service;
}

MockDialogService getAndRegisterDialogService() {
  _removeRegistrationIfExists<DialogService>();
  final service = MockDialogService();
  locator.registerSingleton<DialogService>(service);
  return service;
}

MockDataParserService getAndRegisterDataParserService() {
  _removeRegistrationIfExists<DataParserService>();
  final service = MockDataParserService();
  locator.registerSingleton<DataParserService>(service);
  return service;
}

MockIndicatorService getAndRegisterIndicatorService() {
  _removeRegistrationIfExists<IndicatorService>();
  final service = MockIndicatorService();
  locator.registerSingleton<IndicatorService>(service);
  return service;
}

MockBacktestEngineService getAndRegisterBacktestEngineService() {
  _removeRegistrationIfExists<BacktestEngineService>();
  final service = MockBacktestEngineService();
  locator.registerSingleton<BacktestEngineService>(service);
  return service;
}

MockStorageService getAndRegisterStorageService() {
  _removeRegistrationIfExists<StorageService>();
  final service = MockStorageService();
  locator.registerSingleton<StorageService>(service);
  return service;
}

MockShareService getAndRegisterShareService() {
  _removeRegistrationIfExists<ShareService>();
  final service = MockShareService();
  locator.registerSingleton<ShareService>(service);
  return service;
}

MockSnackbarService getAndRegisterSnackbarService() {
  _removeRegistrationIfExists<SnackbarService>();
  final service = MockSnackbarService();
  locator.registerSingleton<SnackbarService>(service);
  return service;
}

// Lightweight fake AuthService to avoid Supabase dependency in unit tests
class FakeAuthService extends AuthService {
  final bool _isLoggedIn;
  final bool _isEmailVerified;
  FakeAuthService({bool isLoggedIn = false, bool isEmailVerified = false})
      : _isLoggedIn = isLoggedIn,
        _isEmailVerified = isEmailVerified;

  @override
  bool get isLoggedIn => _isLoggedIn;

  @override
  bool get isEmailVerified => _isEmailVerified;

  @override
  Stream<AuthState> get authState => const Stream.empty();

  @override
  Future<void> resendEmailVerification({String? email}) async {}

  @override
  Future<void> signOut() async {}
}

AuthService getAndRegisterFakeAuthService({
  bool isLoggedIn = false,
  bool isEmailVerified = false,
}) {
  _removeRegistrationIfExists<AuthService>();
  final service = FakeAuthService(
    isLoggedIn: isLoggedIn,
    isEmailVerified: isEmailVerified,
  );
  locator.registerSingleton<AuthService>(service);
  return service;
}

// @stacked-mock-create

ClipboardService getAndRegisterClipboardServiceInstance(
    ClipboardService instance) {
  _removeRegistrationIfExists<ClipboardService>();
  locator.registerSingleton<ClipboardService>(instance);
  return instance;
}

void _removeRegistrationIfExists<T extends Object>() {
  if (locator.isRegistered<T>()) {
    locator.unregister<T>();
  }
}

/// Mock path_provider method channel for tests to avoid MissingPluginException.
/// Returns a valid temporary directory path for all directory requests.
void mockPathProviderForTests({String? tempDirPath}) {
  const channel = MethodChannel('plugins.flutter.io/path_provider');
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
  final basePath = tempDirPath ?? createTempDirPath();

  messenger.setMockMethodCallHandler(channel, (MethodCall methodCall) async {
    // path_provider returns a String path; we provide the same.
    switch (methodCall.method) {
      case 'getApplicationDocumentsDirectory':
      case 'getTemporaryDirectory':
      case 'getApplicationSupportDirectory':
      case 'getLibraryDirectory':
        return basePath;
      default:
        return basePath;
    }
  });
}

/// Mock clipboard method channel for tests to intercept `Clipboard.setData`.
/// Supply `onSet` to capture the text written to clipboard.
void mockClipboardForTests({void Function(String text)? onSet}) {
  const platformChannel = MethodChannel('flutter/platform');
  TestWidgetsFlutterBinding.ensureInitialized();
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  messenger.setMockMethodCallHandler(platformChannel,
      (MethodCall methodCall) async {
    if (methodCall.method == 'Clipboard.setData') {
      final args = methodCall.arguments;
      String captured = '';
      if (args is Map || args is Map<dynamic, dynamic>) {
        final dynamic val = (args)["text"];
        if (val is String) captured = val;
      }
      if (onSet != null) onSet(captured);
      return null;
    }
    return null;
  });
}

/// Raise logger threshold to suppress info/debug logs during tests.
void silenceInfoLogsForTests() {
  Logger.level = Level.warning;
}

/// Initialize sqflite database factory for tests in VM and Web.
/// On Dart VM, uses `sqflite_common_ffi`; on Web, uses `sqflite_common_ffi_web`.
void initSqfliteFfiForTests() {
  if (kIsWeb) {
    sqflite.databaseFactory = databaseFactoryFfiWeb;
  } else {
    sqfliteFfiInit();
    sqflite.databaseFactory = databaseFactoryFfi;
  }
}

/// Generate synthetic candles for performance tests.
/// Uses a fixed Random seed for deterministic output across runs.
List<Candle> generateSyntheticCandles({
  required int count,
  DateTime? start,
  double basePrice = 100.0,
  double driftPerStep = 0.0005,
  double volatility = 0.01,
}) {
  assert(count > 1, 'count must be > 1');
  final rnd = Random(42);
  final candles = <Candle>[];
  final startTime = start ?? DateTime(2020, 1, 1);
  double lastClose = basePrice;

  for (int i = 0; i < count; i++) {
    // Price movement: small drift + random noise
    final noise = (rnd.nextDouble() - 0.5) * 2.0 * volatility;
    final move = lastClose * (driftPerStep + noise);
    final close = (lastClose + move).clamp(0.01, double.maxFinite);

    // Build OHLC around close
    final spread = (close.abs() * 0.002) + 0.05; // ~0.2% range
    final open = lastClose;
    final high = max(max(open, close), close + spread);
    final low = min(min(open, close), close - spread);
    final volume = 1000 + rnd.nextInt(5000);

    candles.add(Candle(
      timestamp: startTime.add(Duration(minutes: i)),
      open: open,
      high: high,
      low: low,
      close: close,
      volume: volume.toDouble(),
    ));
    lastClose = close;
  }

  return candles;
}
