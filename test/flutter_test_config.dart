import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'config/temp_dir_stub.dart'
    if (dart.library.io) 'config/temp_dir_io.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Use in-memory SharedPreferences for tests
  SharedPreferences.setMockInitialValues({});

  // Mock path_provider channel to return a temp directory for tests
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = createTempDirPath();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    pathProviderChannel,
    (MethodCall methodCall) async {
      switch (methodCall.method) {
        case 'getApplicationDocumentsDirectory':
        case 'getApplicationSupportDirectory':
        case 'getTemporaryDirectory':
        case 'getLibraryDirectory':
        case 'getDownloadsDirectory':
          return tempDir;
        default:
          return tempDir;
      }
    },
  );

  // Mock file_picker channel to avoid MissingPluginException in tests
  const filePickerChannel = MethodChannel('miguelruivo.plugins.filepicker');
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    filePickerChannel,
    (MethodCall methodCall) async {
      return null; // no-op for tests
    },
  );

  // Mock app_links EventChannel and MethodChannel to avoid MissingPluginException
  const String appLinksEventsChannel = 'com.llfbandit.app_links/events';
  const String appLinksMessagesChannel = 'com.llfbandit.app_links/messages';

  // Handle EventChannel listen/cancel gracefully
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler(
    appLinksEventsChannel,
    (ByteData? message) async {
      // Always return success envelope; avoid decoding to prevent unused variable lint
      return const StandardMethodCodec().encodeSuccessEnvelope(null);
    },
  );

  // Stub messages like getInitialLink/getLatestAppLink
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
    const MethodChannel(appLinksMessagesChannel),
    (MethodCall call) async {
      switch (call.method) {
        case 'getInitialLink':
        case 'getInitialAppLink':
        case 'getLatestAppLink':
        case 'getLinks':
          return null; // No initial or latest link during tests
        default:
          return null;
      }
    },
  );

  await testMain();
}
