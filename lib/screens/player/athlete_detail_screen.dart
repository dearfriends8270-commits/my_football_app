import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/match.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/theme_provider.dart';
import '../matchday/matchday_screen.dart';
import '../talk/athlete_talk_screen.dart';
import '../../widgets/visualization/radar_chart_widget.dart';

/// 선수 상세 대시보드 (기획문서 4.2.4 선수 대시보드)
class AthleteDetailScreen extends ConsumerStatefulWidget {
  final Athlete athlete;

  const AthleteDetailScreen({super.key, required this.athlete});

  @override
  ConsumerState<AthleteDetailScreen> createState() => _AthleteDetailScreenState();
}

class _AthleteDetailScreenState extends ConsumerState<AthleteDetailScreen> {
  @override
  void initState() {
    super.initState();
    // 선수 테마 적용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appThemeProvider.notifier).setThemeByAthlete(widget.athlete);
    });
  }

  @override
  Widget build(BuildContext context) {
    final athlete = widget.athlete;
    final isFavorite = ref.watch(athleteProvider).isFavorite(athlete.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Hero Header (Sliver)
          _buildSliverAppBar(athlete, isFavorite),

          // 콘텐츠
          SliverToBoxAdapter(
            child: Column(
              children: [
                // 다음 경기 위젯
                _buildNextMatchSection(athlete),

                // 시즌 스탯 + 육각형 차트
                _buildSeasonStatsSection(athlete),

                // 플레이 스타일 태그
                _buildPlayStyleSection(athlete),

                // Talk 커뮤니티 바로가기
                _buildTalkSection(athlete),

                // Gear Shop (자연스러운 배치)
                _buildGearShopSection(athlete),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(Athlete athlete, bool isFavorite) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: athlete.teamColor,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isFavorite ? Icons.star : Icons.star_border,
            color: isFavorite ? Colors.amber : Colors.white,
          ),
          onPressed: () {
            ref.read(athleteProvider.notifier).toggleFavorite(athlete);
          },
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () => _shareAthlete(athlete),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: _buildHeroHeader(athlete),
      ),
    );
  }

  Widget _buildHeroHeader(Athlete athlete) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            athlete.teamColor,
            athlete.teamColor.withOpacity(0.8),
            athlete.sport.primaryColor,
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 아이콘
          Positioned(
            right: -40,
            bottom: -40,
            child: Icon(
              athlete.sport.iconData,
              size: 220,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // 선수 정보
          Positioned(
            left: 24,
            bottom: 40,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 종목/팀 태그
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${athlete.sport.icon} ${athlete.sport.englishName} · ${athlete.team}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // 선수 이름 (Bold)
                Text(
                  athlete.lastName,
                  style: const TextStyle(
                    fontSize: 42,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  athlete.nameKr,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),

                const SizedBox(height: 12),

                // 시즌 요약
                Text(
                  athlete.statSummary,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextMatchSection(Athlete athlete) {
    // 샘플 경기 데이터
    final nextMatch = Match(
      id: 'next_match_${athlete.id}',
      homeTeam: athlete.team.split(' ').first,
      awayTeam: 'Opponent',
      kickoffTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      competition: athlete.sport == SportType.football ? 'Ligue 1' : 'League',
      venue: 'Home Stadium',
      venueCity: 'Paris',
      status: MatchStatus.scheduled,
      broadcastChannel: 'SPOTV',
      weatherCondition: '맑음',
      temperature: 12.0,
    );

    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MatchDayScreen(match: nextMatch),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'NEXT MATCH',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  'D-3',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: athlete.teamColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildTeamInfo(nextMatch.homeTeam, isHome: true),
                const Text(
                  'VS',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                _buildTeamInfo(nextMatch.awayTeam, isHome: false),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  '2월 9일 (일) 05:00 KST',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.tv, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Text(
                  nextMatch.broadcastChannel ?? 'TBD',
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamInfo(String team, {required bool isHome}) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            shape: BoxShape.circle,
          ),
          child: const Center(
            child: Icon(Icons.sports_soccer, size: 30, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          team,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          isHome ? 'HOME' : 'AWAY',
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

  Widget _buildSeasonStatsSection(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '📊 시즌 스탯',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => _shareStats(athlete),
                icon: const Icon(Icons.share, size: 18),
                label: const Text('공유'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 주요 스탯 (종목별)
          _buildMainStats(athlete),

          const SizedBox(height: 24),

          // 육각형 차트
          Center(
            child: RadarChartWidget(
              athlete: athlete,
              size: 200,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainStats(Athlete athlete) {
    // 종목별 스탯 표시
    final stats = athlete.sport == SportType.football
        ? [
            {'label': '골', 'value': '${athlete.goals ?? 0}', 'color': Colors.red},
            {'label': '어시스트', 'value': '${athlete.assists ?? 0}', 'color': Colors.blue},
            {'label': '평점', 'value': '${athlete.rating?.toStringAsFixed(1) ?? "-"}', 'color': Colors.amber},
          ]
        : athlete.sport == SportType.baseball
            ? [
                {'label': '타율', 'value': '.${((athlete.battingAvg ?? 0) * 1000).toInt()}', 'color': Colors.green},
                {'label': '홈런', 'value': '${athlete.homeRuns ?? 0}', 'color': Colors.red},
                {'label': 'RBI', 'value': '${athlete.rbi ?? 0}', 'color': Colors.blue},
              ]
            : [
                {'label': '순위', 'value': '#${athlete.worldRanking ?? "-"}', 'color': Colors.amber},
                {'label': '승', 'value': '${athlete.seasonWins ?? 0}', 'color': Colors.green},
                {'label': '기록', 'value': athlete.personalBest ?? '-', 'color': Colors.blue},
              ];

    return Row(
      children: stats.map((stat) {
        return Expanded(
          child: Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: (stat['color'] as Color).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  stat['value'] as String,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: stat['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  stat['label'] as String,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPlayStyleSection(Athlete athlete) {
    // 종목별 기본 플레이 스타일 태그
    final tags = athlete.sport == SportType.football
        ? ['#플레이메이커', '#드리블러', '#비전', '#키패스']
        : athlete.sport == SportType.baseball
            ? ['#컨택히터', '#스피드', '#수비형']
            : athlete.sport == SportType.badminton
                ? ['#공격형', '#네트플레이', '#스매시']
                : ['#기술형', '#체력', '#멘탈'];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🎯 플레이 스타일',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: tags.map((tag) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      athlete.teamColor.withOpacity(0.8),
                      athlete.sport.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  tag,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTalkSection(Athlete athlete) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AthleteTalkScreen(
              athleteId: athlete.id,
              athleteName: athlete.nameKr,
              teamColor: athlete.teamColor,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: athlete.teamColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: athlete.teamColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: athlete.teamColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.chat_bubble, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Talk 커뮤니티',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${athlete.nameKr} 팬들과 이야기하기',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildGearShopSection(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '🛒 Gear Shop',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${athlete.nameKr} 착용 모델',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                _buildGearItem('유니폼', '₩159,000', Icons.checkroom),
                _buildGearItem('축구화', '₩289,000', Icons.sports_soccer),
                _buildGearItem('트레이닝복', '₩89,000', Icons.dry_cleaning),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGearItem(String name, String price, IconData icon) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 36, color: Colors.grey[600]),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            price,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _shareAthlete(Athlete athlete) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${athlete.nameKr} 프로필 공유하기')),
    );
  }

  void _shareStats(Athlete athlete) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${athlete.nameKr} 스탯 카드 공유하기 (준비 중)')),
    );
  }
}
