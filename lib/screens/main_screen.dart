import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/athlete_provider.dart';
import '../utils/app_colors.dart';
import 'home/home_screen_new.dart';
import 'player/player_manage_screen.dart';
import 'ai/ai_summary_screen.dart';
import 'talk/community_screen.dart';
import 'settings/settings_screen.dart';

/// 테마 프리셋 정의
class ThemePreset {
  final String id;
  final String name;
  final String icon;
  final Color primaryColor;
  final Color secondaryColor;

  const ThemePreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.primaryColor,
    required this.secondaryColor,
  });
}

/// 테마 프리셋 목록
final themePresets = [
  const ThemePreset(
    id: 'psg',
    name: 'PSG',
    icon: '🔵',
    primaryColor: Color(0xFF001C58),
    secondaryColor: Color(0xFFED174B),
  ),
  const ThemePreset(
    id: 'spurs',
    name: '토트넘',
    icon: '⚪',
    primaryColor: Color(0xFF132257),
    secondaryColor: Color(0xFFFFFFFF),
  ),
  const ThemePreset(
    id: 'bayern',
    name: '바이에른',
    icon: '🔴',
    primaryColor: Color(0xFFDC052D),
    secondaryColor: Color(0xFF0066B2),
  ),
  const ThemePreset(
    id: 'giants',
    name: 'SF Giants',
    icon: '🧡',
    primaryColor: Color(0xFFFD5A1E),
    secondaryColor: Color(0xFF27251F),
  ),
  const ThemePreset(
    id: 'dark',
    name: '다크',
    icon: '🌙',
    primaryColor: Color(0xFF1A1A2E),
    secondaryColor: Color(0xFF16213E),
  ),
  const ThemePreset(
    id: 'light',
    name: '라이트',
    icon: '☀️',
    primaryColor: Color(0xFF4A90D9),
    secondaryColor: Color(0xFF7EB6FF),
  ),
];

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final List<Widget> _screens = [
    const AISummaryScreen(),
    const PlayerManageScreen(),
    const HomeScreenNew(), // 새로운 홈 화면
    const CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(mainTabIndexProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      // extendBody를 true로 해서 본문이 네비게이션 바 아래까지 확장
      extendBody: true,
      body: IndexedStack(
        index: currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildFloatingBottomNav(),
    );
  }

  /// 컨셉 디자인 하단 네비게이션 바 - 플로팅 + 중앙 원형 홈 버튼
  Widget _buildFloatingBottomNav() {
    return Container(
      // SafeArea 대신 직접 패딩 관리
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
      ),
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 메인 네비게이션 바 (플로팅 라운드)
          Container(
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.6),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                  spreadRadius: 2,
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  blurRadius: 40,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 소식 탭
                _buildNavItem(
                  index: 0,
                  icon: Icons.newspaper_outlined,
                  activeIcon: Icons.newspaper,
                  label: '소식',
                ),
                // 선수 탭
                _buildNavItem(
                  index: 1,
                  icon: Icons.person_outline,
                  activeIcon: Icons.person,
                  label: '선수',
                ),
                // 중앙 홈 버튼 공간 확보
                const SizedBox(width: 64),
                // 톡 탭
                _buildNavItem(
                  index: 3,
                  icon: Icons.chat_bubble_outline,
                  activeIcon: Icons.chat_bubble,
                  label: '톡',
                ),
                // 설정 탭
                _buildNavItem(
                  index: 4,
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings,
                  label: '설정',
                ),
              ],
            ),
          ),

          // 중앙 홈 버튼 (원형, 위로 돌출)
          Positioned(
            bottom: 20,
            child: _buildCenterHomeButton(),
          ),
        ],
      ),
    );
  }

  /// 일반 네비게이션 아이템
  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = ref.watch(mainTabIndexProvider) == index;

    return GestureDetector(
      onTap: () {
        ref.read(mainTabIndexProvider.notifier).state = index;
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 56,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 22,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 중앙 원형 홈 버튼 (컨셉 이미지: 파란색 큰 원, 위로 돌출)
  Widget _buildCenterHomeButton() {
    final isSelected = ref.watch(mainTabIndexProvider) == 2;

    return GestureDetector(
      onTap: () {
        ref.read(mainTabIndexProvider.notifier).state = 2;
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: AppColors.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.5),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 24,
              offset: const Offset(0, 2),
              spreadRadius: 4,
            ),
          ],
          border: Border.all(
            color: isSelected
                ? AppColors.primaryLight.withValues(alpha: 0.6)
                : AppColors.primary.withValues(alpha: 0.3),
            width: 2,
          ),
        ),
        child: Icon(
          isSelected ? Icons.home : Icons.home_outlined,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
