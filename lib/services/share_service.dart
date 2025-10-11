import 'dart:typed_data';
import 'dart:io' as io;

import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as html;

import 'package:backtestx/helpers/filename_helper.dart';
import 'package:backtestx/helpers/share_content_helper.dart';

/// Cross-platform sharing service that wraps share_plus and provides
/// sane fallbacks on Web.
class ShareService {
  /// Share plain text across platforms.
  /// On Web, attempts Web Share API; falls back to clipboard.
  Future<void> shareText(String text, {String? subject}) async {
    final payload = ShareContentHelper.sanitizeText(
      ShareContentHelper.redactPII(text),
    );
    final title = subject ?? 'BacktestX';

    if (kIsWeb) {
      try {
        final navigator = html.window.navigator as dynamic;
        if (navigator.share != null) {
          await navigator.share(<String, dynamic>{
            'title': title,
            'text': payload,
          });
          return;
        }
      } catch (_) {
        // ignore and fallback
      }
      await Clipboard.setData(ClipboardData(text: payload));
      return;
    }

    await Share.share(payload, subject: title);
  }

  /// Share a file by path (mobile/desktop) or trigger browser download (web).
  /// Optionally include accompanying text.
  Future<void> shareFilePath(
    String path, {
    String? text,
    String? mimeType,
    String? filename,
  }) async {
    final note = text == null ? null : ShareContentHelper.sanitizeText(text);
    final name = filename != null ? FilenameHelper.sanitize(filename) : null;

    if (kIsWeb) {
      // On Web we cannot access local file paths; users should prefer shareBytes.
      // If text provided, copy to clipboard as minimal UX.
      if (note != null && note.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: note));
      }
      return;
    }

    final x = XFile(path, mimeType: mimeType, name: name);
    await Share.shareXFiles([x], text: note);
  }

  /// Share raw bytes as a file. On mobile/desktop writes to temp dir and shares;
  /// on Web triggers a download via an anchor with the provided filename.
  Future<void> shareBytes(
    Uint8List bytes, {
    required String filename,
    String? text,
    String? mimeType,
  }) async {
    final fname = FilenameHelper.sanitize(filename);
    final note = text == null ? null : ShareContentHelper.sanitizeText(text);

    if (kIsWeb) {
      final blob = html.Blob([bytes], mimeType ?? 'application/octet-stream');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..download = fname
        ..click();
      // Revoke if a URL was created
      if ((anchor.href ?? '').isNotEmpty) {
        html.Url.revokeObjectUrl(url);
      }
      if (note != null && note.isNotEmpty) {
        await Clipboard.setData(ClipboardData(text: note));
      }
      return;
    }

    final dir = await getTemporaryDirectory();
    final path = '${dir.path}/$fname';
    final file = io.File(path);
    await file.writeAsBytes(bytes, flush: true);

    final x = XFile(path, mimeType: mimeType, name: fname);
    await Share.shareXFiles([x], text: note);
  }
}
