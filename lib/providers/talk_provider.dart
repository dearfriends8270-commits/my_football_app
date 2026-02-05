import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/talk_post.dart';
import '../services/talk_service.dart';

/// TalkService Provider
final talkServiceProvider = Provider<TalkService>((ref) {
  return TalkService();
});

/// 현재 선택된 Talk 카테고리 Provider
final selectedTalkCategoryProvider = StateProvider<TalkCategory>((ref) => TalkCategory.all);

/// Talk 게시글 목록 State
class TalkPostsState {
  final List<TalkPost> posts;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  TalkPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  TalkPostsState copyWith({
    List<TalkPost>? posts,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return TalkPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

/// Talk 게시글 목록 Provider
final talkPostsProvider = StateNotifierProvider.family<TalkPostsNotifier, TalkPostsState, String>(
  (ref, playerId) => TalkPostsNotifier(ref, playerId),
);

class TalkPostsNotifier extends StateNotifier<TalkPostsState> {
  final Ref _ref;
  final String _playerId;

  TalkPostsNotifier(this._ref, this._playerId) : super(TalkPostsState()) {
    loadPosts();
  }

  Future<void> loadPosts({bool refresh = false}) async {
    if (state.isLoading) return;

    final category = _ref.read(selectedTalkCategoryProvider);
    final service = _ref.read(talkServiceProvider);

    if (refresh) {
      state = TalkPostsState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final posts = await service.getPosts(
        playerId: _playerId,
        category: category == TalkCategory.all ? null : category,
        page: refresh ? 1 : state.page,
      );

      if (refresh) {
        state = TalkPostsState(
          posts: posts,
          page: 1,
          hasMore: posts.length >= 20,
        );
      } else {
        state = state.copyWith(
          posts: [...state.posts, ...posts],
          page: state.page + 1,
          hasMore: posts.length >= 20,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> refresh() async {
    await loadPosts(refresh: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadPosts();
  }

  void addPost(TalkPost post) {
    state = state.copyWith(posts: [post, ...state.posts]);
  }

  void removePost(String postId) {
    state = state.copyWith(
      posts: state.posts.where((p) => p.id != postId).toList(),
    );
  }

  void updatePost(TalkPost updatedPost) {
    final posts = state.posts.map((p) {
      return p.id == updatedPost.id ? updatedPost : p;
    }).toList();
    state = state.copyWith(posts: posts);
  }
}

/// 인기 게시글 Provider
final hotPostsProvider = FutureProvider.family<List<TalkPost>, String>((ref, playerId) async {
  final service = ref.read(talkServiceProvider);
  return await service.getHotPosts(playerId: playerId, limit: 5);
});

/// 게시글 상세 Provider
final postDetailProvider = FutureProvider.family<TalkPost?, String>((ref, postId) async {
  final service = ref.read(talkServiceProvider);
  return await service.getPostById(postId);
});

/// 댓글 목록 State
class CommentsState {
  final List<TalkComment> comments;
  final bool isLoading;
  final String? error;

  CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.error,
  });

  CommentsState copyWith({
    List<TalkComment>? comments,
    bool? isLoading,
    String? error,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// 댓글 목록 Provider
final commentsProvider = StateNotifierProvider.family<CommentsNotifier, CommentsState, String>(
  (ref, postId) => CommentsNotifier(ref, postId),
);

class CommentsNotifier extends StateNotifier<CommentsState> {
  final Ref _ref;
  final String _postId;

  CommentsNotifier(this._ref, this._postId) : super(CommentsState()) {
    loadComments();
  }

  Future<void> loadComments() async {
    state = state.copyWith(isLoading: true);

    try {
      final service = _ref.read(talkServiceProvider);
      final comments = await service.getComments(_postId);
      state = CommentsState(comments: comments);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<TalkComment?> addComment({
    required String authorId,
    required String authorName,
    String? authorAvatar,
    required String content,
    String? parentCommentId,
  }) async {
    try {
      final service = _ref.read(talkServiceProvider);
      final comment = await service.createComment(
        postId: _postId,
        authorId: authorId,
        authorName: authorName,
        authorAvatar: authorAvatar,
        content: content,
        parentCommentId: parentCommentId,
      );
      state = state.copyWith(comments: [...state.comments, comment]);
      return comment;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  Future<bool> deleteComment(String commentId) async {
    try {
      final service = _ref.read(talkServiceProvider);
      final success = await service.deleteComment(commentId);
      if (success) {
        state = state.copyWith(
          comments: state.comments.where((c) => c.id != commentId && c.parentCommentId != commentId).toList(),
        );
      }
      return success;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }
}

/// Talk 검색 결과 Provider
final talkSearchProvider = FutureProvider.family<List<TalkPost>, TalkSearchParams>((ref, params) async {
  if (params.query.isEmpty) return [];
  final service = ref.read(talkServiceProvider);
  return await service.searchPosts(
    playerId: params.playerId,
    query: params.query,
    category: params.category,
  );
});

class TalkSearchParams {
  final String playerId;
  final String query;
  final TalkCategory? category;

  TalkSearchParams({
    required this.playerId,
    required this.query,
    this.category,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TalkSearchParams &&
        other.playerId == playerId &&
        other.query == query &&
        other.category == category;
  }

  @override
  int get hashCode => playerId.hashCode ^ query.hashCode ^ category.hashCode;
}
