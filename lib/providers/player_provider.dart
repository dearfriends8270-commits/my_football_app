import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/player.dart';
import '../services/player_service.dart';

/// PlayerService Provider
final playerServiceProvider = Provider<PlayerService>((ref) {
  return PlayerService();
});

/// 전체 선수 목록 Provider
final allPlayersProvider = FutureProvider<List<Player>>((ref) async {
  final service = ref.read(playerServiceProvider);
  return await service.getAllPlayers();
});

/// 선수 상세 정보 Provider (ID 기반)
final playerByIdProvider = FutureProvider.family<Player?, String>((ref, playerId) async {
  final service = ref.read(playerServiceProvider);
  return await service.getPlayerById(playerId);
});

/// 선수 검색 Provider
final playerSearchProvider = FutureProvider.family<List<Player>, String>((ref, query) async {
  if (query.isEmpty) return [];
  final service = ref.read(playerServiceProvider);
  return await service.searchPlayers(query);
});

/// 인기 선수 Provider
final popularPlayersProvider = FutureProvider<List<Player>>((ref) async {
  final service = ref.read(playerServiceProvider);
  return await service.getPopularPlayers(limit: 5);
});

/// 포지션별 선수 Provider
final playersByPositionProvider = FutureProvider.family<List<Player>, String>((ref, position) async {
  final service = ref.read(playerServiceProvider);
  return await service.getPlayersByPosition(position);
});

/// 현재 선택된 선수 정보 Provider
final currentPlayerProvider = FutureProvider<Player?>((ref) async {
  // storage에서 선택된 선수 ID를 가져와서 선수 정보 조회
  // 기본값으로 이강인 반환
  final service = ref.read(playerServiceProvider);
  return await service.getPlayerById('lee_kangin');
});
