import 'dart:convert';
import 'dart:io';

// Simple ARB consistency and unused keys checker.
// - Compares keys between en and id ARB files (excluding metadata keys starting with '@').
// - Reports keys missing in either locale.
// - Reports keys present in ARB but not referenced in AppLocalizations (manual).
// Exit codes:
//   0 -> No issues
//   1 -> Inconsistencies found
//   2 -> Script error

Future<void> main() async {
  final projectRoot = Directory.current.path;
  final enPath = '$projectRoot/lib/l10n/app_en.arb';
  final idPath = '$projectRoot/lib/l10n/app_id.arb';
  final l10nDartPath = '$projectRoot/lib/l10n/app_localizations.dart';

  try {
    final enJson = jsonDecode(await File(enPath).readAsString()) as Map<String, dynamic>;
    final idJson = jsonDecode(await File(idPath).readAsString()) as Map<String, dynamic>;

    // Filter out metadata keys (start with '@') and values that aren't strings
    Set<String> enKeys = enJson.keys.where((k) => !k.startsWith('@') && enJson[k] is String).toSet();
    Set<String> idKeys = idJson.keys.where((k) => !k.startsWith('@') && idJson[k] is String).toSet();

    // Load AppLocalizations references
    final l10nDart = await File(l10nDartPath).readAsString();
    final referencedKeys = _extractReferencedKeys(l10nDart);

    final missingInId = enKeys.difference(idKeys);
    final missingInEn = idKeys.difference(enKeys);

    final unusedInEn = enKeys.difference(referencedKeys);
    final unusedInId = idKeys.difference(referencedKeys);

    bool hasIssues = false;

    if (missingInId.isNotEmpty || missingInEn.isNotEmpty) {
      hasIssues = true;
      stdout.writeln('❌ ARB consistency issues found:');
      if (missingInId.isNotEmpty) {
        stdout.writeln('  - Missing in app_id.arb (present in en):');
        for (final k in missingInId.toList()..sort()) {
          stdout.writeln('    • $k');
        }
      }
      if (missingInEn.isNotEmpty) {
        stdout.writeln('  - Missing in app_en.arb (present in id):');
        for (final k in missingInEn.toList()..sort()) {
          stdout.writeln('    • $k');
        }
      }
    } else {
      stdout.writeln('✅ ARB keys consistent between en and id.');
    }

    // Report unused keys as warnings (do not fail build)
    if (unusedInEn.isNotEmpty || unusedInId.isNotEmpty) {
      stdout.writeln('⚠️  Unused ARB keys (not referenced in AppLocalizations):');
      if (unusedInEn.isNotEmpty) {
        stdout.writeln('  - app_en.arb:');
        for (final k in unusedInEn.toList()..sort()) {
          stdout.writeln('    • $k');
        }
      }
      if (unusedInId.isNotEmpty) {
        stdout.writeln('  - app_id.arb:');
        for (final k in unusedInId.toList()..sort()) {
          stdout.writeln('    • $k');
        }
      }
    } else {
      stdout.writeln('✅ No unused ARB keys found versus AppLocalizations.');
    }

    exit(hasIssues ? 1 : 0);
  } catch (e, st) {
    stderr.writeln('Error running ARB consistency check: $e');
    stderr.writeln(st);
    exit(2);
  }
}

Set<String> _extractReferencedKeys(String source) {
  // Two patterns:
  // 1) Map literals: 'key': 'Value', used in language maps
  // 2) Getter indirection: _text('key') in AppLocalizations getters
  final mapKeyRegex = RegExp(r"'([a-z0-9_]+)'\s*:\s*'", multiLine: true);
  final textCallRegex = RegExp(r"_text\('([a-z0-9_]+)'\)", multiLine: true);

  final keys = <String>{};
  for (final m in mapKeyRegex.allMatches(source)) {
    keys.add(m.group(1)!);
  }
  for (final m in textCallRegex.allMatches(source)) {
    keys.add(m.group(1)!);
  }
  return keys;
}