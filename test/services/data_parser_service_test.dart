import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:backtestx/services/data_parser_service.dart';

void main() {
  group('DataParserService CSV error messages', () {
    test('invalid format (too few columns) returns detailed error', () async {
      final service = DataParserService();
      // Header is optional; provide one invalid data row with 3 columns
      final csv = '2024-01-01,100,101\n';
      final bytes = Uint8List.fromList(csv.codeUnits);

      expect(
        () => service.parseCsvBytes(
          bytes: bytes,
          symbol: 'TEST',
          timeframe: '1H',
        ),
        throwsA(predicate((e) {
          final text = e.toString();
          return text.contains('Format CSV tidak valid') &&
              text.contains('Jumlah kolom terlalu sedikit') &&
              text.contains('Minimal 5 kolom');
        })),
      );
    });

    test('row-level error includes line and column details', () async {
      final service = DataParserService();
      // Header + one bad row (Open not a number) -> no valid candles
      final csv = 'Date,Open,High,Low,Close,Volume\n2024-01-01,abc,101,99,100,1000\n';
      final bytes = Uint8List.fromList(csv.codeUnits);

      expect(
        () => service.parseCsvBytes(
          bytes: bytes,
          symbol: 'TEST',
          timeframe: '1H',
        ),
        throwsA(predicate((e) {
          final text = e.toString();
          // Format check now identifies first data row and failing column
          return text.contains('Format CSV tidak valid') &&
              text.contains('Baris pertama kolom 2 (Open)') &&
              text.contains('bukan angka');
        })),
      );
    });

    test('valid CSV parses successfully', () async {
      final service = DataParserService();
      final csv = 'Date,Open,High,Low,Close,Volume\n2024-01-01,100,101,99,100,1000\n';
      final bytes = Uint8List.fromList(csv.codeUnits);

      final data = await service.parseCsvBytes(
        bytes: bytes,
        symbol: 'TEST',
        timeframe: '1H',
      );

      expect(data.symbol, 'TEST');
      expect(data.timeframe, '1H');
      expect(data.candles.length, 1);
      expect(data.candles.first.open, 100);
      expect(data.candles.first.volume, 1000);
    });
  });
}
