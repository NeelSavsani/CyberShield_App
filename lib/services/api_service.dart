import 'dart:async';
import 'dart:typed_data';
import '../models/scan_result.dart';
import 'threat_engine.dart';

/// Service gateway delegating all analysis directly to the Autonomous Threat Engine
class ApiService {
  static Future<bool> checkHealth() async {
    // Autonomous engine is always operational on-device
    return true;
  }

  static Future<ScanResult> analyzeUrl({
    required String url,
    bool? useTrainedModel,
    void Function(String stage)? onProgress,
  }) async {
    return await ThreatEngine.analyzeUrl(
      url: url,
      useTrainedModel: useTrainedModel,
      onProgress: onProgress,
    );
  }

  static Future<ScanResult> analyzeQrBytes({
    required Uint8List imageBytes,
    required String fileName,
    void Function(String stage)? onProgress,
  }) async {
    return await ThreatEngine.analyzeQrBytes(
      imageBytes: imageBytes,
      fileName: fileName,
      onProgress: onProgress,
    );
  }
}
