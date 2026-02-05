import 'package:shared_preferences/shared_preferences.dart';

/// 로컬 저장소 서비스
class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _prefs;

  StorageService._();

  static Future<StorageService> getInstance() async {
    _instance ??= StorageService._();
    _prefs ??= await SharedPreferences.getInstance();
    return _instance!;
  }

  // Keys
  static const String _keySelectedPlayerId = 'selected_player_id';
  static const String _keyFavoritePlayerIds = 'favorite_player_ids';
  static const String _keyNotificationsEnabled = 'notifications_enabled';
  static const String _keyMatchdayAlerts = 'matchday_alerts';
  static const String _keyGoalAlerts = 'goal_alerts';
  static const String _keyNewsAlerts = 'news_alerts';
  static const String _keyDarkMode = 'dark_mode';
  static const String _keyLanguage = 'language';
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keyOnboardingComplete = 'onboarding_complete';

  // Selected Player
  Future<void> setSelectedPlayerId(String playerId) async {
    await _prefs?.setString(_keySelectedPlayerId, playerId);
  }

  String? getSelectedPlayerId() {
    return _prefs?.getString(_keySelectedPlayerId);
  }

  // Favorite Players
  Future<void> setFavoritePlayerIds(List<String> playerIds) async {
    await _prefs?.setStringList(_keyFavoritePlayerIds, playerIds);
  }

  List<String> getFavoritePlayerIds() {
    return _prefs?.getStringList(_keyFavoritePlayerIds) ?? [];
  }

  Future<void> addFavoritePlayer(String playerId) async {
    final favorites = getFavoritePlayerIds();
    if (!favorites.contains(playerId)) {
      favorites.add(playerId);
      await setFavoritePlayerIds(favorites);
    }
  }

  Future<void> removeFavoritePlayer(String playerId) async {
    final favorites = getFavoritePlayerIds();
    favorites.remove(playerId);
    await setFavoritePlayerIds(favorites);
  }

  bool isFavoritePlayer(String playerId) {
    return getFavoritePlayerIds().contains(playerId);
  }

  // Notification Settings
  Future<void> setNotificationsEnabled(bool enabled) async {
    await _prefs?.setBool(_keyNotificationsEnabled, enabled);
  }

  bool getNotificationsEnabled() {
    return _prefs?.getBool(_keyNotificationsEnabled) ?? true;
  }

  Future<void> setMatchdayAlerts(bool enabled) async {
    await _prefs?.setBool(_keyMatchdayAlerts, enabled);
  }

  bool getMatchdayAlerts() {
    return _prefs?.getBool(_keyMatchdayAlerts) ?? true;
  }

  Future<void> setGoalAlerts(bool enabled) async {
    await _prefs?.setBool(_keyGoalAlerts, enabled);
  }

  bool getGoalAlerts() {
    return _prefs?.getBool(_keyGoalAlerts) ?? true;
  }

  Future<void> setNewsAlerts(bool enabled) async {
    await _prefs?.setBool(_keyNewsAlerts, enabled);
  }

  bool getNewsAlerts() {
    return _prefs?.getBool(_keyNewsAlerts) ?? false;
  }

  // Theme
  Future<void> setDarkMode(bool enabled) async {
    await _prefs?.setBool(_keyDarkMode, enabled);
  }

  bool getDarkMode() {
    return _prefs?.getBool(_keyDarkMode) ?? false;
  }

  // Language
  Future<void> setLanguage(String languageCode) async {
    await _prefs?.setString(_keyLanguage, languageCode);
  }

  String getLanguage() {
    return _prefs?.getString(_keyLanguage) ?? 'ko';
  }

  // Recent Searches
  Future<void> addRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query); // 중복 제거
    searches.insert(0, query); // 맨 앞에 추가
    if (searches.length > 10) {
      searches.removeLast(); // 최대 10개 유지
    }
    await _prefs?.setStringList(_keyRecentSearches, searches);
  }

  List<String> getRecentSearches() {
    return _prefs?.getStringList(_keyRecentSearches) ?? [];
  }

  Future<void> removeRecentSearch(String query) async {
    final searches = getRecentSearches();
    searches.remove(query);
    await _prefs?.setStringList(_keyRecentSearches, searches);
  }

  Future<void> clearRecentSearches() async {
    await _prefs?.setStringList(_keyRecentSearches, []);
  }

  // Onboarding
  Future<void> setOnboardingComplete(bool complete) async {
    await _prefs?.setBool(_keyOnboardingComplete, complete);
  }

  bool getOnboardingComplete() {
    return _prefs?.getBool(_keyOnboardingComplete) ?? false;
  }

  // Clear all data
  Future<void> clearAll() async {
    await _prefs?.clear();
  }
}
