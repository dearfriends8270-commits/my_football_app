import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/theme_provider.dart';
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
      backgroundColor: const Color(0xFF0A0A0A),
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
                  color: _currentStep >= 1 ? const Color(0xFF4F46E5) : Colors.grey[700],
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
        color: isActive ? const Color(0xFF4F46E5) : Colors.grey[700],
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
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.3,
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
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -4.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isSelected
                ? [sport.primaryColor, sport.primaryColor.withOpacity(0.7)]
                : [Colors.grey[850]!, Colors.grey[900]!],
          ),
          border: Border.all(
            color: isSelected ? sport.primaryColor : Colors.grey[700]!,
            width: isSelected ? 3 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sport.primaryColor.withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            // 배경 아이콘
            Positioned(
              right: -10,
              bottom: -10,
              child: Icon(
                sport.iconData,
                size: 80,
                color: Colors.white.withOpacity(0.1),
              ),
            ),

            // 내용
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        sport.icon,
                        style: const TextStyle(fontSize: 36),
                      ),
                      const Spacer(),
                      if (isSelected)
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check,
                            size: 16,
                            color: sport.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    sport.displayName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    sport.englishName,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.6),
                      letterSpacing: 1,
                    ),
                  ),
                ],
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
            const Color(0xFF0A0A0A).withOpacity(0.9),
            const Color(0xFF0A0A0A),
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
                  ? const Color(0xFF4F46E5)
                  : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isEnabled ? 8 : 0,
              shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
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

        // 선수 그리드
        Expanded(
          child: _buildMasonryGrid(filteredAthletes),
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
              color: sport.primaryColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: sport.primaryColor.withOpacity(0.5),
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

  Widget _buildMasonryGrid(List<Athlete> athletes) {
    if (athletes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 60, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              '선택된 종목에 선수가 없습니다',
              style: TextStyle(color: Colors.grey[500], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: _buildMasonryRows(athletes),
      ),
    );
  }

  List<Widget> _buildMasonryRows(List<Athlete> athletes) {
    final List<Widget> rows = [];
    int index = 0;

    while (index < athletes.length) {
      // 패턴: 2열, 1열(큰 카드), 2열 반복
      final rowPattern = (rows.length % 3);

      if (rowPattern == 1 && index < athletes.length) {
        // 1열 큰 카드
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAthleteCard(athletes[index], isLarge: true),
          ),
        );
        index++;
      } else if (index + 1 < athletes.length) {
        // 2열 작은 카드
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Expanded(
                  child: _buildAthleteCard(athletes[index], isLarge: false),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildAthleteCard(athletes[index + 1], isLarge: false),
                ),
              ],
            ),
          ),
        );
        index += 2;
      } else if (index < athletes.length) {
        // 마지막 홀수 카드
        rows.add(
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _buildAthleteCard(athletes[index], isLarge: true),
          ),
        );
        index++;
      }
    }

    return rows;
  }

  Widget _buildAthleteCard(Athlete athlete, {required bool isLarge}) {
    final isSelected = _selectedAthleteIds.contains(athlete.id);
    final cardHeight = isLarge ? 220.0 : 180.0;

    return GestureDetector(
      onTap: () => _toggleAthleteSelection(athlete),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        height: cardHeight,
        transform: Matrix4.identity()
          ..translate(0.0, isSelected ? -8.0 : 0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? athlete.teamColor : Colors.transparent,
            width: 3,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: athlete.teamColor.withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 배경 그라데이션
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      athlete.teamColor.withOpacity(0.8),
                      athlete.teamColor,
                      athlete.sport.primaryColor,
                    ],
                  ),
                ),
              ),

              // 선수 실루엣/그래픽 영역 (플레이스홀더)
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(
                  athlete.sport.iconData,
                  size: isLarge ? 150 : 100,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),

              // 상단 태그
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        athlete.sport.icon,
                        style: const TextStyle(fontSize: 12),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${athlete.sport.englishName} · ${athlete.team.split(' ').first}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // 선택 체크 표시
              if (isSelected)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.check,
                      size: 16,
                      color: athlete.teamColor,
                    ),
                  ),
                ),

              // 하단 선수 정보
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        athlete.lastName,
                        style: TextStyle(
                          fontSize: isLarge ? 32 : 24,
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
                          fontSize: isLarge ? 14 : 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        athlete.statSummary,
                        style: TextStyle(
                          fontSize: isLarge ? 12 : 10,
                          color: Colors.white60,
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
            const Color(0xFF0A0A0A).withOpacity(0.9),
            const Color(0xFF0A0A0A),
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
                  ? const Color(0xFF4F46E5)
                  : Colors.grey[800],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: isEnabled ? 8 : 0,
              shadowColor: const Color(0xFF4F46E5).withOpacity(0.5),
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
