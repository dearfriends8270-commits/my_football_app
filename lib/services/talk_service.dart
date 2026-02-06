import 'package:uuid/uuid.dart';
import '../models/talk_post.dart';

/// Talk 커뮤니티 서비스 (현재는 Mock 데이터, 추후 Firebase 연동)
class TalkService {
  static final TalkService _instance = TalkService._();
  factory TalkService() => _instance;
  TalkService._();

  final _uuid = const Uuid();

  // In-memory storage (추후 Firebase로 대체)
  final List<TalkPost> _posts = [];
  final List<TalkComment> _comments = [];

  /// Mock 데이터 초기화
  void ensureInitialized() {
    _initMockData();
  }

  void _initMockData() {
    if (_posts.isNotEmpty) return;

    final now = DateTime.now();

    // Mock 게시글 데이터
    _posts.addAll([
      TalkPost(
        id: 'post_1',
        authorId: 'user_1',
        authorName: '강인이형',
        authorAvatar: null,
        playerId: 'lee_kangin',
        category: TalkCategory.rumor,
        title: '이강인 레알 마드리드 이적설?!',
        content: '스페인 매체에서 레알 마드리드가 이강인에게 관심을 보이고 있다고 합니다. 이번 시즌 활약이 눈에 띄었나 봐요.',
        createdAt: now.subtract(const Duration(hours: 2)),
        likeCount: 128,
        commentCount: 23,
        viewCount: 1520,
        isHot: true,
        tags: ['이적설', '레알마드리드'],
      ),
      TalkPost(
        id: 'post_2',
        authorId: 'user_2',
        authorName: 'PSG_Fan',
        authorAvatar: null,
        playerId: 'lee_kangin',
        category: TalkCategory.news,
        title: '어제 경기 하이라이트 봤어요?',
        content: '어시스트 장면 진짜 미쳤더라... 그 패스 각도 어떻게 보이는 거지?',
        createdAt: now.subtract(const Duration(hours: 5)),
        likeCount: 89,
        commentCount: 15,
        viewCount: 890,
        tags: ['하이라이트', '어시스트'],
      ),
      TalkPost(
        id: 'post_3',
        authorId: 'user_3',
        authorName: '축구분석가',
        authorAvatar: null,
        playerId: 'lee_kangin',
        category: TalkCategory.question,
        title: '이강인 포지션 어디가 가장 좋을까요?',
        content: '공격형 미드필더? 윙어? 어느 포지션이 이강인한테 가장 잘 맞는다고 생각하세요?',
        createdAt: now.subtract(const Duration(hours: 8)),
        likeCount: 45,
        commentCount: 32,
        viewCount: 567,
        tags: ['전술', '포지션'],
      ),
      TalkPost(
        id: 'post_4',
        authorId: 'user_4',
        authorName: '밈장인',
        authorAvatar: null,
        playerId: 'lee_kangin',
        category: TalkCategory.fanArt,
        title: '이강인 짤 만들어봤습니다 ㅋㅋ',
        content: '어제 세레머니 보고 만들어본 짤입니다. 자유롭게 사용하세요!',
        imageUrls: ['https://example.com/fanart.jpg'],
        createdAt: now.subtract(const Duration(days: 1)),
        likeCount: 234,
        commentCount: 18,
        viewCount: 2100,
        isHot: true,
        tags: ['팬아트', '짤'],
      ),
      TalkPost(
        id: 'post_5',
        authorId: 'user_5',
        authorName: '마르세유전',
        authorAvatar: null,
        playerId: 'lee_kangin',
        category: TalkCategory.liveChat,
        title: '마르세유전 실시간 채팅방',
        content: '다들 여기서 같이 응원해요! 오늘 이강인 선발인가요?',
        createdAt: now.subtract(const Duration(hours: 1)),
        likeCount: 56,
        commentCount: 145,
        viewCount: 890,
        isPinned: true,
        tags: ['실시간', '경기'],
      ),
    ]);

    // Mock 댓글 데이터
    _comments.addAll([
      TalkComment(
        id: 'comment_1',
        postId: 'post_1',
        authorId: 'user_10',
        authorName: '마드리디스타',
        content: '레알 오면 진짜 대박인데... 근데 PSG가 쉽게 보내줄까요?',
        createdAt: now.subtract(const Duration(hours: 1)),
        likeCount: 15,
      ),
      TalkComment(
        id: 'comment_2',
        postId: 'post_1',
        authorId: 'user_11',
        authorName: '강인이응원단',
        content: '레알 가면 벨링엄이랑 같이 뛰는 건가... 상상만 해도 좋다',
        createdAt: now.subtract(const Duration(minutes: 45)),
        likeCount: 23,
      ),
      TalkComment(
        id: 'comment_3',
        postId: 'post_1',
        authorId: 'user_12',
        authorName: '현실주의자',
        content: '아직은 루머 수준이니까 너무 기대하진 말자',
        createdAt: now.subtract(const Duration(minutes: 30)),
        likeCount: 8,
        parentCommentId: 'comment_1',
      ),
      TalkComment(
        id: 'comment_4',
        postId: 'post_3',
        authorId: 'user_13',
        authorName: '전술덕후',
        content: '10번 포지션이 제일 잘 맞는 것 같아요. 패스 시야가 너무 좋아서',
        createdAt: now.subtract(const Duration(hours: 7)),
        likeCount: 12,
      ),
      TalkComment(
        id: 'comment_5',
        postId: 'post_3',
        authorId: 'user_14',
        authorName: '우측날개',
        content: '저는 오른쪽 윙이요! 드리블 돌파가 너무 좋음',
        createdAt: now.subtract(const Duration(hours: 6)),
        likeCount: 9,
      ),
    ]);
  }

