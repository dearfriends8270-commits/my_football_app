import '../models/news_article.dart';

/// 뉴스 서비스 (현재는 Mock 데이터, 추후 크롤링/API 연동)
class NewsService {
  static final NewsService _instance = NewsService._();
  factory NewsService() => _instance;
  NewsService._();

  final List<NewsArticle> _articles = [];

  void _initMockData() {
    if (_articles.isNotEmpty) return;

    final now = DateTime.now();

    _articles.addAll([
      NewsArticle(
        id: 'news_1',
        title: '이강인, PSG 주간 MVP 선정',
        summary: '이강인이 지난 주 경기에서 보여준 활약으로 팀 내 주간 MVP에 선정되었다.',
        content: '''
파리 생제르맹의 이강인이 지난 주 리그1 경기에서 1골 1어시스트를 기록하며 팀 내 주간 MVP에 선정되었다.

이강인은 경기 후 인터뷰에서 "팀이 승리해서 기쁘다. 앞으로도 더 좋은 모습을 보여드리겠다"고 말했다.

엔리케 감독은 이강인에 대해 "점점 더 중요한 선수가 되고 있다. 그의 창의성은 우리 팀에 큰 도움이 된다"고 평가했다.
        ''',
        source: 'L\'Équipe',
        sourceUrl: 'https://www.lequipe.fr/',
        imageUrl: 'https://example.com/news1.jpg',
        playerId: 'lee_kangin',
        publishedAt: now.subtract(const Duration(hours: 6)),
        crawledAt: now.subtract(const Duration(hours: 5)),
        status: NewsStatus.approved,
        translatedTitle: '이강인, PSG 주간 MVP 선정',
        originalLanguage: 'fr',
        tags: ['MVP', 'PSG', '리그1'],
        viewCount: 1234,
        isPinned: true,
      ),
      NewsArticle(
        id: 'news_2',
        title: 'Lee Kang-in shows world-class form',
        summary: 'The Korean midfielder continues to impress in Ligue 1.',
        content: '''
Lee Kang-in has been in exceptional form for Paris Saint-Germain this season, consistently delivering match-winning performances.

The 23-year-old has registered 4 goals and 7 assists in all competitions, establishing himself as a key player in Luis Enrique's system.

His ability to create chances and his vision on the pitch have drawn comparisons to some of the best playmakers in European football.
        ''',
        source: 'ESPN',
        sourceUrl: 'https://www.espn.com/',
        imageUrl: 'https://example.com/news2.jpg',
        playerId: 'lee_kangin',
        publishedAt: now.subtract(const Duration(days: 1)),
        crawledAt: now.subtract(const Duration(hours: 20)),
        status: NewsStatus.approved,
        translatedTitle: '이강인, 월드클래스 폼 과시',
        originalLanguage: 'en',
        tags: ['폼', 'PSG', '활약'],
        viewCount: 890,
      ),
      NewsArticle(
        id: 'news_3',
        title: 'PSG eye Champions League glory',
        summary: 'With key players in form, PSG looks strong for UCL run.',
        content: '''
Paris Saint-Germain is gearing up for their Champions League campaign with optimism. The squad depth and quality have impressed observers.

Key players including Lee Kang-in have stepped up in the absence of some first-team regulars, showing the team's resilience.
        ''',
        source: 'Goal.com',
        sourceUrl: 'https://www.goal.com/',
        playerId: 'lee_kangin',
        publishedAt: now.subtract(const Duration(days: 2)),
        crawledAt: now.subtract(const Duration(days: 1, hours: 12)),
        status: NewsStatus.approved,
        translatedTitle: 'PSG, 챔피언스리그 우승을 향해',
        originalLanguage: 'en',
        tags: ['챔피언스리그', 'PSG'],
        viewCount: 567,
      ),
      NewsArticle(
        id: 'news_4',
        title: '이강인 인터뷰: "더 성장하고 싶다"',
        summary: '한국 매체와의 독점 인터뷰에서 이강인이 자신의 목표를 밝혔다.',
        content: '''
이강인이 한국 매체와의 인터뷰에서 자신의 목표와 포부를 밝혔다.

"항상 더 나은 선수가 되고 싶습니다. PSG에서 많이 배우고 있고, 팀에 더 많은 기여를 하고 싶습니다."

대표팀에 대해서는 "국가대표로 뛰는 것은 항상 영광입니다. 월드컵에서 좋은 성적을 거두고 싶습니다"라고 말했다.
        ''',
        source: 'OSEN',
        sourceUrl: 'https://www.osen.co.kr/',
        playerId: 'lee_kangin',
        publishedAt: now.subtract(const Duration(days: 3)),
        status: NewsStatus.approved,
        originalLanguage: 'ko',
        tags: ['인터뷰', '목표', '대표팀'],
        viewCount: 2345,
      ),
      NewsArticle(
        id: 'news_5',
        title: 'Transfer rumors: Real Madrid interested?',
        summary: 'Spanish giants reportedly monitoring the Korean star.',
        content: '''
According to Spanish media, Real Madrid is keeping tabs on Lee Kang-in's development at PSG.

The Korean international has impressed with his performances, and his contract situation could make him an attractive option for top clubs.

However, PSG is expected to resist any approaches for one of their key players.
        ''',
        source: 'Marca',
        sourceUrl: 'https://www.marca.com/',
        playerId: 'lee_kangin',
        publishedAt: now.subtract(const Duration(hours: 12)),
        status: NewsStatus.pending,
        translatedTitle: '이적 루머: 레알 마드리드 관심?',
        originalLanguage: 'es',
        tags: ['이적', '레알마드리드', '루머'],
        viewCount: 0,
      ),
    ]);
  }

