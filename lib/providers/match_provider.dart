import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match.dart';
import '../services/match_service.dart';

/// MatchService Provider
final matchServiceProvider = Provider<MatchService>((ref) {
  return MatchService();
});

/// 다음 경기 Provider (선수 ID 기반)
final nextMatchProvider = FutureProvider.family<Match?, String>((ref, playerId) async {
  final service = ref.read(matchServiceProvider);
  return await service.getNextMatch(playerId);
});

/// 최근 경기 목록 Provider
final recentMatchesProvider = FutureProvider.family<List<Match>, String>((ref, playerId) async {
  final service = ref.read(matchServiceProvider);
  return await service.getRecentMatches(playerId, limit: 5);
});

/// 예정된 경기 목록 Provider
final upcomingMatchesProvider = FutureProvider.family<List<Match>, String>((ref, playerId) async {
  final service = ref.read(matchServiceProvider);
  return await service.getUpcomingMatches(playerId, limit: 5);
});

/// 실시간 경기 Provider
final liveMatchProvider = FutureProvider.family<Match?, String>((ref, playerId) async {
  final service = ref.read(matchServiceProvider);
  return await service.getLiveMatch(playerId);
});

/// 경기 상세 정보 State
class MatchDetailState {
  final Match? match;
  final bool isLoading;
  final String? error;

  MatchDetailState({
    this.match,
    this.isLoading = false,
    this.error,
  });

  MatchDetailState copyWith({
    Match? match,
    bool? isLoading,
    String? error,
  }) {
    return MatchDetailState(
      match: match ?? this.match,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 경기 상태별 필터 Provider
final matchStatusFilterProvider = StateProvider<MatchStatus?>((ref) => null);

/// 필터링된 경기 목록 Provider
final filteredMatchesProvider = FutureProvider.family<List<Match>, String>((ref, playerId) async {
  final service = ref.read(matchServiceProvider);
  final statusFilter = ref.watch(matchStatusFilterProvider);

  final recentMatches = await service.getRecentMatches(playerId, limit: 10);
  final upcomingMatches = await service.getUpcomingMatches(playerId, limit: 10);

  final allMatches = [...recentMatches, ...upcomingMatches];

  if (statusFilter != null) {
    return allMatches.where((m) => m.status == statusFilter).toList();
  }

  return allMatches..sort((a, b) => a.kickoffTime.compareTo(b.kickoffTime));
});
