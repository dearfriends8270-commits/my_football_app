/// 디지털 티켓 모델 - 경기 관람 기록을 수집 가능한 티켓으로 표현
class DigitalTicket {
  final String id;
  final String matchId;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final String stadium;
  final String competition;
  final DateTime matchDate;
  final String? score;
  final TicketRarity rarity;
  final TicketCondition condition;
  final String? specialMoment; // 특별 순간 (예: 해트트릭, 데뷔골 등)
  final String? playerOfTheMatch;
  final double? playerRating;
  final bool isCollected;
  final DateTime? collectedAt;
  final int viewCount;
  final List<String> tags;
  final TicketDesign design;

  const DigitalTicket({
    required this.id,
    required this.matchId,
    required this.homeTeam,
    required this.awayTeam,
    required this.homeTeamLogo,
    required this.awayTeamLogo,
    required this.stadium,
    required this.competition,
    required this.matchDate,
    this.score,
    this.rarity = TicketRarity.common,
    this.condition = TicketCondition.mint,
    this.specialMoment,
    this.playerOfTheMatch,
    this.playerRating,
    this.isCollected = false,
    this.collectedAt,
    this.viewCount = 0,
    this.tags = const [],
    this.design = TicketDesign.classic,
  });

  DigitalTicket copyWith({
    String? id,
    String? matchId,
    String? homeTeam,
    String? awayTeam,
    String? homeTeamLogo,
    String? awayTeamLogo,
    String? stadium,
    String? competition,
    DateTime? matchDate,
    String? score,
    TicketRarity? rarity,
    TicketCondition? condition,
    String? specialMoment,
    String? playerOfTheMatch,
    double? playerRating,
    bool? isCollected,
    DateTime? collectedAt,
    int? viewCount,
    List<String>? tags,
    TicketDesign? design,
  }) {
    return DigitalTicket(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeTeamLogo: homeTeamLogo ?? this.homeTeamLogo,
      awayTeamLogo: awayTeamLogo ?? this.awayTeamLogo,
      stadium: stadium ?? this.stadium,
      competition: competition ?? this.competition,
      matchDate: matchDate ?? this.matchDate,
      score: score ?? this.score,
      rarity: rarity ?? this.rarity,
      condition: condition ?? this.condition,
      specialMoment: specialMoment ?? this.specialMoment,
      playerOfTheMatch: playerOfTheMatch ?? this.playerOfTheMatch,
      playerRating: playerRating ?? this.playerRating,
      isCollected: isCollected ?? this.isCollected,
      collectedAt: collectedAt ?? this.collectedAt,
      viewCount: viewCount ?? this.viewCount,
      tags: tags ?? this.tags,
      design: design ?? this.design,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matchId': matchId,
      'homeTeam': homeTeam,
      'awayTeam': awayTeam,
      'homeTeamLogo': homeTeamLogo,
      'awayTeamLogo': awayTeamLogo,
      'stadium': stadium,
      'competition': competition,
      'matchDate': matchDate.toIso8601String(),
      'score': score,
      'rarity': rarity.name,
      'condition': condition.name,
      'specialMoment': specialMoment,
      'playerOfTheMatch': playerOfTheMatch,
      'playerRating': playerRating,
      'isCollected': isCollected,
      'collectedAt': collectedAt?.toIso8601String(),
      'viewCount': viewCount,
      'tags': tags,
      'design': design.name,
    };
  }