  /// 승인된 뉴스 목록 조회
  Future<List<NewsArticle>> getApprovedNews({
    required String playerId,
    int page = 1,
    int pageSize = 20,
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    var articles = _articles
        .where((a) => a.playerId == playerId && a.status == NewsStatus.approved)
        .toList()
      ..sort((a, b) {
        // 고정된 뉴스 우선
        if (a.isPinned && !b.isPinned) return -1;
        if (!a.isPinned && b.isPinned) return 1;
        return b.publishedAt.compareTo(a.publishedAt);
      });

    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    if (start >= articles.length) return [];

    return articles.sublist(
      start,
      end > articles.length ? articles.length : end,
    );
  }

  /// 대기 중인 뉴스 목록 조회 (관리자용)
  Future<List<NewsArticle>> getPendingNews({int page = 1, int pageSize = 20}) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    var articles = _articles.where((a) => a.status == NewsStatus.pending).toList()
      ..sort((a, b) => b.crawledAt?.compareTo(a.crawledAt ?? DateTime.now()) ?? 0);

    final start = (page - 1) * pageSize;
    final end = start + pageSize;
    if (start >= articles.length) return [];

    return articles.sublist(
      start,
      end > articles.length ? articles.length : end,
    );
  }

  /// 뉴스 상세 조회
  Future<NewsArticle?> getNewsById(String newsId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 100));

    try {
      return _articles.firstWhere((a) => a.id == newsId);
    } catch (e) {
      return null;
    }
  }

  /// 뉴스 승인
  Future<bool> approveNews(String newsId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _articles.indexWhere((a) => a.id == newsId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(status: NewsStatus.approved);
      return true;
    }
    return false;
  }

  /// 뉴스 거부
  Future<bool> rejectNews(String newsId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    final index = _articles.indexWhere((a) => a.id == newsId);
    if (index != -1) {
      _articles[index] = _articles[index].copyWith(status: NewsStatus.rejected);
      return true;
    }
    return false;
  }

  /// 뉴스 검색
  Future<List<NewsArticle>> searchNews({
    required String playerId,
    required String query,
  }) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 300));

    final lowerQuery = query.toLowerCase();
    return _articles.where((a) {
      if (a.playerId != playerId || a.status != NewsStatus.approved) return false;
      return a.title.toLowerCase().contains(lowerQuery) ||
          a.summary.toLowerCase().contains(lowerQuery) ||
          (a.translatedTitle?.toLowerCase().contains(lowerQuery) ?? false) ||
          a.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
    }).toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  }

  /// 최신 뉴스 조회
  Future<NewsArticle?> getLatestNews(String playerId) async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 100));

    final articles = _articles
        .where((a) => a.playerId == playerId && a.status == NewsStatus.approved)
        .toList()
      ..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));

    return articles.isNotEmpty ? articles.first : null;
  }

  /// 뉴스 통계 조회 (관리자용)
  Future<Map<String, int>> getNewsStats() async {
    _initMockData();
    await Future.delayed(const Duration(milliseconds: 200));

    return {
      'pending': _articles.where((a) => a.status == NewsStatus.pending).length,
      'approved': _articles.where((a) => a.status == NewsStatus.approved).length,
      'rejected': _articles.where((a) => a.status == NewsStatus.rejected).length,
      'total': _articles.length,
    };
  }
}
