import 'package:flutter/foundation.dart' show kIsWeb;

/// EnvService memeriksa konfigurasi environment untuk Supabase.
///
/// Membaca nilai `SUPABASE_URL` dan `SUPABASE_ANON_KEY` dari `String.fromEnvironment`.
/// Digunakan untuk menampilkan peringatan jika env belum dikonfigurasi dan
/// mengaktifkan fallback dev-mode (web-only).
class EnvService {
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'http://localhost',
  );
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'invalid-key',
  );

  /// True jika kedua variabel env telah dikonfigurasi dengan nilai yang valid.
  bool get isSupabaseConfigured {
    final hasUrl = supabaseUrl.startsWith('http');
    final looksProd = supabaseUrl.contains('supabase.co');
    final hasKey =
        supabaseAnonKey.isNotEmpty && supabaseAnonKey != 'invalid-key';
    return hasUrl && hasKey && looksProd;
  }

  /// Mode dev di web ketika Supabase belum dikonfigurasi.
  bool get isDevFallbackWeb => kIsWeb && !isSupabaseConfigured;

  /// Pesan ringkas untuk ditampilkan di UI.
  String get configurationMessage {
    if (isSupabaseConfigured) return 'Supabase env configured';
    return 'Supabase belum dikonfigurasi. Mode dev (web-only) aktif, fitur auth nonaktif.';
  }
}
