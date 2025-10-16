import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/helpers/share_content_helper.dart';

void main() {
  group('PII Redaction', () {
    test('redacts email addresses', () {
      const input = 'Contact me at john.doe@example.com for details';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('example.com'), isFalse);
      expect(out.contains('[email_redacted]'), isTrue);
    });

    test('redacts phone numbers with separators', () {
      const input = 'Phone: +1 (415) 555-1234 is available';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[phone_redacted]'), isTrue);
    });

    test('redacts domestic phone format 021-123-4567', () {
      const input = 'Call center: 021-123-4567 segera';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[phone_redacted]'), isTrue);
    });

    test('redacts phone with parentheses (021) 123-4567', () {
      const input = 'Nomor kantor: (021) 123-4567';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[phone_redacted]'), isTrue);
    });

    test('redacts UUID tokens', () {
      const input =
          'Trace ID: 123e4567-e89b-12d3-a456-426614174000 encountered error';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[uuid_redacted]'), isTrue);
    });

    test('redacts mixed-case UUID tokens', () {
      const input = 'Session: 123E4567-E89B-12D3-A456-426614174000 created';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[uuid_redacted]'), isTrue);
    });

    test('redacts contextual IDs after keywords', () {
      const input = 'account: ABCD-12345678 should not be shared';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[id_redacted]'), isTrue);
      expect(out.contains('account:'), isTrue);
    });

    test('redacts contextual ID for iban keyword', () {
      const input = 'iban: GB82WEST12345698765432 confidential';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[id_redacted]'), isTrue);
      expect(out.contains('iban:'), isTrue);
    });

    test('does not redact generic id without context keyword', () {
      const input = 'id: 1234567890 should remain for debugging';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[id_redacted]'), isFalse);
      expect(out.contains('id: 1234567890'), isTrue);
    });

    test('redacts multiple PII types in one text', () {
      const input =
          'Email: jane+news@sub.example.co.uk, Phone: 62-812-1234-5678, UUID: 123e4567-e89b-12d3-a456-426614174000, account: ABCDE-987654';
      final out = ShareContentHelper.redactPII(input);
      expect(out.contains('[email_redacted]'), isTrue);
      expect(out.contains('[phone_redacted]'), isTrue);
      expect(out.contains('[uuid_redacted]'), isTrue);
      expect(out.contains('[id_redacted]'), isTrue);
    });
  });
}
