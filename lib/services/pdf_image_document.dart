import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Pure-Dart helper to build multi-image PDF documents without app/service dependencies.
class PdfImageDocument {
  /// Build a multi-page PDF embedding PNG/JPEG images.
  /// Each entry in `images` corresponds to a page; optional `titles` appear above images.
  static Future<Uint8List> buildMultiImageDocument(
    List<Uint8List> images, {
    List<String?>? titles,
  }) async {
    final pdf = pw.Document(compress: false);

    for (var i = 0; i < images.length; i++) {
      final img = pw.MemoryImage(images[i]);
      final title = titles != null && i < (titles.length) ? titles[i] : null;
      pdf.addPage(
        pw.Page(
          margin: const pw.EdgeInsets.all(24),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (title != null && title.isNotEmpty) ...[
                  pw.Text(
                    title,
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                ],
                pw.Center(
                  child: pw.Container(
                    height: 400,
                    child: pw.Image(img, fit: pw.BoxFit.contain),
                  ),
                ),
                pw.SizedBox(height: 12),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(vertical: 8),
                  alignment: pw.Alignment.center,
                  child: pw.Text(
                    'Page ${i + 1} of ${images.length}',
                    style: const pw.TextStyle(
                        fontSize: 10, color: PdfColors.grey600),
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    return pdf.save();
  }
}
