import 'package:universal_html/html.dart' as html;

/// Preferences service implementation for Web using LocalStorage.
class PrefsService {
  Future<void> setString(String key, String value) async {
    html.window.localStorage[key] = value;
  }

  Future<String?> getString(String key) async {
    return html.window.localStorage[key];
  }
}
