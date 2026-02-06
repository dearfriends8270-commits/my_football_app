import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/athlete_provider.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../models/talk_post.dart';
import '../../utils/app_colors.dart';
import '../../utils/auth_guard.dart';
import 'talk_write_screen.dart';

/// 전체 커뮤니티 화면 (홈 탭용) - 소식/선수 페이지 스타일 헤더 + 카테고리 탭 통합
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAthleteId;
  String? _selectedAthleteName;
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  SportType? _filterSport;

  final List<TalkCategory> _categories = TalkCategory.values;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _categories.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final athleteState = ref.watch(athleteProvider);
    final favoriteAthletes = athleteState.favoriteAthletes;
    final selectedAthlete = athleteState.selectedAthlete ??
        (favoriteAthletes.isNotEmpty ? favoriteAthletes.first : null);
    final followedSports = ref.watch(followedSportsProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 상단 헤더: 타이틀 + 검색
            _buildTopHeader(),

            const SizedBox(height: 12),

            // 선수 선택기: < 이강인 > 편집
            if (favoriteAthletes.isNotEmpty)
              _buildAthleteSelector(favoriteAthletes, selectedAthlete),

            const SizedBox(height: 14),

            // 스포츠 필터 바
            _buildSportFilterBar(followedSports),

            const SizedBox(height: 10),

            // 검색바 (토글)
            if (_isSearching) _buildSearchBar(),

            // 카테고리 탭 바 (종목 필터 바 바로 아래)
            _buildCategoryTabBar(),

            // 탭 콘텐츠
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: _categories.map((category) {
                  return _buildPostList(category);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
      // 글쓰기 FAB
      floatingActionButton: Container(
        margin: const EdgeInsets.only(bottom: 70),
        child: FloatingActionButton.extended(
          onPressed: () {
            if (!AuthGuard.checkAuth(context, ref)) return;
            if (_selectedAthleteId == null) {
              _showSelectAthleteDialog(favoriteAthletes);
            } else {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TalkWriteScreen(
                    playerId: _selectedAthleteId!,
                    playerName: _selectedAthleteName ?? '',
                  ),
                ),
              );
            }
          },
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.edit, color: Colors.white, size: 18),
          label: const Text(
            '글쓰기',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────
  // 상단 헤더
  // ─────────────────────────────────────────

  Widget _buildTopHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          // 뒤로가기 아이콘 (장식)
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.backgroundCard,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.border.withValues(alpha: 0.5),
              ),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new,
              color: AppColors.textSecondary,
              size: 16,
            ),
          ),

          const Spacer(),

          // "톡" 타이틀
          const Text(
            '톡',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),

          const Spacer(),

          // 검색 버튼
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchQuery = '';
                  _searchController.clear();
                }
              });
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _isSearching
                    ? AppColors.primary.withValues(alpha: 0.2)
                    : AppColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isSearching
                      ? AppColors.primary.withValues(alpha: 0.5)
                      : AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: Icon(
                _isSearching ? Icons.search_off : Icons.search,
                color: _isSearching ? AppColors.primary : AppColors.textSecondary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 선수 선택기
  // ─────────────────────────────────────────

  Widget _buildAthleteSelector(List<Athlete> favorites, Athlete? selected) {
    final currentIndex = selected != null
        ? favorites.indexWhere((a) => a.id == selected.id)
        : 0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 왼쪽 화살표
          GestureDetector(
            onTap: () {
              if (favorites.length <= 1) return;
              final prevIndex =
                  (currentIndex - 1 + favorites.length) % favorites.length;
              ref
                  .read(athleteProvider.notifier)
                  .selectAthlete(favorites[prevIndex]);
              setState(() {
                _selectedAthleteId = favorites[prevIndex].id;
                _selectedAthleteName = favorites[prevIndex].nameKr;
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.chevron_left,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 16),

          // 선수 이름
          GestureDetector(
            onTap: () {
              // 전체 <-> 선수 필터 토글
              if (_selectedAthleteId != null) {
                setState(() {
                  _selectedAthleteId = null;
                  _selectedAthleteName = null;
                });
              } else if (selected != null) {
                setState(() {
                  _selectedAthleteId = selected.id;
                  _selectedAthleteName = selected.nameKr;
                });
              }
            },
            child: Column(
              children: [
                Text(
                  _selectedAthleteId != null
                      ? (_selectedAthleteName ?? selected?.nameKr ?? '전체')
                      : (selected?.nameKr ?? '전체'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (_selectedAthleteId != null)
                  Text(
                    '선수 필터 적용 중',
                    style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // 오른쪽 화살표
          GestureDetector(
            onTap: () {
              if (favorites.length <= 1) return;
              final nextIndex = (currentIndex + 1) % favorites.length;
              ref
                  .read(athleteProvider.notifier)
                  .selectAthlete(favorites[nextIndex]);
              setState(() {
                _selectedAthleteId = favorites[nextIndex].id;
                _selectedAthleteName = favorites[nextIndex].nameKr;
              });
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: const Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ),
          ),

          const SizedBox(width: 12),

          // 편집 링크 → 선수 탭으로 이동
          GestureDetector(
            onTap: () {
              ref.read(mainTabIndexProvider.notifier).state = 1;
            },
            child: const Text(
              '편집',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                decoration: TextDecoration.underline,
                decorationColor: AppColors.primary,
              ),
            ),
          ),

          // 필터 해제 버튼
          if (_selectedAthleteId != null) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAthleteId = null;
                  _selectedAthleteName = null;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.live.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.live.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  '전체',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.live,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 스포츠 필터 바
  // ─────────────────────────────────────────

  Widget _buildSportFilterBar(Set<SportType> followedSports) {
    final sportsList = followedSports.toList();
    final allItems = <SportType?>[null, ...sportsList];

    Widget buildTab(SportType? sport, bool isSelected) {
      return GestureDetector(
        onTap: () {
          setState(() {
            _filterSport = sport;
          });
        },
        child: Container(
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
              Text(sport?.icon ?? '🌐', style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 4),
              Text(
                sport?.displayName ?? '전체',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (allItems.length <= 4) {
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
          children: allItems.map((sport) {
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
        itemCount: allItems.length,
        itemBuilder: (context, index) {
          final sport = allItems[index];
          final isSelected = _filterSport == sport;
          return buildTab(sport, isSelected);
        },
      ),
    );
  }

  // ─────────────────────────────────────────
  // 검색바
  // ─────────────────────────────────────────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.backgroundCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border.withValues(alpha: 0.5),
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: '게시글 검색...',
                  hintStyle: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppColors.textMuted,
                    size: 20,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: AppColors.textMuted,
                            size: 18,
                          ),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                              _searchController.clear();
                            });
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Text(
              '취소',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 카테고리 탭 바
  // ─────────────────────────────────────────

  Widget _buildCategoryTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundCard.withValues(alpha: 0.5),
        border: Border(
          bottom: BorderSide(
            color: AppColors.border.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: AppColors.primary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.primary,
        indicatorWeight: 2.5,
        indicatorSize: TabBarIndicatorSize.label,
        tabAlignment: TabAlignment.start,
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        dividerColor: Colors.transparent,
        tabs: _categories.map((category) {
          return Tab(
            height: 40,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji, style: const TextStyle(fontSize: 13)),
                const SizedBox(width: 4),
                Text(category.displayName),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ─────────────────────────────────────────
  // 게시물 목록
  // ─────────────────────────────────────────

  Widget _buildPostList(TalkCategory category) {
    var posts = _getSamplePosts();

    // 카테고리 필터
    if (category != TalkCategory.all) {
      posts = posts.where((p) => p.category == category).toList();
    }

    // 선수 필터
    if (_selectedAthleteId != null) {
      posts = posts.where((p) => p.playerId == _selectedAthleteId).toList();
    }

    // 스포츠 필터
    if (_filterSport != null) {
      final athletes = ref.read(allAthletesProvider);
      final sportAthleteIds = athletes
          .where((a) => a.sport == _filterSport)
          .map((a) => a.id)
          .toSet();
      posts = posts.where((p) => sportAthleteIds.contains(p.playerId)).toList();
    }

    // 검색어 필터
    if (_searchQuery.isNotEmpty) {
      posts = posts
          .where((p) =>
              p.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.content.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              p.tags.any((tag) =>
                  tag.toLowerCase().contains(_searchQuery.toLowerCase())))
          .toList();
    }

    if (posts.isEmpty) {
      return _buildEmptyState(category);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.backgroundCard,
      onRefresh: () async {
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          return _buildPostCard(posts[index]);
        },
      ),
    );
  }

  Widget _buildEmptyState(TalkCategory category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 48),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedAthleteId != null
                ? '해당 선수의 ${category.displayName} 게시물이 없어요'
                : '${category.displayName} 게시물이 없어요',
            style: const TextStyle(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '첫 번째 글을 작성해보세요!',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMuted,
            ),
          ),
          if (_selectedAthleteId != null) ...[
            const SizedBox(height: 16),
            GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAthleteId = null;
                  _selectedAthleteName = null;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: const Text(
                  '전체 보기',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 게시물 카드
  // ─────────────────────────────────────────

  Widget _buildPostCard(TalkPost post) {
    final athletes = ref.watch(favoriteAthletesProvider);
    final athlete =
        athletes.where((a) => a.id == post.playerId).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.backgroundCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withValues(alpha: 0.4),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            // TODO: 게시물 상세 페이지 이동
          },
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더: 아바타 + 이름 + 선수/카테고리 + 시간 + 뱃지
                Row(
                  children: [
                    // 아바타
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            (athlete?.teamColor ?? AppColors.primary)
                                .withValues(alpha: 0.6),
                            (athlete?.teamColor ?? AppColors.primary)
                                .withValues(alpha: 0.3),
                          ],
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          post.authorName.isNotEmpty
                              ? post.authorName[0]
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                post.authorName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              if (athlete != null) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: athlete.teamColor
                                        .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    athlete.nameKr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: athlete.teamColor
                                          .withValues(alpha: 0.9),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.category.displayName,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    color: AppColors.primaryLight,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(post.createdAt),
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // HOT / 고정 뱃지
                    if (post.isHot)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.live.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 10)),
                            SizedBox(width: 2),
                            Text(
                              'HOT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.live,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (post.isPinned)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('📌', style: TextStyle(fontSize: 10)),
                            SizedBox(width: 2),
                            Text(
                              '고정',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 10),

                // 태그
                if (post.tags.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: post.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#$tag',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.primaryLight,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                // 제목
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 6),

                // 내용 미리보기
                Text(
                  post.content,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 이미지 있으면 표시
                if (post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      height: 140,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundCardLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.image_outlined,
                          size: 36,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 10),

                // 디바이더
                Container(
                  height: 1,
                  color: AppColors.border.withValues(alpha: 0.3),
                ),

                const SizedBox(height: 8),

                // 푸터: 좋아요, 댓글, 조회수
                Row(
                  children: [
                    _buildStatItem(
                        Icons.favorite_border, post.likeCount.toString()),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.chat_bubble_outline,
                        post.commentCount.toString()),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.visibility_outlined,
                        post.viewCount.toString()),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String count) {
    return Row(
      children: [
        Icon(icon, size: 15, color: AppColors.textMuted),
        const SizedBox(width: 4),
        Text(
          count,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textMuted,
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────
  // 유틸
  // ─────────────────────────────────────────

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }

  void _showSelectAthleteDialog(List<Athlete> athletes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: AppColors.border.withValues(alpha: 0.5),
          ),
        ),
        title: const Text(
          '선수 선택',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '글을 작성할 선수를 선택해주세요.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            ...athletes.map((athlete) {
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: AppColors.border.withValues(alpha: 0.4),
                  ),
                ),
                child: ListTile(
                  leading: Text(
                    athlete.sport.icon,
                    style: const TextStyle(fontSize: 22),
                  ),
                  title: Text(
                    athlete.nameKr,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    athlete.team,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => TalkWriteScreen(
                          playerId: athlete.id,
                          playerName: athlete.nameKr,
                        ),
                      ),
                    );
                  },
                ),
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              '취소',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────
  // 샘플 데이터
  // ─────────────────────────────────────────

  List<TalkPost> _getSamplePosts() {
    return [
      TalkPost(
        id: '1',
        authorId: 'user1',
        authorName: '강인이팬',
        playerId: 'lee_kangin',
        category: TalkCategory.rumor,
        title: '라리가 빅클럽에서 강인이 관심 보인다는 루머!',
        content:
            '오늘 스페인 매체에서 나온 기사인데, 라리가 빅클럽에서 관심을 보이고 있다는 소식이에요. 여름 이적 시장에 영입할 수도 있다고 하네요.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 156,
        commentCount: 42,
        viewCount: 1203,
        isHot: true,
        tags: ['이적루머', '라리가'],
      ),
      TalkPost(
        id: '2',
        authorId: 'user2',
        authorName: 'PSG_Korea',
        playerId: 'lee_kangin',
        category: TalkCategory.liveChat,
        title: '[경기 실황] PSG vs OM 실시간 채팅방',
        content: '오늘 경기 같이 봐요! 강인이 선발 출전 확정!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likeCount: 89,
        commentCount: 234,
        viewCount: 567,
        isPinned: true,
        tags: ['실시간', '클라시크'],
      ),
      TalkPost(
        id: '3',
        authorId: 'user3',
        authorName: '팬아트장인',
        playerId: 'lee_kangin',
        category: TalkCategory.fanArt,
        title: '강인이 팬아트 그려봤어요 (직접 그림)',
        content: '3시간 동안 그렸습니다. 피드백 환영해요!',
        imageUrls: ['https://example.com/fanart1.jpg'],
        createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        likeCount: 312,
        commentCount: 28,
        viewCount: 890,
        tags: ['팬아트', '일러스트'],
      ),
      TalkPost(
        id: '4',
        authorId: 'user4',
        authorName: '뉴스봇',
        playerId: 'lee_kangin',
        category: TalkCategory.news,
        title: '[공식] 강인이 이번주 최우수 선수 선정!',
        content:
            '리그앙 공식 발표에 따르면 이강인 선수가 이번 주 최우수 선수로 선정되었습니다.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likeCount: 567,
        commentCount: 89,
        viewCount: 2341,
        tags: ['공식', 'POTW'],
      ),
      TalkPost(
        id: '5',
        authorId: 'user5',
        authorName: '축구초보',
        playerId: 'lee_kangin',
        category: TalkCategory.question,
        title: '강인이 유니폼 사이즈 질문이요',
        content: '처음 유니폼 사려고 하는데 170/65 체형이면 M이 맞을까요?',
        createdAt: DateTime.now().subtract(const Duration(hours: 12)),
        likeCount: 12,
        commentCount: 15,
        viewCount: 89,
        tags: ['유니폼', '질문'],
      ),
      TalkPost(
        id: '6',
        authorId: 'user6',
        authorName: '강인매니아',
        playerId: 'lee_kangin',
        category: TalkCategory.free,
        title: '오늘도 강인이 덕질하는 하루',
        content: '출근길에 강인이 영상 보면서 힐링하고 왔어요 ㅎㅎ',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        likeCount: 34,
        commentCount: 8,
        viewCount: 123,
        tags: ['일상'],
      ),
      TalkPost(
        id: '7',
        authorId: 'user7',
        authorName: '손웹',
        playerId: 'son_heungmin',
        category: TalkCategory.news,
        title: '손흥민 오늘 경기 MOM 선정!',
        content: '2골 1도움으로 팀 승리 이끌었네요. 역시 캡틴!',
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
        likeCount: 234,
        commentCount: 67,
        viewCount: 1890,
        isHot: true,
        tags: ['토트넘', 'MOM'],
      ),
      TalkPost(
        id: '8',
        authorId: 'user8',
        authorName: '자이언츠팬',
        playerId: 'lee_junghoo',
        category: TalkCategory.free,
        title: '이정후 오늘 안타 2개 쳤네요!',
        content: '시즌 타율 3할 유지 중! 역시 우리 정후',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        likeCount: 78,
        commentCount: 34,
        viewCount: 567,
        tags: ['MLB', '샌프란시스코'],
      ),
      TalkPost(
        id: '9',
        authorId: 'user9',
        authorName: '배드민턴매니아',
        playerId: 'an_seyoung',
        category: TalkCategory.liveChat,
        title: '안세영 결승전 응원합시다!',
        content: 'BWF 슈퍼500 결승 진출! 우승 기원!',
        createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        likeCount: 123,
        commentCount: 45,
        viewCount: 789,
        isHot: true,
        tags: ['배드민턴', 'BWF'],
      ),
    ];
  }
}
