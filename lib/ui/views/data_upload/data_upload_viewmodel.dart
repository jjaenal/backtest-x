import 'dart:io';
import 'package:backtestx/app/app.locator.dart';
import 'package:backtestx/models/candle.dart';
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

  final symbolController = TextEditingController();

  String? selectedFileName;
  File? selectedFile;
  String? selectedTimeframe = 'H1';
  ValidationResult? validationResult;
  List<MarketData> recentUploads = [];

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
  }

  Future<void> _loadRecentUploads() async {
    try {
      recentUploads = await _storageService.getAllMarketData();
      notifyListeners();
    } catch (e) {
      print('Error loading recent uploads: $e');
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
      // Parse CSV
      final marketData = await _dataParserService.parseCsvFile(
        file: selectedFile!,
        symbol: symbolController.text.trim().toUpperCase(),
        timeframe: selectedTimeframe!,
      );

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

      // Save to database
      await _storageService.saveMarketData(marketData);

      _snackbarService.showSnackbar(
        message:
            'Data uploaded successfully! ${marketData.candles.length} candles processed.',
        duration: const Duration(seconds: 3),
      );

      // Reset form
      selectedFile = null;
      selectedFileName = null;
      symbolController.clear();
      validationResult = null;

      // Reload recent uploads
      await _loadRecentUploads();
    } catch (e) {
      _snackbarService.showSnackbar(
        message: 'Upload failed: $e',
        duration: const Duration(seconds: 3),
      );
      print('Upload error: $e');
    } finally {
      setBusy(false);
    }
  }

  Future<void> deleteMarketData(String id) async {
    try {
      await _storageService.deleteMarketData(id);
      await _loadRecentUploads();

      _snackbarService.showSnackbar(
        message: 'Data deleted successfully',
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
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
