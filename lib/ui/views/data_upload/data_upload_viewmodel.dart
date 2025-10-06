import 'dart:io';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/core/data_manager.dart';
import 'package:backtestx/services/data_parser_service.dart';
import 'package:backtestx/services/storage_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

class DataUploadViewModel extends BaseViewModel {
  final _dataParserService = locator<DataParserService>();
  final _storageService = locator<StorageService>();
  final _snackbarService = locator<SnackbarService>();
  final _dataManager = DataManager();

  final symbolController = TextEditingController();

  String? selectedFileName;
  File? selectedFile;
  String? selectedTimeframe = 'H1';
  ValidationResult? validationResult;
  List<MarketDataInfo> recentUploads = [];

  final List<String> timeframes = [
    '1m',
    '5m',
    '15m',
    '30m',
    'H1',
    'H4',
    'D1',
    'W1',
    'MN'
  ];

  bool get canUpload =>
      selectedFile != null &&
      symbolController.text.isNotEmpty &&
      selectedTimeframe != null;

  Future<void> initialize() async {
    await _loadRecentUploads();
    _printCacheInfo();
  }

  void _printCacheInfo() {
    debugPrint('\n📊 CACHE INFO:');
    debugPrint(_dataManager.getCacheInfo());
    debugPrint('Memory usage: ${_dataManager.getMemoryUsageFormatted()}');

    final allData = _dataManager.getAllData();
    debugPrint('Total cached datasets: ${allData.length}');
    for (final data in allData) {
      debugPrint(
          '  - ${data.id}: ${data.symbol} ${data.timeframe} (${data.candles.length} candles)');
    }
  }

  Future<void> _loadRecentUploads() async {
    try {
      recentUploads = await _storageService.getAllMarketDataInfo();
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading recent uploads: $e');
    }
  }

  Future<void> pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null && result.files.single.path != null) {
        selectedFile = File(result.files.single.path!);
        selectedFileName = result.files.single.name;
        validationResult = null;
        notifyListeners();
      }
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Error picking file: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  void setTimeframe(String? value) {
    selectedTimeframe = value;
    notifyListeners();
  }

  Future<void> uploadData() async {
    if (!canUpload) return;

    setBusy(true);
    try {
      debugPrint('\n🚀 Starting upload process...');

      // Parse CSV
      debugPrint('📄 Parsing CSV file: ${selectedFile!.path}');
      final marketData = await _dataParserService.parseCsvFile(
        file: selectedFile!,
        symbol: symbolController.text.trim().toUpperCase(),
        timeframe: selectedTimeframe!,
      );

      debugPrint('✅ Parsed ${marketData.candles.length} candles');
      debugPrint('   ID: ${marketData.id}');
      debugPrint('   Symbol: ${marketData.symbol}');
      debugPrint('   Timeframe: ${marketData.timeframe}');

      // Validate
      validationResult = _dataParserService.validateCandles(marketData.candles);
      notifyListeners();

      if (!validationResult!.isValid) {
        _snackbarService.showSnackbar(
          message: 'Validation failed. Check errors below.',
          duration: const Duration(seconds: 3),
        );
        return;
      }

      // CRITICAL: Cache market data in memory + disk (persistent!)
      debugPrint('\n📦 Caching market data (memory + disk)...');
      await _dataManager.cacheData(marketData);
      debugPrint('✅ Data cached successfully!');
      debugPrint('   Cache ID: ${marketData.id}');

      // Verify cache
      final cachedData = _dataManager.getData(marketData.id);
      if (cachedData != null) {
        debugPrint('✅ Verified: Data is in cache');
      } else {
        debugPrint('❌ ERROR: Data not found in cache after caching!');
      }

      // Save metadata only to database
      debugPrint('\n💾 Saving metadata to database...');
      await _storageService.saveMarketData(marketData);
      debugPrint('✅ Metadata saved to database');

      _snackbarService.showSnackbar(
        message:
            'Data uploaded successfully! ${marketData.candles.length} candles processed.',
        duration: const Duration(seconds: 3),
      );

      // Print cache info
      debugPrint('\n📊 Current cache state:');
      _printCacheInfo();

      // Reset form
      selectedFile = null;
      selectedFileName = null;
      symbolController.clear();
      validationResult = null;

      // Reload recent uploads
      await _loadRecentUploads();

      debugPrint('\n✅ Upload process completed successfully!');
    } catch (e, stackTrace) {
      debugPrint('❌ Upload error: $e');
      debugPrint('Stack trace: $stackTrace');
      _snackbarService.showSnackbar(
        message: 'Upload failed: $e',
        duration: const Duration(seconds: 3),
      );
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteMarketData(String id) async {
    try {
      debugPrint('\n🗑️  Deleting market data: $id');

      // Remove from database
      await _storageService.deleteMarketData(id);
      debugPrint('✅ Deleted from database');

      // Remove from cache
      _dataManager.removeData(id);
      debugPrint('✅ Removed from cache');

      await _loadRecentUploads();

      _snackbarService.showSnackbar(
        message: 'Data deleted successfully',
        duration: const Duration(seconds: 2),
      );

      _printCacheInfo();
    } catch (e) {
      debugPrint('❌ Delete error: $e');
      _snackbarService.showSnackbar(
        message: 'Delete failed: $e',
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  void dispose() {
    symbolController.dispose();
    super.dispose();
  }
}
