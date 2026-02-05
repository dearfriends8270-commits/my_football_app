import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../main.dart';
import '../providers/auth_provider.dart';
import '../screens/auth/login_screen.dart';

/// 로그인이 필요한 기능에 접근할 때 사용하는 유틸리티 클래스
class AuthGuard {
  /// 로그인 여부를 확인하고, 비로그인 시 로그인 다이얼로그를 표시
  /// 로그인된 경우 true 반환, 비로그인 시 false 반환
  static bool checkAuth(BuildContext context, WidgetRef ref) {
    // Firebase 미초기화 또는 비로그인 상태
    final isLoggedIn = isFirebaseInitialized
        ? ref.read(authProvider).isAuthenticated
        : false;

    if (!isLoggedIn) {
      showLoginRequiredDialog(context);
      return false;
    }
    return true;
  }

  /// 로그인 필요 다이얼로그 표시
  static void showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.lock_outline, color: Colors.grey[600]),
            const SizedBox(width: 8),
            const Text('로그인 필요'),
          ],
        ),
        content: const Text(
          '이 기능을 사용하려면 로그인이 필요합니다.\n로그인하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              '취소',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E4A6E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('로그인'),
          ),
        ],
      ),
    );
  }

  /// 로그인 상태 확인 (다이얼로그 없이)
  static bool isLoggedIn(WidgetRef ref) {
    return isFirebaseInitialized
        ? ref.read(authProvider).isAuthenticated
        : false;
  }
}
