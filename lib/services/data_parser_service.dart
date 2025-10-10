import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:csv/csv.dart';
import 'package:backtestx/models/candle.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class DataParserService {
  final _uuid = const Uuid();

  /// Parse CSV file to MarketData
  Future<MarketData> parseCsvFile({
    required File file,
    required String symbol,
    required String timeframe,
  }) async {
    try {
      final content = await file.readAsString();
      return _parseCsvContent(
        content: content,
        symbol: symbol,
        timeframe: timeframe,
      );
    } catch (e) {
      throw Exception(
        'Gagal mem-parsing CSV dari file: ${e.toString()}\n'
        'Hint: Pastikan format kolom adalah Date, Open, High, Low, Close, Volume (opsional).',
      );
    }
  }

  /// Parse CSV bytes (web-safe)
  Future<MarketData> parseCsvBytes({
    required Uint8List bytes,
    required String symbol,
    required String timeframe,
  }) async {
    try {
      final content = utf8.decode(bytes);
      return _parseCsvContent(
        content: content,
        symbol: symbol,
        timeframe: timeframe,
      );
    } catch (e) {
      throw Exception(
        'Gagal mem-parsing CSV (bytes): ${e.toString()}\n'
        'Hint: Periksa encoding UTF-8 dan susunan kolom sesuai format standar.',
      );
    }
  }

  /// Shared CSV parsing logic from string content
  MarketData _parseCsvContent({
    required String content,
    required String symbol,
    required String timeframe,
  }) {
    // Force LF line endings for consistency across platforms/tests
    final rows = const CsvToListConverter(eol: '\n').convert(content);

    if (rows.isEmpty) {
      throw Exception('CSV kosong: tidak ada baris data.');
    }

    // Detect if has header
    final hasHeader = _detectHeader(rows.first);
    final dataRows = hasHeader ? rows.skip(1).toList() : rows;

    // Validate format with helpful message
    final formatError = _validateCsvFormatError(dataRows);
    if (formatError != null) {
      throw Exception(
        'Format CSV tidak valid: $formatError\n'
        'Ekspektasi: kolom berurutan Date, Open, High, Low, Close, Volume (opsional).',
      );
    }

    // Parse candles
    final candles = <Candle>[];
    final rowErrors = <String>[];
    for (var i = 0; i < dataRows.length; i++) {
      final row = dataRows[i];
      final lineNumber = i + (hasHeader ? 2 : 1); // 1-based + header line
      try {
        final candle = Candle.fromCsvRow(row);
        candles.add(candle);
      } catch (e) {
        // Bangun pesan error dengan detail kolom dan nilai yang bermasalah
        final detailed = _describeRowError(row, lineNumber, e);
        rowErrors.add(detailed);
        debugPrint(detailed);
      }
    }

    if (candles.isEmpty) {
      final preview = rowErrors.take(5).join('\n- ');
      throw Exception(
        'Tidak ada baris valid yang berhasil diparsing dari CSV.\n'
        'Contoh error baris:\n- $preview\n'
        'Hint: Pastikan tiap baris memiliki nilai numerik untuk OHLC dan tanggal valid.',
      );
    }

    // Sort by timestamp ascending
    candles.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    return MarketData(
      id: _uuid.v4(),
      symbol: symbol,
      timeframe: timeframe,
      candles: candles,
      uploadedAt: DateTime.now(),
    );
  }

  /// Detect if first row is header
  bool _detectHeader(List<dynamic> firstRow) {
    if (firstRow.isEmpty) return false;

    // Check if first cell looks like a date or header text
    final firstCell = firstRow[0].toString().toLowerCase();
    return firstCell.contains('date') ||
        firstCell.contains('time') ||
        firstCell.contains('timestamp');
  }

  /// Validate CSV has required columns, return error message if invalid
  String? _validateCsvFormatError(List<List<dynamic>> rows) {
    if (rows.isEmpty) {
      return 'Tidak ada baris data setelah header';
    }

    final firstRow = rows.first;
    // Minimum: Date, O, H, L, C (Volume optional)
    if (firstRow.length < 5) {
      return 'Jumlah kolom terlalu sedikit (${firstRow.length}). Minimal 5 kolom: Date, Open, High, Low, Close.';
    }

    // Try parsing first row as validation and identify kolom yang gagal
    String? columnError;
    try {
      DateTime.parse(firstRow[0].toString());
    } catch (_) {
      columnError = "Baris pertama kolom 1 (Date) tidak valid: '${firstRow[0]}'";
    }
    if (columnError != null) return columnError;

    try {
      double.parse(firstRow[1].toString());
    } catch (_) {
      columnError = "Baris pertama kolom 2 (Open) bukan angka: '${firstRow[1]}'";
    }
    if (columnError != null) return columnError;

    try {
      double.parse(firstRow[2].toString());
    } catch (_) {
      columnError = "Baris pertama kolom 3 (High) bukan angka: '${firstRow[2]}'";
    }
    if (columnError != null) return columnError;

    try {
      double.parse(firstRow[3].toString());
    } catch (_) {
      columnError = "Baris pertama kolom 4 (Low) bukan angka: '${firstRow[3]}'";
    }
    if (columnError != null) return columnError;

    try {
      double.parse(firstRow[4].toString());
    } catch (_) {
      columnError = "Baris pertama kolom 5 (Close) bukan angka: '${firstRow[4]}'";
    }
    if (columnError != null) return columnError;

    return null;
  }

  /// Build detailed row error with line and column context
  String _describeRowError(List<dynamic> row, int lineNumber, Object error) {
    // Check each column validity to pin-point failing column
    String? reason;
    // Column names
    const names = ['Date', 'Open', 'High', 'Low', 'Close', 'Volume'];

    // Date
    try {
      DateTime.parse(row[0].toString());
    } catch (_) {
      reason = "Baris #$lineNumber kolom 1 (${names[0]}) tidak valid: '${row[0]}'";
      return reason;
    }

    // Numeric columns
    for (int i = 1; i <= 4; i++) {
      try {
        double.parse(row[i].toString());
      } catch (_) {
        reason = "Baris #$lineNumber kolom ${i + 1} (${names[i]}) bukan angka: '${row[i]}'";
        return reason;
      }
    }

    // Volume optional if exists
    if (row.length > 5) {
      try {
        double.parse(row[5].toString());
      } catch (_) {
        reason = "Baris #$lineNumber kolom 6 (${names[5]}) bukan angka: '${row[5]}'";
        return reason;
      }
    }

    // Fallback to original error
    return 'Baris #$lineNumber: $row. Error: $error';
  }

  /// Validate candle data integrity
  ValidationResult validateCandles(List<Candle> candles) {
    final errors = <String>[];

    if (candles.isEmpty) {
      errors.add('No candles to validate');
      return ValidationResult(isValid: false, errors: errors);
    }

    for (var i = 0; i < candles.length; i++) {
      final c = candles[i];

      // Check OHLC relationship
      if (c.high < c.low) {
        errors.add('Candle $i: High < Low');
      }
      if (c.high < c.open || c.high < c.close) {
        errors.add('Candle $i: High is not highest');
      }
      if (c.low > c.open || c.low > c.close) {
        errors.add('Candle $i: Low is not lowest');
      }

      // Check for zero/negative prices
      if (c.open <= 0 || c.high <= 0 || c.low <= 0 || c.close <= 0) {
        errors.add('Candle $i: Contains zero or negative prices');
      }
    }

    return ValidationResult(
      isValid: errors.isEmpty,
      errors: errors,
      totalCandles: candles.length,
    );
  }
}

class ValidationResult {
  final bool isValid;
  final List<String> errors;
  final int? totalCandles;

  ValidationResult({
    required this.isValid,
    required this.errors,
    this.totalCandles,
  });
}
