import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';
import 'home/home_screen_new.dart';
import 'explore/explore_screen.dart';
import 'ai/ai_summary_screen.dart';
import 'talk/community_screen.dart';
import 'settings/settings_screen.dart';
import 'search/global_search_screen.dart';
import 'notification/notification_screen.dart';

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
  int _currentIndex = 2; // 홈을 중앙(인덱스 2)에 배치
  String _selectedThemeId = 'psg';

  final List<Widget> _screens = [
    const AISummaryScreen(),
    const ExploreScreen(),
    const HomeScreenNew(), // 새로운 홈 화면
    const CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _buildDarkBottomNav(),
    );
  }

  /// 다크 테마 하단 네비게이션 바
  Widget _buildDarkBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        border: Border(
          top: BorderSide(color: AppColors.border, width: 1),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDarkNavItem(
                index: 0,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'AI',
              ),
              _buildDarkNavItem(
                index: 1,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '선수',
              ),
              _buildHomeNavItem(), // 중앙 홈 버튼
              _buildDarkNavItem(
                index: 3,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: '톡',
              ),
              _buildDarkNavItem(
                index: 4,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: '설정',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDarkNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isSelected = _currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? AppColors.primary : AppColors.textMuted,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.primary : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 중앙 홈 버튼 (강조)
  Widget _buildHomeNavItem() {
    final isSelected = _currentIndex == 2;

    return GestureDetector(
      onTap: () {
        setState(() {
          _currentIndex = 2;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          gradient: isSelected
              ? AppColors.primaryGradient
              : null,
          color: isSelected ? null : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 0 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? Icons.home : Icons.home_outlined,
              color: isSelected ? Colors.white : AppColors.textMuted,
              size: 26,
            ),
            const SizedBox(height: 4),
            Text(
              '홈',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