  factory DigitalTicket.fromJson(Map<String, dynamic> json) {
    return DigitalTicket(
      id: json['id'] as String,
      matchId: json['matchId'] as String,
      homeTeam: json['homeTeam'] as String,
      awayTeam: json['awayTeam'] as String,
      homeTeamLogo: json['homeTeamLogo'] as String,
      awayTeamLogo: json['awayTeamLogo'] as String,
      stadium: json['stadium'] as String,
      competition: json['competition'] as String,
      matchDate: DateTime.parse(json['matchDate'] as String),
      score: json['score'] as String?,
      rarity: TicketRarity.values.firstWhere(
        (e) => e.name == json['rarity'],
        orElse: () => TicketRarity.common,
      ),
      condition: TicketCondition.values.firstWhere(
        (e) => e.name == json['condition'],
        orElse: () => TicketCondition.mint,
      ),
      specialMoment: json['specialMoment'] as String?,
      playerOfTheMatch: json['playerOfTheMatch'] as String?,
      playerRating: json['playerRating'] as double?,
      isCollected: json['isCollected'] as bool? ?? false,
      collectedAt: json['collectedAt'] != null
          ? DateTime.parse(json['collectedAt'] as String)
          : null,
      viewCount: json['viewCount'] as int? ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.cast<String>() ?? [],
      design: TicketDesign.values.firstWhere(
        (e) => e.name == json['design'],
        orElse: () => TicketDesign.classic,
      ),
    );
  }
}

/// 티켓 희귀도
enum TicketRarity {
  common, // 일반
  uncommon, // 비일반
  rare, // 희귀
  epic, // 에픽
  legendary, // 레전드리
}

extension TicketRarityExtension on TicketRarity {
  String get displayName {
    switch (this) {
      case TicketRarity.common:
        return '일반';
      case TicketRarity.uncommon:
        return '비일반';
      case TicketRarity.rare:
        return '희귀';
      case TicketRarity.epic:
        return '에픽';
      case TicketRarity.legendary:
        return '레전드리';
    }
  }

  String get icon {
    switch (this) {
      case TicketRarity.common:
        return '⚪';
      case TicketRarity.uncommon:
        return '🟢';
      case TicketRarity.rare:
        return '🔵';
      case TicketRarity.epic:
        return '🟣';
      case TicketRarity.legendary:
        return '🟡';
    }
  }

  int get colorValue {
    switch (this) {
      case TicketRarity.common:
        return 0xFF9E9E9E;
      case TicketRarity.uncommon:
        return 0xFF4CAF50;
      case TicketRarity.rare:
        return 0xFF2196F3;
      case TicketRarity.epic:
        return 0xFF9C27B0;
      case TicketRarity.legendary:
        return 0xFFFFD700;
    }
  }
}

/// 티켓 상태
enum TicketCondition {
  mint, // 최상
  nearMint, // 준최상
  excellent, // 우수
  good, // 양호
  fair, // 보통
}

extension TicketConditionExtension on TicketCondition {
  String get displayName {
    switch (this) {
      case TicketCondition.mint:
        return '민트';
      case TicketCondition.nearMint:
        return '니어민트';
      case TicketCondition.excellent:
        return '우수';
      case TicketCondition.good:
        return '양호';
      case TicketCondition.fair:
        return '보통';
    }
  }
}

/// 티켓 디자인 테마
enum TicketDesign {
  classic, // 클래식
  modern, // 모던
  retro, // 레트로
  holographic, // 홀로그래픽
  premium, // 프리미엄
}

extension TicketDesignExtension on TicketDesign {
  String get displayName {
    switch (this) {
      case TicketDesign.classic:
        return '클래식';
      case TicketDesign.modern:
        return '모던';
      case TicketDesign.retro:
        return '레트로';
      case TicketDesign.holographic:
        return '홀로그래픽';
      case TicketDesign.premium:
        return '프리미엄';
    }
  }
}

/// 티켓 컬렉션 통계
class TicketCollectionStats {
  final int totalTickets;
  final int collectedTickets;
  final Map<TicketRarity, int> rarityCount;
  final int uniqueStadiums;
  final int uniqueCompetitions;
  final String? favoriteTeam;
  final DateTime? firstTicketDate;
  final DateTime? latestTicketDate;

  const TicketCollectionStats({
    required this.totalTickets,
    required this.collectedTickets,
    required this.rarityCount,
    required this.uniqueStadiums,
    required this.uniqueCompetitions,
    this.favoriteTeam,
    this.firstTicketDate,
    this.latestTicketDate,
  });

  double get collectionProgress =>
      totalTickets > 0 ? collectedTickets / totalTickets : 0;
}
