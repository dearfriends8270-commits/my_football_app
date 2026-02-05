import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../main.dart';
import '../../providers/storage_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/auth_provider.dart';
import '../../services/share_service.dart';
import '../player/player_manage_screen.dart';
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
    final favoritePlayerIds = ref.watch(favoritePlayerIdsProvider);
    // Firebase 미초기화 시 게스트 모드로 처리
    final isLoggedIn = isFirebaseInitialized
        ? ref.watch(authProvider).isAuthenticated
        : false;

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4A6E),
        title: const Text(
          '설정',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // 사용자 프로필
            _buildUserProfile(),

            const SizedBox(height: 24),

            // 앱 설정
            _buildSectionTitle('앱 설정'),
            _buildSettingsGroup([
              _SettingItem(
                icon: Icons.widgets,
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
                icon: Icons.notifications,
                title: '알림 설정',
                subtitle: notificationSettings.enabled ? '알림 켜짐' : '알림 꺼짐',
                onTap: () => _showNotificationSettingsDialog(context),
              ),
              _SettingItem(
                icon: Icons.language,
                title: '언어',
                subtitle: '한국어',
                onTap: () => _showLanguageDialog(context),
              ),
              _SettingItem(
                icon: Icons.dark_mode,
                title: '다크 모드',
                subtitle: darkMode ? '켜짐' : '꺼짐',
                trailing: Switch(
                  value: darkMode,
                  onChanged: (value) {
                    ref.read(darkModeProvider.notifier).setDarkMode(value);
                  },
                  activeColor: const Color(0xFF1E4A6E),
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
                icon: Icons.person,
                title: '관심 선수 관리',
                subtitle: '내 선수 추가/삭제/순서 변경',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const PlayerManageScreen(),
                    ),
                  );
                },
              ),
              _SettingItem(
                icon: Icons.sports_soccer,
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
                icon: Icons.cloud_download,
                title: '오프라인 데이터',
                subtitle: '12.5 MB 사용 중',
                onTap: () => _showOfflineDataDialog(context),
              ),
              _SettingItem(
                icon: Icons.delete_outline,
                title: '캐시 삭제',
                subtitle: '임시 데이터 정리',
                onTap: () {
                  _showClearCacheDialog(context);
                },
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
                icon: Icons.description,
                title: '이용약관',
                onTap: () => _openUrl('https://example.com/terms'),
              ),
              _SettingItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                onTap: () => _openUrl('https://example.com/privacy'),
              ),
              _SettingItem(
                icon: Icons.share,
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

            // 로그아웃 (로그인된 경우에만 표시)
            if (isLoggedIn)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      _showLogoutDialog(context);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('로그아웃'),
                  ),
                ),
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    // Firebase 미초기화 시 게스트 모드로 처리
    final isLoggedIn = isFirebaseInitialized
        ? ref.watch(authProvider).isAuthenticated
        : false;
    final userProfile = isFirebaseInitialized
        ? ref.watch(authProvider).userProfile
        : null;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: isLoggedIn
          ? Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                  backgroundImage: userProfile?.photoUrl != null
                      ? NetworkImage(userProfile!.photoUrl!)
                      : null,
                  child: userProfile?.photoUrl == null
                      ? const Text(
                          '👤',
                          style: TextStyle(fontSize: 28),
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userProfile?.nickname ?? '사용자',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userProfile?.email ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.amber.shade700),
                            const SizedBox(width: 4),
                            Text(
                              'Lv.5 열정팬',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.amber.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => _showEditProfileDialog(context),
                  color: Colors.grey,
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
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.grey.shade200,
              child: Icon(
                Icons.person_outline,
                size: 32,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '게스트 모드',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '로그인하여 더 많은 기능을 이용하세요',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
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
                  backgroundColor: const Color(0xFF1E4A6E),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('로그인'),
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
                  foregroundColor: const Color(0xFF1E4A6E),
                  side: const BorderSide(color: Color(0xFF1E4A6E)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('회원가입'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.grey.shade600,
        ),
      ),
    );
  }

  Widget _buildSettingsGroup(List<_SettingItem> items) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == items.length - 1;

          return Column(
            children: [
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    item.icon,
                    color: const Color(0xFF1E4A6E),
                    size: 20,
                  ),
                ),
                title: Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: item.subtitle != null
                    ? Text(
                        item.subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      )
                    : null,
                trailing: item.trailing ??
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey.shade400,
                    ),
                onTap: item.onTap,
              ),
              if (!isLast) const Divider(height: 1, indent: 72),
            ],
          );
        }).toList(),
      ),
    );
  }

  void _showNotificationSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final settings = ref.watch(notificationSettingsProvider);
            return AlertDialog(
              title: const Text('알림 설정'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SwitchListTile(
                    title: const Text('전체 알림'),
                    subtitle: const Text('모든 알림 허용'),
                    value: settings.enabled,
                    onChanged: (value) {
                      ref.read(notificationSettingsProvider.notifier).setEnabled(value);
                    },
                  ),
                  const Divider(),
                  SwitchListTile(
                    title: const Text('경기 알림'),
                    subtitle: const Text('매치데이 시작 알림'),
                    value: settings.matchdayAlerts,
                    onChanged: settings.enabled
                        ? (value) {
                            ref.read(notificationSettingsProvider.notifier).setMatchdayAlerts(value);
                          }
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('골 알림'),
                    subtitle: const Text('관심 선수 골/어시스트 알림'),
                    value: settings.goalAlerts,
                    onChanged: settings.enabled
                        ? (value) {
                            ref.read(notificationSettingsProvider.notifier).setGoalAlerts(value);
                          }
                        : null,
                  ),
                  SwitchListTile(
                    title: const Text('뉴스 알림'),
                    subtitle: const Text('새 뉴스 알림'),
                    value: settings.newsAlerts,
                    onChanged: settings.enabled
                        ? (value) {
                            ref.read(notificationSettingsProvider.notifier).setNewsAlerts(value);
                          }
                        : null,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('언어 선택'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('한국어'),
                trailing: const Icon(Icons.check, color: Color(0xFF1E4A6E)),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                title: const Text('English'),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('영어 지원 예정입니다')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showFavoritePlayersDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Consumer(
          builder: (context, ref, child) {
            final playersAsync = ref.watch(allPlayersProvider);
            final favorites = ref.watch(favoritePlayerIdsProvider);

            return AlertDialog(
              title: const Text('관심 선수 관리'),
              content: SizedBox(
                width: double.maxFinite,
                height: 400,
                child: playersAsync.when(
                  data: (players) => ListView.builder(
                    itemCount: players.length,
                    itemBuilder: (context, index) {
                      final player = players[index];
                      final isFavorite = favorites.contains(player.id);
                      return CheckboxListTile(
                        title: Text(player.name),
                        subtitle: Text(player.team),
                        value: isFavorite,
                        onChanged: (value) {
                          ref.read(favoritePlayerIdsProvider.notifier).toggleFavorite(player.id);
                        },
                      );
                    },
                  ),
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, s) => Center(child: Text('오류: $e')),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showOfflineDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('오프라인 데이터'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('저장된 데이터:'),
              SizedBox(height: 12),
              _DataItem(label: '선수 정보', size: '2.1 MB'),
              _DataItem(label: '경기 일정', size: '1.5 MB'),
              _DataItem(label: '뉴스 기사', size: '5.8 MB'),
              _DataItem(label: '이미지 캐시', size: '3.1 MB'),
              Divider(),
              _DataItem(label: '총 사용량', size: '12.5 MB', isBold: true),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('캐시 삭제'),
          content: const Text('임시 데이터를 모두 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('캐시가 삭제되었습니다'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('삭제', style: TextStyle(color: Colors.red)),
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
        return AlertDialog(
          title: const Text('K-Player Tracker'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('버전: 1.0.0'),
              SizedBox(height: 8),
              Text('빌드: 2024.01.15'),
              SizedBox(height: 16),
              Text(
                '해외파 축구선수 추적 앱\n좋아하는 선수의 모든 소식을 한눈에!',
                style: TextStyle(color: Colors.grey),
              ),
              SizedBox(height: 16),
              Text('© 2024 K-Player Tracker'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('확인'),
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
        return AlertDialog(
          title: const Text('피드백 보내기'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('앱 사용 중 불편한 점이나 개선 사항을 알려주세요.'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: '피드백 내용을 입력하세요...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('피드백을 보내주셔서 감사합니다!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              child: const Text('보내기'),
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
        return AlertDialog(
          title: const Text('프로필 수정'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  labelText: '닉네임',
                  hintText: '강인이팬',
                ),
              ),
              SizedBox(height: 16),
              Text(
                '프로필 사진 변경은 추후 지원 예정입니다.',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('프로필이 저장되었습니다')),
                );
              },
              child: const Text('저장'),
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
        return AlertDialog(
          title: const Text('선수 다시 선택'),
          content: const Text('현재 선택된 선수를 초기화하고\n처음부터 다시 선택하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                // 선택된 선수 초기화
                ref.read(athleteProvider.notifier).setFavoriteAthletes([]);
                // 온보딩 화면으로 이동
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                    builder: (context) => const PickYourStarScreen(),
                  ),
                  (route) => false,
                );
              },
              child: const Text(
                '다시 선택',
                style: TextStyle(color: Colors.orange),
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
        return AlertDialog(
          title: const Text('로그아웃'),
          content: const Text('정말 로그아웃 하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Firebase 초기화된 경우에만 로그아웃 처리
                if (isFirebaseInitialized) {
                  await ref.read(authProvider.notifier).signOut();
                }
                // 선택된 선수 초기화
                ref.read(athleteProvider.notifier).setFavoriteAthletes([]);
                // 환영 화면으로 이동
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
                style: TextStyle(color: Colors.red),
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

class _DataItem extends StatelessWidget {
  final String label;
  final String size;
  final bool isBold;

  const _DataItem({
    required this.label,
    required this.size,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            size,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: isBold ? const Color(0xFF1E4A6E) : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
