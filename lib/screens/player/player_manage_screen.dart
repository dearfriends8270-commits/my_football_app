import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../utils/app_colors.dart';

/// 선수 관리 화면 - 2탭 구조 (컨셉 매칭)
/// Tab 0: 관심 종목 설정
/// Tab 1: 내 선수 픽업
class PlayerManageScreen extends ConsumerStatefulWidget {
  const PlayerManageScreen({super.key});

  @override
  ConsumerState<PlayerManageScreen> createState() =>
      _PlayerManageScreenState();
}

class _PlayerManageScreenState extends ConsumerState<PlayerManageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  SportType? _filterSport;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary, size: 20),
                onPressed: () => Navigator.of(context).pop(),
              ),
              centerTitle: true,
              title: const Text(
                '선수',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : null,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 타이틀 (임베디드 모드에서만)
            if (!canPop) _buildTitle(),

            // 탭 버튼
            _buildTabButtons(),

            // 스포츠 필터 바
            _buildSportFilterBar(),

            // 안내 텍스트
            _buildInfoText(),

            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildSportSelectionGrid(),
                  _buildAthletePickupList(),
                ],
              ),
            ),

            // 하단 여백 (floating nav bar)
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 타이틀 (IndexedStack 임베디드 시)
  // ═══════════════════════════════════════════

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          // 왼쪽 빈 공간 밸런스
          const SizedBox(width: 36),
          const Spacer(),
          const Text(
            '선수',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          // 오른쪽 빈 공간 밸런스
          const SizedBox(width: 36),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 탭 버튼 (2개 사각 버튼)
  // ═══════════════════════════════════════════

  Widget _buildTabButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(child: _tabButton(0, '관심 종목 설정')),
          const SizedBox(width: 10),
          Expanded(child: _tabButton(1, '내 선수 픽업')),
        ],
      ),
    );
  }

  Widget _tabButton(int index, String label) {
    final isActive = _tabController.index == index;
    return GestureDetector(
      onTap: () {
        _tabController.animateTo(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isActive ? AppColors.backgroundCard : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppColors.textPrimary : AppColors.textMuted,
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 스포츠 필터 바 (가로 스크롤 칩)
  // ═══════════════════════════════════════════

  Widget _buildSportFilterBar() {
    final followedSports = ref.watch(followedSportsProvider);

    // Tab 0 (관심 종목 설정): 전체 종목 표시
    // Tab 1 (내 선수 픽업): 팔로우된 종목만 필터로 표시
    final List<SportType?> sportsList;
    if (_tabController.index == 0) {
      sportsList = SportType.values.toList().cast<SportType?>();
    } else {
      final followed = followedSports.isNotEmpty
          ? followedSports.toList()
          : SportType.values.toList();
      sportsList = <SportType?>[null, ...followed];
    }

    Widget buildTab(SportType? sport, bool isSelected) {
      final isFollowed = sport != null && followedSports.contains(sport);

      return GestureDetector(
        onTap: () {
          if (_tabController.index == 0 && sport != null) {
            ref.read(athleteProvider.notifier).toggleFollowedSport(sport);
          } else {
            setState(() {
              _filterSport = sport;
            });
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: _tabController.index == 0
                    ? (isFollowed ? AppColors.primary : Colors.transparent)
                    : (isSelected ? AppColors.primary : Colors.transparent),
                width: 2.5,
              ),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(sport?.icon ?? '🌐', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                sport?.displayName ?? '전체',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: _tabController.index == 0
                      ? (isFollowed ? FontWeight.bold : FontWeight.w500)
                      : (isSelected ? FontWeight.bold : FontWeight.w500),
                  color: _tabController.index == 0
                      ? (isFollowed ? AppColors.textPrimary : AppColors.textMuted)
                      : (isSelected ? AppColors.textPrimary : AppColors.textMuted),
                ),
              ),
              if (_tabController.index == 0 && isFollowed) ...[
                const SizedBox(width: 4),
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 14),
              ],
            ],
          ),
        ),
      );
    }

    if (sportsList.length <= 4) {
      return Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: AppColors.border.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: sportsList.map((sport) {
            final isSelected = _filterSport == sport;
            return Expanded(child: buildTab(sport, isSelected));
          }).toList(),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      height: 44,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: sportsList.length,
        itemBuilder: (context, index) {
          final sport = sportsList[index];
          final isSelected = _filterSport == sport;
          return buildTab(sport, isSelected);
        },
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 안내 텍스트
  // ═══════════════════════════════════════════

  Widget _buildInfoText() {
    final followedCount = ref.watch(followedSportsProvider).length;
    final favoriteCount = ref.watch(favoriteAthletesProvider).length;

    final text = _tabController.index == 0
        ? '좋아하는 스포츠 종목을 선택하면 목록에 추가됩니다\n(현재 총 $followedCount종목 선택)'
        : '좋아하는 스포츠 선수를 선택하면 메인홈에 추가됩니다\n(현재 총 $favoriteCount선수 선택)';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 0: 관심 종목 설정 (3열 그리드)
  // ═══════════════════════════════════════════

  Widget _buildSportSelectionGrid() {
    final followedSports = ref.watch(followedSportsProvider);
    final sports = SportType.values;

    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.0,
      ),
      itemCount: sports.length,
      itemBuilder: (context, index) {
        final sport = sports[index];
        final isSelected = followedSports.contains(sport);
        return _buildSportCard(sport, isSelected);
      },
    );
  }

  Widget _buildSportCard(SportType sport, bool isSelected) {
    return GestureDetector(
      onTap: () {
        ref.read(athleteProvider.notifier).toggleFollowedSport(sport);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected
              ? sport.primaryColor.withValues(alpha: 0.15)
              : AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? sport.primaryColor : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sport.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    spreadRadius: 1,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // 배경 아이콘
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(
                sport.iconData,
                size: 56,
                color: (isSelected ? sport.primaryColor : AppColors.textMuted)
                    .withValues(alpha: 0.12),
              ),
            ),
            // 메인 콘텐츠
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(sport.icon, style: const TextStyle(fontSize: 32)),
                  const SizedBox(height: 8),
                  Text(
                    sport.displayName,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontSize: 14,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // 체크 표시
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: sport.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 14,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════
  // Tab 1: 내 선수 픽업 (풀와이드 카드 리스트)
  // ═══════════════════════════════════════════

  Widget _buildAthletePickupList() {
    final allAthletes = ref.watch(allAthletesProvider);
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);
    final favoriteIds = favoriteAthletes.map((a) => a.id).toSet();
    final followedSports = ref.watch(followedSportsProvider);

    // 필터 적용
    List<Athlete> filtered;
    if (_filterSport != null) {
      filtered =
          allAthletes.where((a) => a.sport == _filterSport).toList();
    } else if (followedSports.isNotEmpty) {
      filtered = allAthletes
          .where((a) => followedSports.contains(a.sport))
          .toList();
    } else {
      filtered = allAthletes;
    }

    if (filtered.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.search_off,
                size: 48, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            Text(
              _filterSport != null
                  ? '${_filterSport!.displayName} 종목의 선수가 없습니다'
                  : '관심 종목을 먼저 선택해주세요',
              style: const TextStyle(
                color: AppColors.textMuted,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filtered.length,
      itemBuilder: (context, index) {
        final athlete = filtered[index];
        final isFavorite = favoriteIds.contains(athlete.id);
        return _buildAthleteCard(athlete, isFavorite);
      },
    );
  }

  Widget _buildAthleteCard(Athlete athlete, bool isFavorite) {
    return GestureDetector(
      onTap: () {
        if (isFavorite) {
          ref.read(athleteProvider.notifier).removeFavorite(athlete.id);
        } else {
          ref.read(athleteProvider.notifier).addFavorite(athlete);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFavorite
                ? athlete.teamColor.withValues(alpha: 0.6)
                : AppColors.border,
            width: isFavorite ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Row(
                children: [
                  // ── 왼쪽: 선수 비주얼 영역 ──
                  _buildPlayerVisual(athlete),

                  // ── 중앙: 선수 정보 ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 영문 이름 + 한글 이름
                          Text(
                            '${athlete.name.split(' ').first}-${athlete.name.split(' ').last} ${athlete.lastName.toUpperCase()}',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            athlete.nameKr,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // 스탯
                          Text(
                            athlete.statSummary,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // 시즌평점
                          Row(
                            children: [
                              const Text(
                                '시즌평점 ',
                                style: TextStyle(
                                  color: AppColors.textMuted,
                                  fontSize: 11,
                                ),
                              ),
                              Text(
                                _getAthleteRating(athlete),
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ── 오른쪽: 팀 정보 ──
                  _buildTeamInfo(athlete),
                ],
              ),

              // 체크마크
              if (isFavorite)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 선수 왼쪽 비주얼 (팀컬러 + 등번호 + 아이콘) ──
  Widget _buildPlayerVisual(Athlete athlete) {
    return Container(
      width: 90,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            athlete.teamColor,
            athlete.teamColor.withValues(alpha: 0.6),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 배경 종목 아이콘
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              athlete.sport.iconData,
              size: 64,
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          // 종목 아이콘 (중앙)
          Center(
            child: Text(
              athlete.sport.icon,
              style: const TextStyle(fontSize: 32),
            ),
          ),
          // 종목 뱃지
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${athlete.sport.icon} ${athlete.sport.englishName.toUpperCase()}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 8,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          // 선수 이름 (하단)
          Positioned(
            bottom: 8,
            left: 8,
            right: 4,
            child: Text(
              athlete.nameKr,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: Colors.black54,
                    blurRadius: 4,
                  ),
                ],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── 오른쪽 팀 정보 ──
  Widget _buildTeamInfo(Athlete athlete) {
    // 팀 이니셜
    final teamInitial = athlete.team.isNotEmpty
        ? athlete.team.substring(0, athlete.team.length >= 3 ? 3 : athlete.team.length)
        : '?';

    return Container(
      width: 64,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 팀 아이콘 (이니셜)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: athlete.teamColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: athlete.teamColor.withValues(alpha: 0.4),
                width: 1.5,
              ),
            ),
            child: Center(
              child: Text(
                teamInitial,
                style: TextStyle(
                  color: athlete.teamColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          // 팀 이름
          Text(
            athlete.team,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 2),
          // 리그
          Text(
            _getLeagueName(athlete),
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 8,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════
  // 헬퍼 메서드
  // ═══════════════════════════════════════════

  String _getAthleteRating(Athlete athlete) {
    switch (athlete.sport) {
      case SportType.football:
        return (athlete.rating ?? 0).toStringAsFixed(1);
      case SportType.baseball:
        return (athlete.battingAvg != null)
            ? '.${(athlete.battingAvg! * 1000).toInt()}'
            : '-';
      case SportType.badminton:
      case SportType.swimming:
      case SportType.golf:
        return '${athlete.worldRanking ?? '-'}위';
      case SportType.basketball:
        return '${athlete.stats['points'] ?? '-'}';
    }
  }

  String _getLeagueName(Athlete athlete) {
    switch (athlete.sport) {
      case SportType.football:
        if (athlete.team.contains('Paris') || athlete.team.contains('PSG')) {
          return 'Ligue 1';
        }
        if (athlete.team.contains('Tottenham')) return 'Premier League';
        if (athlete.team.contains('Bayern')) return 'Bundesliga';
        if (athlete.team.contains('LAFC')) return 'MLS';
        return 'League';
      case SportType.baseball:
        return 'MLB';
      case SportType.badminton:
        return 'BWF Tour';
      case SportType.swimming:
        return 'World Aquatics';
      case SportType.golf:
        return 'LPGA Tour';
      case SportType.basketball:
        return 'KBL';
    }
  }
}
