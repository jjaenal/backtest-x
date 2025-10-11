import 'package:flutter/services.dart';

/// Simple wrapper to make clipboard operations testable without platform channels.
class ClipboardService {
  Future<void> copyText(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
  }
}
