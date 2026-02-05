/// 루머/이적설 모델
class Rumor {
  final String id;
  final String playerId;
  final String playerName;
  final String title;
  final String description;
  final RumorType type;
  final String? targetTeam;
  final String? currentTeam;
  final double? transferFee; // 예상 이적료 (백만 유로)
  final List<RumorSource> sources;
  final double reliabilityScore; // 0.0 ~ 1.0
  final List<ReliabilityFactor> factors;
  final DateTime firstReportedAt;
  final DateTime lastUpdatedAt;
  final RumorStatus status;
  final String? outcome; // 결과 (확정된 경우)

  const Rumor({
    required this.id,
    required this.playerId,
    required this.playerName,
    required this.title,
    required this.description,
    required this.type,
    this.targetTeam,
    this.currentTeam,
    this.transferFee,
    required this.sources,
    required this.reliabilityScore,
    required this.factors,
    required this.firstReportedAt,
    required this.lastUpdatedAt,
    this.status = RumorStatus.active,
    this.outcome,
  });

  ReliabilityLevel get reliabilityLevel {
    if (reliabilityScore >= 0.8) return ReliabilityLevel.veryHigh;
    if (reliabilityScore >= 0.6) return ReliabilityLevel.high;
    if (reliabilityScore >= 0.4) return ReliabilityLevel.medium;
    if (reliabilityScore >= 0.2) return ReliabilityLevel.low;
    return ReliabilityLevel.veryLow;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'playerId': playerId,
      'playerName': playerName,
      'title': title,
      'description': description,
      'type': type.name,
      'targetTeam': targetTeam,
      'currentTeam': currentTeam,
      'transferFee': transferFee,
      'sources': sources.map((s) => s.toJson()).toList(),
      'reliabilityScore': reliabilityScore,
      'factors': factors.map((f) => f.toJson()).toList(),
      'firstReportedAt': firstReportedAt.toIso8601String(),
      'lastUpdatedAt': lastUpdatedAt.toIso8601String(),
      'status': status.name,
      'outcome': outcome,
    };
  }
}

/// 루머 타입
enum RumorType {
  transfer, // 이적
  loan, // 임대
  contractRenewal, // 재계약
  contractDispute, // 계약 분쟁
  injury, // 부상
  other, // 기타
}

extension RumorTypeExtension on RumorType {
  String get displayName {
    switch (this) {
      case RumorType.transfer:
        return '이적';
      case RumorType.loan:
        return '임대';
      case RumorType.contractRenewal:
        return '재계약';
      case RumorType.contractDispute:
        return '계약 분쟁';
      case RumorType.injury:
        return '부상';
      case RumorType.other:
        return '기타';
    }
  }

  String get icon {
    switch (this) {
      case RumorType.transfer:
        return '✈️';
      case RumorType.loan:
        return '🔄';
      case RumorType.contractRenewal:
        return '📝';
      case RumorType.contractDispute:
        return '⚠️';
      case RumorType.injury:
        return '🏥';
      case RumorType.other:
        return '📰';
    }
  }
}

/// 루머 상태
enum RumorStatus {
  active, // 진행 중
  confirmed, // 확정
  denied, // 부인됨
  expired, // 만료 (시간 경과)
}

extension RumorStatusExtension on RumorStatus {
  String get displayName {
    switch (this) {
      case RumorStatus.active:
        return '진행 중';
      case RumorStatus.confirmed:
        return '확정';
      case RumorStatus.denied:
        return '부인';
      case RumorStatus.expired:
        return '만료';
    }
  }

  int get colorValue {
    switch (this) {
      case RumorStatus.active:
        return 0xFF2196F3;
      case RumorStatus.confirmed:
        return 0xFF4CAF50;
      case RumorStatus.denied:
        return 0xFFF44336;
      case RumorStatus.expired:
        return 0xFF9E9E9E;
    }
  }
}

/// 신뢰도 레벨
enum ReliabilityLevel {
  veryHigh,
  high,
  medium,
  low,
  veryLow,
}

extension ReliabilityLevelExtension on ReliabilityLevel {
  String get displayName {
    switch (this) {
      case ReliabilityLevel.veryHigh:
        return '매우 높음';
      case ReliabilityLevel.high:
        return '높음';
      case ReliabilityLevel.medium:
        return '보통';
      case ReliabilityLevel.low:
        return '낮음';
      case ReliabilityLevel.veryLow:
        return '매우 낮음';
    }
  }

  String get emoji {
    switch (this) {
      case ReliabilityLevel.veryHigh:
        return '🟢';
      case ReliabilityLevel.high:
        return '🔵';
      case ReliabilityLevel.medium:
        return '🟡';
      case ReliabilityLevel.low:
        return '🟠';
      case ReliabilityLevel.veryLow:
        return '🔴';
    }
  }

  int get colorValue {
    switch (this) {
      case ReliabilityLevel.veryHigh:
        return 0xFF4CAF50;
      case ReliabilityLevel.high:
        return 0xFF2196F3;
      case ReliabilityLevel.medium:
        return 0xFFFFEB3B;
      case ReliabilityLevel.low:
        return 0xFFFF9800;
      case ReliabilityLevel.veryLow:
        return 0xFFF44336;
    }
  }
}

/// 루머 출처
class RumorSource {
  final String id;
  final String name;
  final String type; // journalist, media, insider, social
  final double tierScore; // 1.0 = Tier 1, 0.5 = Tier 2, etc.
  final String? country;
  final DateTime reportedAt;
  final String? quote;

  const RumorSource({
    required this.id,
    required this.name,
    required this.type,
    required this.tierScore,
    this.country,
    required this.reportedAt,
    this.quote,
  });

  String get tierLabel {
    if (tierScore >= 0.9) return 'Tier 1';
    if (tierScore >= 0.7) return 'Tier 2';
    if (tierScore >= 0.5) return 'Tier 3';
    return 'Unverified';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'tierScore': tierScore,
      'country': country,
      'reportedAt': reportedAt.toIso8601String(),
      'quote': quote,
    };
  }
}

/// 신뢰도 계산 요소
class ReliabilityFactor {
  final String name;
  final String description;
  final double weight; // 가중치 (0.0 ~ 1.0)
  final double score; // 점수 (0.0 ~ 1.0)
  final bool isPositive;

  const ReliabilityFactor({
    required this.name,
    required this.description,
    required this.weight,
    required this.score,
    required this.isPositive,
  });

  double get contribution => weight * score * (isPositive ? 1 : -1);

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'weight': weight,
      'score': score,
      'isPositive': isPositive,
    };
  }
}
