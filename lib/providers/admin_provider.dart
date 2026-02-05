import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/news_article.dart';
import '../models/crawl_source.dart';
import '../services/admin_service.dart';

// Admin Service Provider
final adminServiceProvider = Provider<AdminService>((ref) {
  return AdminService();
});

// 뉴스 목록 Provider
final adminArticlesProvider = StateNotifierProvider<AdminArticlesNotifier, List<NewsArticle>>((ref) {
  return AdminArticlesNotifier(ref.watch(adminServiceProvider));
});

class AdminArticlesNotifier extends StateNotifier<List<NewsArticle>> {
  final AdminService _service;

  AdminArticlesNotifier(this._service) : super([]) {
    _loadArticles();
  }

  void _loadArticles() {
    state = _service.getAllArticles();
  }

  Future<bool> approveArticle(String articleId) async {
    final result = await _service.approveArticle(articleId);
    if (result) {
      _loadArticles();
    }
    return result;
  }

  Future<bool> rejectArticle(String articleId) async {
    final result = await _service.rejectArticle(articleId);
    if (result) {
      _loadArticles();
    }
    return result;
  }

  void refresh() {
    _loadArticles();
  }
}

// 필터링된 뉴스 Provider
final filteredArticlesProvider = Provider.family<List<NewsArticle>, NewsStatus>((ref, status) {
  final articles = ref.watch(adminArticlesProvider);
  return articles.where((a) => a.status == status).toList();
});

// 뉴스 상태별 카운트 Provider
final articleCountByStatusProvider = Provider.family<int, NewsStatus>((ref, status) {
  final articles = ref.watch(adminArticlesProvider);
  return articles.where((a) => a.status == status).length;
});

// 크롤링 소스 Provider
final adminSourcesProvider = StateNotifierProvider<AdminSourcesNotifier, List<CrawlSource>>((ref) {
  return AdminSourcesNotifier(ref.watch(adminServiceProvider));
});

class AdminSourcesNotifier extends StateNotifier<List<CrawlSource>> {
  final AdminService _service;

  AdminSourcesNotifier(this._service) : super([]) {
    _loadSources();
  }

  void _loadSources() {
    state = _service.getAllSources();
  }

  Future<bool> toggleActive(String sourceId, bool isActive) async {
    final result = await _service.toggleSourceActive(sourceId, isActive);
    if (result) {
      _loadSources();
    }
    return result;
  }

  Future<bool> addSource(CrawlSource source) async {
    final result = await _service.addSource(source);
    if (result) {
      _loadSources();
    }
    return result;
  }

  Future<bool> updateSource(CrawlSource source) async {
    final result = await _service.updateSource(source);
    if (result) {
      _loadSources();
    }
    return result;
  }

  Future<bool> deleteSource(String sourceId) async {
    final result = await _service.deleteSource(sourceId);
    if (result) {
      _loadSources();
    }
    return result;
  }

  Future<bool> runCrawl(String sourceId) async {
    final result = await _service.runCrawl(sourceId);
    if (result) {
      _loadSources();
    }
    return result;
  }

  void refresh() {
    _loadSources();
  }
}

// 활성 소스 Provider
final activeSourcesProvider = Provider<List<CrawlSource>>((ref) {
  final sources = ref.watch(adminSourcesProvider);
  return sources.where((s) => s.isActive).toList();
});

// 비활성 소스 Provider
final inactiveSourcesProvider = Provider<List<CrawlSource>>((ref) {
  final sources = ref.watch(adminSourcesProvider);
  return sources.where((s) => !s.isActive).toList();
});

// Admin 통계 Provider
final adminStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final service = ref.watch(adminServiceProvider);
  final articles = ref.watch(adminArticlesProvider);
  final sources = ref.watch(adminSourcesProvider);

  final pendingCount = articles.where((a) => a.status == NewsStatus.pending).length;
  final approvedCount = articles.where((a) => a.status == NewsStatus.approved).length;
  final activeSourceCount = sources.where((s) => s.isActive).length;

  return {
    'pendingCount': pendingCount,
    'approvedTodayCount': approvedCount,
    'activeSourceCount': activeSourceCount,
    ...service.getAdminStats(),
  };
});
