/// 경기 모델
class Match {
  final String id;
  final String homeTeam;
  final String awayTeam;
  final String homeTeamLogo;
  final String awayTeamLogo;
  final DateTime kickoffTime;
  final String competition;
  final String venue;
  final String? venueCity;
  final String? stadiumCity;     // 경기장 도시 (현지 정보용)
  final MatchStatus status;
  final int? homeScore;
  final int? awayScore;
  final String? playerId; // 관심 선수 ID
  final String? weatherCondition;
  final double? temperature;
  final List<MatchEvent> events;
  final String? broadcastChannel;
  final String? stadium;         // 경기장 이름
  final DateTime dateTime;       // 경기 일시
  final bool isMatchday;         // 매치데이 여부

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    this.homeTeamLogo = '',
    this.awayTeamLogo = '',
    required this.kickoffTime,
    required this.competition,
    required this.venue,
    this.venueCity,
    this.stadiumCity,
    this.status = MatchStatus.scheduled,
    this.homeScore,
    this.awayScore,
    this.playerId,
    this.weatherCondition,
    this.temperature,
    this.events = const [],
    this.broadcastChannel,
    this.stadium,
    DateTime? dateTime,
    this.isMatchday = false,
  }) : dateTime = dateTime ?? kickoffTime;

  /// 경기 시작까지 남은 시간
  Duration get timeUntilKickoff => kickoffTime.difference(DateTime.now());

  /// 매치데이 모드 활성화 여부 (경기 3시간 전부터)
  bool get isMatchDayMode => timeUntilKickoff.inHours <= 3 && timeUntilKickoff.inMinutes > 0;

  /// 경기 진행 중 여부
  bool get isLive => status == MatchStatus.live || status == MatchStatus.halfTime;

  /// 경기 종료 여부
  bool get isFinished => status == MatchStatus.finished;
}

/// 경기 상태
enum MatchStatus {
  scheduled,    // 예정됨
  live,         // 진행 중
  halfTime,     // 하프타임
  finished,     // 종료
  postponed,    // 연기
  cancelled,    // 취소
}

extension MatchStatusExtension on MatchStatus {
  String get displayName {
    switch (this) {
      case MatchStatus.scheduled:
        return '예정';
      case MatchStatus.live:
        return 'LIVE';
      case MatchStatus.halfTime:
        return 'HT';
      case MatchStatus.finished:
        return '종료';
      case MatchStatus.postponed:
        return '연기';
      case MatchStatus.cancelled:
        return '취소';
    }
  }
}

/// 경기 이벤트 (골, 어시스트, 카드 등)
class MatchEvent {
  final String id;
  final int minute;
  final MatchEventType type;
  final String playerName;
  final String? assistPlayerName;
  final String team;
  final String? description;

  MatchEvent({
    required this.id,
    required this.minute,
    required this.type,
    required this.playerName,
    this.assistPlayerName,
    required this.team,
    this.description,
  });
}

enum MatchEventType {
  goal,
  assist,
  yellowCard,
  redCard,
  substitution,
  penaltyMissed,
  penaltyScored,
  ownGoal,
}

extension MatchEventTypeExtension on MatchEventType {
  String get emoji {
    switch (this) {
      case MatchEventType.goal:
        return '⚽';
      case MatchEventType.assist:
        return '👟';
      case MatchEventType.yellowCard:
        return '🟨';
      case MatchEventType.redCard:
        return '🟥';
      case MatchEventType.substitution:
        return '🔄';
      case MatchEventType.penaltyMissed:
        return '❌';
      case MatchEventType.penaltyScored:
        return '⚽️';
      case MatchEventType.ownGoal:
        return '😓';
    }
  }

  String get displayName {
    switch (this) {
      case MatchEventType.goal:
        return '골';
      case MatchEventType.assist:
        return '어시스트';
      case MatchEventType.yellowCard:
        return '경고';
      case MatchEventType.redCard:
        return '퇴장';
      case MatchEventType.substitution:
        return '교체';
      case MatchEventType.penaltyMissed:
        return 'PK 실축';
      case MatchEventType.penaltyScored:
        return 'PK 성공';
      case MatchEventType.ownGoal:
        return '자책골';
    }
  }
}
