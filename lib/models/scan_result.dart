class ScanResult {
  final String id;
  final String url;
  final String? targetUrl;
  final String? finalUrl;
  final List<String> redirectChain;
  final String verdict; // 'safe', 'suspicious', 'phishing'
  final int riskScore; // 0 - 100
  final double confidence;
  final DateTime analyzedAt;
  final int? durationMs;
  final String classifier;
  final String? screenshotUrl;
  final String? screenshotBase64;
  final List<String> indicators;
  final Map<String, dynamic> features;
  final List<EvidenceContributor> contributors;
  final DnsMetadata? dns;
  final SslMetadata? ssl;
  final DomMetadata? dom;
  final JsMetadata? js;
  final ReputationMetadata? reputation;

  ScanResult({
    required this.id,
    required this.url,
    this.targetUrl,
    this.finalUrl,
    this.redirectChain = const [],
    required this.verdict,
    required this.riskScore,
    this.confidence = 0.95,
    required this.analyzedAt,
    this.durationMs,
    this.classifier = 'evidence-baseline-v1',
    this.screenshotUrl,
    this.screenshotBase64,
    this.indicators = const [],
    this.features = const {},
    this.contributors = const [],
    this.dns,
    this.ssl,
    this.dom,
    this.js,
    this.reputation,
  });

  bool get isSafe => verdict.toLowerCase() == 'safe';
  bool get isSuspicious => verdict.toLowerCase() == 'suspicious';
  bool get isPhishing => verdict.toLowerCase() == 'phishing' || verdict.toLowerCase() == 'malicious';

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    // Check root data envelope
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final classification = (data['classification'] is Map<String, dynamic>)
        ? data['classification']
        : (json['classification'] is Map<String, dynamic> ? json['classification'] : {});

    final rawFeatures = (data['features'] is Map<String, dynamic>)
        ? data['features'] as Map<String, dynamic>
        : (json['features'] is Map<String, dynamic> ? json['features'] as Map<String, dynamic> : <String, dynamic>{});

    // Parse risk score
    int score = 0;
    if (classification['risk_score'] != null) {
      score = (classification['risk_score'] as num).toInt();
    } else if (json['risk_score'] != null) {
      score = (json['risk_score'] as num).toInt();
    } else if (classification['phishing_probability'] != null) {
      score = ((classification['phishing_probability'] as num) * 100).round();
    }

    String verdict = classification['verdict'] ?? json['verdict'] ?? (score >= 70 ? 'phishing' : (score >= 40 ? 'suspicious' : 'safe'));

    // Extract contributors
    List<EvidenceContributor> contributorsList = [];
    if (classification['contributors'] is List) {
      contributorsList = (classification['contributors'] as List)
          .map((c) => EvidenceContributor.fromJson(c is Map<String, dynamic> ? c : {'feature': c.toString(), 'weight': 0.1}))
          .toList();
    } else if (classification['explanations'] is List) {
      contributorsList = (classification['explanations'] as List)
          .map((c) => EvidenceContributor.fromJson(c is Map<String, dynamic> ? c : {'feature': c.toString(), 'weight': 0.1}))
          .toList();
    }

    // Extract indicators
    List<String> inds = [];
    if (classification['indicators'] is List) {
      inds = List<String>.from(classification['indicators']);
    } else if (json['indicators'] is List) {
      inds = List<String>.from(json['indicators']);
    }

    // Extract DNS
    final dnsRaw = data['dns'] is Map<String, dynamic> ? data['dns'] : json['dns'];
    final sslRaw = data['ssl'] is Map<String, dynamic> ? data['ssl'] : json['ssl'];
    final domRaw = data['dom'] is Map<String, dynamic> ? data['dom'] : json['dom'];
    final jsRaw = data['javascript'] is Map<String, dynamic> ? data['javascript'] : json['javascript'];
    final repRaw = data['reputation'] is Map<String, dynamic> ? data['reputation'] : json['reputation'];

    return ScanResult(
      id: json['job_id'] ?? json['id'] ?? data['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      url: json['url'] ?? data['url'] ?? 'https://example.com',
      targetUrl: data['target_url'] ?? json['target_url'],
      finalUrl: data['final_url'] ?? json['final_url'],
      redirectChain: (data['redirect_chain'] is List)
          ? List<String>.from(data['redirect_chain'])
          : (json['redirect_chain'] is List ? List<String>.from(json['redirect_chain']) : []),
      verdict: verdict,
      riskScore: score,
      confidence: (classification['confidence'] is num) ? (classification['confidence'] as num).toDouble() : 0.95,
      analyzedAt: json['analyzed_at'] != null ? DateTime.tryParse(json['analyzed_at'].toString()) ?? DateTime.now() : DateTime.now(),
      durationMs: json['scan_duration_ms'] ?? data['scan_duration_ms'],
      classifier: classification['model'] ?? json['classifier'] ?? 'evidence-baseline-v1',
      screenshotUrl: data['screenshot_url'] ?? json['screenshot_url'],
      screenshotBase64: data['screenshot_base64'] ?? json['screenshot_base64'],
      indicators: inds,
      features: rawFeatures,
      contributors: contributorsList,
      dns: dnsRaw != null ? DnsMetadata.fromJson(dnsRaw) : null,
      ssl: sslRaw != null ? SslMetadata.fromJson(sslRaw) : null,
      dom: domRaw != null ? DomMetadata.fromJson(domRaw) : null,
      js: jsRaw != null ? JsMetadata.fromJson(jsRaw) : null,
      reputation: repRaw != null ? ReputationMetadata.fromJson(repRaw) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'url': url,
    'target_url': targetUrl,
    'final_url': finalUrl,
    'redirect_chain': redirectChain,
    'verdict': verdict,
    'risk_score': riskScore,
    'confidence': confidence,
    'analyzed_at': analyzedAt.toIso8601String(),
    'scan_duration_ms': durationMs,
    'classifier': classifier,
    'screenshot_url': screenshotUrl,
    'screenshot_base64': screenshotBase64,
    'indicators': indicators,
    'features': features,
    'contributors': contributors.map((c) => c.toJson()).toList(),
    'dns': dns?.toJson(),
    'ssl': ssl?.toJson(),
    'dom': dom?.toJson(),
    'javascript': js?.toJson(),
    'reputation': reputation?.toJson(),
  };
}

class EvidenceContributor {
  final String feature;
  final double weight;
  final String description;
  final String? humanLabel;

  EvidenceContributor({
    required this.feature,
    required this.weight,
    this.description = '',
    this.humanLabel,
  });

  factory EvidenceContributor.fromJson(Map<String, dynamic> json) {
    return EvidenceContributor(
      feature: json['feature'] ?? json['name'] ?? 'Indicator',
      weight: (json['weight'] is num) ? (json['weight'] as num).toDouble() : 0.0,
      description: json['description'] ?? json['reason'] ?? '',
      humanLabel: json['human_label'] ?? json['label'],
    );
  }

  Map<String, dynamic> toJson() => {
    'feature': feature,
    'weight': weight,
    'description': description,
    'human_label': humanLabel,
  };
}

class DnsMetadata {
  final int? domainAgeDays;
  final bool dnssecEnabled;
  final List<String> aRecords;
  final List<String> nsRecords;
  final List<String> mxRecords;
  final String? registrar;

  DnsMetadata({
    this.domainAgeDays,
    this.dnssecEnabled = false,
    this.aRecords = const [],
    this.nsRecords = const [],
    this.mxRecords = const [],
    this.registrar,
  });

  factory DnsMetadata.fromJson(Map<String, dynamic> json) {
    return DnsMetadata(
      domainAgeDays: json['domain_age_days'] is num ? (json['domain_age_days'] as num).toInt() : null,
      dnssecEnabled: json['dnssec_enabled'] == true || json['dnssec_enabled'] == 1,
      aRecords: json['a_records'] is List ? List<String>.from(json['a_records']) : [],
      nsRecords: json['ns_records'] is List ? List<String>.from(json['ns_records']) : [],
      mxRecords: json['mx_records'] is List ? List<String>.from(json['mx_records']) : [],
      registrar: json['registrar']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'domain_age_days': domainAgeDays,
    'dnssec_enabled': dnssecEnabled,
    'a_records': aRecords,
    'ns_records': nsRecords,
    'mx_records': mxRecords,
    'registrar': registrar,
  };
}

class SslMetadata {
  final bool hasValidTls;
  final int? certificateAgeDays;
  final String? issuer;
  final String? protocol;
  final String? validTo;

  SslMetadata({
    this.hasValidTls = true,
    this.certificateAgeDays,
    this.issuer,
    this.protocol,
    this.validTo,
  });

  factory SslMetadata.fromJson(Map<String, dynamic> json) {
    return SslMetadata(
      hasValidTls: json['has_valid_tls'] == true || json['has_valid_tls'] == 1 || json['valid'] == true,
      certificateAgeDays: json['certificate_age_days'] is num ? (json['certificate_age_days'] as num).toInt() : null,
      issuer: json['issuer']?.toString(),
      protocol: json['protocol']?.toString(),
      validTo: json['valid_to']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
    'has_valid_tls': hasValidTls,
    'certificate_age_days': certificateAgeDays,
    'issuer': issuer,
    'protocol': protocol,
    'valid_to': validTo,
  };
}

class DomMetadata {
  final int passwordFieldCount;
  final int otpFieldCount;
  final int creditCardFieldCount;
  final int hiddenIframeCount;
  final int crossDomainFormActions;
  final int insecureFormActions;

  DomMetadata({
    this.passwordFieldCount = 0,
    this.otpFieldCount = 0,
    this.creditCardFieldCount = 0,
    this.hiddenIframeCount = 0,
    this.crossDomainFormActions = 0,
    this.insecureFormActions = 0,
  });

  factory DomMetadata.fromJson(Map<String, dynamic> json) {
    return DomMetadata(
      passwordFieldCount: json['password_field_count'] ?? 0,
      otpFieldCount: json['otp_field_count'] ?? 0,
      creditCardFieldCount: json['credit_card_field_count'] ?? 0,
      hiddenIframeCount: json['hidden_iframe_count'] ?? 0,
      crossDomainFormActions: json['cross_domain_form_actions'] ?? 0,
      insecureFormActions: json['insecure_form_actions'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'password_field_count': passwordFieldCount,
    'otp_field_count': otpFieldCount,
    'credit_card_field_count': creditCardFieldCount,
    'hidden_iframe_count': hiddenIframeCount,
    'cross_domain_form_actions': crossDomainFormActions,
    'insecure_form_actions': insecureFormActions,
  };
}

class JsMetadata {
  final int obfuscatedScriptCount;
  final int popupCount;
  final int downloadCount;
  final int javascriptErrorCount;

  JsMetadata({
    this.obfuscatedScriptCount = 0,
    this.popupCount = 0,
    this.downloadCount = 0,
    this.javascriptErrorCount = 0,
  });

  factory JsMetadata.fromJson(Map<String, dynamic> json) {
    return JsMetadata(
      obfuscatedScriptCount: json['obfuscated_script_count'] ?? 0,
      popupCount: json['popup_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      javascriptErrorCount: json['javascript_error_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'obfuscated_script_count': obfuscatedScriptCount,
    'popup_count': popupCount,
    'download_count': downloadCount,
    'javascript_error_count': javascriptErrorCount,
  };
}

class ReputationMetadata {
  final int reputationDetectionCount;
  final bool safeBrowsingFlagged;
  final int virusTotalScore;

  ReputationMetadata({
    this.reputationDetectionCount = 0,
    this.safeBrowsingFlagged = false,
    this.virusTotalScore = 0,
  });

  factory ReputationMetadata.fromJson(Map<String, dynamic> json) {
    return ReputationMetadata(
      reputationDetectionCount: json['reputation_detection_count'] ?? 0,
      safeBrowsingFlagged: json['safe_browsing_flagged'] == true || json['safe_browsing_flagged'] == 1,
      virusTotalScore: json['virustotal_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'reputation_detection_count': reputationDetectionCount,
    'safe_browsing_flagged': safeBrowsingFlagged,
    'virustotal_score': virusTotalScore,
  };
}
