import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/theme_provider.dart';
import '../../utils/app_colors.dart';
import '../main_screen.dart';

class PickYourStarScreen extends ConsumerStatefulWidget {
  final bool isGuestMode;

  const PickYourStarScreen({
    super.key,
    this.isGuestMode = false,
  });

  @override
  ConsumerState<PickYourStarScreen> createState() => _PickYourStarScreenState();
}

class _PickYourStarScreenState extends ConsumerState<PickYourStarScreen>
    with TickerProviderStateMixin {
  // 단계: 0 = 종목 선택, 1 = 선수 선택
  int _currentStep = 0;

  final Set<SportType> _selectedSports = {};
  final Set<String> _selectedAthleteIds = {};

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    _fadeController.forward();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleSportSelection(SportType sport) {
    setState(() {
      if (_selectedSports.contains(sport)) {
        _selectedSports.remove(sport);
      } else {
        _selectedSports.add(sport);
      }
    });
  }

  void _toggleAthleteSelection(Athlete athlete) {
    setState(() {
      if (_selectedAthleteIds.contains(athlete.id)) {
        _selectedAthleteIds.remove(athlete.id);
      } else {
        _selectedAthleteIds.add(athlete.id);
      }
    });
  }

  void _goToNextStep() {
    if (_selectedSports.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1개의 종목을 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _currentStep = 1;
    });
    _pageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousStep() {
    setState(() {
      _currentStep = 0;
    });
    _pageController.animateToPage(
      0,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _onStartPressed() {
    if (_selectedAthleteIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('최소 1명의 선수를 선택해주세요'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // 선택된 선수들 가져오기
    final athletes = ref.read(allAthletesProvider);
    final selectedAthletes = athletes
        .where((a) => _selectedAthleteIds.contains(a.id))
        .toList();

    // 즐겨찾기 설정
    ref.read(athleteProvider.notifier).setFavoriteAthletes(selectedAthletes);

    // 첫 번째 선수의 테마 적용
    if (selectedAthletes.isNotEmpty) {
      ref.read(appThemeProvider.notifier).setThemeByAthlete(selectedAthletes.first);
    }

    // 메인 화면으로 이동
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // 상단 진행 표시
              _buildProgressIndicator(),

              // 페이지뷰
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildSportSelectionPage(),
                    _buildAthleteSelectionPage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          // 뒤로가기 버튼 (2단계에서만)
          if (_currentStep == 1)
            IconButton(
              onPressed: _goToPreviousStep,
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            )
          else
            const SizedBox(width: 48),

          // 진행 바
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildStepDot(0),
                Container(
                  width: 40,
                  height: 2,
                  color: _currentStep >= 1 ? AppColors.primary : Colors.grey[700],
                ),
                _buildStepDot(1),
              ],
            ),
          ),

          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildStepDot(int step) {
    final isActive = _currentStep >= step;
    final isCurrent = _currentStep == step;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isCurrent ? 12 : 10,
      height: isCurrent ? 12 : 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? AppColors.primary : Colors.grey[700],
        border: isCurrent
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
    );
  }

  // ===== 1단계: 종목 선택 =====
  Widget _buildSportSelectionPage() {
    return Column(
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🎯', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Text(
                    '관심 종목 선택',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '응원할 종목을 선택하세요 (복수 선택 가능)',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        ),

        // 종목 그리드
        Expanded(
          child: _buildSportGrid(),
        ),

        // 다음 버튼
        _buildNextButton(),
      ],
    );
  }

  Widget _buildSportGrid() {
    final sports = SportType.values;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.0,
        ),
        itemCount: sports.length,
        itemBuilder: (context, index) {
          return _buildSportCard(sports[index]);
        },
      ),
    );
  }

  Widget _buildSportCard(SportType sport) {
    final isSelected = _selectedSports.contains(sport);

    return GestureDetector(
      onTap: () => _toggleSportSelection(sport),
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

  Widget _buildNextButton() {
    final selectedCount = _selectedSports.length;
    final isEnabled = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withValues(alpha: 0.9),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isEnabled ? _goToNextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? AppColors.primary
                  : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isEnabled ? 8 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  selectedCount > 0
                      ? '다음 ($selectedCount개 종목 선택됨)'
                      : '종목을 선택해주세요',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.arrow_forward, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===== 2단계: 선수 선택 =====
  Widget _buildAthleteSelectionPage() {
    final athletes = ref.watch(allAthletesProvider);

    // 선택된 종목의 선수만 필터링
    final filteredAthletes = athletes
        .where((a) => _selectedSports.contains(a.sport))
        .toList();

    return Column(
      children: [
        // 헤더
        Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text('🌟', style: TextStyle(fontSize: 32)),
                  SizedBox(width: 12),
                  Text(
                    'Pick Your Star',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '응원할 선수를 선택하세요 (복수 선택 가능)',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.grey[400],
                ),
              ),
              const SizedBox(height: 12),
              // 선택된 종목 태그
              _buildSelectedSportsTags(),
            ],
          ),
        ),

        // 선수 리스트
        Expanded(
          child: _buildAthleteList(filteredAthletes),
        ),

        // 시작 버튼
        _buildStartButton(),
      ],
    );
  }

  Widget _buildSelectedSportsTags() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _selectedSports.map((sport) {
          return Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: sport.primaryColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sport.primaryColor.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(sport.icon, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  sport.displayName,
                  style: TextStyle(
                    fontSize: 12,
                    color: sport.primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAthleteList(List<Athlete> athletes) {
    if (athletes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 60, color: AppColors.textMuted.withValues(alpha: 0.5)),
            const SizedBox(height: 16),
            const Text(
              '선택된 종목에 선수가 없습니다',
              style: TextStyle(color: AppColors.textMuted, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: athletes.length,
      itemBuilder: (context, index) {
        final athlete = athletes[index];
        return _buildAthleteCard(athlete);
      },
    );
  }

  Widget _buildAthleteCard(Athlete athlete) {
    final isSelected = _selectedAthleteIds.contains(athlete.id);

    return GestureDetector(
      onTap: () => _toggleAthleteSelection(athlete),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        height: 120,
        decoration: BoxDecoration(
          color: AppColors.backgroundCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? athlete.teamColor.withValues(alpha: 0.6)
                : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Stack(
            children: [
              Row(
                children: [
                  // ── 왼쪽: 선수 비주얼 영역 ──
                  Container(
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
                        Positioned(
                          right: -10,
                          bottom: -10,
                          child: Icon(
                            athlete.sport.iconData,
                            size: 64,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                        Center(
                          child: Text(
                            athlete.sport.icon,
                            style: const TextStyle(fontSize: 32),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
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
                                Shadow(color: Colors.black54, blurRadius: 4),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 중앙: 선수 정보 ──
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                          Text(
                            athlete.statSummary,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
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
                  Container(
                    width: 64,
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
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
                              athlete.team.length >= 3
                                  ? athlete.team.substring(0, 3)
                                  : athlete.team,
                              style: TextStyle(
                                color: athlete.teamColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
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
                  ),
                ],
              ),

              // 체크마크
              if (isSelected)
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

  Widget _buildStartButton() {
    final selectedCount = _selectedAthleteIds.length;
    final isEnabled = selectedCount > 0;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            AppColors.background.withValues(alpha: 0.9),
            AppColors.background,
          ],
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: isEnabled ? _onStartPressed : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isEnabled
                  ? AppColors.primary
                  : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isEnabled ? 8 : 0,
              shadowColor: AppColors.primary.withValues(alpha: 0.5),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.rocket_launch, size: 20),
                const SizedBox(width: 8),
                Text(
                  selectedCount > 0
                      ? '시작하기 ($selectedCount명 선택됨)'
                      : '선수를 선택해주세요',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
