import '../models/match.dart';

/// 경기 데이터 서비스 (현재는 Mock 데이터, 추후 API 연동)
class MatchService {
  static final MatchService _instance = MatchService._();
  factory MatchService() => _instance;
  MatchService._();

  /// 선수의 다음 경기 조회
  Future<Match?> getNextMatch(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 300));

    // Mock 데이터 - 선수별 다음 경기
    final matches = _getMockMatches(playerId);
    final now = DateTime.now();

    try {
      return matches.firstWhere(
        (m) => m.kickoffTime.isAfter(now) && m.status == MatchStatus.scheduled,
      );
    } catch (e) {
      // 예정된 경기가 없으면 가장 가까운 미래 경기 반환
      return matches.isNotEmpty ? matches.first : null;
    }
  }

  /// 선수의 최근 경기 목록 조회
  Future<List<Match>> getRecentMatches(String playerId, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final matches = _getMockMatches(playerId);
    final now = DateTime.now();

    final recentMatches = matches
        .where((m) => m.kickoffTime.isBefore(now) || m.status == MatchStatus.finished)
        .toList()
      ..sort((a, b) => b.kickoffTime.compareTo(a.kickoffTime));

    return recentMatches.take(limit).toList();
  }

  /// 선수의 예정된 경기 목록 조회
  Future<List<Match>> getUpcomingMatches(String playerId, {int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 300));

    final matches = _getMockMatches(playerId);
    final now = DateTime.now();

    final upcomingMatches = matches
        .where((m) => m.kickoffTime.isAfter(now) && m.status == MatchStatus.scheduled)
        .toList()
      ..sort((a, b) => a.kickoffTime.compareTo(b.kickoffTime));

    return upcomingMatches.take(limit).toList();
  }

  /// 실시간 경기 정보 조회 (LIVE 경기)
  Future<Match?> getLiveMatch(String playerId) async {
    await Future.delayed(const Duration(milliseconds: 200));

    final matches = _getMockMatches(playerId);
    try {
      return matches.firstWhere((m) => m.isLive);
    } catch (e) {
      return null;
    }
  }

  /// Mock 데이터 생성
  List<Match> _getMockMatches(String playerId) {
    final now = DateTime.now();

    switch (playerId) {
      case 'lee_kangin':
        return [
          Match(
            id: 'match_1',
            homeTeam: 'Paris Saint-Germain',
            awayTeam: 'Olympique Marseille',
            homeTeamLogo: 'https://media.api-sports.io/football/teams/85.png',
            awayTeamLogo: 'https://media.api-sports.io/football/teams/81.png',
            kickoffTime: now.add(const Duration(days: 3, hours: 5)),
            competition: 'Ligue 1',
            venue: 'Parc des Princes',
            venueCity: 'Paris',
            playerId: playerId,
            broadcastChannel: 'SPOTV ON',
            weatherCondition: '맑음',
            temperature: 12.5,
          ),
          Match(
            id: 'match_2',
            homeTeam: 'Barcelona',
            awayTeam: 'Paris Saint-Germain',
            homeTeamLogo: 'https://media.api-sports.io/football/teams/529.png',
            awayTeamLogo: 'https://media.api-sports.io/football/teams/85.png',
            kickoffTime: now.add(const Duration(days: 10)),
            competition: 'Champions League',
            venue: 'Camp Nou',
            venueCity: 'Barcelona',
            playerId: playerId,
            broadcastChannel: 'TVING',
          ),
          Match(
            id: 'match_3',
            homeTeam: 'Paris Saint-Germain',
            awayTeam: 'Lyon',
            homeTeamLogo: 'https://media.api-sports.io/football/teams/85.png',
            awayTeamLogo: 'https://media.api-sports.io/football/teams/80.png',
            kickoffTime: now.subtract(const Duration(days: 4)),
            competition: 'Ligue 1',
            venue: 'Parc des Princes',
            status: MatchStatus.finished,
            homeScore: 3,
            awayScore: 1,
            playerId: playerId,
            events: [
              MatchEvent(
                id: 'event_1',
                minute: 23,
                type: MatchEventType.goal,
                playerName: '이강인',
                team: 'PSG',
              ),
              MatchEvent(
                id: 'event_2',
                minute: 67,
                type: MatchEventType.assist,
                playerName: '이강인',
                team: 'PSG',
                description: '음바페 골 어시스트',
              ),
            ],
          ),
        ];

      case 'son_heungmin':
        return [
          Match(
            id: 'match_4',
            homeTeam: 'Tottenham Hotspur',
            awayTeam: 'Manchester United',
            homeTeamLogo: 'https://media.api-sports.io/football/teams/47.png',
            awayTeamLogo: 'https://media.api-sports.io/football/teams/33.png',
            kickoffTime: now.add(const Duration(days: 2, hours: 3)),
            competition: 'Premier League',
            venue: 'Tottenham Hotspur Stadium',
            venueCity: 'London',
            playerId: playerId,
            broadcastChannel: 'SPOTV ON',
          ),
          Match(
            id: 'match_5',
            homeTeam: 'Arsenal',
            awayTeam: 'Tottenham Hotspur',
            homeTeamLogo: 'https://media.api-sports.io/football/teams/42.png',
            awayTeamLogo: 'https://media.api-sports.io/football/teams/47.png',
            kickoffTime: now.subtract(const Duration(days: 7)),
            competition: 'Premier League',
            venue: 'Emirates Stadium',
            status: MatchStatus.finished,
            homeScore: 2,
            awayScore: 3,
            playerId: playerId,
            events: [
              MatchEvent(
                id: 'event_3',
                minute: 15,
                type: MatchEventType.goal,
                playerName: '손흥민',
                team: 'Tottenham',
              ),
              MatchEvent(
                id: 'event_4',
                minute: 78,
                type: MatchEventType.goal,
                playerName: '손흥민',
                team: 'Tottenham',
              ),
            ],
          ),
        ];

      default:
        return [
          Match(
            id: 'match_default',
            homeTeam: 'Home Team',
            awayTeam: 'Away Team',
            kickoffTime: now.add(const Duration(days: 5)),
            competition: 'League',
            venue: 'Stadium',
            playerId: playerId,
          ),
        ];
    }
  }
}
