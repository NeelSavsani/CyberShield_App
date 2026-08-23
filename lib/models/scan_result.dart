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
  final HttpMetadata? http;
  final LexicalMetadata? lexical;
  final WhoisMetadata? whois;

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
    this.http,
    this.lexical,
    this.whois,
  });

  bool get isSafe => verdict.toLowerCase() == 'safe';
  bool get isSuspicious => verdict.toLowerCase() == 'suspicious';
  bool get isPhishing => verdict.toLowerCase() == 'phishing' || verdict.toLowerCase() == 'malicious';

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic> ? json['data'] : json;
    final classification = (data['classification'] is Map<String, dynamic>)
        ? data['classification']
        : (json['classification'] is Map<String, dynamic> ? json['classification'] : {});

    final rawFeatures = (data['features'] is Map<String, dynamic>)
        ? data['features'] as Map<String, dynamic>
        : (json['features'] is Map<String, dynamic> ? json['features'] as Map<String, dynamic> : <String, dynamic>{});

    int score = 0;
    if (classification['risk_score'] != null) {
      score = (classification['risk_score'] as num).toInt();
    } else if (json['risk_score'] != null) {
      score = (json['risk_score'] as num).toInt();
    } else if (classification['phishing_probability'] != null) {
      score = ((classification['phishing_probability'] as num) * 100).round();
    }

    String verdict = classification['verdict'] ?? json['verdict'] ?? (score >= 70 ? 'phishing' : (score >= 40 ? 'suspicious' : 'safe'));

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

    List<String> inds = [];
    if (classification['indicators'] is List) {
      inds = List<String>.from(classification['indicators']);
    } else if (json['indicators'] is List) {
      inds = List<String>.from(json['indicators']);
    }

    final dnsRaw = data['dns'] is Map<String, dynamic> ? data['dns'] : json['dns'];
    final sslRaw = data['ssl'] is Map<String, dynamic> ? data['ssl'] : json['ssl'];
    final domRaw = data['dom'] is Map<String, dynamic> ? data['dom'] : json['dom'];
    final jsRaw = data['javascript'] is Map<String, dynamic> ? data['javascript'] : json['javascript'];
    final repRaw = data['reputation'] is Map<String, dynamic> ? data['reputation'] : json['reputation'];
    final httpRaw = data['http'] is Map<String, dynamic> ? data['http'] : json['http'];
    final lexRaw = data['lexical'] is Map<String, dynamic> ? data['lexical'] : json['lexical'];
    final whoisRaw = data['whois'] is Map<String, dynamic> ? data['whois'] : json['whois'];

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
      http: httpRaw != null ? HttpMetadata.fromJson(httpRaw) : null,
      lexical: lexRaw != null ? LexicalMetadata.fromJson(lexRaw) : null,
      whois: whoisRaw != null ? WhoisMetadata.fromJson(whoisRaw) : null,
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
    'http': http?.toJson(),
    'lexical': lexical?.toJson(),
    'whois': whois?.toJson(),
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
  final List<String> aaaaRecords;
  final List<String> nsRecords;
  final List<String> mxRecords;
  final List<String> txtRecords;
  final String? registrar;
  final String? asn;
  final String? ipLocation;
  final int ttl;

  DnsMetadata({
    this.domainAgeDays,
    this.dnssecEnabled = false,
    this.aRecords = const [],
    this.aaaaRecords = const [],
    this.nsRecords = const [],
    this.mxRecords = const [],
    this.txtRecords = const [],
    this.registrar,
    this.asn,
    this.ipLocation,
    this.ttl = 300,
  });

  factory DnsMetadata.fromJson(Map<String, dynamic> json) {
    return DnsMetadata(
      domainAgeDays: json['domain_age_days'] is num ? (json['domain_age_days'] as num).toInt() : null,
      dnssecEnabled: json['dnssec_enabled'] == true || json['dnssec_enabled'] == 1,
      aRecords: json['a_records'] is List ? List<String>.from(json['a_records']) : [],
      aaaaRecords: json['aaaa_records'] is List ? List<String>.from(json['aaaa_records']) : [],
      nsRecords: json['ns_records'] is List ? List<String>.from(json['ns_records']) : [],
      mxRecords: json['mx_records'] is List ? List<String>.from(json['mx_records']) : [],
      txtRecords: json['txt_records'] is List ? List<String>.from(json['txt_records']) : [],
      registrar: json['registrar']?.toString(),
      asn: json['asn']?.toString(),
      ipLocation: json['ip_location']?.toString(),
      ttl: json['ttl'] is num ? (json['ttl'] as num).toInt() : 300,
    );
  }

  Map<String, dynamic> toJson() => {
    'domain_age_days': domainAgeDays,
    'dnssec_enabled': dnssecEnabled,
    'a_records': aRecords,
    'aaaa_records': aaaaRecords,
    'ns_records': nsRecords,
    'mx_records': mxRecords,
    'txt_records': txtRecords,
    'registrar': registrar,
    'asn': asn,
    'ip_location': ipLocation,
    'ttl': ttl,
  };
}

