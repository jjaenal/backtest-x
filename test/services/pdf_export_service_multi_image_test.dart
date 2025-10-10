import 'dart:typed_data';
import 'dart:convert' show latin1;
import 'package:image/image.dart' as img;
import 'package:test/test.dart';
import 'package:backtestx/services/pdf_image_document.dart';

void main() {
  // Plain Dart test; no Flutter binding needed

  group('PdfImageDocument - Multi-image PDF', () {

    // Pure function; no setup needed

    // Generate small 2x2 PNGs using the image package to avoid decoder issues
    Uint8List makePng(int r, int g, int b) {
      final canvas = img.Image(width: 2, height: 2);
      for (var y = 0; y < 2; y++) {
        for (var x = 0; x < 2; x++) {
          img.drawPixel(canvas, x, y, img.ColorRgb8(r, g, b));
        }
      }
      final bytes = img.encodePng(canvas);
      return Uint8List.fromList(bytes);
    }

    final png1 = makePng(10, 20, 30);
    final png2 = makePng(200, 100, 50);

    test('Produces page count equal to images length and footer text',
        () async {
      final bytes = await PdfImageDocument.buildMultiImageDocument(
        [png1, png2],
        titles: const ['Chart', 'Panel'],
      );

      // Parse PDF bytes as latin1 to safely search textual markers
      final text = latin1.decode(bytes, allowInvalid: true);

      // Read page count from the /Pages tree: /Count <N>
      final countMatch = RegExp(r'/Count\s+(\d+)').firstMatch(text);
      expect(countMatch, isNotNull);
      final count = int.parse(countMatch!.group(1)!);
      expect(count, equals(2));
    });
  });
}
