import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_article.dart';
import '../services/news_service.dart';

/// NewsService Provider
final newsServiceProvider = Provider<NewsService>((ref) {
  return NewsService();
});

/// 뉴스 목록 State
class NewsListState {
  final List<NewsArticle> articles;
  final bool isLoading;
  final bool hasMore;
  final int page;
  final String? error;

  NewsListState({
    this.articles = const [],
    this.isLoading = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  NewsListState copyWith({
    List<NewsArticle>? articles,
    bool? isLoading,
    bool? hasMore,
    int? page,
    String? error,
  }) {
    return NewsListState(
      articles: articles ?? this.articles,
      isLoading: isLoading ?? this.isLoading,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error,
    );
  }
}

/// 승인된 뉴스 목록 Provider
final approvedNewsProvider = StateNotifierProvider.family<ApprovedNewsNotifier, NewsListState, String>(
  (ref, playerId) => ApprovedNewsNotifier(ref, playerId),
);

class ApprovedNewsNotifier extends StateNotifier<NewsListState> {
  final Ref _ref;
  final String _playerId;

  ApprovedNewsNotifier(this._ref, this._playerId) : super(NewsListState()) {
    loadNews();
  }

  Future<void> loadNews({bool refresh = false}) async {
    if (state.isLoading) return;

    final service = _ref.read(newsServiceProvider);

    if (refresh) {
      state = NewsListState(isLoading: true);
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final articles = await service.getApprovedNews(
        playerId: _playerId,
        page: refresh ? 1 : state.page,
      );

      if (refresh) {
        state = NewsListState(
          articles: articles,
          page: 1,
          hasMore: articles.length >= 20,
        );
      } else {
        state = state.copyWith(
          articles: [...state.articles, ...articles],
          page: state.page + 1,
          hasMore: articles.length >= 20,
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
    await loadNews(refresh: true);
  }

  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;
    await loadNews();
  }
}

/// 대기 중인 뉴스 목록 Provider (관리자용)
final pendingNewsProvider = FutureProvider<List<NewsArticle>>((ref) async {
  final service = ref.read(newsServiceProvider);
  return await service.getPendingNews();
});

/// 뉴스 상세 Provider
final newsDetailProvider = FutureProvider.family<NewsArticle?, String>((ref, newsId) async {
  final service = ref.read(newsServiceProvider);
  return await service.getNewsById(newsId);
});

/// 최신 뉴스 Provider
final latestNewsProvider = FutureProvider.family<NewsArticle?, String>((ref, playerId) async {
  final service = ref.read(newsServiceProvider);
  return await service.getLatestNews(playerId);
});

/// 뉴스 검색 Provider
final newsSearchProvider = FutureProvider.family<List<NewsArticle>, NewsSearchParams>((ref, params) async {
  if (params.query.isEmpty) return [];
  final service = ref.read(newsServiceProvider);
  return await service.searchNews(
    playerId: params.playerId,
    query: params.query,
  );
});

class NewsSearchParams {
  final String playerId;
  final String query;

  NewsSearchParams({
    required this.playerId,
    required this.query,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NewsSearchParams &&
        other.playerId == playerId &&
        other.query == query;
  }

  @override
  int get hashCode => playerId.hashCode ^ query.hashCode;
}

/// 뉴스 통계 Provider (관리자용)
final newsStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final service = ref.read(newsServiceProvider);
  return await service.getNewsStats();
});

/// 뉴스 승인/거부 액션 Provider
final newsActionProvider = Provider<NewsActionNotifier>((ref) {
  return NewsActionNotifier(ref);
});

class NewsActionNotifier {
  final Ref _ref;

  NewsActionNotifier(this._ref);

  Future<bool> approveNews(String newsId) async {
    final service = _ref.read(newsServiceProvider);
    final success = await service.approveNews(newsId);
    if (success) {
      _ref.invalidate(pendingNewsProvider);
      _ref.invalidate(newsStatsProvider);
    }
    return success;
  }

  Future<bool> rejectNews(String newsId) async {
    final service = _ref.read(newsServiceProvider);
    final success = await service.rejectNews(newsId);
    if (success) {
      _ref.invalidate(pendingNewsProvider);
      _ref.invalidate(newsStatsProvider);
    }
    return success;
  }
}
