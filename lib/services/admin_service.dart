import '../models/news_article.dart';
import '../models/crawl_source.dart';

class AdminService {
  static final AdminService _instance = AdminService._internal();
  factory AdminService() => _instance;
  AdminService._internal();

  // 뉴스 목록
  final List<NewsArticle> _articles = [
    NewsArticle(
      id: '1',
      title: 'Lee Kang-in Scores Brilliant Goal in PSG Victory',
      summary: 'The South Korean midfielder netted a stunning goal to help PSG secure a 3-1 win.',
      content: 'Full article content here...',
      source: "L'Equipe",
      sourceUrl: 'https://lequipe.fr/...',
      imageUrl: 'https://example.com/image1.jpg',
      playerId: '1',
      publishedAt: DateTime.now().subtract(const Duration(hours: 2)),
      crawledAt: DateTime.now().subtract(const Duration(hours: 1)),
      status: NewsStatus.pending,
      originalLanguage: 'fr',
      tags: ['골', '리그1', 'PSG'],
    ),
    NewsArticle(
      id: '2',
      title: 'Son Heung-min Named Captain for Spurs Match',
      summary: 'Tottenham manager announces Son as captain for the upcoming Premier League fixture.',
      content: 'Full article content here...',
      source: 'BBC Sport',
      sourceUrl: 'https://bbc.com/sport/...',
      imageUrl: 'https://example.com/image2.jpg',
      playerId: '2',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      crawledAt: DateTime.now().subtract(const Duration(hours: 4)),
      status: NewsStatus.pending,
      originalLanguage: 'en',
      tags: ['주장', '프리미어리그', '토트넘'],
    ),
    NewsArticle(
      id: '3',
      title: 'Kim Min-jae Receives High Marks After Bayern Win',
      summary: 'The defender earned praise from coach and fans after solid performance.',
      content: 'Full article content here...',
      source: 'Kicker',
      sourceUrl: 'https://kicker.de/...',
      playerId: '3',
      publishedAt: DateTime.now().subtract(const Duration(days: 1)),
      crawledAt: DateTime.now().subtract(const Duration(hours: 23)),
      status: NewsStatus.approved,
      originalLanguage: 'de',
      tags: ['분데스리가', '바이에른', '수비'],
    ),
    NewsArticle(
      id: '4',
      title: 'Hwang Hee-chan Scores Winner in Wolves Victory',
      summary: 'The Korean forward sealed the win with a late goal.',
      content: 'Full article content here...',
      source: 'Sky Sports',
      sourceUrl: 'https://skysports.com/...',
      playerId: '4',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      crawledAt: DateTime.now().subtract(const Duration(hours: 7)),
      status: NewsStatus.pending,
      originalLanguage: 'en',
      tags: ['울브스', '프리미어리그', '골'],
    ),
  ];

  // 크롤링 소스 목록
  final List<CrawlSource> _sources = [
    CrawlSource(
      id: '1',
      name: "L'Equipe",
      baseUrl: 'https://lequipe.fr',
      feedUrl: 'https://lequipe.fr/rss/actu_foot.xml',
      type: CrawlSourceType.rss,
      language: 'fr',
      isActive: true,
      lastCrawledAt: DateTime.now().subtract(const Duration(minutes: 30)),
      successCount: 1250,
      failCount: 12,
      targetPlayerIds: ['1'],
    ),
    CrawlSource(
      id: '2',
      name: 'BBC Sport',
      baseUrl: 'https://bbc.com/sport',
      feedUrl: 'https://feeds.bbci.co.uk/sport/football/rss.xml',
      type: CrawlSourceType.rss,
      language: 'en',
      isActive: true,
      lastCrawledAt: DateTime.now().subtract(const Duration(minutes: 45)),
      successCount: 2340,
      failCount: 5,
      targetPlayerIds: ['2'],
    ),
    CrawlSource(
      id: '3',
      name: 'Kicker',
      baseUrl: 'https://kicker.de',
      feedUrl: 'https://rss.kicker.de/live/bundesliga',
      type: CrawlSourceType.rss,
      language: 'de',
      isActive: true,
      lastCrawledAt: DateTime.now().subtract(const Duration(hours: 1)),
      successCount: 890,
      failCount: 23,
      targetPlayerIds: ['3'],
    ),
    CrawlSource(
      id: '4',
      name: 'API-Football',
      baseUrl: 'https://api-football.com',
      feedUrl: 'https://api-football.com/v3',
      type: CrawlSourceType.api,
      language: 'en',
      isActive: true,
      lastCrawledAt: DateTime.now().subtract(const Duration(minutes: 15)),
      successCount: 5600,
      failCount: 8,
      targetPlayerIds: ['1', '2', '3', '4'],
    ),
    CrawlSource(
      id: '5',
      name: 'PSG Official Twitter',
      baseUrl: 'https://twitter.com/PSG_inside',
      feedUrl: 'twitter://PSG_inside',
      type: CrawlSourceType.twitter,
      language: 'fr',
      isActive: false,
      lastCrawledAt: DateTime.now().subtract(const Duration(days: 2)),
      successCount: 156,
      failCount: 45,
      targetPlayerIds: ['1'],
    ),
  ];

