import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/admin_provider.dart';

class AdminStatsScreen extends ConsumerWidget {
  const AdminStatsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(adminStatsProvider);
    final sources = ref.watch(adminSourcesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 기간 선택
          Container(
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
            child: Row(
              children: [
                const Icon(Icons.calendar_today, size: 20, color: Color(0xFF1E4A6E)),
                const SizedBox(width: 12),
                const Text(
                  '기간:',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '최근 7일',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // 뉴스 통계
          _buildSectionTitle('뉴스 파이프라인 통계'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '크롤링된 뉴스',
                  value: '${stats['totalCrawled']}',
                  change: '+12.5%',
                  isPositive: true,
                  icon: Icons.downloading,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '승인된 뉴스',
                  value: '${stats['totalApproved']}',
                  change: '+8.3%',
                  isPositive: true,
                  icon: Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  title: '거부율',
                  value: '${stats['rejectionRate']}%',
                  change: '-2.1%',
                  isPositive: true,
                  icon: Icons.block,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  title: '평균 처리 시간',
                  value: '${stats['avgProcessingTime']}h',
                  change: '-15min',
                  isPositive: true,
                  icon: Icons.timer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 선수별 뉴스 분포
          _buildSectionTitle('선수별 뉴스 분포'),
          const SizedBox(height: 12),
          _buildPlayerNewsChart(),
          const SizedBox(height: 24),

          // 소스별 성과
          _buildSectionTitle('소스별 성과'),
          const SizedBox(height: 12),
          _buildSourcePerformanceList(sources),
          const SizedBox(height: 24),

          // 시간대별 크롤링
          _buildSectionTitle('시간대별 크롤링 현황'),
          const SizedBox(height: 12),
          _buildHourlyChart(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required IconData icon,
  }) {
    return Container(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: const Color(0xFF1E4A6E), size: 24),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isPositive
                      ? Colors.green.withValues(alpha: 0.1)
                      : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  change,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerNewsChart() {
    final players = [
      {'name': 'LEE KANG IN', 'count': 456, 'color': const Color(0xFF1E4A6E)},
      {'name': 'SON HEUNG MIN', 'count': 523, 'color': Colors.blue},
      {'name': 'KIM MIN JAE', 'count': 312, 'color': Colors.red},
      {'name': 'HWANG HEE CHAN', 'count': 198, 'color': Colors.orange},
    ];

    final maxCount = players
        .map((p) => p['count'] as int)
        .reduce((a, b) => a > b ? a : b);

    return Container(
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
        children: players.map((player) {
          final count = player['count'] as int;
          final color = player['color'] as Color;
          final percentage = count / maxCount;

          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      player['name'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$count건',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: percentage,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSourcePerformanceList(List sources) {
    final sortedSources = sources.where((s) => s.isActive).toList()
      ..sort((a, b) => b.successCount.compareTo(a.successCount));

    return Container(
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
        children: sortedSources.asMap().entries.map((entry) {
          final index = entry.key;
          final source = entry.value;
          final isLast = index == sortedSources.length - 1;
          final successRate = source.successCount + source.failCount > 0
              ? (source.successCount / (source.successCount + source.failCount) * 100)
              : 0.0;

          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: isLast
                  ? null
                  : Border(
                      bottom: BorderSide(color: Colors.grey.shade200),
                    ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E4A6E),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        source.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${source.successCount}건 수집',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${successRate.toStringAsFixed(1)}%',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildHourlyChart() {
    // 시간대별 데이터 (0-23시)
    final hourlyData = [
      12, 8, 5, 3, 2, 4, 15, 28, 45, 52, 48, 42,
      38, 44, 50, 55, 62, 58, 48, 35, 28, 22, 18, 15,
    ];

    final maxValue = hourlyData.reduce((a, b) => a > b ? a : b);

    return Container(
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
        children: [
          SizedBox(
            height: 150,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: hourlyData.asMap().entries.map((entry) {
                final hour = entry.key;
                final value = entry.value;
                final height = (value / maxValue) * 130;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          height: height,
                          decoration: BoxDecoration(
                            color: hour >= 9 && hour <= 18
                                ? const Color(0xFF1E4A6E)
                                : const Color(0xFF1E4A6E).withValues(alpha: 0.4),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('0시', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              Text('6시', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              Text('12시', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              Text('18시', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
              Text('24시', style: TextStyle(fontSize: 10, color: Colors.grey.shade600)),
            ],
          ),
        ],
      ),
    );
  }
}
