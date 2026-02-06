import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../utils/app_colors.dart';
import '../player/player_manage_screen.dart';

class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> {
  SportType _selectedSport = SportType.football;

  @override
  Widget build(BuildContext context) {
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);
    final selectedAthlete = ref.watch(selectedAthleteProvider);

    if (favoriteAthletes.isEmpty) {
      return _buildEmptyState(context);
    }

    final currentAthlete = selectedAthlete ?? favoriteAthletes.first;

    return Container(
      color: AppColors.background,
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            // 앱 헤더 (K-SPORTS STAR)
            SliverToBoxAdapter(
              child: _buildAppHeader(context, currentAthlete, favoriteAthletes),
            ),

            // 스포츠 탭 바
            SliverToBoxAdapter(
              child: _buildSportTabs(),
            ),

            // 이달의 경기 (대형 배너)
            SliverToBoxAdapter(
              child: _buildFeaturedMatch(currentAthlete),
            ),

            // 오늘의 경기 일정
            SliverToBoxAdapter(
              child: _buildTodayMatches(),
            ),

            // 선수 프로필 카드
            SliverToBoxAdapter(
              child: _buildPlayerProfileCard(currentAthlete),
            ),

            // 최근 활약 및 관련 뉴스
            SliverToBoxAdapter(
              child: _buildRecentNewsSection(currentAthlete),
            ),

            // 하단 여백
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sports_soccer,
              size: 80,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              '팔로우할 선수를 선택해주세요',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const PlayerManageScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.add),
              label: const Text('선수 추가하기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 앱 헤더 - K-SPORTS STAR 로고 + 선수 스와이프
  Widget _buildAppHeader(
    BuildContext context,
    Athlete currentAthlete,
    List<Athlete> athletes,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // 로고
          const Text(
            'K-SPORTS STAR',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 16),

          // 선수 선택 스와이프
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () => _switchAthlete(athletes, -1),
                icon: const Icon(
                  Icons.chevron_left,
                  color: AppColors.textSecondary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _showAthleteSelector(context, athletes),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundCard,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        currentAthlete.nameKr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(
                        Icons.unfold_more,
                        color: AppColors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _switchAthlete(athletes, 1),
                icon: const Icon(
                  Icons.chevron_right,
                  color: AppColors.textSecondary,
                  size: 28,
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
                child: const Text(
                  '편집',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _switchAthlete(List<Athlete> athletes, int direction) {
    final currentIndex = athletes.indexWhere(
      (a) => a.id == ref.read(selectedAthleteProvider)?.id,
    );
    final newIndex = (currentIndex + direction) % athletes.length;
    final newAthlete = athletes[newIndex < 0 ? athletes.length - 1 : newIndex];
    ref.read(athleteProvider.notifier).selectAthlete(newAthlete);
  }

  void _showAthleteSelector(BuildContext context, List<Athlete> athletes) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              '선수 선택',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...athletes.map((athlete) => ListTile(
              leading: CircleAvatar(
                backgroundColor: athlete.teamColor,
                child: Text(
                  athlete.sport.icon,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
              title: Text(
                athlete.nameKr,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                athlete.team,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
              onTap: () {
                ref.read(athleteProvider.notifier).selectAthlete(athlete);
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

  /// 스포츠 탭 바
  Widget _buildSportTabs() {
    final sports = [
      {'type': SportType.football, 'icon': '⚽', 'name': '축구'},
      {'type': SportType.baseball, 'icon': '⚾', 'name': '야구'},
      {'type': SportType.basketball, 'icon': '🏀', 'name': '농구'},
      {'type': SportType.badminton, 'icon': '🏸', 'name': '배구'},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: sports.map((sport) {
          final isSelected = _selectedSport == sport['type'];
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSport = sport['type'] as SportType;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      sport['icon'] as String,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      sport['name'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.textPrimary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// 이달의 경기 - 대형 배너
  Widget _buildFeaturedMatch(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '이달의 경기',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 대형 경기 카드 (경기장 배경 이미지 스타일)
          Container(
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.backgroundCardLight,
                  AppColors.backgroundCard,
                ],
              ),
              border: Border.all(color: AppColors.border, width: 1),
            ),
            child: Stack(
              children: [
                // 배경 패턴 (경기장 느낌)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: StadiumPatternPainter(),
                    ),
                  ),
                ),

                // 경기 정보
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // 날짜/시간
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                        child: const Text(
                          '2월 5일 (목)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 시간
                      const Text(
                        '22:30',
                        style: TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimary,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 팀 vs 팀
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTeamBadge('IMFC', '🖤'),
                          const SizedBox(width: 40),
                          _buildTeamBadge('LAFC', '💛'),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // 선수 출전 정보
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${athlete.nameKr} 출격 대기',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w600,
                          ),
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

  Widget _buildTeamBadge(String name, String emoji) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
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
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// 오늘의 경기 일정 (가로 스크롤)
  Widget _buildTodayMatches() {
    final matches = [
      {
        'status': 'live',
        'time': '진행중',
        'team1': 'PSG',
        'team2': 'Marseille',
        'athlete': '이강인 교체',
        'icon': '⚽',
      },
      {
        'status': 'scheduled',
        'time': '14:00',
        'team1': '자이언츠',
        'team2': '다저스',
        'athlete': '이정후',
        'icon': '⚾',
      },
      {
        'status': 'scheduled',
        'time': '15:30',
        'team1': 'BWF Super',
        'team2': '500 결승',
        'athlete': '안세영',
        'icon': '🏸',
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '오늘의 경기 일정',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.live,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'LIVE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {},
                icon: const Icon(
                  Icons.calendar_month,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                label: const Text(
                  '전체 일정 보기',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: matches.length,
              itemBuilder: (context, index) {
                final match = matches[index];
                return _buildMatchCard(match);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchCard(Map<String, dynamic> match) {
    final isLive = match['status'] == 'live';

    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.live : AppColors.border,
          width: isLive ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isLive ? AppColors.live : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  match['time'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLive ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                match['icon'] as String,
                style: const TextStyle(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${match['team1']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Text(
            'VS ${match['team2']}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              match['athlete'] as String,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 선수 프로필 카드
  Widget _buildPlayerProfileCard(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            athlete.teamColor.withOpacity(0.8),
            athlete.teamColor.withOpacity(0.4),
            AppColors.backgroundCard,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // 선수 이미지 자리 (원형)
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              color: athlete.teamColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    athlete.sport.icon,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '7',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // 선수 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'heung-min Son',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  athlete.nameKr,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '13경기12골 3어시스트',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  '시즌평점 8.7',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // 팀 로고 자리
          Column(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('💛', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                athlete.team.split(' ').first,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const Text(
                'Major League Soccer 🏈',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 최근 활약 및 뉴스
  Widget _buildRecentNewsSection(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '최근 활약 및 관련 뉴스',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildNewsIcon(Icons.article, '뉴스'),
              _buildNewsIcon(Icons.show_chart, '통계'),
              _buildNewsIcon(Icons.video_library, '영상'),
              _buildNewsIcon(Icons.emoji_events, '수상'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsIcon(IconData icon, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.textSecondary, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// 경기장 패턴 페인터
class StadiumPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.border.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 필드 라인 (간단한 경기장 패턴)
    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 센터 서클
    canvas.drawCircle(
      Offset(centerX, centerY + 20),
      40,
      paint,
    );

    // 가로선
    canvas.drawLine(
      Offset(0, centerY + 20),
      Offset(size.width, centerY + 20),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
