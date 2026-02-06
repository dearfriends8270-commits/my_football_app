import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/match.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../utils/app_colors.dart';
import '../player/athlete_detail_screen.dart';
import '../matchday/matchday_screen.dart';

class HomeScreenNew extends ConsumerStatefulWidget {
  const HomeScreenNew({super.key});

  @override
  ConsumerState<HomeScreenNew> createState() => _HomeScreenNewState();
}

class _HomeScreenNewState extends ConsumerState<HomeScreenNew> {
  SportType? _selectedSport;

  @override
  Widget build(BuildContext context) {
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);
    final selectedAthlete = ref.watch(selectedAthleteProvider);
    final followedSports = ref.watch(followedSportsProvider);

    // 초기 선택 종목 설정 (팔로우 종목 기반)
    if (_selectedSport == null && followedSports.isNotEmpty) {
      _selectedSport = followedSports.first;
    } else if (_selectedSport == null && favoriteAthletes.isNotEmpty) {
      _selectedSport = favoriteAthletes.first.sport;
    }

    if (favoriteAthletes.isEmpty && followedSports.isEmpty) {
      return _buildEmptyState(context);
    }

    final currentAthlete = selectedAthlete ??
        (favoriteAthletes.isNotEmpty ? favoriteAthletes.first : null);

