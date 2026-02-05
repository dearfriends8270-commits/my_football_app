import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/match.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/theme_provider.dart';
import '../../providers/match_provider.dart';
import '../player/player_manage_screen.dart';
import '../onboarding/pick_your_star_screen.dart';
import '../matchday/matchday_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);
    final selectedAthlete = ref.watch(selectedAthleteProvider);
    final themeState = ref.watch(appThemeProvider);

    if (favoriteAthletes.isEmpty) {
      return _buildEmptyState(context, ref);
    }

    final currentAthlete = selectedAthlete ?? favoriteAthletes.first;

    return RefreshIndicator(
      onRefresh: () async {
        await _refreshData(ref);
      },
      child: CustomScrollView(
        slivers: [
          // 즐겨찾기 선수 슬라이더
          SliverToBoxAdapter(
            child: _buildFavoriteSlider(
              context,
              ref,
              favoriteAthletes,
              currentAthlete,
            ),
          ),

          // 📅 다가오는 경기 배너
          SliverToBoxAdapter(
            child: _buildUpcomingMatchBanner(context, currentAthlete),
          ),

          // 오늘의 경기일정 (캐러셀)
          SliverToBoxAdapter(
            child: _buildTodayMatchSchedule(context, favoriteAthletes),
          ),

          // 리그 순위 카드
          SliverToBoxAdapter(
            child: _buildLeagueStandings(context, currentAthlete),
          ),

          // 선수 대시보드
          SliverToBoxAdapter(
            child: _buildAthleteDashboard(context, ref, currentAthlete),
          ),

          // 최근 활약 (선수별 필터링)
          SliverToBoxAdapter(
            child: _buildRecentPerformance(context, currentAthlete),
          ),

          // 최신 뉴스 (선수별 필터링)
          SliverToBoxAdapter(
            child: _buildLatestNews(context, currentAthlete),
          ),

          // 하단 여백
          const SliverToBoxAdapter(
            child: SizedBox(height: 100),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData(WidgetRef ref) async {
    ref.invalidate(upcomingMatchesProvider);
    await Future.delayed(const Duration(milliseconds: 500));
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_search,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            '팔로우할 선수를 선택해주세요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const PickYourStarScreen(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('선수 추가하기'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteSlider(
    BuildContext context,
    WidgetRef ref,
    List<Athlete> athletes,
    Athlete currentAthlete,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Text(
                  '내 선수',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const PlayerManageScreen(),
                      ),
                    );
                  },
                  child: const Text('편집'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: athletes.length + 1,
              itemBuilder: (context, index) {
                if (index == athletes.length) {
                  return _buildAddAthleteButton(context);
                }
                final athlete = athletes[index];
                final isSelected = athlete.id == currentAthlete.id;
                return _buildAthleteAvatar(context, ref, athlete, isSelected);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAthleteAvatar(
    BuildContext context,
    WidgetRef ref,
    Athlete athlete,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () {
        ref.read(athleteProvider.notifier).selectAthlete(athlete);
        ref.read(appThemeProvider.notifier).setThemeByAthlete(athlete);
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? athlete.teamColor : Colors.grey[300]!,
                  width: isSelected ? 3 : 2,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: athlete.teamColor.withOpacity(0.4),
                          blurRadius: 12,
                          spreadRadius: 2,
                        ),
                      ]
                    : [],
              ),
              child: CircleAvatar(
                backgroundColor: athlete.teamColor.withOpacity(0.2),
                child: Text(
                  athlete.sport.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              athlete.nameKr,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? athlete.teamColor : Colors.grey[700],
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddAthleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => const PlayerManageScreen(),
          ),
        );
      },
      child: Container(
        width: 70,
        margin: const EdgeInsets.symmetric(horizontal: 6),
        child: Column(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.grey[300]!,
                  width: 2,
                  style: BorderStyle.solid,
                ),
              ),
              child: Icon(
                Icons.add,
                color: Colors.grey[400],
                size: 28,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '추가',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📅 다가오는 경기 배너 (진행중인 경기 포함)
  Widget _buildUpcomingMatchBanner(BuildContext context, Athlete athlete) {
    // 샘플: 가장 가까운 경기 정보
    final isLive = false; // 진행 중 여부
    final daysUntil = 2;

    return GestureDetector(
      onTap: () => _showMatchDetail(context, athlete, isLive),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isLive
                ? [Colors.red.shade600, Colors.red.shade800]
                : [athlete.teamColor, athlete.teamColor.withOpacity(0.8)],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isLive ? Colors.red : athlete.teamColor).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      if (isLive) ...[
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text(
                          '경기 진행중',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ] else ...[
                        Icon(Icons.calendar_today, size: 12, color: athlete.teamColor),
                        const SizedBox(width: 6),
                        Text(
                          'D-$daysUntil',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: athlete.teamColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Ligue 1',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('🔵', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'PSG',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Text(
                      isLive ? 'VS' : '05:00',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isLive ? '전반 진행중' : '2월 6일 (목)',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text('⚪', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Marseille',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    athlete.sport.icon,
                    style: const TextStyle(fontSize: 14),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${athlete.nameKr} 출전 예정',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.95),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 경기 상세 정보 바텀시트
  void _showMatchDetail(BuildContext context, Athlete athlete, bool isLive) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 경기 정보 헤더
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [athlete.teamColor, athlete.teamColor.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isLive ? '🔴 경기 진행중' : '📅 예정된 경기',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isLive ? Colors.red : athlete.teamColor,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Ligue 1',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildTeamColumn('PSG', '🔵'),
                        Column(
                          children: [
                            Text(
                              isLive ? '1 - 0' : 'VS',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              isLive ? "45' 전반" : '05:00 KST',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        _buildTeamColumn('Marseille', '⚪'),
                      ],
                    ),
                  ],
                ),
              ),

              // 탭 형태의 상세 정보
              Expanded(
                child: DefaultTabController(
                  length: 3,
                  child: Column(
                    children: [
                      TabBar(
                        labelColor: athlete.teamColor,
                        unselectedLabelColor: Colors.grey,
                        indicatorColor: athlete.teamColor,
                        tabs: const [
                          Tab(text: '경기 정보'),
                          Tab(text: '출전 선수'),
                          Tab(text: '전술/포메이션'),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          children: [
                            _buildMatchInfoTab(athlete),
                            _buildLineupTab(athlete),
                            _buildTacticsTab(athlete),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamColumn(String name, String emoji) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 28)),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  /// 경기 정보 탭
  Widget _buildMatchInfoTab(Athlete athlete) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        _buildInfoRow(Icons.calendar_today, '일시', '2026년 2월 6일 (목) 05:00'),
        _buildInfoRow(Icons.stadium, '경기장', 'Parc des Princes'),
        _buildInfoRow(Icons.location_on, '위치', 'Paris, France'),
        _buildInfoRow(Icons.tv, '중계', 'SPOTV ON'),
        _buildInfoRow(Icons.people, '예상 관중', '47,000명'),
        const SizedBox(height: 20),
        const Text(
          '📊 시즌 상대 전적',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatColumn('PSG 승', '3'),
              _buildStatColumn('무승부', '1'),
              _buildStatColumn('Marseille 승', '1'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// 출전 선수 탭
  Widget _buildLineupTab(Athlete athlete) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '선발 예상',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              athlete.nameKr,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        const Text(
          '🔵 PSG 예상 라인업',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildPlayerListItem('GK', '도나루마', '99'),
        _buildPlayerListItem('DF', '하키미', '2'),
        _buildPlayerListItem('DF', '마르키뇨스', '5'),
        _buildPlayerListItem('DF', '스키르냐르', '37'),
        _buildPlayerListItem('DF', '메낭', '25'),
        _buildPlayerListItem('MF', '자이르 엠바페', '33'),
        _buildPlayerListItem('MF', '비티냐', '8'),
        _buildPlayerListItem('MF', '이강인 ⭐', '19', isHighlighted: true),
        _buildPlayerListItem('FW', '데엠벨레', '10'),
        _buildPlayerListItem('FW', '바르콜라', '7'),
        _buildPlayerListItem('FW', '콜로 무아니', '23'),
      ],
    );
  }

  Widget _buildPlayerListItem(String position, String name, String number, {bool isHighlighted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.blue.withOpacity(0.1) : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: isHighlighted ? Border.all(color: Colors.blue.withOpacity(0.3)) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isHighlighted ? Colors.blue : Colors.grey[300],
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isHighlighted ? Colors.white : Colors.grey[700],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            position,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
                color: isHighlighted ? Colors.blue[700] : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 전술 탭
  Widget _buildTacticsTab(Athlete athlete) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          '📋 예상 포메이션',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          height: 300,
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // 축구장 라인
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white30, width: 2),
                  ),
                ),
              ),
              // 포메이션 텍스트
              const Center(
                child: Text(
                  '4-3-3',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              // 선수 이름
              Positioned(
                left: 20,
                top: 120,
                child: _buildFormationPlayer('이강인', true),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          '💡 전술 분석',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTacticsItem('공격 스타일', '점유율 기반 빌드업'),
              _buildTacticsItem('수비 스타일', '높은 전방 압박'),
              _buildTacticsItem('${athlete.nameKr} 역할', '우측 공격형 미드필더 (인버티드 윙어)'),
              _buildTacticsItem('주요 임무', '중앙 침투, 키패스, 세트피스'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFormationPlayer(String name, bool isHighlighted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.yellow : Colors.white,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        name,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: isHighlighted ? Colors.black : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTacticsItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• $label: ',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 오늘의 경기일정 (캐러셀 형태)
  Widget _buildTodayMatchSchedule(BuildContext context, List<Athlete> athletes) {
    final sampleMatches = [
      {
        'id': 'match_1',
        'time': '05:00',
        'icon': '⚽',
        'title': 'PSG vs Marseille',
        'athlete': '이강인',
        'status': 'live',
        'competition': 'Ligue 1',
      },
      {
        'id': 'match_2',
        'time': '09:30',
        'icon': '⚾',
        'title': 'Giants vs Dodgers',
        'athlete': '이정후',
        'status': 'scheduled',
        'competition': 'MLB',
      },
      {
        'id': 'match_3',
        'time': '14:00',
        'icon': '🏸',
        'title': 'BWF Super 500 결승',
        'athlete': '안세영',
        'status': 'scheduled',
        'competition': 'BWF',
      },
      {
        'id': 'match_4',
        'time': '21:00',
        'icon': '⚽',
        'title': 'Tottenham vs Arsenal',
        'athlete': '손흥민',
        'status': 'scheduled',
        'competition': 'EPL',
      },
    ];

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 경기일정',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '2026.02.04',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  // 전체 일정 보기
                  _showAllSchedules(context);
                },
                icon: const Icon(Icons.calendar_month, size: 18),
                label: const Text('전체일정'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 캐러셀 형태의 경기 카드 (3개만 표시, 드래그 가능)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: sampleMatches.length,
              itemBuilder: (context, index) {
                final match = sampleMatches[index];
                return _buildMatchCard(context, match);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(BuildContext context, Map<String, dynamic> match) {
    final isLive = match['status'] == 'live';

    return GestureDetector(
      onTap: () {
        // 매치데이 화면으로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MatchDayScreen(
              match: Match(
                id: match['id'] as String,
                homeTeam: (match['title'] as String).split(' vs ')[0],
                awayTeam: (match['title'] as String).split(' vs ')[1],
                kickoffTime: DateTime.now(),
                competition: match['competition'] as String,
                venue: '',
                venueCity: '',
                status: isLive ? MatchStatus.live : MatchStatus.scheduled,
              ),
            ),
          ),
        );
      },
      child: Container(
        width: 160,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isLive
              ? Border.all(color: Colors.red, width: 2)
              : Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(
                    color: isLive ? Colors.red : Colors.grey[200],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    isLive ? '🔴 진행중' : match['time'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isLive ? Colors.white : Colors.grey[700],
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  match['icon'] as String,
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              match['title'] as String,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${match['athlete']} 출전',
              style: TextStyle(
                fontSize: 10,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAllSchedules(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                '전체 경기 일정',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  children: const [
                    // 일정 목록
                    Text('일정 목록이 여기에 표시됩니다.'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 리그 순위 카드
  Widget _buildLeagueStandings(BuildContext context, Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Text(
                '🏆 리그 현황',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: athlete.teamColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      athlete.sport.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getLeagueName(athlete),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${athlete.team}: ${_getLeagueRanking(athlete)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey[400],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLeagueName(Athlete athlete) {
    switch (athlete.sport.displayName) {
      case '축구':
        return 'Ligue 1 2025-26';
      case '야구':
        return 'MLB 2026';
      case '배드민턴':
        return 'BWF World Tour';
      case '수영':
        return 'World Aquatics';
      default:
        return '리그 정보';
    }
  }

  String _getLeagueRanking(Athlete athlete) {
    switch (athlete.sport.displayName) {
      case '축구':
        return '2위 (54pts)';
      case '야구':
        return '3위 (45-38)';
      case '배드민턴':
        return '세계랭킹 1위';
      case '수영':
        return '한국신기록 보유';
      default:
        return '-';
    }
  }

  Widget _buildAthleteDashboard(
    BuildContext context,
    WidgetRef ref,
    Athlete athlete,
  ) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 200,
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
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: athlete.teamColor.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Stack(
              children: [
                Positioned(
                  right: -30,
                  bottom: -30,
                  child: Icon(
                    athlete.sport.iconData,
                    size: 180,
                    color: Colors.white.withOpacity(0.1),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${athlete.sport.icon} ${athlete.team}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              '다음 경기 D-3',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Text(
                        athlete.lastName,
                        style: const TextStyle(
                          fontSize: 36,
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
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.8),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        athlete.statSummary,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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

  /// 최근 활약 (선택된 선수만)
  Widget _buildRecentPerformance(BuildContext context, Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📊 ${athlete.nameKr}의 최근 활약',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildPerformanceCard(athlete),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: athlete.teamColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                athlete.sport.icon,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  athlete.nameKr,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  athlete.statSummary,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.green[400],
            size: 20,
          ),
        ],
      ),
    );
  }

  /// 최신 뉴스 (선택된 선수만)
  Widget _buildLatestNews(BuildContext context, Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📰 ${athlete.nameKr} 관련 뉴스',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('더보기'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildNewsCard(
            title: '${athlete.nameKr}, 최근 3경기 연속 공격포인트 기록',
            source: 'Sports News',
            time: '2시간 전',
          ),
          const SizedBox(height: 12),
          _buildNewsCard(
            title: '${athlete.team} 감독 "${athlete.nameKr}는 핵심 선수"',
            source: 'Football Daily',
            time: '5시간 전',
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String source,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.article,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      source,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[400],
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
}
