import 'package:flutter/material.dart';
import 'sport_type.dart';

/// 멀티 스포츠 선수 모델
class Athlete {
  final String id;
  final String name;
  final String nameKr;
  final String lastName; // Magazine Cover용 성
  final SportType sport;
  final String team;
  final String teamLogo;
  final Color teamColor;
  final String? position;
  final String nationality;
  final String? imageUrl;
  final String? graphicUrl;
  final String? matchdayGraphicUrl;
  final bool isFavorite;
  final int favoriteOrder; // 즐겨찾기 순서

  // 공통 스탯
  final Map<String, dynamic> stats;

  // 축구 전용
  final int? goals;
  final int? assists;
  final double? rating;

  // 야구 전용
  final double? battingAvg;
  final int? homeRuns;
  final int? rbi;

  // 배드민턴/수영/골프 전용
  final int? worldRanking;
  final int? seasonWins;
  final String? personalBest;

  // 캐시 정보
  final DateTime? lastUpdated;

  Athlete({
    required this.id,
    required this.name,
    required this.nameKr,
    required this.lastName,
    required this.sport,
    required this.team,
    this.teamLogo = '',
    required this.teamColor,
    this.position,
    this.nationality = 'KOR',
    this.imageUrl,
    this.graphicUrl,
    this.matchdayGraphicUrl,
    this.isFavorite = false,
    this.favoriteOrder = 0,
    this.stats = const {},
    this.goals,
    this.assists,
    this.rating,
    this.battingAvg,
    this.homeRuns,
    this.rbi,
    this.worldRanking,
    this.seasonWins,
    this.personalBest,
    this.lastUpdated,
  });

  /// 스탯 요약 문자열
  String get statSummary {
    switch (sport) {
      case SportType.football:
        return '${goals ?? 0}G ${assists ?? 0}A | ⭐ ${rating?.toStringAsFixed(1) ?? '-'}';
      case SportType.baseball:
        return '.${((battingAvg ?? 0) * 1000).toInt()} AVG | ${homeRuns ?? 0} HR | ${rbi ?? 0} RBI';
      case SportType.badminton:
        return '세계랭킹 ${worldRanking ?? '-'}위 | 시즌 ${seasonWins ?? 0}승';
      case SportType.swimming:
        return '${personalBest ?? '-'} | 세계랭킹 ${worldRanking ?? '-'}위';
      case SportType.golf:
        return '세계랭킹 ${worldRanking ?? '-'}위 | 시즌 ${seasonWins ?? 0}승';
      case SportType.basketball:
        return '${stats['points'] ?? '-'}PPG | ${stats['rebounds'] ?? '-'}RPG';
    }
  }

