import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../auth/login_screen.dart';
import 'edit_profile_screen.dart';

/// 사용자 프로필 화면
class UserProfileScreen extends ConsumerWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final themeState = ref.watch(appThemeProvider);
    final primaryColor = themeState.primaryColor;

    // 로그인되지 않은 경우
    if (!authState.isAuthenticated) {
      return _buildLoginPrompt(context, primaryColor);
    }

    final profile = authState.userProfile;
    if (profile == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '내 프로필',
          style: TextStyle(color: Colors.black87),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.black87),
            onPressed: () => _showSettingsSheet(context, ref),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 프로필 헤더
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // 프로필 이미지
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: primaryColor.withValues(alpha: 0.1),
                        backgroundImage: profile.photoUrl != null
                            ? NetworkImage(profile.photoUrl!)
                            : null,
                        child: profile.photoUrl == null
                            ? Text(
                                profile.nickname[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.bold,
                                  color: primaryColor,
                                ),
                              )
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // 닉네임
                  Text(
                    profile.nickname,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // 이메일
                  Text(
                    profile.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      profile.bio!,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 20),
                  // 프로필 편집 버튼
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const EditProfileScreen(),
                        ),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      side: BorderSide(color: primaryColor),
                    ),
                    icon: Icon(Icons.edit, size: 18, color: primaryColor),
                    label: Text(
                      '프로필 편집',
                      style: TextStyle(color: primaryColor),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 활동 통계
            Container(
              color: Colors.white,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '활동 통계',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.article_outlined,
                        label: '작성글',
                        value: '${profile.stats.postCount}',
                        color: primaryColor,
                      ),
                      _buildStatDivider(),
                      _buildStatItem(
                        icon: Icons.comment_outlined,
                        label: '댓글',
                        value: '${profile.stats.commentCount}',
                        color: Colors.blue,
                      ),
                      _buildStatDivider(),
                      _buildStatItem(
                        icon: Icons.favorite_outline,
                        label: '받은 좋아요',
                        value: '${profile.stats.likeReceived}',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 메뉴 목록
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.favorite_outline,
                    title: '내 선수 관리',
                    onTap: () {
                      // TODO: 선수 관리 화면으로 이동
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.article_outlined,
                    title: '내가 작성한 글',
                    onTap: () {
                      // TODO: 작성 글 목록으로 이동
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.bookmark_outline,
                    title: '북마크',
                    onTap: () {
                      // TODO: 북마크 목록으로 이동
                    },
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.notifications_outlined,
                    title: '알림 설정',
                    onTap: () {
                      // TODO: 알림 설정 화면으로 이동
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 기타 메뉴
            Container(
              color: Colors.white,
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.help_outline,
                    title: '고객센터',
                    onTap: () {},
                  ),
                  _buildMenuDivider(),
                  _buildMenuItem(
                    icon: Icons.info_outline,
                    title: '앱 정보',
                    subtitle: 'v1.0.0',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // 로그아웃
            Container(
              color: Colors.white,
              child: _buildMenuItem(
                icon: Icons.logout,
                title: '로그아웃',
                textColor: Colors.red,
                onTap: () => _confirmSignOut(context, ref),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, Color primaryColor) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          '프로필',
          style: TextStyle(color: Colors.black87),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 80,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 24),
              const Text(
                '로그인이 필요합니다',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '로그인하고 더 많은 기능을 이용해보세요',
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '로그인',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    String? subtitle,
    Color? textColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? Colors.grey.shade700),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.grey.shade500),
            )
          : Icon(
              Icons.chevron_right,
              color: Colors.grey.shade400,
            ),
      onTap: onTap,
    );
  }

  Widget _buildMenuDivider() {
    return Divider(
      height: 1,
      indent: 56,
      color: Colors.grey.shade200,
    );
  }

  void _showSettingsSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.lock_outline),
              title: const Text('비밀번호 변경'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 비밀번호 변경 화면
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text('계정 삭제', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteAccount(context, ref);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).signOut();
            },
            child: const Text('로그아웃', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('계정 삭제'),
        content: const Text(
          '계정을 삭제하면 모든 데이터가 영구적으로 삭제되며 복구할 수 없습니다.\n\n정말 삭제하시겠습니까?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(authProvider.notifier).deleteAccount();
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
