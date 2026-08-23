import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result.dart';

class StorageService {
  static const String _keyHistory = 'cybershield_history';
  static const String _keySensitivity = 'cybershield_sensitivity';
  static const String _keyUseTrainedModel = 'cybershield_use_trained_model';
  static const String _keySoundEnabled = 'cybershield_sound_enabled';
  static const String _keyHomographCheck = 'cybershield_homograph_check';

  static Future<List<ScanResult>> getScanHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_keyHistory);
    if (jsonStr == null || jsonStr.isEmpty) return _getInitialSeedHistory();
    try {
      final List decoded = jsonDecode(jsonStr);
      return decoded.map((item) => ScanResult.fromJson(item)).toList();
    } catch (_) {
      return _getInitialSeedHistory();
    }
  }

  static Future<void> saveScan(ScanResult result) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getScanHistory();
    // Prepend new scan
    history.removeWhere((item) => item.id == result.id);
    history.insert(0, result);
    // Keep max 50 items
    if (history.length > 50) history.removeLast();
    final jsonList = history.map((item) => item.toJson()).toList();
    await prefs.setString(_keyHistory, jsonEncode(jsonList));
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHistory);
  }

  static Future<String> getEngineSensitivity() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySensitivity) ?? 'standard';
  }

  static Future<void> setEngineSensitivity(String sensitivity) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySensitivity, sensitivity);
  }

  static Future<bool> getUseTrainedModel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyUseTrainedModel) ?? true;
  }

  static Future<void> setUseTrainedModel(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyUseTrainedModel, value);
  }

  static Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySoundEnabled) ?? true;
  }

  static Future<void> setSoundEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySoundEnabled, value);
  }

  static Future<bool> getHomographCheckEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHomographCheck) ?? true;
  }

  static Future<void> setHomographCheckEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHomographCheck, value);
  }

  static List<ScanResult> _getInitialSeedHistory() {
    return [
      ScanResult(
        id: 'seed-1',
        url: 'https://secure-login-verify-account-update.xyz/auth',
        targetUrl: 'https://secure-login-verify-account-update.xyz/auth',
        verdict: 'phishing',
        riskScore: 94,
        confidence: 0.98,
        analyzedAt: DateTime.now().subtract(const Duration(minutes: 15)),
        durationMs: 1420,
        classifier: 'evidence-baseline-v1',
        indicators: [
          'Domain is 2 days old (critical risk)',
          'Form submits password to external endpoint',
          'Let\'s Encrypt certificate issued 48 hours ago',
          'Hidden iframe detected in DOM tree',
        ],
        contributors: [
          EvidenceContributor(feature: 'domain_age_risk', weight: 0.35, description: 'Domain registered 2 days ago'),
          EvidenceContributor(feature: 'cross_domain_form_actions', weight: 0.28, description: 'Form posts data to 185.220.101.5'),
          EvidenceContributor(feature: 'password_field_count', weight: 0.20, description: '2 unencrypted password inputs'),
          EvidenceContributor(feature: 'hidden_iframe_count', weight: 0.17, description: '1 obscured tracking frame'),
        ],
      ),
      ScanResult(
        id: 'seed-2',
        url: 'https://github.com/login',
        targetUrl: 'https://github.com/login',
        verdict: 'safe',
        riskScore: 4,
        confidence: 0.99,
        analyzedAt: DateTime.now().subtract(const Duration(hours: 2)),
        durationMs: 890,
        classifier: 'evidence-baseline-v1',
        indicators: [
          'Established domain registered over 6,000 days ago',
          'Extended Validation DigiCert TLS certificate',
          'DNSSEC securely validated',
        ],
        contributors: [
          EvidenceContributor(feature: 'domain_age_days', weight: 0.02, description: 'Long-standing legitimate domain'),
          EvidenceContributor(feature: 'has_valid_tls', weight: 0.01, description: 'Strong enterprise TLS'),
        ],
      ),
      ScanResult(
        id: 'seed-3',
        url: 'http://tracking-package-update.tk/invoice.php',
        targetUrl: 'http://tracking-package-update.tk/invoice.php',
        verdict: 'suspicious',
        riskScore: 58,
        confidence: 0.88,
        analyzedAt: DateTime.now().subtract(const Duration(hours: 5)),
        durationMs: 1150,
        classifier: 'evidence-baseline-v1',
        indicators: [
          'Unencrypted HTTP connection on payment gateway',
          'Free TLD (.tk) known for temporary abuse campaigns',
          'Multiple redirect hops across 3 different domains',
        ],
        contributors: [
          EvidenceContributor(feature: 'insecure_form_actions', weight: 0.32, description: 'Data sent over unencrypted HTTP'),
          EvidenceContributor(feature: 'redirect_count', weight: 0.26, description: '3 redirect hops before landing'),
        ],
      ),
    ];
  }
}
