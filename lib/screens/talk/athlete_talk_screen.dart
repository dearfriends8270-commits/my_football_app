import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/talk_post.dart';
import '../../utils/auth_guard.dart';
import 'talk_write_screen.dart';

/// 선수 전용 톡방 화면
/// 선수 상세 페이지에서 Talk 커뮤니티 클릭 시 열리는 화면
class AthleteTalkScreen extends ConsumerStatefulWidget {
  final String athleteId;
  final String athleteName;
  final Color? teamColor;

  const AthleteTalkScreen({
    super.key,
    required this.athleteId,
    required this.athleteName,
    this.teamColor,
  });

  @override
  ConsumerState<AthleteTalkScreen> createState() => _AthleteTalkScreenState();
}

class _AthleteTalkScreenState extends ConsumerState<AthleteTalkScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  // 카테고리 목록
  final List<TalkCategory> _categories = TalkCategory.values;

  Color get _primaryColor => widget.teamColor ?? const Color(0xFF1E4A6E);

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
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // 카테고리 탭 바
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
      // 글쓰기 FAB
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // 로그인 체크
          if (!AuthGuard.checkAuth(context, ref)) return;

          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => TalkWriteScreen(
                playerId: widget.athleteId,
                playerName: widget.athleteName,
              ),
            ),
          );
        },
        backgroundColor: _primaryColor,
        icon: const Icon(Icons.edit, color: Colors.white),
        label: const Text(
          '글쓰기',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _primaryColor,
      leading: IconButton(
        icon: Icon(
          _isSearching ? Icons.close : Icons.arrow_back,
          color: Colors.white,
        ),
        onPressed: () {
          if (_isSearching) {
            setState(() {
              _isSearching = false;
              _searchQuery = '';
              _searchController.clear();
            });
          } else {
            Navigator.of(context).pop();
          }
        },
      ),
      title: _isSearching
          ? TextField(
              controller: _searchController,
              autofocus: true,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: '게시글 검색...',
                hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
                border: InputBorder.none,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : Column(
              children: [
                Text(
                  '${widget.athleteName} Talk',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  '팬들과 함께하는 공간',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
      centerTitle: !_isSearching,
      actions: [
        if (!_isSearching)
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                _isSearching = true;
              });
            },
          ),
        if (_isSearching && _searchQuery.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () {
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
          ),
      ],
    );
  }

  Widget _buildCategoryTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        labelColor: _primaryColor,
        unselectedLabelColor: Colors.grey,
        indicatorColor: _primaryColor,
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
    // 샘플 게시물 데이터 (해당 선수만 필터링)
    var posts = _getSamplePosts();

    // 카테고리 필터
    if (category != TalkCategory.all) {
      posts = posts.where((p) => p.category == category).toList();
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
            '${category.displayName} 게시물이 없어요',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.athleteName} 팬들과 첫 번째 글을 작성해보세요!',
            style: TextStyle(fontSize: 14, color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildPostCard(TalkPost post) {
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
                      backgroundColor: _primaryColor.withValues(alpha: 0.1),
                      child: Text(
                        post.authorName.isNotEmpty ? post.authorName[0] : '?',
                        style: TextStyle(
                          color: _primaryColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            post.authorName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: _primaryColor.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  post.category.displayName,
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: _primaryColor,
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
                          color: _primaryColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '#$tag',
                          style: TextStyle(
                            fontSize: 11,
                            color: _primaryColor,
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
                    _buildStatItem(Icons.chat_bubble_outline, post.commentCount.toString()),
                    const SizedBox(width: 16),
                    _buildStatItem(Icons.visibility_outlined, post.viewCount.toString()),
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

  /// 샘플 게시물 데이터 (해당 선수 전용)
  List<TalkPost> _getSamplePosts() {
    return [
      TalkPost(
        id: '1',
        authorId: 'user1',
        authorName: '열정팬',
        playerId: widget.athleteId,
        category: TalkCategory.rumor,
        title: '빅클럽 이적설, 신뢰도는?',
        content: '오늘 해외 매체에서 나온 기사인데, 빅클럽에서 관심을 보이고 있다는 소식이에요.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        likeCount: 156,
        commentCount: 42,
        viewCount: 1203,
        isHot: true,
        tags: ['이적루머', '해외축구'],
      ),
      TalkPost(
        id: '2',
        authorId: 'user2',
        authorName: '실시간러버',
        playerId: widget.athleteId,
        category: TalkCategory.liveChat,
        title: '[경기 실황] 오늘 경기 실시간 채팅방',
        content: '오늘 경기 같이 봐요! 선발 출전 확정!',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        likeCount: 89,
        commentCount: 234,
        viewCount: 567,
        isPinned: true,
        tags: ['실시간', '경기'],
      ),
      TalkPost(
        id: '3',
        authorId: 'user3',
        authorName: '팬아트장인',
        playerId: widget.athleteId,
        category: TalkCategory.fanArt,
        title: '팬아트 그려봤어요 (직접 그림)',
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
        playerId: widget.athleteId,
        category: TalkCategory.news,
        title: '[공식] 이번주 최우수 선수 선정!',
        content: '공식 발표에 따르면 이번 주 최우수 선수로 선정되었습니다.',
        createdAt: DateTime.now().subtract(const Duration(hours: 8)),
        likeCount: 567,
        commentCount: 89,
        viewCount: 2341,
        tags: ['공식', 'POTW'],
      ),
      TalkPost(
        id: '5',
        authorId: 'user5',
        authorName: '초보팬',
        playerId: widget.athleteId,
        category: TalkCategory.question,
        title: '유니폼 사이즈 질문이요',
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
        authorName: '매니아',
        playerId: widget.athleteId,
        category: TalkCategory.free,
        title: '오늘도 덕질하는 하루',
        content: '출근길에 영상 보면서 힐링하고 왔어요 ㅎㅎ',
        createdAt: DateTime.now().subtract(const Duration(hours: 10)),
        likeCount: 34,
        commentCount: 8,
        viewCount: 123,
        tags: ['일상'],
      ),
    ];
  }
}
