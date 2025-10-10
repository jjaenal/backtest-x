import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock path_provider channel to return a temp directory for tests
  const pathProviderChannel = MethodChannel('plugins.flutter.io/path_provider');
  final tempDir = Directory.systemTemp.createTempSync('flutter_test_path_provider').path;
  pathProviderChannel.setMockMethodCallHandler((MethodCall methodCall) async {
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
  });

  // Mock file_picker channel to avoid MissingPluginException in tests
  const filePickerChannel = MethodChannel('miguelruivo.plugins.filepicker');
  filePickerChannel.setMockMethodCallHandler((MethodCall methodCall) async {
    return null; // no-op for tests
  });

  await testMain();
}