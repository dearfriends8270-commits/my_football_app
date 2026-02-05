import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/digital_ticket.dart';

/// 티켓 컬렉션 서비스 Provider
final ticketCollectionServiceProvider = Provider<TicketCollectionService>((ref) {
  return TicketCollectionService();
});

/// 티켓 컬렉션 상태 Provider
final ticketCollectionProvider =
    StateNotifierProvider<TicketCollectionNotifier, TicketCollectionState>((ref) {
  return TicketCollectionNotifier();
});

/// 컬렉션 통계 Provider
final collectionStatsProvider = Provider<TicketCollectionStats>((ref) {
  final state = ref.watch(ticketCollectionProvider);
  return _calculateStats(state.tickets);
});

/// 희귀도별 티켓 필터 Provider
final ticketsByRarityProvider =
    Provider.family<List<DigitalTicket>, TicketRarity?>((ref, rarity) {
  final state = ref.watch(ticketCollectionProvider);
  if (rarity == null) return state.tickets;
  return state.tickets.where((t) => t.rarity == rarity).toList();
});

/// 수집된 티켓만 필터 Provider
final collectedTicketsProvider = Provider<List<DigitalTicket>>((ref) {
  final state = ref.watch(ticketCollectionProvider);
  return state.tickets.where((t) => t.isCollected).toList();
});

/// 티켓 컬렉션 상태
class TicketCollectionState {
  final List<DigitalTicket> tickets;
  final bool isLoading;
  final String? error;
  final TicketSortOption sortOption;
  final TicketRarity? filterRarity;

  const TicketCollectionState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.sortOption = TicketSortOption.dateDesc,
    this.filterRarity,
  });

  TicketCollectionState copyWith({
    List<DigitalTicket>? tickets,
    bool? isLoading,
    String? error,
    TicketSortOption? sortOption,
    TicketRarity? filterRarity,
    bool clearFilter = false,
  }) {
    return TicketCollectionState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      sortOption: sortOption ?? this.sortOption,
      filterRarity: clearFilter ? null : (filterRarity ?? this.filterRarity),
    );
  }
}

/// 정렬 옵션
enum TicketSortOption {
  dateDesc,
  dateAsc,
  rarityDesc,
  rarityAsc,
}

extension TicketSortOptionExtension on TicketSortOption {
  String get displayName {
    switch (this) {
      case TicketSortOption.dateDesc:
        return '최신순';
      case TicketSortOption.dateAsc:
        return '오래된순';
      case TicketSortOption.rarityDesc:
        return '희귀도 높은순';
      case TicketSortOption.rarityAsc:
        return '희귀도 낮은순';
    }
  }
}

/// 티켓 컬렉션 Notifier
class TicketCollectionNotifier extends StateNotifier<TicketCollectionState> {
  TicketCollectionNotifier() : super(const TicketCollectionState()) {
    _loadSampleData();
  }

  void _loadSampleData() {
    state = state.copyWith(isLoading: true);

    // 샘플 데이터 로드
    final sampleTickets = _generateSampleTickets();
    state = state.copyWith(
      tickets: sampleTickets,
      isLoading: false,
    );
  }

  void collectTicket(String ticketId) {
    final updatedTickets = state.tickets.map((ticket) {
      if (ticket.id == ticketId && !ticket.isCollected) {
        return ticket.copyWith(
          isCollected: true,
          collectedAt: DateTime.now(),
        );
      }
      return ticket;
    }).toList();

    state = state.copyWith(tickets: updatedTickets);
  }

  void incrementViewCount(String ticketId) {
    final updatedTickets = state.tickets.map((ticket) {
      if (ticket.id == ticketId) {
        return ticket.copyWith(viewCount: ticket.viewCount + 1);
      }
      return ticket;
    }).toList();

    state = state.copyWith(tickets: updatedTickets);
  }

