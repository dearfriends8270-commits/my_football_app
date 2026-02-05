import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/crawl_source.dart';
import '../../providers/admin_provider.dart';
import 'edit_source_screen.dart';

class AdminSourcesScreen extends ConsumerWidget {
  const AdminSourcesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSources = ref.watch(activeSourcesProvider);
    final inactiveSources = ref.watch(inactiveSourcesProvider);

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(adminSourcesProvider.notifier).refresh();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 활성 소스
            _buildSectionHeader('활성 소스', activeSources.length),
            ...activeSources.map((source) => _SourceCard(source: source)),
            const SizedBox(height: 24),
            // 비활성 소스
            if (inactiveSources.isNotEmpty) ...[
              _buildSectionHeader('비활성 소스', inactiveSources.length),
              ...inactiveSources.map((source) => _SourceCard(source: source)),
            ],
            const SizedBox(height: 80), // FAB 공간
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF1E4A6E),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SourceCard extends ConsumerStatefulWidget {
  final CrawlSource source;

  const _SourceCard({required this.source});

  @override
  ConsumerState<_SourceCard> createState() => _SourceCardState();
}

class _SourceCardState extends ConsumerState<_SourceCard> {
  bool _isCrawling = false;

  @override
  Widget build(BuildContext context) {
    final source = widget.source;
    final successRate = source.successCount + source.failCount > 0
        ? (source.successCount / (source.successCount + source.failCount) * 100)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: source.isActive ? Colors.transparent : Colors.grey.shade300,
        ),
        boxShadow: source.isActive
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                ),
              ]
            : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 타입 아이콘
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: source.isActive
                            ? const Color(0xFF1E4A6E).withValues(alpha: 0.1)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          source.type.icon,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 소스 정보
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                source.name,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: source.isActive
                                      ? Colors.black87
                                      : Colors.grey.shade500,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade200,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  source.language.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            source.type.displayName,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // 활성/비활성 스위치
                    Switch(
                      value: source.isActive,
                      onChanged: (value) async {
                        await ref.read(adminSourcesProvider.notifier).toggleActive(source.id, value);
                      },
                      activeThumbColor: Colors.white,
                      activeTrackColor: const Color(0xFF1E4A6E),
                    ),
                  ],
                ),
                if (source.isActive) ...[
                  const SizedBox(height: 16),
                  // 성공률 바
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '성공률',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                Text(
                                  '${successRate.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: successRate / 100,
                                backgroundColor: Colors.grey.shade200,
                                valueColor:
                                    const AlwaysStoppedAnimation(Colors.green),
                                minHeight: 6,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // 통계
                  Row(
                    children: [
                      _buildStatItem(
                        icon: Icons.check_circle,
                        label: '성공',
                        value: source.successCount.toString(),
                        color: Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        icon: Icons.error,
                        label: '실패',
                        value: source.failCount.toString(),
                        color: Colors.red,
                      ),
                      const Spacer(),
                      if (source.lastCrawledAt != null)
                        Text(
                          '마지막: ${_formatTime(source.lastCrawledAt!)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          // 액션 버튼
          if (source.isActive)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => EditSourceScreen(source: source),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('수정'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E4A6E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _isCrawling ? null : () => _runCrawl(source),
                      icon: _isCrawling
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation(Colors.white),
                              ),
                            )
                          : const Icon(Icons.play_arrow, size: 16),
                      label: Text(_isCrawling ? '실행 중...' : '수동 실행'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E4A6E),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else {
      return '${diff.inDays}일 전';
    }
  }

  Future<void> _runCrawl(CrawlSource source) async {
    setState(() {
      _isCrawling = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${source.name} 크롤링을 시작합니다...'),
        backgroundColor: const Color(0xFF1E4A6E),
      ),
    );

    final result = await ref.read(adminSourcesProvider.notifier).runCrawl(source.id);

    if (mounted) {
      setState(() {
        _isCrawling = false;
      });

      if (result) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${source.name} 크롤링이 완료되었습니다'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}
