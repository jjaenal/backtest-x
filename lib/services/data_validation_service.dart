import 'dart:math';

import 'package:flutter/material.dart';

import '../models/candle.dart';

/// Service untuk validasi kualitas market data
class DataValidationService {
  /// Validate market data dan return hasil validasi
  ValidationResult validateMarketData(MarketData marketData) {
    final issues = <ValidationIssue>[];
    final warnings = <String>[];

    // Basic validation
    if (!marketData.isValid) {
      issues.add(ValidationIssue(
        severity: IssueSeverity.error,
        message: 'Invalid market data: empty or missing required fields',
        type: IssueType.structure,
      ));
    }

    // Check minimum candles
    if (marketData.candlesCount < 100) {
      warnings.add(
          'Limited data: Only ${marketData.candlesCount} candles available. '
          'Minimum 100 recommended for accurate analysis.');
    }

    // Check for gaps
    if (marketData.hasGaps) {
      issues.add(ValidationIssue(
        severity: IssueSeverity.warning,
        message: 'Data contains gaps in timestamps',
        type: IssueType.gaps,
      ));
    }

    // Check volume data
    if (!marketData.hasVolumeData) {
      warnings.add(
          'No volume data available. Some indicators may not work properly.');
    }

    // Validate individual candles
    final candleIssues = _validateCandles(marketData.candles);
    issues.addAll(candleIssues);

    // Check for duplicates
    final duplicates = _checkDuplicateTimestamps(marketData.candles);
    if (duplicates.isNotEmpty) {
      issues.add(ValidationIssue(
        severity: IssueSeverity.error,
        message: 'Found ${duplicates.length} duplicate timestamps',
        type: IssueType.duplicates,
        details: duplicates,
      ));
    }

    // Check chronological order
    if (!_isChronological(marketData.candles)) {
      issues.add(ValidationIssue(
        severity: IssueSeverity.error,
        message: 'Candles are not in chronological order',
        type: IssueType.order,
      ));
    }

    // Statistical anomalies
    final anomalies = _detectAnomalies(marketData.candles);
    issues.addAll(anomalies);

    return ValidationResult(
      isValid: issues.where((i) => i.severity == IssueSeverity.error).isEmpty,
      issues: issues,
      warnings: warnings,
      summary: _generateSummary(issues, warnings),
    );
  }

  /// Validate individual candles
  List<ValidationIssue> _validateCandles(List<Candle> candles) {
    final issues = <ValidationIssue>[];

    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];

      // Check OHLC relationship
      if (candle.high < candle.low) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.error,
          message: 'Candle #$i: High (${{
            candle.high
          }}) is less than Low (${candle.low})',
          type: IssueType.invalidPrice,
          candleIndex: i,
        ));
      }

      if (candle.close > candle.high || candle.close < candle.low) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.error,
          message:
              'Candle #$i: Close (${candle.close}) is outside High-Low range',
          type: IssueType.invalidPrice,
          candleIndex: i,
        ));
      }

      if (candle.open > candle.high || candle.open < candle.low) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.error,
          message:
              'Candle #$i: Open (${candle.open}) is outside High-Low range',
          type: IssueType.invalidPrice,
          candleIndex: i,
        ));
      }

      // Check for zero/negative prices
      if (candle.open <= 0 ||
          candle.high <= 0 ||
          candle.low <= 0 ||
          candle.close <= 0) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.error,
          message: 'Candle #$i: Contains zero or negative prices',
          type: IssueType.invalidPrice,
          candleIndex: i,
        ));
      }

      // Check for zero range (suspicious)
      if (candle.high == candle.low) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.warning,
          message: 'Candle #$i: Zero range (High equals Low)',
          type: IssueType.suspicious,
          candleIndex: i,
        ));
      }

      // Check for negative volume
      if (candle.volume < 0) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.error,
          message: 'Candle #$i: Negative volume',
          type: IssueType.invalidVolume,
          candleIndex: i,
        ));
      }
    }

    return issues;
  }

  /// Check for duplicate timestamps
  List<DateTime> _checkDuplicateTimestamps(List<Candle> candles) {
    final seen = <DateTime>{};
    final duplicates = <DateTime>[];

    for (var candle in candles) {
      if (seen.contains(candle.timestamp)) {
        if (!duplicates.contains(candle.timestamp)) {
          duplicates.add(candle.timestamp);
        }
      } else {
        seen.add(candle.timestamp);
      }
    }

    return duplicates;
  }

  /// Check if candles are in chronological order
  bool _isChronological(List<Candle> candles) {
    for (int i = 1; i < candles.length; i++) {
      if (candles[i].timestamp.isBefore(candles[i - 1].timestamp)) {
        return false;
      }
    }
    return true;
  }

  /// Detect statistical anomalies
  List<ValidationIssue> _detectAnomalies(List<Candle> candles) {
    if (candles.length < 20) return [];

    final issues = <ValidationIssue>[];

    // Calculate average price and standard deviation
    final prices = candles.map((c) => c.close).toList();
    final avgPrice = prices.reduce((a, b) => a + b) / prices.length;

    final variance = prices.map((p) {
          final diff = p - avgPrice;
          return diff * diff;
        }).reduce((a, b) => a + b) /
        prices.length;

    final stdDev = sqrt(variance);
    final threshold = stdDev * 3; // 3 standard deviations

    // Find outliers
    for (int i = 0; i < candles.length; i++) {
      final candle = candles[i];

      if ((candle.close - avgPrice).abs() > threshold) {
        issues.add(ValidationIssue(
          severity: IssueSeverity.warning,
          message:
              'Candle #$i: Price outlier detected (${candle.close.toStringAsFixed(4)})',
          type: IssueType.outlier,
          candleIndex: i,
        ));
      }

      // Check for extreme spikes
      if (i > 0) {
        final priceChange = candle.priceChangePercent(candles[i - 1]);
        if (priceChange.abs() > 10) {
          issues.add(ValidationIssue(
            severity: IssueSeverity.warning,
            message:
                'Candle #$i: Extreme price movement (${priceChange.toStringAsFixed(2)}%)',
            type: IssueType.spike,
            candleIndex: i,
          ));
        }
      }
    }

    return issues;
  }

  /// Generate summary text
  String _generateSummary(List<ValidationIssue> issues, List<String> warnings) {
    final errorCount =
        issues.where((i) => i.severity == IssueSeverity.error).length;
    final warningCount =
        issues.where((i) => i.severity == IssueSeverity.warning).length;

    if (errorCount == 0 && warningCount == 0 && warnings.isEmpty) {
      return 'Data validation passed with no issues.';
    }

    final buffer = StringBuffer();

    if (errorCount > 0) {
      buffer.write('Found $errorCount critical error(s). ');
    }

    if (warningCount > 0) {
      buffer.write('Found $warningCount warning(s). ');
    }

    if (warnings.isNotEmpty) {
      buffer.write('${warnings.length} general warning(s).');
    }

    return buffer.toString().trim();
  }

  /// Quick validation (fast checks only)
  bool quickValidate(MarketData marketData) {
    if (marketData.candles.isEmpty) return false;
    if (marketData.symbol.isEmpty) return false;

    // Check first few candles for basic validity
    final sampleSize =
        marketData.candles.length < 10 ? marketData.candles.length : 10;

    for (int i = 0; i < sampleSize; i++) {
      final candle = marketData.candles[i];

      if (candle.high < candle.low) return false;
      if (candle.close > candle.high || candle.close < candle.low) return false;
      if (candle.open > candle.high || candle.open < candle.low) return false;
      if (candle.open <= 0 ||
          candle.high <= 0 ||
          candle.low <= 0 ||
          candle.close <= 0) return false;
    }

    return true;
  }
}

