import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/sport_type.dart';
import '../models/athlete.dart';

/// 앱 테마 상태
class AppThemeState {
  final Color primaryColor;
  final Color secondaryColor;
  final SportType? currentSport;
  final Athlete? primaryAthlete;
  final Brightness brightness;

  const AppThemeState({
    this.primaryColor = const Color(0xFF001C58), // 기본: Navy
    this.secondaryColor = const Color(0xFFED174B), // 기본: Red
    this.currentSport,
    this.primaryAthlete,
    this.brightness = Brightness.light,
  });

  AppThemeState copyWith({
    Color? primaryColor,
    Color? secondaryColor,
    SportType? currentSport,
    Athlete? primaryAthlete,
    Brightness? brightness,
  }) {
    return AppThemeState(
      primaryColor: primaryColor ?? this.primaryColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      currentSport: currentSport ?? this.currentSport,
      primaryAthlete: primaryAthlete ?? this.primaryAthlete,
      brightness: brightness ?? this.brightness,
    );
  }

  /// ThemeData 생성
  ThemeData get themeData {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: brightness,
        primary: primaryColor,
        secondary: secondaryColor,
      ),
      fontFamily: 'Roboto',
      useMaterial3: true,
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: secondaryColor,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: primaryColor,
        unselectedItemColor: Colors.grey,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: primaryColor, width: 2),
        ),
      ),
    );
  }
}

/// 테마 Notifier
class AppThemeNotifier extends StateNotifier<AppThemeState> {
  AppThemeNotifier() : super(const AppThemeState());

  /// 종목별 테마로 변경
  void setThemeBySport(SportType sport) {
    state = state.copyWith(
      primaryColor: sport.primaryColor,
      secondaryColor: sport.secondaryColor,
      currentSport: sport,
    );
  }

  /// 선수별 테마로 변경 (선수의 팀 컬러 적용)
  void setThemeByAthlete(Athlete athlete) {
    state = state.copyWith(
      primaryColor: athlete.teamColor,
      secondaryColor: athlete.sport.secondaryColor,
      currentSport: athlete.sport,
      primaryAthlete: athlete,
    );
  }

  /// 프리셋으로 테마 변경
  void setThemeByPreset(Color primaryColor, Color secondaryColor) {
    state = state.copyWith(
      primaryColor: primaryColor,
      secondaryColor: secondaryColor,
    );
  }

  /// 밝기 모드 변경
  void setBrightness(Brightness brightness) {
    state = state.copyWith(brightness: brightness);
  }

  /// 다크모드 토글
  void toggleDarkMode() {
    state = state.copyWith(
      brightness: state.brightness == Brightness.light
          ? Brightness.dark
          : Brightness.light,
    );
  }

  /// 기본 테마로 리셋
  void resetTheme() {
    state = const AppThemeState();
  }
}

/// 테마 Provider
final appThemeProvider =
    StateNotifierProvider<AppThemeNotifier, AppThemeState>((ref) {
  return AppThemeNotifier();
});

/// 현재 ThemeData Provider
final themeDataProvider = Provider<ThemeData>((ref) {
  final themeState = ref.watch(appThemeProvider);
  return themeState.themeData;
});
