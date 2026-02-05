import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/theme_provider.dart';
import '../../providers/athlete_provider.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../models/talk_post.dart';
import '../../utils/auth_guard.dart';
import 'talk_write_screen.dart';

/// 전체 커뮤니티 화면 (홈 탭용) - 선수별 필터 + 카테고리 탭 통합
class CommunityScreen extends ConsumerStatefulWidget {
  const CommunityScreen({super.key});

  @override
  ConsumerState<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends ConsumerState<CommunityScreen>
    with SingleTickerProviderStateMixin {
  String? _selectedAthleteId; // null이면 전체
  String? _selectedAthleteName;
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // 카테고리 목록 (TalkCategory 기반)
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
    final themeState = ref.watch(appThemeProvider);
    final favoriteAthletes = ref.watch(favoriteAthletesProvider);

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          // 검색바 (선택적 표시)
          if (_isSearching) _buildSearchBar(themeState.primaryColor),

          // 선수 필터 슬라이더
          _buildAthleteFilter(favoriteAthletes, themeState.primaryColor),

          // 카테고리 탭 바
          _buildCategoryTabBar(themeState.primaryColor),

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
      // 글쓰기 FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 로그인 체크
          if (!AuthGuard.checkAuth(context, ref)) return;

          // 선수 선택 안 했으면 선수 선택 다이얼로그
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
        backgroundColor: themeState.primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          '글쓰기',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  /// 검색바
  Widget _buildSearchBar(Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: '게시글 검색...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          setState(() {
                            _searchQuery = '';
                            _searchController.clear();
                          });
                        },
                      )
                    : null,
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _isSearching = false;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 선수 필터 위젯
  Widget _buildAthleteFilter(List<Athlete> athletes, Color primaryColor) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.filter_list, size: 18, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '선수 필터',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[700],
                  ),
                ),
                const Spacer(),
                // 검색 버튼
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isSearching = true;
                    });
                  },
                  child: Icon(Icons.search, size: 22, color: Colors.grey[600]),
                ),
                if (_selectedAthleteId != null) ...[
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedAthleteId = null;
                        _selectedAthleteName = null;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '필터 해제',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.close, size: 14, color: Colors.grey[600]),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: athletes.length + 1, // +1 for "전체"
              itemBuilder: (context, index) {
                if (index == 0) {
                  // 전체 필터
                  final isSelected = _selectedAthleteId == null;
                  return _buildFilterChip(
                    label: '전체',
                    icon: '🌐',
                    isSelected: isSelected,
                    color: primaryColor,
                    onTap: () {
                      setState(() {
                        _selectedAthleteId = null;
                        _selectedAthleteName = null;
                      });
                    },
                  );
                }

                final athlete = athletes[index - 1];
                final isSelected = _selectedAthleteId == athlete.id;
                return _buildFilterChip(
                  label: athlete.nameKr,
                  icon: athlete.sport.icon,
                  isSelected: isSelected,
                  color: athlete.teamColor,
                  onTap: () {
                    // 선수 클릭 시 페이지 이동 없이 필터만 적용
                    setState(() {
                      _selectedAthleteId = athlete.id;
                      _selectedAthleteName = athlete.nameKr;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required String icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 카테고리 탭 바
  Widget _buildCategoryTabBar(Color primaryColor) {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: primaryColor,
        indicatorWeight: 3,
        tabAlignment: TabAlignment.start,
        tabs: _categories.map((category) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(category.emoji),
                const SizedBox(width: 4),
                Text(category.displayName),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPostList(TalkCategory category) {
    // 샘플 게시물 데이터
    var posts = _getSamplePosts();

    // 카테고리 필터
    if (category != TalkCategory.all) {
      posts = posts.where((p) => p.category == category).toList();
    }

    // 선수 필터 적용
    if (_selectedAthleteId != null) {
      posts = posts.where((p) => p.playerId == _selectedAthleteId).toList();
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
      onRefresh: () async {
        // TODO: 새로고침 로직
        await Future.delayed(const Duration(seconds: 1));
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
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
            style: const TextStyle(fontSize: 60),
          ),
          const SizedBox(height: 16),
          Text(
            _selectedAthleteId != null
                ? '해당 선수의 ${category.displayName} 게시물이 없어요'
                : '${category.displayName} 게시물이 없어요',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '첫 번째 글을 작성해보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
          if (_selectedAthleteId != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _selectedAthleteId = null;
                  _selectedAthleteName = null;
                });
              },
              child: const Text('전체 보기'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPostCard(TalkPost post) {
    // 선수 이름 가져오기
    final athletes = ref.watch(favoriteAthletesProvider);
    final athlete = athletes.where((a) => a.id == post.playerId).firstOrNull;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더
                Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey[200],
                      child: Text(
                        post.authorName.isNotEmpty
                            ? post.authorName[0]
                            : '?',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontWeight: FontWeight.bold,
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
                                  fontSize: 14,
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
                                    color: athlete.teamColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    athlete.nameKr,
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: athlete.teamColor,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.category.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _formatTime(post.createdAt),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (post.isHot)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('🔥', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              'HOT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.red,
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
                          color: Colors.amber.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('📌', style: TextStyle(fontSize: 12)),
                            SizedBox(width: 4),
                            Text(
                              '고정',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                // 태그
                if (post.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: post.tags.map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$tag',
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.blue,
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                if (post.tags.isNotEmpty) const SizedBox(height: 8),

                // 제목
                Text(
                  post.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 8),

                // 내용 미리보기
                Text(
                  post.content,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                // 이미지 있으면 표시
                if (post.imageUrls.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 12),

                // 푸터
                Row(
                  children: [
                    _buildStatItem(Icons.favorite_border, post.likeCount.toString()),
                    const SizedBox(width: 16),
                    _buildStatItem(
                        Icons.chat_bubble_outline, post.commentCount.toString()),
                    const SizedBox(width: 16),
                    _buildStatItem(
                        Icons.visibility_outlined, post.viewCount.toString()),
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
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 4),
        Text(
          count,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[500],
          ),
        ),
      ],
    );
  }

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
        title: const Text('선수 선택'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('글을 작성할 선수를 선택해주세요.'),
            const SizedBox(height: 16),
            ...athletes.map((athlete) {
              return ListTile(
                leading: Text(athlete.sport.icon,
                    style: const TextStyle(fontSize: 24)),
                title: Text(athlete.nameKr),
                subtitle: Text(athlete.team),
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
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
        ],
      ),
    );
  }

  /// 샘플 게시물 데이터
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
