import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';

class ScanProvider extends ChangeNotifier {
  bool _isScanning = false;
  String _currentStage = '';
  ScanResult? _activeResult;
  String? _errorMessage;
  List<ScanResult> _history = [];
  bool _isEngineReady = true;
  String _activeFilter = 'all'; // all, safe, suspicious, phishing

  bool get isScanning => _isScanning;
  String get currentStage => _currentStage;
  ScanResult? get activeResult => _activeResult;
  String? get errorMessage => _errorMessage;
  List<ScanResult> get history => _history;
  bool get isBackendOnline => _isEngineReady;
  bool get isEngineReady => _isEngineReady;
  String get activeFilter => _activeFilter;

  List<ScanResult> get filteredHistory {
    if (_activeFilter == 'all') return _history;
    return _history.where((s) => s.verdict.toLowerCase() == _activeFilter.toLowerCase()).toList();
  }

  int get totalScans => _history.length;
  int get phishingDetected => _history.where((s) => s.isPhishing).length;
  int get safeUrls => _history.where((s) => s.isSafe).length;
  int get suspiciousUrls => _history.where((s) => s.isSuspicious).length;

  ScanProvider() {
    loadHistory();
    checkHealth();
  }

  Future<void> loadHistory() async {
    _history = await StorageService.getScanHistory();
    notifyListeners();
  }

  Future<void> checkHealth() async {
    _isEngineReady = await ApiService.checkHealth();
    notifyListeners();
  }

  void setFilter(String filter) {
    _activeFilter = filter;
    notifyListeners();
  }

  void setActiveResult(ScanResult result) {
    _activeResult = result;
    notifyListeners();
  }

  Future<ScanResult?> scanUrl(String url) async {
    if (url.trim().isEmpty) return null;

    _isScanning = true;
    _currentStage = 'Initializing CyberShield Threat Engine...';
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.analyzeUrl(
        url: url,
        onProgress: (stage) {
          _currentStage = stage;
          notifyListeners();
        },
      );

      _activeResult = result;
      await StorageService.saveScan(result);
      await loadHistory();
      _isScanning = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isScanning = false;
      notifyListeners();
      return null;
    }
  }

  Future<ScanResult?> scanQrImage(Uint8List bytes, String filename) async {
    _isScanning = true;
    _currentStage = 'Parsing QR Code & Decoding Embedded URL...';
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await ApiService.analyzeQrBytes(
        imageBytes: bytes,
        fileName: filename,
        onProgress: (stage) {
          _currentStage = stage;
          notifyListeners();
        },
      );

      _activeResult = result;
      await StorageService.saveScan(result);
      await loadHistory();
      _isScanning = false;
      notifyListeners();
      return result;
    } catch (e) {
      _errorMessage = e.toString();
      _isScanning = false;
      notifyListeners();
      return null;
    }
  }

  Future<void> clearAllHistory() async {
    await StorageService.clearHistory();
    _history = [];
    notifyListeners();
  }
}
