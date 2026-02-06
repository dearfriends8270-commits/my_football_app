import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../providers/storage_provider.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/share_service.dart';
import '../../utils/app_colors.dart';
import '../onboarding/pick_your_star_screen.dart';
import '../auth/login_screen.dart';
import '../auth/signup_screen.dart';
import '../auth/welcome_screen.dart';
import 'widget_settings_screen.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final darkMode = ref.watch(darkModeProvider);
    final notificationSettings = ref.watch(notificationSettingsProvider);
    final isLoggedIn = isFirebaseInitialized
        ? ref.watch(authProvider).isAuthenticated
        : false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 상단 헤더: 타이틀
              _buildTopHeader(),

              const SizedBox(height: 20),

              // 사용자 프로필
              _buildUserProfile(isLoggedIn),

              const SizedBox(height: 24),

              // 앱 설정
              _buildSectionTitle('앱 설정'),
              _buildSettingsGroup([
                _SettingItem(
                  icon: Icons.widgets_outlined,
                  title: '홈 화면 위젯',
                  subtitle: '위젯 크기 및 표시 설정',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const WidgetSettingsScreen(),
                      ),
                    );
                  },
                ),
                _SettingItem(
                  icon: Icons.notifications_outlined,
                  title: '알림 설정',
                  subtitle: notificationSettings.enabled ? '알림 켜짐' : '알림 꺼짐',
                  onTap: () => _showNotificationSettingsDialog(context),
                ),
                _SettingItem(
                  icon: Icons.language_outlined,
                  title: '언어',
                  subtitle: '한국어',
                  onTap: () => _showLanguageDialog(context),
                ),
                _SettingItem(
                  icon: Icons.dark_mode_outlined,
                  title: '다크 모드',
                  subtitle: darkMode ? '켜짐' : '꺼짐',
                  trailing: Switch(
                    value: darkMode,
                    onChanged: (value) {
                      ref.read(darkModeProvider.notifier).setDarkMode(value);
                    },
                    activeThumbColor: AppColors.primary,
                    activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
                    inactiveThumbColor: AppColors.textMuted,
                    inactiveTrackColor: AppColors.backgroundCardLight,
                  ),
                  onTap: () {
                    ref.read(darkModeProvider.notifier).toggle();
                  },
                ),
              ]),

              const SizedBox(height: 24),

              // 선수 설정
              _buildSectionTitle('선수 설정'),
              _buildSettingsGroup([
                _SettingItem(
                  icon: Icons.person_outline,
                  title: '관심 선수 관리',
                  subtitle: '내 선수 추가/삭제/순서 변경',
                  onTap: () {
                    ref.read(mainTabIndexProvider.notifier).state = 1;
                  },
                ),
                _SettingItem(
                  icon: Icons.sports_soccer_outlined,
                  title: '선수 다시 선택하기',
                  subtitle: '온보딩으로 돌아가기',
                  onTap: () => _showResetPlayersDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // 데이터 및 저장공간
              _buildSectionTitle('데이터 및 저장공간'),
              _buildSettingsGroup([
                _SettingItem(
                  icon: Icons.cloud_download_outlined,
                  title: '오프라인 데이터',
                  subtitle: '12.5 MB 사용 중',
                  onTap: () => _showOfflineDataDialog(context),
                ),
                _SettingItem(
                  icon: Icons.delete_outline,
                  title: '캐시 삭제',
                  subtitle: '임시 데이터 정리',
                  onTap: () => _showClearCacheDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // 정보
              _buildSectionTitle('정보'),
              _buildSettingsGroup([
                _SettingItem(
                  icon: Icons.info_outline,
                  title: '앱 정보',
                  subtitle: 'v1.0.0',
                  onTap: () => _showAppInfoDialog(context),
                ),
                _SettingItem(
                  icon: Icons.description_outlined,
                  title: '이용약관',
                  onTap: () => _openUrl('https://example.com/terms'),
                ),
                _SettingItem(
                  icon: Icons.privacy_tip_outlined,
                  title: '개인정보 처리방침',
                  onTap: () => _openUrl('https://example.com/privacy'),
                ),
                _SettingItem(
                  icon: Icons.share_outlined,
                  title: '앱 공유하기',
                  onTap: () => ShareService().shareApp(),
                ),
                _SettingItem(
                  icon: Icons.feedback_outlined,
                  title: '피드백 보내기',
                  onTap: () => _showFeedbackDialog(context),
                ),
              ]),

              const SizedBox(height: 24),

              // 로그아웃
              if (isLoggedIn)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => _showLogoutDialog(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.live,
                        side: BorderSide(
                          color: AppColors.live.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        '로그아웃',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // 상단 헤더
  // ─────────────────────────────────────────

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ),
          const Spacer(),
          const Text(
            '설정',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          // 우측 빈 공간 밸런스
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 사용자 프로필
  // ─────────────────────────────────────────

  Widget _buildUserProfile(bool isLoggedIn) {
    final userProfile = isFirebaseInitialized
        ? ref.watch(authProvider).userProfile
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: isLoggedIn
          ? Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.4),
                        AppColors.primary.withValues(alpha: 0.2),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: userProfile?.photoUrl != null
                      ? ClipOval(
                          child: Image.network(
                            userProfile!.photoUrl!,
                            fit: BoxFit.cover,
                          ),
                        )
                      : const Center(
                          child: Text('👤', style: TextStyle(fontSize: 26)),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.nickname ?? '사용자',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        userProfile?.email ?? '',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star,
                                size: 13, color: AppColors.accent),
                            const SizedBox(width: 4),
                            Text(
                              'Lv.5 열정팬',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.accent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => _showEditProfileDialog(context),
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.border.withValues(alpha: 0.5),
                      ),
                    ),
                    child: const Icon(
                      Icons.edit_outlined,
                      color: AppColors.textMuted,
                      size: 16,
                    ),
                  ),
                ),
              ],
            )
          : _buildGuestProfile(),
    );
  }

  Widget _buildGuestProfile() {
    return Column(
      children: [
        Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.backgroundCardLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_outline,
                size: 28,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '게스트 모드',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 3),
                  const Text(
                    '로그인하여 더 많은 기능을 이용하세요',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  '로그인',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SignUpScreen(),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  '회원가입',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // 섹션 / 그룹
  // ─────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Row(
        children: [
          Container(
            width: 3,
            height: 16,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                leading: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      )
                    : null,
                trailing: item.trailing ??
                    const Icon(
                      Icons.chevron_right,
                      color: AppColors.textMuted,
                      size: 20,
                    ),
                onTap: item.onTap,
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 66),
                  child: Container(
                    height: 1,
                    color: AppColors.border.withValues(alpha: 0.3),
                  ),
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // 다이얼로그들 (다크 테마 적용)
  // ─────────────────────────────────────────

  AlertDialog _darkDialog({
    required String title,
    required Widget content,
    required List<Widget> actions,
  }) {
    return AlertDialog(
      backgroundColor: AppColors.backgroundCard,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
          fontSize: 17,
        ),
      ),
      content: content,
      actions: actions,
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(notificationSettingsProvider);
            return _darkDialog(
              title: '알림 설정',
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDarkSwitchTile(
                    title: '전체 알림',
                    subtitle: '모든 알림 허용',
                    value: settings.enabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setEnabled(value);
                    },
                  ),
                  Container(
                      height: 1,
                      color: AppColors.border.withValues(alpha: 0.3)),
                  _buildDarkSwitchTile(
                    title: '경기 알림',
                    subtitle: '매치데이 시작 알림',
                    value: settings.matchdayAlerts,
                    enabled: settings.enabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setMatchdayAlerts(value);
                    },
                  ),
                  _buildDarkSwitchTile(
                    title: '골 알림',
                    subtitle: '관심 선수 골/어시스트 알림',
                    value: settings.goalAlerts,
                    enabled: settings.enabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setGoalAlerts(value);
                    },
                  ),
                  _buildDarkSwitchTile(
                    title: '뉴스 알림',
                    subtitle: '새 뉴스 알림',
                    value: settings.newsAlerts,
                    enabled: settings.enabled,
                    onChanged: (value) {
                      ref
                          .read(notificationSettingsProvider.notifier)
                          .setNewsAlerts(value);
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    '확인',
                    style: TextStyle(color: AppColors.primary),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildDarkSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    bool enabled = true,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: enabled
                        ? AppColors.textPrimary
                        : AppColors.textMuted,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textMuted,
            inactiveTrackColor: AppColors.backgroundCardLight,
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '언어 선택',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDarkListTile(
                title: '한국어',
                trailing: const Icon(Icons.check, color: AppColors.primary, size: 20),
                onTap: () => Navigator.pop(context),
              ),
              Container(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.3)),
              _buildDarkListTile(
                title: 'English',
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('영어 지원 예정입니다'),
                      backgroundColor: AppColors.backgroundCard,
                    ),
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDarkListTile({
    required String title,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  void _showOfflineDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '오프라인 데이터',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '저장된 데이터:',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 12),
              _buildDarkDataItem('선수 정보', '2.1 MB'),
              _buildDarkDataItem('경기 일정', '1.5 MB'),
              _buildDarkDataItem('뉴스 기사', '5.8 MB'),
              _buildDarkDataItem('이미지 캐시', '3.1 MB'),
              Container(
                  height: 1,
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  color: AppColors.border.withValues(alpha: 0.3)),
              _buildDarkDataItem('총 사용량', '12.5 MB', isBold: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDarkDataItem(String label, String size, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.textPrimary : AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          Text(
            size,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? AppColors.primary : AppColors.textMuted,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '캐시 삭제',
          content: const Text(
            '임시 데이터를 모두 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('캐시가 삭제되었습니다'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('삭제',
                  style: TextStyle(color: AppColors.live)),
            ),
          ],
        );
      },
    );
  }

  void _showAppInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: 'K-SPORTS STAR',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('버전: 1.0.0',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 6),
              const Text('빌드: 2025.02.06',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 13)),
              const SizedBox(height: 14),
              const Text(
                '해외파 스포츠 스타 추적 앱\n좋아하는 선수의 모든 소식을 한눈에!',
                style: TextStyle(color: AppColors.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 14),
              const Text(
                '© 2025 K-SPORTS STAR',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showFeedbackDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '피드백 보내기',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '앱 사용 중 불편한 점이나 개선 사항을 알려주세요.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: controller,
                maxLines: 4,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '피드백 내용을 입력하세요...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('피드백을 보내주셔서 감사합니다!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('보내기',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showEditProfileDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '프로필 수정',
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  labelText: '닉네임',
                  labelStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  hintText: '강인이팬',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                  ),
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.5),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                '프로필 사진 변경은 추후 지원 예정입니다.',
                style: TextStyle(color: AppColors.textMuted, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('프로필이 저장되었습니다'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('저장',
                  style: TextStyle(color: AppColors.primary)),
            ),
          ],
        );
      },
    );
  }

  void _showResetPlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '선수 다시 선택',
          content: const Text(
            '현재 선택된 선수를 초기화하고\n처음부터 다시 선택하시겠습니까?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ref.read(athleteProvider.notifier).setFavoriteAthletes([]);
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const PickYourStarScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                '다시 선택',
                style: TextStyle(
                  color: AppColors.warning,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return _darkDialog(
          title: '로그아웃',
          content: const Text(
            '정말 로그아웃 하시겠습니까?',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소',
                  style: TextStyle(color: AppColors.textMuted)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                if (isFirebaseInitialized) {
                  await ref.read(authProvider.notifier).signOut();
                }
                ref.read(athleteProvider.notifier).setFavoriteAthletes([]);
                if (mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                      builder: (context) => const WelcomeScreen(),
                    ),
                    (route) => false,
                  );
                }
              },
              child: const Text(
                '로그아웃',
                style: TextStyle(
                  color: AppColors.live,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('링크를 열 수 없습니다')),
        );
      }
    }
  }
}

class _SettingItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  _SettingItem({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    required this.onTap,
  });
}