  /// 게시글 목록 조회
  Future<List<TalkPost>> getPosts({
    required String playerId,
    TalkCategory? category,
    int page = 1,
    int pageSize = 20,
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    var filteredPosts = _posts.where((p) => p.playerId == playerId).toList();

    if (category != null && category != TalkCategory.all) {
      filteredPosts = filteredPosts.where((p) => p.category == category).toList();
    }

    // 정렬: 고정글 우선, 그 다음 최신순
    filteredPosts.sort((a, b) {
      if (a.isPinned && !b.isPinned) return -1;
      if (!a.isPinned && b.isPinned) return 1;
      return b.createdAt.compareTo(a.createdAt);
    });

    // 페이지네이션
    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    if (start >= filteredPosts.length) return [];

    return filteredPosts.sublist(
      start,
      end > filteredPosts.length ? filteredPosts.length : end,
    );
  }

  /// 인기 게시글 조회
  Future<List<TalkPost>> getHotPosts({
    required String playerId,
    int limit = 5,
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    final posts = _posts.where((p) => p.playerId == playerId && p.isHot).toList()
      ..sort((a, b) => b.likeCount.compareTo(a.likeCount));

    return posts.take(limit).toList();
  }

  /// 게시글 상세 조회
  Future<TalkPost?> getPostById(String postId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      return _posts.firstWhere((p) => p.id == postId);
    } catch (e) {
      return null;
    }
  }

  /// 게시글 작성
  Future<TalkPost> createPost({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String playerId,
    required TalkCategory category,
    required String title,
    required String content,
    List<String> imageUrls = const [],
    List<String> tags = const [],
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 500));

    final post = TalkPost(
      id: _uuid.v4(),
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      playerId: playerId,
      category: category,
      title: title,
      content: content,
      imageUrls: imageUrls,
      createdAt: DateTime.now(),
      tags: tags,
    );

    _posts.insert(0, post);
    return post;
  }