  void setSortOption(TicketSortOption option) {
    final sortedTickets = List<DigitalTicket>.from(state.tickets);

    switch (option) {
      case TicketSortOption.dateDesc:
        sortedTickets.sort((a, b) => b.matchDate.compareTo(a.matchDate));
        break;
      case TicketSortOption.dateAsc:
        sortedTickets.sort((a, b) => a.matchDate.compareTo(b.matchDate));
        break;
      case TicketSortOption.rarityDesc:
        sortedTickets.sort((a, b) => b.rarity.index.compareTo(a.rarity.index));
        break;
      case TicketSortOption.rarityAsc:
        sortedTickets.sort((a, b) => a.rarity.index.compareTo(b.rarity.index));
        break;
    }

    state = state.copyWith(
      tickets: sortedTickets,
      sortOption: option,
    );
  }

  void setFilterRarity(TicketRarity? rarity) {
    state = state.copyWith(
      filterRarity: rarity,
      clearFilter: rarity == null,
    );
  }
}

/// 티켓 컬렉션 서비스
class TicketCollectionService {
  /// 경기 결과에 따른 티켓 희귀도 계산
  TicketRarity calculateRarity({
    required String? score,
    required String? specialMoment,
    required double? playerRating,
    required String competition,
  }) {
    int rarityScore = 0;

    // 특별 순간이 있으면 높은 희귀도
    if (specialMoment != null) {
      if (specialMoment.contains('해트트릭') || specialMoment.contains('데뷔골')) {
        rarityScore += 4;
      } else if (specialMoment.contains('결승골') || specialMoment.contains('MVP')) {
        rarityScore += 3;
      } else {
        rarityScore += 2;
      }
    }

    // 선수 평점이 높으면
    if (playerRating != null) {
      if (playerRating >= 9.0) {
        rarityScore += 3;
      } else if (playerRating >= 8.0) {
        rarityScore += 2;
      } else if (playerRating >= 7.0) {
        rarityScore += 1;
      }
    }

    // 대회 중요도
    if (competition.contains('Champions League') ||
        competition.contains('World Cup')) {
      rarityScore += 2;
    } else if (competition.contains('Final') || competition.contains('결승')) {
      rarityScore += 3;
    }

    // 희귀도 결정
    if (rarityScore >= 7) return TicketRarity.legendary;
    if (rarityScore >= 5) return TicketRarity.epic;
    if (rarityScore >= 3) return TicketRarity.rare;
    if (rarityScore >= 1) return TicketRarity.uncommon;
    return TicketRarity.common;
  }
}

/// 컬렉션 통계 계산
TicketCollectionStats _calculateStats(List<DigitalTicket> tickets) {
  final collectedTickets = tickets.where((t) => t.isCollected).toList();

  final rarityCount = <TicketRarity, int>{};
  for (final rarity in TicketRarity.values) {
    rarityCount[rarity] = collectedTickets.where((t) => t.rarity == rarity).length;
  }

  final stadiums = collectedTickets.map((t) => t.stadium).toSet();
  final competitions = collectedTickets.map((t) => t.competition).toSet();

  // 가장 많이 본 팀
  final teamCounts = <String, int>{};
  for (final ticket in collectedTickets) {
    teamCounts[ticket.homeTeam] = (teamCounts[ticket.homeTeam] ?? 0) + 1;
    teamCounts[ticket.awayTeam] = (teamCounts[ticket.awayTeam] ?? 0) + 1;
  }
  String? favoriteTeam;
  int maxCount = 0;
  teamCounts.forEach((team, count) {
    if (count > maxCount) {
      maxCount = count;
      favoriteTeam = team;
    }
  });

  final sortedByDate = List<DigitalTicket>.from(collectedTickets)
    ..sort((a, b) => a.matchDate.compareTo(b.matchDate));

  return TicketCollectionStats(
    totalTickets: tickets.length,
    collectedTickets: collectedTickets.length,
    rarityCount: rarityCount,
    uniqueStadiums: stadiums.length,
    uniqueCompetitions: competitions.length,
    favoriteTeam: favoriteTeam,
    firstTicketDate: sortedByDate.isNotEmpty ? sortedByDate.first.matchDate : null,
    latestTicketDate: sortedByDate.isNotEmpty ? sortedByDate.last.matchDate : null,
  );
}

