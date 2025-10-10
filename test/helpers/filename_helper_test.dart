import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/helpers/filename_helper.dart';

void main() {
  group('FilenameHelper', () {
    test('sanitize replaces illegal chars and trims underscores', () {
      final input = ':/bad*name?<>|__file__';
      final out = FilenameHelper.sanitize(input);
      expect(out, 'bad_name_file');
    });

    test('build assembles parts with timestamp and extension', () {
      final ts = DateTime(2024, 1, 2, 3, 4, 5);
      final out = FilenameHelper.build(['btc', '1h', 'report'], ext: 'pdf', timestamp: ts);
      expect(out, 'btc_1h_report_20240102_030405.pdf');
    });
  });
}