  // 뉴스 관련 메서드
  List<NewsArticle> getAllArticles() => List.unmodifiable(_articles);

  List<NewsArticle> getArticlesByStatus(NewsStatus status) {
    return _articles.where((a) => a.status == status).toList();
  }

  int getArticleCountByStatus(NewsStatus status) {
    return _articles.where((a) => a.status == status).length;
  }

  Future<bool> approveArticle(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(status: NewsStatus.approved);
      return true;
    }
    return false;
  }

  Future<bool> rejectArticle(String articleId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _articles.indexWhere((a) => a.id == articleId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(status: NewsStatus.rejected);
      return true;
    }
    return false;
  }

  // 소스 관련 메서드
  List<CrawlSource> getAllSources() => List.unmodifiable(_sources);

  List<CrawlSource> getActiveSources() {
    return _sources.where((s) => s.isActive).toList();
  }

  List<CrawlSource> getInactiveSources() {
    return _sources.where((s) => !s.isActive).toList();
  }

  Future<bool> toggleSourceActive(String sourceId, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sources.indexWhere((s) => s.id == sourceId);
    if (index != -1) {
      _sources[index] = CrawlSource(
        id: _sources[index].id,
        name: _sources[index].name,
        baseUrl: _sources[index].baseUrl,
        feedUrl: _sources[index].feedUrl,
        type: _sources[index].type,
        language: _sources[index].language,
        isActive: isActive,
        lastCrawledAt: _sources[index].lastCrawledAt,
        successCount: _sources[index].successCount,
        failCount: _sources[index].failCount,
        targetPlayerIds: _sources[index].targetPlayerIds,
      );
      return true;
    }
    return false;
  }

  Future<bool> addSource(CrawlSource source) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sources.add(source);
    return true;
  }

  Future<bool> updateSource(CrawlSource source) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _sources.indexWhere((s) => s.id == source.id);
    if (index != -1) {
      _sources[index] = source;
      return true;
    }
    return false;
  }

  Future<bool> deleteSource(String sourceId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _sources.removeWhere((s) => s.id == sourceId);
    return true;
  }

  Future<bool> runCrawl(String sourceId) async {
    // 시뮬레이션: 크롤링 실행
    await Future.delayed(const Duration(seconds: 2));
    final index = _sources.indexWhere((s) => s.id == sourceId);
    if (index != -1) {
      _sources[index] = CrawlSource(
        id: _sources[index].id,
        name: _sources[index].name,
        baseUrl: _sources[index].baseUrl,
        feedUrl: _sources[index].feedUrl,
        type: _sources[index].type,
        language: _sources[index].language,
        isActive: _sources[index].isActive,
        lastCrawledAt: DateTime.now(),
        successCount: _sources[index].successCount + 5,
        failCount: _sources[index].failCount,
        targetPlayerIds: _sources[index].targetPlayerIds,
      );
      return true;
    }
    return false;
  }

  // 통계 관련 메서드
  Map<String, dynamic> getAdminStats() {
    final pendingCount = getArticleCountByStatus(NewsStatus.pending);
    final approvedCount = getArticleCountByStatus(NewsStatus.approved);
    final activeSourceCount = getActiveSources().length;

    return {
      'pendingCount': pendingCount,
      'approvedTodayCount': approvedCount,
      'activeSourceCount': activeSourceCount,
      'totalCrawled': 1247,
      'totalApproved': 892,
      'rejectionRate': 28.5,
      'avgProcessingTime': 4.2,
    };
  }
}