// ========== MODELS ==========

class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final List<String> warnings;
  final String summary;

  ValidationResult({
    required this.isValid,
    required this.issues,
    required this.warnings,
    required this.summary,
  });

  bool get hasErrors => issues.any((i) => i.severity == IssueSeverity.error);
  bool get hasWarnings =>
      issues.any((i) => i.severity == IssueSeverity.warning) ||
      warnings.isNotEmpty;

  int get errorCount =>
      issues.where((i) => i.severity == IssueSeverity.error).length;
  int get warningCount =>
      issues.where((i) => i.severity == IssueSeverity.warning).length;

  List<ValidationIssue> get errors =>
      issues.where((i) => i.severity == IssueSeverity.error).toList();
  List<ValidationIssue> get warningsIssues =>
      issues.where((i) => i.severity == IssueSeverity.warning).toList();

  /// Export to readable text
  String toDetailedReport() {
    final buffer = StringBuffer();

    buffer.writeln('Data Validation Report');
    buffer.writeln('=' * 50);
    buffer.writeln();
    buffer.writeln('Status: ${isValid ? "PASSED" : "FAILED"}');
    buffer.writeln('Summary: $summary');
    buffer.writeln();

    if (hasErrors) {
      buffer.writeln('ERRORS (${errorCount}):');
      buffer.writeln('-' * 50);
      for (var issue in errors) {
        buffer.writeln('• ${issue.message}');
        if (issue.candleIndex != null) {
          buffer.writeln('  At candle index: ${issue.candleIndex}');
        }
      }
      buffer.writeln();
    }

    if (hasWarnings) {
      buffer.writeln('WARNINGS (${warningCount + warnings.length}):');
      buffer.writeln('-' * 50);
      for (var issue in warningsIssues) {
        buffer.writeln('• ${issue.message}');
      }
      for (var warning in warnings) {
        buffer.writeln('• $warning');
      }
      buffer.writeln();
    }

    if (!hasErrors && !hasWarnings) {
      buffer.writeln('No issues found. Data is clean!');
    }

    return buffer.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'isValid': isValid,
      'summary': summary,
      'errorCount': errorCount,
      'warningCount': warningCount,
      'issues': issues.map((i) => i.toJson()).toList(),
      'warnings': warnings,
    };
  }
}

class ValidationIssue {
  final IssueSeverity severity;
  final String message;
  final IssueType type;
  final int? candleIndex;
  final List<dynamic>? details;

  ValidationIssue({
    required this.severity,
    required this.message,
    required this.type,
    this.candleIndex,
    this.details,
  });

  Color get severityColor {
    switch (severity) {
      case IssueSeverity.error:
        return Colors.red;
      case IssueSeverity.warning:
        return Colors.orange;
      case IssueSeverity.info:
        return Colors.blue;
    }
  }

  IconData get severityIcon {
    switch (severity) {
      case IssueSeverity.error:
        return Icons.error;
      case IssueSeverity.warning:
        return Icons.warning;
      case IssueSeverity.info:
        return Icons.info;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'severity': severity.toString(),
      'message': message,
      'type': type.toString(),
      'candleIndex': candleIndex,
      'details': details,
    };
  }
}

enum IssueSeverity {
  error, // Critical issues that prevent analysis
  warning, // Issues that may affect accuracy
  info, // Informational notices
}

enum IssueType {
  structure, // Basic structure problems
  invalidPrice, // Price validation failures
  invalidVolume, // Volume validation failures
  gaps, // Missing data/gaps
  duplicates, // Duplicate timestamps
  order, // Chronological order issues
  suspicious, // Suspicious patterns
  outlier, // Statistical outliers
  spike, // Extreme price movements
}
