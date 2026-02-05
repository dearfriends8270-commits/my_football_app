import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/theme_provider.dart';
import 'home/home_screen.dart';
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
  int _currentIndex = 0;
  String _selectedThemeId = 'psg';

  final List<Widget> _screens = [
    const HomeScreen(),
    const ExploreScreen(),
    const AISummaryScreen(),
    const CommunityScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(appThemeProvider);
    final primaryColor = themeState.primaryColor;

    return Scaffold(
      body: Column(
        children: [
          // 상단 테마 선택 탭
          _buildThemeTabs(primaryColor),

          // 메인 콘텐츠
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: _screens,
            ),
          ),
        ],
      ),
      // 하단 네비게이션
      bottomNavigationBar: _buildBottomNav(primaryColor),
    );
  }

  Widget _buildThemeTabs(Color primaryColor) {
    return Container(
      color: primaryColor,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 앱 타이틀
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Text(
                    'K-Player Tracker',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GlobalSearchScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const NotificationScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 테마 선택 탭
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: themePresets.length,
                itemBuilder: (context, index) {
                  final preset = themePresets[index];
                  return _buildThemeTab(
                    preset: preset,
                    isSelected: _selectedThemeId == preset.id,
                    onTap: () {
                      setState(() {
                        _selectedThemeId = preset.id;
                      });
                      // 테마 변경
                      ref.read(appThemeProvider.notifier).setThemeByPreset(
                        preset.primaryColor,
                        preset.secondaryColor,
                      );
                    },
                    currentPrimaryColor: primaryColor,
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeTab({
    required ThemePreset preset,
    required bool isSelected,
    required VoidCallback onTap,
    required Color currentPrimaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.white
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: preset.primaryColor, width: 2)
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(preset.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              preset.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? preset.primaryColor : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav(Color primaryColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                index: 0,
                icon: Icons.home_outlined,
                activeIcon: Icons.home,
                label: '홈',
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                index: 1,
                icon: Icons.person_outline,
                activeIcon: Icons.person,
                label: '선수',
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                index: 2,
                icon: Icons.auto_awesome_outlined,
                activeIcon: Icons.auto_awesome,
                label: 'AI',
                primaryColor: primaryColor,
                isPremium: true,
              ),
              _buildNavItem(
                index: 3,
                icon: Icons.chat_bubble_outline,
                activeIcon: Icons.chat_bubble,
                label: 'Talk',
                primaryColor: primaryColor,
              ),
              _buildNavItem(
                index: 4,
                icon: Icons.settings_outlined,
                activeIcon: Icons.settings,
                label: '설정',
                primaryColor: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required Color primaryColor,
    bool isPremium = false,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected ? primaryColor : Colors.grey,
                  size: 24,
                ),
                if (isPremium)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'PRO',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? primaryColor : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