class SslMetadata {
  final bool hasValidTls;
  final int? certificateAgeDays;
  final String? issuer;
  final String? protocol;
  final String? cipherSuite;
  final String? validFrom;
  final String? validTo;
  final List<String> subjectAltNames;

  SslMetadata({
    this.hasValidTls = true,
    this.certificateAgeDays,
    this.issuer,
    this.protocol,
    this.cipherSuite,
    this.validFrom,
    this.validTo,
    this.subjectAltNames = const [],
  });

  factory SslMetadata.fromJson(Map<String, dynamic> json) {
    return SslMetadata(
      hasValidTls: json['has_valid_tls'] == true || json['has_valid_tls'] == 1 || json['valid'] == true,
      certificateAgeDays: json['certificate_age_days'] is num ? (json['certificate_age_days'] as num).toInt() : null,
      issuer: json['issuer']?.toString(),
      protocol: json['protocol']?.toString(),
      cipherSuite: json['cipher_suite']?.toString(),
      validFrom: json['valid_from']?.toString(),
      validTo: json['valid_to']?.toString(),
      subjectAltNames: json['subject_alt_names'] is List ? List<String>.from(json['subject_alt_names']) : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'has_valid_tls': hasValidTls,
    'certificate_age_days': certificateAgeDays,
    'issuer': issuer,
    'protocol': protocol,
    'cipher_suite': cipherSuite,
    'valid_from': validFrom,
    'valid_to': validTo,
    'subject_alt_names': subjectAltNames,
  };
}

class DomMetadata {
  final int passwordFieldCount;
  final int otpFieldCount;
  final int creditCardFieldCount;
  final int hiddenIframeCount;
  final int crossDomainFormActions;
  final int insecureFormActions;
  final int totalInputFields;
  final int totalForms;
  final bool hasMetaRefresh;

  DomMetadata({
    this.passwordFieldCount = 0,
    this.otpFieldCount = 0,
    this.creditCardFieldCount = 0,
    this.hiddenIframeCount = 0,
    this.crossDomainFormActions = 0,
    this.insecureFormActions = 0,
    this.totalInputFields = 0,
    this.totalForms = 0,
    this.hasMetaRefresh = false,
  });

