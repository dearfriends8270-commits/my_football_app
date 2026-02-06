import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete.dart';
import '../models/sport_type.dart';

/// 선수 상태
class AthleteState {
  final List<Athlete> allAthletes;
  final List<Athlete> favoriteAthletes;
  final Athlete? selectedAthlete;
  final SportType? selectedSport;
  final Set<SportType> followedSports;
  final bool isLoading;

  const AthleteState({
    this.allAthletes = const [],
    this.favoriteAthletes = const [],
    this.selectedAthlete,
    this.selectedSport,
    this.followedSports = const <SportType>{},
    this.isLoading = false,
  });

  AthleteState copyWith({
    List<Athlete>? allAthletes,
    List<Athlete>? favoriteAthletes,
    Athlete? selectedAthlete,
    SportType? selectedSport,
    Set<SportType>? followedSports,
    bool? isLoading,
  }) {
    return AthleteState(
      allAthletes: allAthletes ?? this.allAthletes,
      favoriteAthletes: favoriteAthletes ?? this.favoriteAthletes,
      selectedAthlete: selectedAthlete ?? this.selectedAthlete,
      selectedSport: selectedSport ?? this.selectedSport,
      followedSports: followedSports ?? this.followedSports,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  /// 특정 종목의 선수 목록
  List<Athlete> getAthletesBySport(SportType sport) {
    return allAthletes.where((a) => a.sport == sport).toList();
  }

  /// 즐겨찾기 여부 확인
  bool isFavorite(String athleteId) {
    return favoriteAthletes.any((a) => a.id == athleteId);
  }
}

/// 선수 Notifier
class AthleteNotifier extends StateNotifier<AthleteState> {
  AthleteNotifier() : super(const AthleteState()) {
    _loadInitialData();
  }

  /// 초기 데이터 로드
  void _loadInitialData() {
    state = state.copyWith(
      allAthletes: SampleAthletes.all,
      isLoading: false,
    );
  }

  /// 즐겨찾기 토글
  void toggleFavorite(Athlete athlete) {
    final currentFavorites = List<Athlete>.from(state.favoriteAthletes);
    final index = currentFavorites.indexWhere((a) => a.id == athlete.id);

    if (index >= 0) {
      currentFavorites.removeAt(index);
    } else {
      final updatedAthlete = athlete.copyWith(
        isFavorite: true,
        favoriteOrder: currentFavorites.length,
      );
      currentFavorites.add(updatedAthlete);
    }

    state = state.copyWith(favoriteAthletes: currentFavorites);
  }

  /// 즐겨찾기 선수 설정 (온보딩에서 사용)
  void setFavoriteAthletes(List<Athlete> athletes) {
    final updatedAthletes = athletes.asMap().entries.map((entry) {
      return entry.value.copyWith(
        isFavorite: true,
        favoriteOrder: entry.key,
      );
    }).toList();

    // 선수들의 종목을 자동 팔로우
    final sports = updatedAthletes.map((a) => a.sport).toSet();
    final updatedSports = Set<SportType>.from(state.followedSports)..addAll(sports);

    state = state.copyWith(
      favoriteAthletes: updatedAthletes,
      selectedAthlete: updatedAthletes.isNotEmpty ? updatedAthletes.first : null,
      followedSports: updatedSports,
    );
  }

  /// 현재 선택된 선수 변경
  void selectAthlete(Athlete athlete) {
    state = state.copyWith(selectedAthlete: athlete);
  }

  /// 현재 선택된 종목 변경
  void selectSport(SportType sport) {
    state = state.copyWith(selectedSport: sport);
  }

  /// 1순위 즐겨찾기 선수 가져오기
  Athlete? get primaryAthlete {
    if (state.favoriteAthletes.isEmpty) return null;
    return state.favoriteAthletes.first;
  }

  /// 즐겨찾기 순서 변경
  void reorderFavorites(int oldIndex, int newIndex) {
    final favorites = List<Athlete>.from(state.favoriteAthletes);
    if (newIndex > oldIndex) newIndex--;
    final item = favorites.removeAt(oldIndex);
    favorites.insert(newIndex, item);

    final updatedFavorites = favorites.asMap().entries.map((entry) {
      return entry.value.copyWith(favoriteOrder: entry.key);
    }).toList();

    state = state.copyWith(favoriteAthletes: updatedFavorites);
  }

  /// 즐겨찾기 추가 (해당 종목 자동 팔로우)
  void addFavorite(Athlete athlete) {
    if (state.favoriteAthletes.any((a) => a.id == athlete.id)) return;

    final updatedAthlete = athlete.copyWith(
      isFavorite: true,
      favoriteOrder: state.favoriteAthletes.length,
    );
    final updated = [...state.favoriteAthletes, updatedAthlete];

    // 해당 종목 자동 팔로우
    final updatedSports = Set<SportType>.from(state.followedSports)..add(athlete.sport);

    state = state.copyWith(
      favoriteAthletes: updated,
      followedSports: updatedSports,
    );
  }

  /// 즐겨찾기 제거
  void removeFavorite(String athleteId) {
    final updated = state.favoriteAthletes.where((a) => a.id != athleteId).toList();
    final reordered = updated.asMap().entries.map((entry) {
      return entry.value.copyWith(favoriteOrder: entry.key);
    }).toList();
    state = state.copyWith(favoriteAthletes: reordered);
  }

  // ─── 팔로우 종목 관리 ───

  /// 팔로우 종목 추가
  void addFollowedSport(SportType sport) {
    final updated = Set<SportType>.from(state.followedSports)..add(sport);
    state = state.copyWith(followedSports: updated);
  }

  /// 팔로우 종목 제거
  void removeFollowedSport(SportType sport) {
    final updated = Set<SportType>.from(state.followedSports)..remove(sport);
    state = state.copyWith(followedSports: updated);
  }

  /// 팔로우 종목 토글
  void toggleFollowedSport(SportType sport) {
    if (state.followedSports.contains(sport)) {
      removeFollowedSport(sport);
    } else {
      addFollowedSport(sport);
    }
  }

  /// 팔로우 종목 일괄 설정
  void setFollowedSports(Set<SportType> sports) {
    state = state.copyWith(followedSports: sports);
  }
}

/// 선수 Provider
final athleteProvider =
    StateNotifierProvider<AthleteNotifier, AthleteState>((ref) {
  return AthleteNotifier();
});

/// 모든 선수 목록 Provider
final allAthletesProvider = Provider<List<Athlete>>((ref) {
  return ref.watch(athleteProvider).allAthletes;
});

/// 즐겨찾기 선수 목록 Provider
final favoriteAthletesProvider = Provider<List<Athlete>>((ref) {
  return ref.watch(athleteProvider).favoriteAthletes;
});

/// 즐겨찾기 선수 관리를 위한 Notifier Provider
class FavoriteAthletesNotifier {
  final Ref _ref;

  FavoriteAthletesNotifier(this._ref);

  void addFavorite(Athlete athlete) {
    _ref.read(athleteProvider.notifier).addFavorite(athlete);
  }

  void removeFavorite(String athleteId) {
    _ref.read(athleteProvider.notifier).removeFavorite(athleteId);
  }

  void reorder(int oldIndex, int newIndex) {
    _ref.read(athleteProvider.notifier).reorderFavorites(oldIndex, newIndex);
  }
}

final favoriteAthletesNotifierProvider = Provider<FavoriteAthletesNotifier>((ref) {
  return FavoriteAthletesNotifier(ref);
});

/// 현재 선택된 선수 Provider
final selectedAthleteProvider = Provider<Athlete?>((ref) {
  return ref.watch(athleteProvider).selectedAthlete;
});

/// 종목별 선수 목록 Provider
final athletesBySportProvider =
    Provider.family<List<Athlete>, SportType>((ref, sport) {
  return ref.watch(athleteProvider).getAthletesBySport(sport);
});

/// 팔로우 종목 Provider
final followedSportsProvider = Provider<Set<SportType>>((ref) {
  return ref.watch(athleteProvider).followedSports;
});

/// 종목만 팔로우 (선수 없는 종목) Provider
final sportOnlyFollowsProvider = Provider<Set<SportType>>((ref) {
  final state = ref.watch(athleteProvider);
  final sportsWithAthletes = state.favoriteAthletes.map((a) => a.sport).toSet();
  return state.followedSports.difference(sportsWithAthletes);
});

/// MainScreen 탭 인덱스 Provider
final mainTabIndexProvider = StateProvider<int>((ref) => 2);
