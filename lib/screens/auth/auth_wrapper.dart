import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../main.dart';
import '../../providers/auth_provider.dart';
import '../../providers/athlete_provider.dart';
import '../onboarding/pick_your_star_screen.dart';
import '../main_screen.dart';
import 'welcome_screen.dart';

/// 인증 상태에 따라 적절한 화면으로 라우팅하는 래퍼 위젯
class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);

    // Firebase가 초기화되지 않은 경우 -> 환영 화면으로 바로 이동
    if (!isFirebaseInitialized) {
      // 즐겨찾기가 있으면 메인 화면, 없으면 환영 화면
      if (favoriteAthletes.isNotEmpty) {
        return const MainScreen();
      }
      return const WelcomeScreen();
    }

    // Firebase가 초기화된 경우에만 인증 상태 확인
    final authState = ref.watch(authProvider);

    // 인증 상태 초기화 중
    if (authState.status == AuthStatus.initial) {
      return const _LoadingScreen();
    }

    // 로그인되지 않은 경우 -> 환영 화면 (로그인/회원가입 선택)
    if (authState.status == AuthStatus.unauthenticated) {
      return const WelcomeScreen();
    }

    // 로그인된 경우
    if (authState.status == AuthStatus.authenticated) {
      // 즐겨찾기 선수가 없으면 -> 온보딩
      if (favoriteAthletes.isEmpty) {
        return const PickYourStarScreen();
      }
      // 즐겨찾기 선수가 있으면 -> 메인 화면
      return const MainScreen();
    }

    // 로딩 중
    return const _LoadingScreen();
  }
}

/// 로딩 화면
class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0A0A),
              Color(0xFF1A1A2E),
              Color(0xFF16213E),
            ],
          ),
        ),
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