  factory DomMetadata.fromJson(Map<String, dynamic> json) {
    return DomMetadata(
      passwordFieldCount: json['password_field_count'] ?? 0,
      otpFieldCount: json['otp_field_count'] ?? 0,
      creditCardFieldCount: json['credit_card_field_count'] ?? 0,
      hiddenIframeCount: json['hidden_iframe_count'] ?? 0,
      crossDomainFormActions: json['cross_domain_form_actions'] ?? 0,
      insecureFormActions: json['insecure_form_actions'] ?? 0,
      totalInputFields: json['total_input_fields'] ?? 0,
      totalForms: json['total_forms'] ?? 0,
      hasMetaRefresh: json['has_meta_refresh'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'password_field_count': passwordFieldCount,
    'otp_field_count': otpFieldCount,
    'credit_card_field_count': creditCardFieldCount,
    'hidden_iframe_count': hiddenIframeCount,
    'cross_domain_form_actions': crossDomainFormActions,
    'insecure_form_actions': insecureFormActions,
    'total_input_fields': totalInputFields,
    'total_forms': totalForms,
    'has_meta_refresh': hasMetaRefresh,
  };
}

class JsMetadata {
  final int scriptCount;
  final int obfuscatedScriptCount;
  final int popupCount;
  final int downloadCount;
  final int javascriptErrorCount;
  final int evalCallsDetected;
  final bool webSocketEndpoints;

  JsMetadata({
    this.scriptCount = 0,
    this.obfuscatedScriptCount = 0,
    this.popupCount = 0,
    this.downloadCount = 0,
    this.javascriptErrorCount = 0,
    this.evalCallsDetected = 0,
    this.webSocketEndpoints = false,
  });

  factory JsMetadata.fromJson(Map<String, dynamic> json) {
    return JsMetadata(
      scriptCount: json['script_count'] ?? 0,
      obfuscatedScriptCount: json['obfuscated_script_count'] ?? 0,
      popupCount: json['popup_count'] ?? 0,
      downloadCount: json['download_count'] ?? 0,
      javascriptErrorCount: json['javascript_error_count'] ?? 0,
      evalCallsDetected: json['eval_calls_detected'] ?? 0,
      webSocketEndpoints: json['websocket_endpoints'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'script_count': scriptCount,
    'obfuscated_script_count': obfuscatedScriptCount,
    'popup_count': popupCount,
    'download_count': downloadCount,
    'javascript_error_count': javascriptErrorCount,
    'eval_calls_detected': evalCallsDetected,
    'websocket_endpoints': webSocketEndpoints,
  };
}

class ReputationMetadata {
  final int reputationDetectionCount;
  final bool safeBrowsingFlagged;
  final int virusTotalScore;
  final int totalScanners;
  final String phishTankStatus;
  final int abuseIpScore;

  ReputationMetadata({
    this.reputationDetectionCount = 0,
    this.safeBrowsingFlagged = false,
    this.virusTotalScore = 0,
    this.totalScanners = 72,
    this.phishTankStatus = 'Clean',
    this.abuseIpScore = 0,
  });

  factory ReputationMetadata.fromJson(Map<String, dynamic> json) {
    return ReputationMetadata(
      reputationDetectionCount: json['reputation_detection_count'] ?? 0,
      safeBrowsingFlagged: json['safe_browsing_flagged'] == true || json['safe_browsing_flagged'] == 1,
      virusTotalScore: json['virustotal_score'] ?? 0,
      totalScanners: json['total_scanners'] ?? 72,
      phishTankStatus: json['phishtank_status']?.toString() ?? 'Clean',
      abuseIpScore: json['abuseip_score'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'reputation_detection_count': reputationDetectionCount,
    'safe_browsing_flagged': safeBrowsingFlagged,
    'virustotal_score': virusTotalScore,
    'total_scanners': totalScanners,
    'phishtank_status': phishTankStatus,
    'abuseip_score': abuseIpScore,
  };
}

class HttpMetadata {
  final int statusCode;
  final String serverHeader;
  final String contentType;
  final bool hstsEnabled;
  final bool cspEnabled;
  final String xFrameOptions;
  final bool xContentTypeOptions;

  HttpMetadata({
    this.statusCode = 200,
    this.serverHeader = 'cloudflare',
    this.contentType = 'text/html; charset=UTF-8',
    this.hstsEnabled = true,
    this.cspEnabled = true,
    this.xFrameOptions = 'SAMEORIGIN',
    this.xContentTypeOptions = true,
  });

  factory HttpMetadata.fromJson(Map<String, dynamic> json) {
    return HttpMetadata(
      statusCode: json['status_code'] ?? 200,
      serverHeader: json['server_header']?.toString() ?? 'cloudflare',
      contentType: json['content_type']?.toString() ?? 'text/html; charset=UTF-8',
      hstsEnabled: json['hsts_enabled'] == true,
      cspEnabled: json['csp_enabled'] == true,
      xFrameOptions: json['x_frame_options']?.toString() ?? 'SAMEORIGIN',
      xContentTypeOptions: json['x_content_type_options'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'status_code': statusCode,
    'server_header': serverHeader,
    'content_type': contentType,
    'hsts_enabled': hstsEnabled,
    'csp_enabled': cspEnabled,
    'x_frame_options': xFrameOptions,
    'x_content_type_options': xContentTypeOptions,
  };
}

class LexicalMetadata {
  final int urlLength;
  final int hostLength;
  final int pathDepth;
  final int subdomainCount;
  final double shannonEntropy;
  final int digitCount;
  final int specialCharCount;
  final bool isIpLiteral;

  LexicalMetadata({
    this.urlLength = 0,
    this.hostLength = 0,
    this.pathDepth = 0,
    this.subdomainCount = 0,
    this.shannonEntropy = 0.0,
    this.digitCount = 0,
    this.specialCharCount = 0,
    this.isIpLiteral = false,
  });

  factory LexicalMetadata.fromJson(Map<String, dynamic> json) {
    return LexicalMetadata(
      urlLength: json['url_length'] ?? 0,
      hostLength: json['host_length'] ?? 0,
      pathDepth: json['path_depth'] ?? 0,
      subdomainCount: json['subdomain_count'] ?? 0,
      shannonEntropy: (json['shannon_entropy'] is num) ? (json['shannon_entropy'] as num).toDouble() : 0.0,
      digitCount: json['digit_count'] ?? 0,
      specialCharCount: json['special_char_count'] ?? 0,
      isIpLiteral: json['is_ip_literal'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'url_length': urlLength,
    'host_length': hostLength,
    'path_depth': pathDepth,
    'subdomain_count': subdomainCount,
    'shannon_entropy': shannonEntropy,
    'digit_count': digitCount,
    'special_char_count': specialCharCount,
    'is_ip_literal': isIpLiteral,
  };
}

class WhoisMetadata {
  final String registrarName;
  final String creationDate;
  final String expiryDate;
  final String registrantCountry;
  final bool privacyProtected;

  WhoisMetadata({
    this.registrarName = 'Unknown',
    this.creationDate = 'Unknown',
    this.expiryDate = 'Unknown',
    this.registrantCountry = 'US',
    this.privacyProtected = true,
  });

  factory WhoisMetadata.fromJson(Map<String, dynamic> json) {
    return WhoisMetadata(
      registrarName: json['registrar_name']?.toString() ?? 'Unknown',
      creationDate: json['creation_date']?.toString() ?? 'Unknown',
      expiryDate: json['expiry_date']?.toString() ?? 'Unknown',
      registrantCountry: json['registrant_country']?.toString() ?? 'US',
      privacyProtected: json['privacy_protected'] == true,
    );
  }

  Map<String, dynamic> toJson() => {
    'registrar_name': registrarName,
    'creation_date': creationDate,
    'expiry_date': expiryDate,
    'registrant_country': registrantCountry,
    'privacy_protected': privacyProtected,
  };
}
