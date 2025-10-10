/// Helpers to sanitize, redact PII, and validate textual share content and filenames.
class ShareContentHelper {
  /// Remove control characters, collapse whitespace, and trim.
  static String sanitizeText(String input) {
    // Remove non-printable ASCII control chars except \n\r\t
    final withoutCtl = input.replaceAll(RegExp(r'[\x00-\x08\x0B\x0C\x0E-\x1F]'), '');
    // Collapse multiple spaces/newlines
    final collapsedSpaces = withoutCtl.replaceAll(RegExp(r'[ ]{2,}'), ' ');
    final collapsedLines = collapsedSpaces.replaceAll(RegExp(r'\n{3,}'), '\n\n');
    // Trim
    final trimmed = collapsedLines.trim();
    // Guard against extremely long payloads
    const maxLen = 50000; // practical safety limit
    return trimmed.length > maxLen ? trimmed.substring(0, maxLen) : trimmed;
  }

  /// Policy flags to control which PII types are redacted.
  static const PIIRedactionPolicy defaultPolicy = PIIRedactionPolicy();

  /// Redact common PII patterns from free-form text.
  /// Email, phone, UUID, and common ID tokens following context keywords.
  static String redactPII(String input, {PIIRedactionPolicy? policy}) {
    final p = policy ?? defaultPolicy;
    var out = input;
    // Removed debug prints for cleaner test output

    if (p.redactEmails) {
      // Basic email pattern
      final email = RegExp(r'\b[\w._%+-]+@[\w.-]+\.[A-Za-z]{2,}\b', caseSensitive: false);
      out = out.replaceAll(email, p.emailReplacement);
    }

    if (p.redactPhones) {
      // Phone patterns require separators/parentheses to avoid matching generic IDs
      final phone = RegExp(
          r'(?:\+?\d{1,3}[\s.-])?(?:\(?\d{2,4}\)?)[\s.-]\d{3,4}[\s.-]\d{3,4}\b',
          caseSensitive: false);
      out = out.replaceAll(phone, p.phoneReplacement);
    }

    if (p.redactUUIDs) {
      final uuid = RegExp(
        r'\b[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}\b',
        caseSensitive: false,
      );
      out = out.replaceAll(uuid, p.uuidReplacement);
    }

    if (p.redactContextualIds) {
      // Contextual IDs: keywords followed by long token; exclude generic 'id' to avoid clobbering UUIDs
      final idCtx = RegExp(
        r'(?:account|acct|account_number|iban|no\.?)[\s:]+([A-Za-z0-9][A-Za-z0-9\-]{5,})',
        caseSensitive: false,
      );
      out = out.replaceAllMapped(idCtx, (m) {
        final full = m.group(0)!;
        final key = m.group(1)!;
        return full.replaceFirst(key, p.idReplacement);
      });
    }

    return out;
  }
}

class PIIRedactionPolicy {
  final bool redactEmails;
  final bool redactPhones;
  final bool redactUUIDs;
  final bool redactContextualIds;
  final String emailReplacement;
  final String phoneReplacement;
  final String uuidReplacement;
  final String idReplacement;

  const PIIRedactionPolicy({
    this.redactEmails = true,
    this.redactPhones = true,
    this.redactUUIDs = true,
    this.redactContextualIds = true,
    this.emailReplacement = '[email_redacted]',
    this.phoneReplacement = '[phone_redacted]',
    this.uuidReplacement = '[uuid_redacted]',
    this.idReplacement = '[id_redacted]',
  });
}