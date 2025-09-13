class CleanResult {
  final CleanedUrl primary;
  final List<CleanedUrl> alternatives;
  final CleanMeta meta;

  CleanResult({
    required this.primary,
    required this.alternatives,
    required this.meta,
  });

  factory CleanResult.fromJson(Map<String, dynamic> json) {
    return CleanResult(
      primary: CleanedUrl.fromJson(json['primary']),
      alternatives: (json['alternatives'] as List)
          .map((e) => CleanedUrl.fromJson(e))
          .toList(),
      meta: CleanMeta.fromJson(json['meta']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'primary': primary.toJson(),
      'alternatives': alternatives.map((e) => e.toJson()).toList(),
      'meta': meta.toJson(),
    };
  }
}

class CleanedUrl {
  final String url;
  final double confidence;
  final List<String> actions;
  final List<String>? redirectionChain;
  final String? reason;

  CleanedUrl({
    required this.url,
    required this.confidence,
    required this.actions,
    this.redirectionChain,
    this.reason,
  });

  factory CleanedUrl.fromJson(Map<String, dynamic> json) {
    return CleanedUrl(
      url: json['url'],
      confidence: (json['confidence'] as num).toDouble(),
      actions: List<String>.from(json['actions']),
      redirectionChain: json['redirectionChain'] != null
          ? List<String>.from(json['redirectionChain'])
          : null,
      reason: json['reason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'confidence': confidence,
      'actions': actions,
      'redirectionChain': redirectionChain,
      'reason': reason,
    };
  }
}

class CleanMeta {
  final String domain;
  final String strategyId;
  final String strategyVersion;
  final TimingMetrics timing;
  final String appliedAt;

  CleanMeta({
    required this.domain,
    required this.strategyId,
    required this.strategyVersion,
    required this.timing,
    required this.appliedAt,
  });

  factory CleanMeta.fromJson(Map<String, dynamic> json) {
    return CleanMeta(
      domain: json['domain'],
      strategyId: json['strategyId'],
      strategyVersion: json['strategyVersion'],
      timing: TimingMetrics.fromJson(json['timing']),
      appliedAt: json['appliedAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'domain': domain,
      'strategyId': strategyId,
      'strategyVersion': strategyVersion,
      'timing': timing.toJson(),
      'appliedAt': appliedAt,
    };
  }
}

class TimingMetrics {
  final int totalMs;
  final int redirectMs;
  final int processingMs;

  TimingMetrics({
    required this.totalMs,
    required this.redirectMs,
    required this.processingMs,
  });

  factory TimingMetrics.fromJson(Map<String, dynamic> json) {
    return TimingMetrics(
      totalMs: json['totalMs'],
      redirectMs: json['redirectMs'],
      processingMs: json['processingMs'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalMs': totalMs,
      'redirectMs': redirectMs,
      'processingMs': processingMs,
    };
  }
}
