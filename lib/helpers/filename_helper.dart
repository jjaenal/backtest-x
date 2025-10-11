import 'package:intl/intl.dart';

class FilenameHelper {
  static String sanitize(String input) {
    final replaced = input.replaceAll(RegExp(r'[\/:*?"<>|]+'), '_');
    final collapsed = replaced.replaceAll(RegExp(r'_+'), '_');
    return collapsed.trim().replaceAll(RegExp(r'^_+|_+$'), '');
  }

  static String formattedTimestamp(DateTime ts) {
    final fmt = DateFormat('yyyyMMdd_HHmmss');
    return fmt.format(ts);
  }

  static String build(List<String> parts,
      {required String ext, DateTime? timestamp}) {
    final ts = timestamp ?? DateTime.now();
    final raw = [...parts, formattedTimestamp(ts)].join('_');
    final base = sanitize(raw);
    return '$base.$ext';
  }
}
