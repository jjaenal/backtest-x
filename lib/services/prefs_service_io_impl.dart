import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Preferences service implementation for IO platforms (mobile/desktop).
class PrefsService {
  static const String _fileName = 'backtestx_prefs.json';
  Map<String, dynamic>? _cache;

  Future<File> _prefsFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<void> _ensureLoaded() async {
    if (_cache != null) return;
    try {
      final file = await _prefsFile();
      if (await file.exists()) {
        final content = await file.readAsString();
        _cache = json.decode(content) as Map<String, dynamic>;
      } else {
        _cache = <String, dynamic>{};
      }
    } catch (_) {
      _cache = <String, dynamic>{};
    }
  }

  Future<void> _flush() async {
    try {
      final file = await _prefsFile();
      await file.writeAsString(json.encode(_cache ?? {}));
    } catch (_) {
      // Non-critical
    }
  }

  Future<void> setString(String key, String value) async {
    await _ensureLoaded();
    _cache![key] = value;
    await _flush();
  }

  Future<String?> getString(String key) async {
    await _ensureLoaded();
    final v = _cache![key];
    return v is String ? v : null;
  }
}