    return Container(
      color: AppColors.background,
      child: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // 앱 헤더 (K-SPORTS STAR)
            SliverToBoxAdapter(
              child: _buildAppHeader(context, currentAthlete, favoriteAthletes),
            ),

            // 스포츠 탭 바 (동적)
            SliverToBoxAdapter(
              child: _buildSportTabs(followedSports, favoriteAthletes),
            ),

            // 구분선
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                height: 1,
                color: AppColors.border.withValues(alpha: 0.3),
              ),
            ),

            // 이달의 경기 (대형 배너)
            if (currentAthlete != null)
              SliverToBoxAdapter(
                child: _buildFeaturedMatch(currentAthlete),
              ),

            // 종목만 팔로우인 경우 (선수 없음) - 스포츠 피드 모드
            if (currentAthlete == null && _selectedSport != null)
              SliverToBoxAdapter(
                child: _buildSportOnlyFeed(_selectedSport!),
              ),

            // 오늘의 경기 일정
            SliverToBoxAdapter(
              child: _buildTodayMatches(),
            ),

            // 선수 프로필 카드
            if (currentAthlete != null)
              SliverToBoxAdapter(
                child: _buildPlayerProfileCard(currentAthlete),
              ),

            // 최근 활약 및 관련 뉴스
            if (currentAthlete != null)
              SliverToBoxAdapter(
                child: _buildRecentNewsSection(currentAthlete),
              ),

            // 하단 여백 (플로팅 네비게이션 바 공간)
            const SliverToBoxAdapter(
              child: SizedBox(height: 120),
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
                ref.read(mainTabIndexProvider.notifier).state = 1;
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

  /// ─────────────────────────────────────────
  /// 앱 헤더 - K-SPORTS STAR 로고 + 선수 스와이프
  /// 컨셉: 이탤릭 타이틀 + < 손흥민 > + 편집
  /// ─────────────────────────────────────────
  Widget _buildAppHeader(
    BuildContext context,
    Athlete? currentAthlete,
    List<Athlete> athletes,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 20, right: 20, top: 12, bottom: 8),
      child: Column(
        children: [
          // 로고 - 컨셉: 이탤릭 스타일
          const Text(
            'K-SPORTS STAR',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
              fontStyle: FontStyle.italic,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),

          // 선수 선택 스와이프 (선수가 있을 때만)
          if (athletes.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _switchAthlete(athletes, -1),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _showAthleteSelector(context, athletes),
                  child: Text(
                    currentAthlete?.nameKr ?? '선수 선택',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: () => _switchAthlete(athletes, 1),
                  child: const Padding(
                    padding: EdgeInsets.all(8),
                    child: Icon(
                      Icons.chevron_right,
                      color: AppColors.textSecondary,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () {
                    ref.read(mainTabIndexProvider.notifier).state = 1;
                  },
                  child: const Text(
                    '편집',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            // 선수 없을 때 편집 버튼만
            GestureDetector(
              onTap: () {
                ref.read(mainTabIndexProvider.notifier).state = 1;
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add, color: AppColors.primary, size: 18),
                    SizedBox(width: 6),
                    Text(
                      '선수 추가하기',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
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
    final sportOnlyFollows = ref.read(sportOnlyFollowsProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
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

            // 선수 목록
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
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
                          style: const TextStyle(
                              color: AppColors.textSecondary),
                        ),
                        onTap: () {
                          ref
                              .read(athleteProvider.notifier)
                              .selectAthlete(athlete);
                          setState(() => _selectedSport = athlete.sport);
                          Navigator.pop(context);
                        },
                      )),

                  // 종목만 팔로우 섹션
                  if (sportOnlyFollows.isNotEmpty) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: AppColors.divider),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Text(
                        '종목 팔로우 (선수 미등록)',
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    ...sportOnlyFollows.map((sport) => ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                sport.primaryColor.withValues(alpha: 0.3),
                            child: Text(
                              sport.icon,
                              style: const TextStyle(fontSize: 20),
                            ),
                          ),
                          title: Text(
                            sport.displayName,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            '선수를 추가해보세요',
                            style: TextStyle(
                                color: AppColors.textMuted, fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.primary,
                            size: 20,
                          ),
                          onTap: () {
                            setState(() => _selectedSport = sport);
                            Navigator.pop(context);
                            // 선수 관리 탭으로 전환
                            ref.read(mainTabIndexProvider.notifier).state = 1;
                          },
                        )),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ─────────────────────────────────────────
  /// 스포츠 탭 바 (동적 - followedSports 기반)
  /// ─────────────────────────────────────────
  Widget _buildSportTabs(
    Set<SportType> followedSports,
    List<Athlete> favoriteAthletes,
  ) {
    // 팔로우 종목 + 선수 종목 합집합
    final sportsFromAthletes = favoriteAthletes.map((a) => a.sport).toSet();
    final allSports = <SportType>{...followedSports, ...sportsFromAthletes};

    // 종목이 없으면 기본 4종목
    final sportsList = allSports.isNotEmpty
        ? allSports.toList()
        : [SportType.football, SportType.baseball, SportType.basketball, SportType.badminton];

    // 4개 이하면 Expanded(Row), 그 이상이면 가로 스크롤
    if (sportsList.length <= 4) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: sportsList.map((sport) {
            final isSelected = _selectedSport == sport;
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedSport = sport),
                child: _buildSportTab(sport, isSelected),
              ),
            );
          }).toList(),
        ),
      );
    }

    // 5개 이상이면 스크롤 가능
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: sportsList.length,
        itemBuilder: (context, index) {
          final sport = sportsList[index];
          final isSelected = _selectedSport == sport;
          return GestureDetector(
            onTap: () => setState(() => _selectedSport = sport),
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildSportTab(sport, isSelected),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSportTab(SportType sport, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2.5,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(sport.icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            sport.displayName,
            style: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────
  /// 종목만 팔로우 모드 (선수 미등록)
  /// ─────────────────────────────────────────
  Widget _buildSportOnlyFeed(SportType sport) {
    final allAthletes = ref.watch(allAthletesProvider);
    final sportAthletes =
        allAthletes.where((a) => a.sport == sport).toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 종목 헤더
          Row(
            children: [
              Text(sport.icon, style: const TextStyle(fontSize: 24)),
              const SizedBox(width: 8),
              Text(
                '${sport.displayName} 피드',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 리그 경기 정보 카드
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: sport.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.sports,
                        color: sport.primaryColor.withValues(alpha: 0.7), size: 18),
                    const SizedBox(width: 6),
                    Text(
                      '${sport.displayName} 주요 일정',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text(
                  '등록된 선수가 없습니다.\n선수를 추가하면 맞춤 정보를 제공해드립니다.',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          // 추천 선수 섹션
          if (sportAthletes.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              '추천 선수',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: sportAthletes.length,
                itemBuilder: (context, index) {
                  final athlete = sportAthletes[index];
                  return GestureDetector(
                    onTap: () {
                      ref
                          .read(athleteProvider.notifier)
                          .addFavorite(athlete);
                      ref
                          .read(athleteProvider.notifier)
                          .selectAthlete(athlete);
                    },
                    child: Container(
                      width: 90,
                      margin: const EdgeInsets.only(right: 10),
                      child: Column(
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: athlete.teamColor.withValues(alpha: 0.2),
                              border: Border.all(
                                color: athlete.teamColor.withValues(alpha: 0.4),
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                sport.icon,
                                style: const TextStyle(fontSize: 24),
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            athlete.nameKr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            athlete.team,
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 9,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────
  /// 이달의 경기 - 대형 배너
  /// 컨셉: 경기장 배경, 팀 로고 양쪽, 중앙에 날짜+시간, 하단에 선수 출격 대기
  /// ─────────────────────────────────────────
  Widget _buildFeaturedMatch(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // "이달의 경기" 헤더 - 컨셉: 중앙 정렬, 가로선 양쪽
          Row(
            children: [
              Expanded(
                child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  '이달의 경기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 1,
                  ),
                ),
              ),
              Expanded(
                child: Container(height: 1, color: AppColors.border.withValues(alpha: 0.4)),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 대형 경기 카드
          GestureDetector(
            onTap: () => _openMatchDay(athlete),
            child: Container(
            height: 220,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF1A3A2A),
                  AppColors.backgroundCard,
                ],
              ),
              border: Border.all(color: AppColors.border.withValues(alpha: 0.5), width: 1),
            ),
            child: Stack(
              children: [
                // 배경 패턴 (경기장 필드 느낌)
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: CustomPaint(
                      painter: StadiumFieldPainter(),
                    ),
                  ),
                ),

                // 상단 그라데이션 오버레이 (배경 어둡게)
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.2),
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.4),
                        ],
                        stops: const [0.0, 0.4, 1.0],
                      ),
                    ),
                  ),
                ),

                // 경기 정보
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // 날짜
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '2월 5일 (목)',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // 팀 로고 + 시간 중앙 레이아웃
                      Expanded(
                        child: Row(
                          children: [
                            // 왼쪽 팀
                            Expanded(
                              child: _buildTeamSection(
                                'IMFC',
                                Icons.shield_outlined,
                                const Color(0xFFF5B0C9),
                              ),
                            ),

                            // 시간 (중앙)
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '22:30',
                                  style: TextStyle(
                                    fontSize: 40,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textPrimary,
                                    letterSpacing: 2,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),

                            // 오른쪽 팀
                            Expanded(
                              child: _buildTeamSection(
                                'LAFC',
                                Icons.shield,
                                const Color(0xFFD4AF37),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // 선수 출격 대기 배지
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${athlete.nameKr} 출격 대기',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.accent,
                            fontWeight: FontWeight.w700,
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
        ],
      ),
    );
  }

  /// 경기 상세 화면으로 이동
  void _openMatchDay(Athlete athlete) {
    final sampleMatch = Match(
      id: 'featured_1',
      homeTeam: 'IMFC',
      awayTeam: 'LAFC',
      kickoffTime: DateTime.now().add(const Duration(days: 1)),
      competition: 'MLS',
      venue: 'Saputo Stadium',
      status: MatchStatus.scheduled,
      playerId: athlete.id,
      broadcastChannel: 'Apple TV',
      stadium: 'Saputo Stadium',
      venueCity: 'Montreal',
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => MatchDayScreen(match: sampleMatch),
      ),
    );
  }

  /// 팀 섹션 (로고 + 팀명)
  Widget _buildTeamSection(String name, IconData icon, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.black.withValues(alpha: 0.3),
            border: Border.all(color: color.withValues(alpha: 0.5), width: 1.5),
          ),
          child: Icon(icon, color: color, size: 30),
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: 1,
          ),
        ),
      ],
    );
  }

  /// ─────────────────────────────────────────
  /// 오늘의 경기 일정 (가로 스크롤)
  /// 컨셉: "오늘의 경기 일정" + 🗓 전체 일정 보기 | 3개 카드 수평
  /// ─────────────────────────────────────────
  Widget _buildTodayMatches() {
    final matches = [
      {
        'status': 'live',
        'time': '진행중',
        'team1': 'PSG',
        'team2': 'Marseille',
        'athlete': '이강인 교체',
        'icon': '⚽',
        'teamColor': const Color(0xFF001C58),
      },
      {
        'status': 'scheduled',
        'time': '14:00',
        'team1': '자이언츠',
        'team2': '다저스',
        'athlete': '이정후',
        'icon': '⚾',
        'teamColor': const Color(0xFFFD5A1E),
      },
      {
        'status': 'scheduled',
        'time': '15:30',
        'team1': 'BWF Super',
        'team2': '500 결승',
        'detail': 'VS 천위페이',
        'athlete': '안세영',
        'icon': '🏸',
        'teamColor': const Color(0xFF8B5CF6),
      },
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // 헤더
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
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_month_outlined,
                      size: 14,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '전체 일정 보기',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 가로 스크롤 매치 카드들
          SizedBox(
            height: 130,
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
      width: 130,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isLive ? AppColors.live.withValues(alpha: 0.6) : AppColors.border.withValues(alpha: 0.5),
          width: isLive ? 1.5 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상태 배지 + 스포츠 아이콘
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isLive
                      ? AppColors.live.withValues(alpha: 0.2)
                      : AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(6),
                  border: isLive
                      ? Border.all(color: AppColors.live.withValues(alpha: 0.5))
                      : null,
                ),
                child: Text(
                  match['time'] as String,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isLive ? AppColors.live : AppColors.textSecondary,
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
          const SizedBox(height: 8),

          // 팀 정보
          Text(
            '${match['team1']}',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            match['detail'] != null
                ? match['detail'] as String
                : 'VS ${match['team2']}',
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),

          // 선수 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isLive
                  ? AppColors.success.withValues(alpha: 0.15)
                  : AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.person,
                  size: 10,
                  color: isLive ? AppColors.success : AppColors.primary,
                ),
                const SizedBox(width: 3),
                Flexible(
                  child: Text(
                    match['athlete'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: isLive ? AppColors.success : AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ─────────────────────────────────────────
  /// 선수 프로필 카드
  /// 컨셉: 왼쪽에 선수영역(등번호+아이콘), 중앙에 이름+스탯, 오른쪽에 팀로고+리그
  /// ─────────────────────────────────────────
  Widget _buildPlayerProfileCard(Athlete athlete) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => AthleteDetailScreen(athlete: athlete),
          ),
        );
      },
      child: Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            athlete.teamColor.withValues(alpha: 0.6),
            athlete.teamColor.withValues(alpha: 0.2),
            AppColors.backgroundCard,
          ],
          stops: const [0.0, 0.4, 1.0],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: athlete.teamColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 왼쪽: 선수 이미지 영역 (등번호 + 스포츠 아이콘)
          Container(
            width: 80,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  athlete.teamColor.withValues(alpha: 0.4),
                  athlete.teamColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: athlete.teamColor.withValues(alpha: 0.3),
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 영문 이름 (세로 배치 느낌)
                Positioned(
                  top: 6,
                  left: 8,
                  child: Text(
                    'heung-min Son',
                    style: TextStyle(
                      fontSize: 7,
                      color: Colors.white.withValues(alpha: 0.4),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                // 한글 이름
                Positioned(
                  top: 18,
                  left: 8,
                  child: Text(
                    athlete.nameKr,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                // 등번호
                Positioned(
                  bottom: 4,
                  left: 8,
                  child: Text(
                    '7',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withValues(alpha: 0.25),
                      height: 1.0,
                    ),
                  ),
                ),
                // 스포츠 아이콘
                Positioned(
                  bottom: 10,
                  right: 8,
                  child: Text(
                    athlete.sport.icon,
                    style: const TextStyle(fontSize: 24),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // 중앙: 선수 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 시즌 스탯
                Text(
                  '13경기 12골 3어시스트',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // 시즌 평점
                Row(
                  children: [
                    Text(
                      '시즌평점 ',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '8.7',
                      style: TextStyle(
                        fontSize: 16,
                        color: AppColors.accent,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 오른쪽: 팀 로고 + 리그 정보
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 팀 로고 원형
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withValues(alpha: 0.3),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.5),
                  ),
                ),
                child: Center(
                  child: Text(
                    athlete.team.substring(0, 1),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                athlete.team.split(' ').first,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Major League Soccer',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.textMuted,
                ),
              ),
            ],
          ),
        ],
      ),
      ),
    );
  }

  /// ─────────────────────────────────────────
  /// 최근 활약 및 관련 뉴스
  /// 컨셉: 라운드 카드, 4개 아이콘 그리드 (뉴스/통계/영상/수상)
  /// ─────────────────────────────────────────
  Widget _buildRecentNewsSection(Athlete athlete) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
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
          const SizedBox(height: 20),
          Row(
            children: [
              _buildNewsIcon(Icons.article_outlined, '뉴스'),
              _buildNewsIcon(Icons.show_chart, '통계'),
              _buildNewsIcon(Icons.videocam_outlined, '영상'),
              _buildNewsIcon(Icons.emoji_events_outlined, '수상'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNewsIcon(IconData icon, String label) {
    return Expanded(
      child: GestureDetector(
        onTap: () {},
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.4),
                ),
              ),
              child: Icon(icon, color: AppColors.textSecondary, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ─────────────────────────────────────────
/// 경기장 필드 패턴 페인터 (컨셉: 초록색 잔디 필드 라인)
/// ─────────────────────────────────────────
class StadiumFieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF2D5A3D).withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final centerX = size.width / 2;
    final centerY = size.height / 2;

    // 외곽선
    final fieldRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(20, 20, size.width - 40, size.height - 40),
      const Radius.circular(4),
    );
    canvas.drawRRect(fieldRect, paint);

    // 센터 라인
    canvas.drawLine(
      Offset(centerX, 20),
      Offset(centerX, size.height - 20),
      paint,
    );

    // 센터 서클
    canvas.drawCircle(
      Offset(centerX, centerY),
      30,
      paint,
    );

    // 센터 점
    final dotPaint = Paint()
      ..color = const Color(0xFF2D5A3D).withValues(alpha: 0.4)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(centerX, centerY), 2, dotPaint);

    // 왼쪽 골 에어리어
    canvas.drawRect(
      Rect.fromLTWH(20, centerY - 40, 40, 80),
      paint,
    );

    // 오른쪽 골 에어리어
    canvas.drawRect(
      Rect.fromLTWH(size.width - 60, centerY - 40, 40, 80),
      paint,
    );

    // 필드 줄무늬 (잔디 느낌)
    final stripePaint = Paint()
      ..color = const Color(0xFF2D5A3D).withValues(alpha: 0.06)
      ..style = PaintingStyle.fill;

    for (double x = 20; x < size.width - 20; x += 40) {
      if ((x ~/ 40) % 2 == 0) {
        canvas.drawRect(
          Rect.fromLTWH(x, 20, 20, size.height - 40),
          stripePaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