/// 샘플 티켓 데이터 생성
List<DigitalTicket> _generateSampleTickets() {
  return [
    DigitalTicket(
      id: 'ticket_1',
      matchId: 'match_1',
      homeTeam: 'PSG',
      awayTeam: 'Monaco',
      homeTeamLogo: '🔴🔵',
      awayTeamLogo: '🔴⚪',
      stadium: 'Parc des Princes',
      competition: 'Ligue 1',
      matchDate: DateTime(2024, 1, 28),
      score: '3 - 1',
      rarity: TicketRarity.epic,
      specialMoment: '이강인 데뷔골 + 도움',
      playerOfTheMatch: 'Lee Kang-In',
      playerRating: 8.7,
      isCollected: true,
      collectedAt: DateTime(2024, 1, 28),
      viewCount: 156,
      tags: ['데뷔골', '도움', 'MOTM'],
      design: TicketDesign.holographic,
    ),
    DigitalTicket(
      id: 'ticket_2',
      matchId: 'match_2',
      homeTeam: 'PSG',
      awayTeam: 'Real Sociedad',
      homeTeamLogo: '🔴🔵',
      awayTeamLogo: '🔵⚪',
      stadium: 'Parc des Princes',
      competition: 'Champions League',
      matchDate: DateTime(2024, 2, 14),
      score: '2 - 0',
      rarity: TicketRarity.legendary,
      specialMoment: 'UCL 16강 진출 확정',
      playerOfTheMatch: 'Lee Kang-In',
      playerRating: 9.1,
      isCollected: true,
      collectedAt: DateTime(2024, 2, 14),
      viewCount: 342,
      tags: ['UCL', '16강', '올스타급'],
      design: TicketDesign.premium,
    ),
    DigitalTicket(
      id: 'ticket_3',
      matchId: 'match_3',
      homeTeam: 'Lyon',
      awayTeam: 'PSG',
      homeTeamLogo: '🔵⚪',
      awayTeamLogo: '🔴🔵',
      stadium: 'Groupama Stadium',
      competition: 'Ligue 1',
      matchDate: DateTime(2024, 1, 21),
      score: '1 - 4',
      rarity: TicketRarity.rare,
      playerRating: 7.8,
      isCollected: true,
      collectedAt: DateTime(2024, 1, 21),
      viewCount: 89,
      tags: ['원정승', '대승'],
      design: TicketDesign.modern,
    ),
    DigitalTicket(
      id: 'ticket_4',
      matchId: 'match_4',
      homeTeam: 'PSG',
      awayTeam: 'Marseille',
      homeTeamLogo: '🔴🔵',
      awayTeamLogo: '⚪🔵',
      stadium: 'Parc des Princes',
      competition: 'Ligue 1',
      matchDate: DateTime(2024, 1, 14),
      score: '0 - 0',
      rarity: TicketRarity.common,
      playerRating: 6.5,
      isCollected: true,
      collectedAt: DateTime(2024, 1, 14),
      viewCount: 45,
      tags: ['르클라시크', '무승부'],
      design: TicketDesign.classic,
    ),
    DigitalTicket(
      id: 'ticket_5',
      matchId: 'match_5',
      homeTeam: 'Newcastle',
      awayTeam: 'PSG',
      homeTeamLogo: '⚫⚪',
      awayTeamLogo: '🔴🔵',
      stadium: 'St. James\' Park',
      competition: 'Champions League',
      matchDate: DateTime(2023, 10, 4),
      score: '4 - 1',
      rarity: TicketRarity.uncommon,
      playerRating: 5.8,
      isCollected: false,
      viewCount: 23,
      tags: ['UCL', '원정패'],
      design: TicketDesign.retro,
    ),
    DigitalTicket(
      id: 'ticket_6',
      matchId: 'match_6',
      homeTeam: 'PSG',
      awayTeam: 'Nice',
      homeTeamLogo: '🔴🔵',
      awayTeamLogo: '🔴⚫',
      stadium: 'Parc des Princes',
      competition: 'Coupe de France Final',
      matchDate: DateTime(2024, 5, 25),
      score: '2 - 1',
      rarity: TicketRarity.legendary,
      specialMoment: '결승전 결승골',
      playerOfTheMatch: 'Lee Kang-In',
      playerRating: 9.4,
      isCollected: false,
      viewCount: 0,
      tags: ['결승', '우승', '결승골'],
      design: TicketDesign.holographic,
    ),
  ];
}
