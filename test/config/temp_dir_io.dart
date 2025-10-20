import 'dart:io';

String createTempDirPath() {
  return Directory.systemTemp.createTempSync('flutter_test_path_provider').path;
}
