import '../models/player.dart';

/// 선수 데이터 서비스 (현재는 Mock 데이터, 추후 API 연동)
class PlayerService {
  static final PlayerService _instance = PlayerService._();
  factory PlayerService() => _instance;
  PlayerService._();

  // Mock 선수 데이터
  final List<Player> _players = [
    Player(
      id: 'lee_kangin',
      name: '이강인',
      team: 'Paris Saint-Germain',
      number: 19,
      position: 'MF',
      nationality: '대한민국',
      imageUrl: 'https://media.api-sports.io/football/players/184432.png',
      goals: 4,
      assists: 7,
      rating: 7.2,
    ),
    Player(
      id: 'son_heungmin',
      name: '손흥민',
      team: 'Tottenham Hotspur',
      number: 7,
      position: 'FW',
      nationality: '대한민국',
      imageUrl: 'https://media.api-sports.io/football/players/186.png',
      goals: 12,
      assists: 6,
      rating: 7.5,
    ),
    Player(
      id: 'kim_minjae',
      name: '김민재',
      team: 'Bayern Munich',
      number: 3,
      position: 'DF',
      nationality: '대한민국',
      imageUrl: 'https://media.api-sports.io/football/players/50096.png',
      goals: 1,
      assists: 0,
      rating: 7.1,
    ),
    Player(
      id: 'hwang_heechan',
      name: '황희찬',
      team: 'Wolverhampton',
      number: 11,
      position: 'FW',
      nationality: '대한민국',
      imageUrl: 'https://media.api-sports.io/football/players/38908.png',
      goals: 8,
      assists: 3,
      rating: 6.9,
    ),
    Player(
      id: 'jeong_wooeyong',
      name: '정우영',
      team: 'VfB Stuttgart',
      number: 29,
      position: 'MF',
      nationality: '대한민국',
      imageUrl: 'https://media.api-sports.io/football/players/24821.png',
      goals: 2,
      assists: 4,
      rating: 6.8,
    ),
    Player(
      id: 'cho_gyuesung',
      name: '조규성',
      team: 'Midtjylland',
      number: 9,
      position: 'FW',
      nationality: '대한민국',
      goals: 6,
      assists: 2,
      rating: 6.7,
    ),
  ];

  /// 모든 선수 목록 조회
  Future<List<Player>> getAllPlayers() async {
    // API 연동 시 네트워크 요청으로 대체
    await Future.delayed(const Duration(milliseconds: 300));
    return _players;
  }

  /// 선수 ID로 선수 조회
  Future<Player?> getPlayerById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  /// 선수 검색 (이름, 팀으로 검색)
  Future<List<Player>> searchPlayers(String query) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final lowerQuery = query.toLowerCase();
    return _players.where((player) {
      return player.name.toLowerCase().contains(lowerQuery) ||
          player.team.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  /// 포지션별 선수 조회
  Future<List<Player>> getPlayersByPosition(String position) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _players.where((p) => p.position == position).toList();
  }

  /// 팀별 선수 조회
  Future<List<Player>> getPlayersByTeam(String team) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _players.where((p) => p.team == team).toList();
  }

  /// 인기 선수 조회 (상위 N명)
  Future<List<Player>> getPopularPlayers({int limit = 5}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final sorted = List<Player>.from(_players)
      ..sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(limit).toList();
  }
}
