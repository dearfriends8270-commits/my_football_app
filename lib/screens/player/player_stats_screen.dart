import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/player.dart';
import '../../widgets/visualization/art_heatmap_widget.dart';
import '../../widgets/visualization/pass_master_map_widget.dart';

/// 선수 통계 화면 - 아트 히트맵과 패스 마스터 맵 포함
class PlayerStatsScreen extends ConsumerStatefulWidget {
  final Player player;

  const PlayerStatsScreen({super.key, required this.player});

  @override
  ConsumerState<PlayerStatsScreen> createState() => _PlayerStatsScreenState();
}

class _PlayerStatsScreenState extends ConsumerState<PlayerStatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  HeatmapStyle _heatmapStyle = HeatmapStyle.watercolor;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E4A6E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.player.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E4A6E),
                      Color(0xFF2E6A8E),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // 배경 패턴
                    Positioned(
                      right: -50,
                      top: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.05),
                        ),
                      ),
                    ),
                    // 선수 정보
                    Positioned(
                      left: 20,
                      bottom: 60,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              widget.player.position,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              widget.player.team,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: '히트맵'),
                Tab(text: '패스맵'),
                Tab(text: '시즌통계'),
              ],
            ),
          ),

          // 탭 콘텐츠
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildHeatmapTab(),
                _buildPassMapTab(),
                _buildSeasonStatsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeatmapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 스타일 선택
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _heatmapStyle = HeatmapStyle.watercolor),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _heatmapStyle == HeatmapStyle.watercolor
                          ? const Color(0xFF1E4A6E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1E4A6E),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.water_drop,
                          size: 18,
                          color: _heatmapStyle == HeatmapStyle.watercolor
                              ? Colors.white
                              : const Color(0xFF1E4A6E),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '워터컬러',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _heatmapStyle == HeatmapStyle.watercolor
                                ? Colors.white
                                : const Color(0xFF1E4A6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _heatmapStyle = HeatmapStyle.neon),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _heatmapStyle == HeatmapStyle.neon
                          ? const Color(0xFF1E4A6E)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1E4A6E),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.flash_on,
                          size: 18,
                          color: _heatmapStyle == HeatmapStyle.neon
                              ? Colors.white
                              : const Color(0xFF1E4A6E),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '네온',
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: _heatmapStyle == HeatmapStyle.neon
                                ? Colors.white
                                : const Color(0xFF1E4A6E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 히트맵 위젯
          ArtHeatmapWidget(
            playerId: widget.player.id,
            playerName: widget.player.name,
            heatmapData: generateSampleHeatmapData(widget.player.id),
            style: _heatmapStyle,
          ),

          const SizedBox(height: 20),

          // 경기별 히트맵 선택
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '최근 경기 선택',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 80,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _buildMatchChip('vs Monaco', '2024.01.28', true),
                      _buildMatchChip('vs Lyon', '2024.01.21', false),
                      _buildMatchChip('vs Marseille', '2024.01.14', false),
                      _buildMatchChip('vs Lens', '2024.01.07', false),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchChip(String opponent, String date, bool isSelected) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1E4A6E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: isSelected
            ? null
            : Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            opponent,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 10,
              color: isSelected ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassMapTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 패스 마스터 맵
          PassMasterMapWidget(
            mainPlayerId: widget.player.id,
            mainPlayerName: widget.player.name,
            connections: generateSamplePassConnections(widget.player.id),
            highlightInsight: '오늘은 Mbappé와 호흡이 좋았네요! 28회 패스 교환',
          ),

          const SizedBox(height: 20),

          // 패스 통계 요약
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '패스 분석',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildPassStatCard(
                        '패스 성공률',
                        '87.3%',
                        Icons.check_circle,
                        Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPassStatCard(
                        '키패스',
                        '4회',
                        Icons.stars,
                        Colors.orange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPassStatCard(
                        '롱패스',
                        '12회',
                        Icons.trending_up,
                        Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildPassStatCard(
                        '크로스',
                        '7회',
                        Icons.swap_horiz,
                        Colors.purple,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonStatsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 시즌 요약
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E4A6E), Color(0xFF2E6A8E)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Text(
                  '2023-24 시즌',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSeasonStatItem('출전', '28', '경기'),
                    _buildSeasonStatItem('골', '8', '골'),
                    _buildSeasonStatItem('도움', '12', '도움'),
                    _buildSeasonStatItem('평점', '7.4', '평균'),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 상세 통계
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '상세 통계',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatRow('슈팅', 62, 100),
                _buildStatRow('유효 슈팅', 28, 62),
                _buildStatRow('드리블 성공', 45, 60),
                _buildStatRow('듀얼 승리', 89, 150),
                _buildStatRow('파울 유도', 34, 50),
                _buildStatRow('찬스 생성', 42, 50),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // 대회별 기록
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '대회별 기록',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildCompetitionRow('Ligue 1', 22, 5, 8),
                const Divider(),
                _buildCompetitionRow('Champions League', 6, 3, 4),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeasonStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, int value, int max) {
    final progress = value / max;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              Text(
                '$value',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E4A6E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade200,
              valueColor: const AlwaysStoppedAnimation(Color(0xFF1E4A6E)),
              minHeight: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompetitionRow(
    String competition,
    int games,
    int goals,
    int assists,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              competition,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$games',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E4A6E),
                  ),
                ),
                Text(
                  '경기',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$goals',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  '골',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Text(
                  '$assists',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
                Text(
                  '도움',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
