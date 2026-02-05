/// 크롤링 소스 모델
class CrawlSource {
  final String id;
  final String name;
  final String baseUrl;
  final String feedUrl;
  final CrawlSourceType type;
  final String language;
  final bool isActive;
  final Duration crawlInterval;
  final DateTime? lastCrawledAt;
  final int successCount;
  final int failCount;
  final List<String> targetPlayerIds;

  CrawlSource({
    required this.id,
    required this.name,
    required this.baseUrl,
    required this.feedUrl,
    required this.type,
    this.language = 'en',
    this.isActive = true,
    this.crawlInterval = const Duration(hours: 1),
    this.lastCrawledAt,
    this.successCount = 0,
    this.failCount = 0,
    this.targetPlayerIds = const [],
  });
}

/// 크롤링 소스 타입
enum CrawlSourceType {
  rss,        // RSS 피드
  api,        // API
  scraper,    // 웹 스크래핑
  twitter,    // 트위터/X
  instagram,  // 인스타그램
}

extension CrawlSourceTypeExtension on CrawlSourceType {
  String get displayName {
    switch (this) {
      case CrawlSourceType.rss:
        return 'RSS 피드';
      case CrawlSourceType.api:
        return 'API';
      case CrawlSourceType.scraper:
        return '웹 스크래핑';
      case CrawlSourceType.twitter:
        return 'Twitter/X';
      case CrawlSourceType.instagram:
        return 'Instagram';
    }
  }

  String get icon {
    switch (this) {
      case CrawlSourceType.rss:
        return '📡';
      case CrawlSourceType.api:
        return '🔌';
      case CrawlSourceType.scraper:
        return '🕷️';
      case CrawlSourceType.twitter:
        return '🐦';
      case CrawlSourceType.instagram:
        return '📸';
    }
  }
}

/// 크롤링 로그
class CrawlLog {
  final String id;
  final String sourceId;
  final DateTime startedAt;
  final DateTime? completedAt;
  final CrawlStatus status;
  final int articlesFound;
  final int articlesAdded;
  final String? errorMessage;

  CrawlLog({
    required this.id,
    required this.sourceId,
    required this.startedAt,
    this.completedAt,
    this.status = CrawlStatus.running,
    this.articlesFound = 0,
    this.articlesAdded = 0,
    this.errorMessage,
  });
}

enum CrawlStatus {
  running,
  success,
  failed,
  partial,
}
