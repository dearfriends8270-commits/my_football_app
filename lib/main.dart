import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/splash_screen.dart';
import 'providers/theme_provider.dart';

// Firebase 초기화 상태를 전역으로 관리
bool isFirebaseInitialized = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (실패해도 앱 실행 가능)
  try {
    await Firebase.initializeApp();
    isFirebaseInitialized = true;
    debugPrint('✅ Firebase 초기화 성공');
  } catch (e) {
    isFirebaseInitialized = false;
    debugPrint('⚠️ Firebase 초기화 실패 (오프라인 모드로 실행): $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(appThemeProvider);

    return MaterialApp(
      title: 'K-Player Tracker',
      debugShowCheckedModeBanner: false,
      theme: themeState.themeData,
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: themeState.primaryColor,
          brightness: Brightness.dark,
          primary: themeState.primaryColor,
          secondary: themeState.secondaryColor,
        ),
        fontFamily: 'Roboto',
        useMaterial3: true,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: themeState.primaryColor,
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
            backgroundColor: themeState.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
      themeMode: themeState.brightness == Brightness.dark
          ? ThemeMode.dark
          : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}
