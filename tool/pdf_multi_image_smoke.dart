import 'dart:convert';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:backtestx/services/pdf_export_service.dart';

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

Future<void> main() async {
  final service = PdfExportService();
  final png1 = makePng(10, 20, 30);
  final png2 = makePng(200, 100, 50);

  final pdfBytes = await service.buildMultiImageDocument(
    [png1, png2],
    titles: const ['Chart', 'Panel'],
  );

  final text = latin1.decode(pdfBytes, allowInvalid: true);
  final pagesCount = RegExp(r'/Type\s*/Page').allMatches(text).length;
  final hasFooter1 = text.contains('Page 1 of 2');
  final hasFooter2 = text.contains('Page 2 of 2');

  print('PDF length: ${pdfBytes.length}');
  print('Pages detected: $pagesCount');
  print('Footer page 1: $hasFooter1');
  print('Footer page 2: $hasFooter2');
}