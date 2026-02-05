import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/storage_service.dart';

/// StorageService Provider
final storageServiceProvider = FutureProvider<StorageService>((ref) async {
  return await StorageService.getInstance();
});

/// 선택된 선수 ID Provider
final selectedPlayerIdProvider = StateNotifierProvider<SelectedPlayerIdNotifier, String?>((ref) {
  return SelectedPlayerIdNotifier(ref);
});

class SelectedPlayerIdNotifier extends StateNotifier<String?> {
  final Ref _ref;

  SelectedPlayerIdNotifier(this._ref) : super(null) {
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final storage = await _ref.read(storageServiceProvider.future);
    state = storage.getSelectedPlayerId();
  }

  Future<void> setPlayerId(String playerId) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setSelectedPlayerId(playerId);
    state = playerId;
  }

  Future<void> clearPlayerId() async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setSelectedPlayerId('');
    state = null;
  }
}

/// 즐겨찾기 선수 목록 Provider
final favoritePlayerIdsProvider = StateNotifierProvider<FavoritePlayerIdsNotifier, List<String>>((ref) {
  return FavoritePlayerIdsNotifier(ref);
});

class FavoritePlayerIdsNotifier extends StateNotifier<List<String>> {
  final Ref _ref;

  FavoritePlayerIdsNotifier(this._ref) : super([]) {
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final storage = await _ref.read(storageServiceProvider.future);
    state = storage.getFavoritePlayerIds();
  }

  Future<void> addFavorite(String playerId) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.addFavoritePlayer(playerId);
    if (!state.contains(playerId)) {
      state = [...state, playerId];
    }
  }

  Future<void> removeFavorite(String playerId) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.removeFavoritePlayer(playerId);
    state = state.where((id) => id != playerId).toList();
  }

  Future<void> toggleFavorite(String playerId) async {
    if (state.contains(playerId)) {
      await removeFavorite(playerId);
    } else {
      await addFavorite(playerId);
    }
  }

  bool isFavorite(String playerId) => state.contains(playerId);
}

/// 다크모드 Provider
final darkModeProvider = StateNotifierProvider<DarkModeNotifier, bool>((ref) {
  return DarkModeNotifier(ref);
});

class DarkModeNotifier extends StateNotifier<bool> {
  final Ref _ref;

  DarkModeNotifier(this._ref) : super(false) {
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final storage = await _ref.read(storageServiceProvider.future);
    state = storage.getDarkMode();
  }

  Future<void> toggle() async {
    final storage = await _ref.read(storageServiceProvider.future);
    final newValue = !state;
    await storage.setDarkMode(newValue);
    state = newValue;
  }

  Future<void> setDarkMode(bool value) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setDarkMode(value);
    state = value;
  }
}

/// 알림 설정 Provider
final notificationSettingsProvider = StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>((ref) {
  return NotificationSettingsNotifier(ref);
});

class NotificationSettings {
  final bool enabled;
  final bool matchdayAlerts;
  final bool goalAlerts;
  final bool newsAlerts;

  NotificationSettings({
    this.enabled = true,
    this.matchdayAlerts = true,
    this.goalAlerts = true,
    this.newsAlerts = false,
  });

  NotificationSettings copyWith({
    bool? enabled,
    bool? matchdayAlerts,
    bool? goalAlerts,
    bool? newsAlerts,
  }) {
    return NotificationSettings(
      enabled: enabled ?? this.enabled,
      matchdayAlerts: matchdayAlerts ?? this.matchdayAlerts,
      goalAlerts: goalAlerts ?? this.goalAlerts,
      newsAlerts: newsAlerts ?? this.newsAlerts,
    );
  }
}

class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final Ref _ref;

  NotificationSettingsNotifier(this._ref) : super(NotificationSettings()) {
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final storage = await _ref.read(storageServiceProvider.future);
    state = NotificationSettings(
      enabled: storage.getNotificationsEnabled(),
      matchdayAlerts: storage.getMatchdayAlerts(),
      goalAlerts: storage.getGoalAlerts(),
      newsAlerts: storage.getNewsAlerts(),
    );
  }

  Future<void> setEnabled(bool value) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setNotificationsEnabled(value);
    state = state.copyWith(enabled: value);
  }

  Future<void> setMatchdayAlerts(bool value) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setMatchdayAlerts(value);
    state = state.copyWith(matchdayAlerts: value);
  }

  Future<void> setGoalAlerts(bool value) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setGoalAlerts(value);
    state = state.copyWith(goalAlerts: value);
  }

  Future<void> setNewsAlerts(bool value) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.setNewsAlerts(value);
    state = state.copyWith(newsAlerts: value);
  }
}

/// 최근 검색어 Provider
final recentSearchesProvider = StateNotifierProvider<RecentSearchesNotifier, List<String>>((ref) {
  return RecentSearchesNotifier(ref);
});

class RecentSearchesNotifier extends StateNotifier<List<String>> {
  final Ref _ref;

  RecentSearchesNotifier(this._ref) : super([]) {
    _loadInitialValue();
  }

  Future<void> _loadInitialValue() async {
    final storage = await _ref.read(storageServiceProvider.future);
    state = storage.getRecentSearches();
  }

  Future<void> addSearch(String query) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.addRecentSearch(query);
    final searches = [...state];
    searches.remove(query);
    searches.insert(0, query);
    if (searches.length > 10) searches.removeLast();
    state = searches;
  }

  Future<void> removeSearch(String query) async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.removeRecentSearch(query);
    state = state.where((s) => s != query).toList();
  }

  Future<void> clearAll() async {
    final storage = await _ref.read(storageServiceProvider.future);
    await storage.clearRecentSearches();
    state = [];
  }
}
