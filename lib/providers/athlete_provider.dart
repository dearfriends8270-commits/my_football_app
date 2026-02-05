import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/athlete.dart';
import '../models/sport_type.dart';

/// 선수 상태
class AthleteState {
  final List<Athlete> allAthletes;
  final List<Athlete> favoriteAthletes;
  final Athlete? selectedAthlete;
  final SportType? selectedSport;
  final bool isLoading;

  const AthleteState({
    this.allAthletes = const [],
    this.favoriteAthletes = const [],
    this.selectedAthlete,
    this.selectedSport,
    this.isLoading = false,
  });

  AthleteState copyWith({
    List<Athlete>? allAthletes,
    List<Athlete>? favoriteAthletes,
    Athlete? selectedAthlete,
    SportType? selectedSport,
    bool? isLoading,
  }) {
    return AthleteState(
      allAthletes: allAthletes ?? this.allAthletes,
      favoriteAthletes: favoriteAthletes ?? this.favoriteAthletes,
      selectedAthlete: selectedAthlete ?? this.selectedAthlete,
      selectedSport: selectedSport ?? this.selectedSport,
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
      // 이미 즐겨찾기 -> 제거
      currentFavorites.removeAt(index);
    } else {
      // 즐겨찾기 추가
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

    state = state.copyWith(
      favoriteAthletes: updatedAthletes,
      selectedAthlete: updatedAthletes.isNotEmpty ? updatedAthletes.first : null,
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

    // 순서 업데이트
    final updatedFavorites = favorites.asMap().entries.map((entry) {
      return entry.value.copyWith(favoriteOrder: entry.key);
    }).toList();

    state = state.copyWith(favoriteAthletes: updatedFavorites);
  }

  /// 즐겨찾기 추가
  void addFavorite(Athlete athlete) {
    if (state.favoriteAthletes.any((a) => a.id == athlete.id)) return;

    final updatedAthlete = athlete.copyWith(
      isFavorite: true,
      favoriteOrder: state.favoriteAthletes.length,
    );
    final updated = [...state.favoriteAthletes, updatedAthlete];
    state = state.copyWith(favoriteAthletes: updated);
  }

  /// 즐겨찾기 제거
  void removeFavorite(String athleteId) {
    final updated = state.favoriteAthletes.where((a) => a.id != athleteId).toList();
    // 순서 재정렬
    final reordered = updated.asMap().entries.map((entry) {
      return entry.value.copyWith(favoriteOrder: entry.key);
    }).toList();
    state = state.copyWith(favoriteAthletes: reordered);
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
