import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/services/data_parser_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:backtestx/models/candle.dart';

/// Seeds a locked sample market dataset so the app is usable out-of-box.
class SampleDataLoader {
  static const String assetPath = 'assets/sample_data/eurusd_h1_sample.csv';
  static const String sampleId = 'sample_eurusd_h1';
  static const String sampleSymbol = 'EURUSD';
  static const String sampleTimeframe = 'H1';

  /// Returns true if the sample was seeded, false if data already exists or seeding failed.
  static Future<bool> seedIfEmpty() async {
    final storage = locator<StorageService>();
    final existing = await storage.getAllMarketDataInfo();
    if (existing.isNotEmpty) return false;

    try {
      final csv = await rootBundle.loadString(assetPath);
      final bytes = Uint8List.fromList(utf8.encode(csv));
      final parser = locator<DataParserService>();
      var data = await parser.parseCsvBytes(
        bytes: bytes,
        symbol: sampleSymbol,
        timeframe: sampleTimeframe,
      );

      // Force a stable id so we can lock deletion and recognize the dataset.
      data = MarketData(
        id: sampleId,
        symbol: data.symbol,
        timeframe: data.timeframe,
        candles: data.candles,
        uploadedAt: DateTime.now(),
      );

      // Cache (memory + disk) and record metadata in DB
      await locator<DataManager>().cacheData(data);
      await storage.saveMarketData(data);
      return true;
    } catch (e) {
      // Non-fatal; app will still run but without data
      return false;
    }
  }

  /// Ensure the sample dataset exists; seed it only if missing.
  /// Returns true if sample is present (either pre-existing or newly seeded).
  static Future<bool> ensureSeeded() async {
    try {
      final storage = locator<StorageService>();
      final existing = await storage.getAllMarketDataInfo();
      final hasSample = existing.any((e) => e.id == sampleId);
      if (hasSample) return true;

      final csv = await rootBundle.loadString(assetPath);
      final bytes = Uint8List.fromList(utf8.encode(csv));
      final parser = locator<DataParserService>();
      var data = await parser.parseCsvBytes(
        bytes: bytes,
        symbol: sampleSymbol,
        timeframe: sampleTimeframe,
      );

      data = MarketData(
        id: sampleId,
        symbol: data.symbol,
        timeframe: data.timeframe,
        candles: data.candles,
        uploadedAt: DateTime.now(),
      );

      await locator<DataManager>().cacheData(data);
      await storage.saveMarketData(data);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Convenience: check whether a given id is the locked sample dataset.
  static bool isSampleId(String id) =>
      id == sampleId || id.startsWith('sample_');
}
