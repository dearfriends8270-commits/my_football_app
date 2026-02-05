import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';
import '../settings/settings_screen.dart';
import 'admin_news_screen.dart';
import 'admin_sources_screen.dart';
import 'admin_stats_screen.dart';
import 'add_source_screen.dart';

class AdminDashboardScreen extends ConsumerStatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  ConsumerState<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends ConsumerState<AdminDashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    AdminNewsScreen(),
    AdminSourcesScreen(),
    AdminStatsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(adminStatsProvider);
    final pendingCount = stats['pendingCount'] as int;
    final approvedCount = stats['approvedTodayCount'] as int;
    final activeSourceCount = stats['activeSourceCount'] as int;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4A6E),
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined, color: Colors.white),
                if (pendingCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 14,
                        minHeight: 14,
                      ),
                      child: Text(
                        pendingCount > 9 ? '9+' : '$pendingCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              _showNotificationsDialog();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 요약 카드
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _buildSummaryCard(
                  title: '대기 중',
                  count: pendingCount,
                  icon: Icons.pending_actions,
                  color: Colors.orange,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  title: '오늘 승인',
                  count: approvedCount,
                  icon: Icons.check_circle,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _buildSummaryCard(
                  title: '활성 소스',
                  count: activeSourceCount,
                  icon: Icons.rss_feed,
                  color: Colors.blue,
                ),
              ],
            ),
          ),
          // 탭 네비게이션
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                _buildTabButton(
                  index: 0,
                  label: '뉴스 관리',
                  icon: Icons.article,
                ),
                _buildTabButton(
                  index: 1,
                  label: '소스 관리',
                  icon: Icons.source,
                ),
                _buildTabButton(
                  index: 2,
                  label: '통계',
                  icon: Icons.analytics,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 메인 컨텐츠
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF1E4A6E),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const AddSourceScreen(),
                  ),
                );
              },
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 8),
            Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF1E4A6E).withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected
                    ? const Color(0xFF1E4A6E)
                    : Colors.grey.shade400,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF1E4A6E)
                      : Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotificationsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Consumer(
          builder: (context, ref, child) {
            final stats = ref.watch(adminStatsProvider);
            final pendingCount = stats['pendingCount'] as int;

            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (pendingCount > 0) ...[
                  ListTile(
                    leading: const Icon(Icons.pending_actions, color: Colors.orange),
                    title: Text('$pendingCount개의 뉴스가 승인 대기 중입니다'),
                    subtitle: const Text('뉴스 관리 탭에서 확인하세요'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ] else ...[
                  const ListTile(
                    leading: Icon(Icons.check_circle, color: Colors.green),
                    title: Text('모든 뉴스가 처리되었습니다'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}
