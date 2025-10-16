import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/helpers/share_content_helper.dart';

void main() {
  group('ShareContentHelper.sanitizeText', () {
    test('removes control characters but preserves \n and \t', () {
      const input = 'Hello\x00World\nLine2\tTabbed\x1FEnd';
      final out = ShareContentHelper.sanitizeText(input);
      expect(out, 'HelloWorld\nLine2\tTabbedEnd');
    });

    test('collapses multiple spaces and newlines, trims ends', () {
      const input = '  A   B   C\n\n\nD  ';
      final out = ShareContentHelper.sanitizeText(input);
      expect(out, 'A B C\n\nD');
    });

    test('limits extremely long payloads', () {
      final input = 'x' * 60000; // 60k
      final out = ShareContentHelper.sanitizeText(input);
      expect(out.length, 50000);
    });
  });
}
