import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/theme_provider.dart';
import '../onboarding/pick_your_star_screen.dart';

/// 선수 관리 화면 - 바둑판 레이아웃으로 변경
class PlayerManageScreen extends ConsumerStatefulWidget {
  const PlayerManageScreen({super.key});

  @override
  ConsumerState<PlayerManageScreen> createState() => _PlayerManageScreenState();
}

class _PlayerManageScreenState extends ConsumerState<PlayerManageScreen> {
  SportType? _filterSport;
  bool _showAllAthletes = false; // 전체보기 / 종목별보기 토글

  @override
  Widget build(BuildContext context) {
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);
    final allAthletes = ref.watch(allAthletesProvider);
    final themeState = ref.watch(appThemeProvider);
    final primaryColor = themeState.primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '내 선수 관리',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton.icon(
            onPressed: () => _navigateToPickStar(context),
            icon: const Icon(Icons.add, color: Colors.white, size: 20),
            label: const Text(
              '추가',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // 상단 필터 바
          _buildFilterBar(primaryColor),

          // 바둑판 선수 그리드
          Expanded(
            child: _showAllAthletes
                ? _buildAllAthletesGrid(allAthletes, favoriteAthletes, primaryColor)
                : _buildFavoriteAthletesGrid(favoriteAthletes, primaryColor),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // 전체보기 / 내 선수 토글
          Row(
            children: [
              Expanded(
                child: _buildToggleButton(
                  label: '내 선수',
                  icon: Icons.star,
                  isSelected: !_showAllAthletes,
                  color: primaryColor,
                  onTap: () {
                    setState(() {
                      _showAllAthletes = false;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildToggleButton(
                  label: '전체 선수',
                  icon: Icons.grid_view,
                  isSelected: _showAllAthletes,
                  color: primaryColor,
                  onTap: () {
                    setState(() {
                      _showAllAthletes = true;
                    });
                  },
                ),
              ),
            ],
          ),

          if (_showAllAthletes) ...[
            const SizedBox(height: 12),
            // 종목 필터
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildSportChip(null, '전체', '🌐', primaryColor),
                  ...SportType.values.map((sport) =>
                      _buildSportChip(sport, sport.displayName, sport.icon, primaryColor)),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String label,
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSportChip(SportType? sport, String label, String icon, Color primaryColor) {
    final isSelected = _filterSport == sport;
    return GestureDetector(
      onTap: () {
        setState(() {
          _filterSport = sport;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? primaryColor : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.grey[300]!,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 내 선수 바둑판 그리드
  Widget _buildFavoriteAthletesGrid(List<Athlete> athletes, Color primaryColor) {
    if (athletes.isEmpty) {
      return _buildEmptyState(primaryColor);
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: athletes.length + 1, // +1 for add button
      itemBuilder: (context, index) {
        if (index == athletes.length) {
          return _buildAddCard(primaryColor);
        }
        final athlete = athletes[index];
        return _buildAthleteGridCard(
          athlete: athlete,
          isFavorite: true,
          isPrimary: index == 0,
          primaryColor: primaryColor,
        );
      },
    );
  }

  /// 전체 선수 바둑판 그리드
  Widget _buildAllAthletesGrid(
    List<Athlete> allAthletes,
    List<Athlete> favorites,
    Color primaryColor,
  ) {
    final favoriteIds = favorites.map((a) => a.id).toSet();

    // 종목 필터 적용
    var filteredAthletes = _filterSport != null
        ? allAthletes.where((a) => a.sport == _filterSport).toList()
        : allAthletes;

    if (filteredAthletes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              '해당 종목의 선수가 없습니다',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: filteredAthletes.length,
      itemBuilder: (context, index) {
        final athlete = filteredAthletes[index];
        final isFavorite = favoriteIds.contains(athlete.id);
        return _buildAthleteGridCard(
          athlete: athlete,
          isFavorite: isFavorite,
          isPrimary: false,
          primaryColor: primaryColor,
        );
      },
    );
  }

  /// 바둑판 선수 카드
  Widget _buildAthleteGridCard({
    required Athlete athlete,
    required bool isFavorite,
    required bool isPrimary,
    required Color primaryColor,
  }) {
    return GestureDetector(
      onTap: () => _toggleFavorite(athlete, isFavorite),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isFavorite ? athlete.teamColor : Colors.grey[200]!,
            width: isFavorite ? 2 : 1,
          ),
          boxShadow: isFavorite
              ? [
                  BoxShadow(
                    color: athlete.teamColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          children: [
            // 메인 콘텐츠
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 종목 아이콘
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: athlete.teamColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: athlete.teamColor.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      athlete.sport.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // 이름
                Text(
                  athlete.nameKr,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isFavorite ? athlete.teamColor : Colors.grey[800],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                // 팀
                Text(
                  athlete.team,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[500],
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),

            // 체크 표시 (즐겨찾기)
            if (isFavorite)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: athlete.teamColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),

            // 대표 배지
            if (isPrimary)
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '대표',
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  /// 추가 버튼 카드
  Widget _buildAddCard(Color primaryColor) {
    return GestureDetector(
      onTap: () => _navigateToPickStar(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                color: primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '선수 추가',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(Color primaryColor) {
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
            '아직 등록된 선수가 없어요',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '응원할 선수를 추가해보세요!',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _navigateToPickStar(context),
            icon: const Icon(Icons.add),
            label: const Text('선수 추가하기'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _toggleFavorite(Athlete athlete, bool currentlyFavorite) {
    if (currentlyFavorite) {
      _confirmRemove(context, athlete);
    } else {
      _addAthlete(athlete);
    }
  }

  void _addAthlete(Athlete athlete) {
    ref.read(favoriteAthletesNotifierProvider).addFavorite(athlete);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${athlete.nameKr}을(를) 추가했습니다'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: '취소',
          onPressed: () {
            ref.read(favoriteAthletesNotifierProvider).removeFavorite(athlete.id);
          },
        ),
      ),
    );
  }

  void _confirmRemove(BuildContext context, Athlete athlete) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('선수 삭제'),
        content: Text('${athlete.nameKr}을(를) 내 선수 목록에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(favoriteAthletesNotifierProvider).removeFavorite(athlete.id);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${athlete.nameKr}을(를) 삭제했습니다'),
                  duration: const Duration(seconds: 2),
                  behavior: SnackBarBehavior.floating,
                  action: SnackBarAction(
                    label: '취소',
                    onPressed: () {
                      ref.read(favoriteAthletesNotifierProvider).addFavorite(athlete);
                    },
                  ),
                ),
              );
            },
            child: const Text('삭제', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _navigateToPickStar(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const PickYourStarScreen(),
      ),
    );
  }
}