  /// 게시글 삭제
  Future<bool> deletePost(String postId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      _posts.removeAt(index);
      // 관련 댓글도 삭제
      _comments.removeWhere((c) => c.postId == postId);
      return true;
    }
    return false;
  }

  /// 댓글 목록 조회
  Future<List<TalkComment>> getComments(String postId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    final comments = _comments.where((c) => c.postId == postId).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return comments;
  }

  /// 댓글 작성
  Future<TalkComment> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
    String? parentCommentId,
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    final comment = TalkComment(
      id: _uuid.v4(),
      postId: postId,
      authorId: authorId,
      authorName: authorName,
      authorAvatar: authorAvatar,
      content: content,
      createdAt: DateTime.now(),
      parentCommentId: parentCommentId,
    );

    _comments.add(comment);

    // 게시글의 댓글 수 업데이트 (실제로는 서버에서 처리)
    final postIndex = _posts.indexWhere((p) => p.id == postId);
    if (postIndex != -1) {
      final post = _posts[postIndex];
      _posts[postIndex] = TalkPost(
        id: post.id,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatar: post.authorAvatar,
        playerId: post.playerId,
        category: post.category,
        title: post.title,
        content: post.content,
        imageUrls: post.imageUrls,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        likeCount: post.likeCount,
        commentCount: post.commentCount + 1,
        viewCount: post.viewCount,
        isPinned: post.isPinned,
        isHot: post.isHot,
        tags: post.tags,
      );
    }

    return comment;
  }

  /// 댓글 삭제
  Future<bool> deleteComment(String commentId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _comments.indexWhere((c) => c.id == commentId);
    if (index != -1) {
      final comment = _comments[index];
      _comments.removeAt(index);

      // 대댓글도 삭제
      _comments.removeWhere((c) => c.parentCommentId == commentId);

      // 게시글의 댓글 수 업데이트
      final postIndex = _posts.indexWhere((p) => p.id == comment.postId);
      if (postIndex != -1) {
        final post = _posts[postIndex];
        _posts[postIndex] = TalkPost(
          id: post.id,
          authorId: post.authorId,
          authorName: post.authorName,
          authorAvatar: post.authorAvatar,
          playerId: post.playerId,
          category: post.category,
          title: post.title,
          content: post.content,
          imageUrls: post.imageUrls,
          createdAt: post.createdAt,
          updatedAt: post.updatedAt,
          likeCount: post.likeCount,
          commentCount: post.commentCount > 0 ? post.commentCount - 1 : 0,
          viewCount: post.viewCount,
          isPinned: post.isPinned,
          isHot: post.isHot,
          tags: post.tags,
        );
      }

      return true;
    }
    return false;
  }

  /// 게시글 검색
  Future<List<TalkPost>> searchPosts({
    required String playerId,
    required String query,
    TalkCategory? category,
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    var results = _posts.where((p) {
      if (p.playerId != playerId) return false;
      if (category != null && category != TalkCategory.all && p.category != category) {
        return false;
      }
      return p.title.toLowerCase().contains(lowerQuery) ||
          p.content.toLowerCase().contains(lowerQuery) ||
          p.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList();

    results.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return results;
  }

  /// 좋아요 토글
  Future<int> toggleLike(String postId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 100));

    final index = _posts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final post = _posts[index];
      // 간단하게 좋아요 증가 (실제로는 사용자별 상태 관리 필요)
      final newLikeCount = post.likeCount + 1;
      _posts[index] = TalkPost(
        id: post.id,
        authorId: post.authorId,
        authorName: post.authorName,
        authorAvatar: post.authorAvatar,
        playerId: post.playerId,
        category: post.category,
        title: post.title,
        content: post.content,
        imageUrls: post.imageUrls,
        createdAt: post.createdAt,
        updatedAt: post.updatedAt,
        likeCount: newLikeCount,
        commentCount: post.commentCount,
        viewCount: post.viewCount,
        isPinned: post.isPinned,
        isHot: post.isHot,
        tags: post.tags,
      );
      return newLikeCount;
    }
    return 0;
  }
}