  /// 복사본 생성
  Athlete copyWith({
    String? id,
    String? name,
    String? nameKr,
    String? lastName,
    SportType? sport,
    String? team,
    String? teamLogo,
    Color? teamColor,
    String? position,
    String? nationality,
    String? imageUrl,
    String? graphicUrl,
    String? matchdayGraphicUrl,
    bool? isFavorite,
    int? favoriteOrder,
    Map<String, dynamic>? stats,
    int? goals,
    int? assists,
    double? rating,
    double? battingAvg,
    int? homeRuns,
    int? rbi,
    int? worldRanking,
    int? seasonWins,
    String? personalBest,
    DateTime? lastUpdated,
  }) {
    return Athlete(
      id: id ?? this.id,
      name: name ?? this.name,
      nameKr: nameKr ?? this.nameKr,
      lastName: lastName ?? this.lastName,
      sport: sport ?? this.sport,
      team: team ?? this.team,
      teamLogo: teamLogo ?? this.teamLogo,
      teamColor: teamColor ?? this.teamColor,
      position: position ?? this.position,
      nationality: nationality ?? this.nationality,
      imageUrl: imageUrl ?? this.imageUrl,
      graphicUrl: graphicUrl ?? this.graphicUrl,
      matchdayGraphicUrl: matchdayGraphicUrl ?? this.matchdayGraphicUrl,
      isFavorite: isFavorite ?? this.isFavorite,
      favoriteOrder: favoriteOrder ?? this.favoriteOrder,
      stats: stats ?? this.stats,
      goals: goals ?? this.goals,
      assists: assists ?? this.assists,
      rating: rating ?? this.rating,
      battingAvg: battingAvg ?? this.battingAvg,
      homeRuns: homeRuns ?? this.homeRuns,
      rbi: rbi ?? this.rbi,
      worldRanking: worldRanking ?? this.worldRanking,
      seasonWins: seasonWins ?? this.seasonWins,
      personalBest: personalBest ?? this.personalBest,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

/// 샘플 선수 데이터
class SampleAthletes {
  static List<Athlete> get all => [
    // 축구
    Athlete(
      id: 'lee_kangin',
      name: 'LEE KANG IN',
      nameKr: '이강인',
      lastName: 'KANG IN',
      sport: SportType.football,
      team: 'Paris Saint-Germain',
      teamColor: const Color(0xFF001C58),
      position: 'Midfielder',
      imageUrl: 'assets/images/players/lee_kangin.png',
      goals: 5,
      assists: 7,
      rating: 7.8,
    ),
    Athlete(
      id: 'son_heungmin',
      name: 'SON HEUNG MIN',
      nameKr: '손흥민',
      lastName: 'HEUNG MIN',
      sport: SportType.football,
      team: 'Tottenham Hotspur',
      teamColor: const Color(0xFF132257),
      position: 'Forward',
      imageUrl: 'assets/images/players/son_heungmin.png',
      goals: 12,
      assists: 5,
      rating: 7.5,
    ),
    Athlete(
      id: 'kim_minjae',
      name: 'KIM MIN JAE',
      nameKr: '김민재',
      lastName: 'MIN JAE',
      sport: SportType.football,
      team: 'Bayern Munich',
      teamColor: const Color(0xFFDC052D),
      position: 'Defender',
      imageUrl: 'assets/images/players/kim_minjae.png',
      goals: 2,
      assists: 1,
      rating: 7.2,
    ),

    // 야구
    Athlete(
      id: 'lee_junghoo',
      name: 'LEE JUNG HOO',
      nameKr: '이정후',
      lastName: 'JUNG HOO',
      sport: SportType.baseball,
      team: 'San Francisco Giants',
      teamColor: const Color(0xFFFD5A1E),
      position: 'Outfielder',
      imageUrl: 'assets/images/players/lee_junghoo.png',
      battingAvg: 0.312,
      homeRuns: 8,
      rbi: 45,
    ),
    Athlete(
      id: 'kim_hasung',
      name: 'KIM HA SEONG',
      nameKr: '김하성',
      lastName: 'HA SEONG',
      sport: SportType.baseball,
      team: 'San Diego Padres',
      teamColor: const Color(0xFF2F241D),
      position: 'Infielder',
      imageUrl: 'assets/images/players/kim_hasung.png',
      battingAvg: 0.278,
      homeRuns: 11,
      rbi: 52,
    ),

    // 배드민턴
    Athlete(
      id: 'an_seyoung',
      name: 'AN SE YOUNG',
      nameKr: '안세영',
      lastName: 'SE YOUNG',
      sport: SportType.badminton,
      team: 'Korea National Team',
      teamColor: const Color(0xFF6B21A8),
      position: 'Singles',
      imageUrl: 'assets/images/players/an_seyoung.png',
      worldRanking: 1,
      seasonWins: 5,
    ),

    // 수영
    Athlete(
      id: 'hwang_sunwoo',
      name: 'HWANG SUN WOO',
      nameKr: '황선우',
      lastName: 'SUN WOO',
      sport: SportType.swimming,
      team: 'Korea National Team',
      teamColor: const Color(0xFF0284C7),
      position: '자유형',
      imageUrl: 'assets/images/players/hwang_sunwoo.png',
      worldRanking: 3,
      personalBest: '47.12 (100m)',
    ),

    // 골프
    Athlete(
      id: 'ko_jinyoung',
      name: 'KO JIN YOUNG',
      nameKr: '고진영',
      lastName: 'JIN YOUNG',
      sport: SportType.golf,
      team: 'LPGA Tour',
      teamColor: const Color(0xFF10B981),
      imageUrl: 'assets/images/players/ko_jinyoung.png',
      worldRanking: 2,
      seasonWins: 3,
    ),
  ];

  static List<Athlete> getBySport(SportType sport) {
    return all.where((a) => a.sport == sport).toList();
  }

  static Athlete? getById(String id) {
    try {
      return all.firstWhere((a) => a.id == id);
    } catch (e) {
      return null;
    }
  }
}
