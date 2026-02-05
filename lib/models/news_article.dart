/// 뉴스 기사 모델
class NewsArticle {
  final String id;
  final String title;
  final String summary;
  final String content;
  final String source;
  final String sourceUrl;
  final String? imageUrl;
  final String playerId;
  final DateTime publishedAt;
  final DateTime? crawledAt;
  final NewsStatus status;
  final String? translatedTitle;
  final String? translatedContent;
  final String originalLanguage;
  final List<String> tags;
  final int viewCount;
  final bool isPinned;

  NewsArticle({
    required this.id,
    required this.title,
    required this.summary,
    required this.content,
    required this.source,
    required this.sourceUrl,
    this.imageUrl,
    required this.playerId,
    required this.publishedAt,
    this.crawledAt,
    this.status = NewsStatus.pending,
    this.translatedTitle,
    this.translatedContent,
    this.originalLanguage = 'en',
    this.tags = const [],
    this.viewCount = 0,
    this.isPinned = false,
  });

  NewsArticle copyWith({
    String? id,
    String? title,
    String? summary,
    String? content,
    String? source,
    String? sourceUrl,
    String? imageUrl,
    String? playerId,
    DateTime? publishedAt,
    DateTime? crawledAt,
    NewsStatus? status,
    String? translatedTitle,
    String? translatedContent,
    String? originalLanguage,
    List<String>? tags,
    int? viewCount,
    bool? isPinned,
  }) {
    return NewsArticle(
      id: id ?? this.id,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      content: content ?? this.content,
      source: source ?? this.source,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      playerId: playerId ?? this.playerId,
      publishedAt: publishedAt ?? this.publishedAt,
      crawledAt: crawledAt ?? this.crawledAt,
      status: status ?? this.status,
      translatedTitle: translatedTitle ?? this.translatedTitle,
      translatedContent: translatedContent ?? this.translatedContent,
      originalLanguage: originalLanguage ?? this.originalLanguage,
      tags: tags ?? this.tags,
      viewCount: viewCount ?? this.viewCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }
}

/// 뉴스 상태
enum NewsStatus {
  pending,    // 크롤링 완료, 검토 대기
  approved,   // 승인됨, 앱에 표시
  rejected,   // 거부됨
  archived,   // 보관됨
}

extension NewsStatusExtension on NewsStatus {
  String get displayName {
    switch (this) {
      case NewsStatus.pending:
        return '검토 대기';
      case NewsStatus.approved:
        return '승인됨';
      case NewsStatus.rejected:
        return '거부됨';
      case NewsStatus.archived:
        return '보관됨';
    }
  }

  String get emoji {
    switch (this) {
      case NewsStatus.pending:
        return '⏳';
      case NewsStatus.approved:
        return '✅';
      case NewsStatus.rejected:
        return '❌';
      case NewsStatus.archived:
        return '📦';
    }
  }
}
