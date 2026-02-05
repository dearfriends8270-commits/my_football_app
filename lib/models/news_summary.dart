/// AI 뉴스 요약 모델
class NewsSummary {
  final String id;
  final String newsId;
  final String originalTitle;
  final String originalContent;
  final String originalSource;
  final String originalLanguage;
  final List<String> summaryLines; // 3줄 요약
  final String? sentiment; // 긍정/부정/중립
  final double sentimentScore; // -1.0 ~ 1.0
  final List<String> keywords;
  final String? playerRelevance; // 선수와의 관련성 설명
  final DateTime publishedAt;
  final DateTime summarizedAt;
  final SummarySource summarySource;
  final bool isVerified; // AI 요약 검증 여부

  const NewsSummary({
    required this.id,
    required this.newsId,
    required this.originalTitle,
    required this.originalContent,
    required this.originalSource,
    required this.originalLanguage,
    required this.summaryLines,
    this.sentiment,
    this.sentimentScore = 0.0,
    this.keywords = const [],
    this.playerRelevance,
    required this.publishedAt,
    required this.summarizedAt,
    required this.summarySource,
    this.isVerified = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'newsId': newsId,
      'originalTitle': originalTitle,
      'originalContent': originalContent,
      'originalSource': originalSource,
      'originalLanguage': originalLanguage,
      'summaryLines': summaryLines,
      'sentiment': sentiment,
      'sentimentScore': sentimentScore,
      'keywords': keywords,
      'playerRelevance': playerRelevance,
      'publishedAt': publishedAt.toIso8601String(),
      'summarizedAt': summarizedAt.toIso8601String(),
      'summarySource': summarySource.name,
      'isVerified': isVerified,
    };
  }

  factory NewsSummary.fromJson(Map<String, dynamic> json) {
    return NewsSummary(
      id: json['id'] as String,
      newsId: json['newsId'] as String,
      originalTitle: json['originalTitle'] as String,
      originalContent: json['originalContent'] as String,
      originalSource: json['originalSource'] as String,
      originalLanguage: json['originalLanguage'] as String,
      summaryLines: (json['summaryLines'] as List<dynamic>).cast<String>(),
      sentiment: json['sentiment'] as String?,
      sentimentScore: (json['sentimentScore'] as num?)?.toDouble() ?? 0.0,
      keywords: (json['keywords'] as List<dynamic>?)?.cast<String>() ?? [],
      playerRelevance: json['playerRelevance'] as String?,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
      summarizedAt: DateTime.parse(json['summarizedAt'] as String),
      summarySource: SummarySource.values.firstWhere(
        (e) => e.name == json['summarySource'],
        orElse: () => SummarySource.ai,
      ),
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }
}

/// 요약 출처
enum SummarySource {
  ai, // AI 자동 요약
  editor, // 편집자 작성
  community, // 커뮤니티 기여
}

extension SummarySourceExtension on SummarySource {
  String get displayName {
    switch (this) {
      case SummarySource.ai:
        return 'AI 요약';
      case SummarySource.editor:
        return '에디터 요약';
      case SummarySource.community:
        return '커뮤니티';
    }
  }

  String get icon {
    switch (this) {
      case SummarySource.ai:
        return '🤖';
      case SummarySource.editor:
        return '✍️';
      case SummarySource.community:
        return '👥';
    }
  }
}

/// 언론사 정보
class NewsSource {
  final String id;
  final String name;
  final String country;
  final String language;
  final String? logoUrl;
  final double credibilityScore; // 0.0 ~ 1.0
  final List<String> specialties; // 전문 분야

  const NewsSource({
    required this.id,
    required this.name,
    required this.country,
    required this.language,
    this.logoUrl,
    this.credibilityScore = 0.5,
    this.specialties = const [],
  });

  String get countryFlag {
    switch (country) {
      case 'France':
        return '🇫🇷';
      case 'Spain':
        return '🇪🇸';
      case 'Germany':
        return '🇩🇪';
      case 'England':
        return '🏴󠁧󠁢󠁥󠁮󠁧󠁿';
      case 'Italy':
        return '🇮🇹';
      case 'Korea':
        return '🇰🇷';
      default:
        return '🌍';
    }
  }
}

/// 감정 분석 결과
enum NewsSentiment {
  veryPositive,
  positive,
  neutral,
  negative,
  veryNegative,
}

extension NewsSentimentExtension on NewsSentiment {
  String get displayName {
    switch (this) {
      case NewsSentiment.veryPositive:
        return '매우 긍정';
      case NewsSentiment.positive:
        return '긍정';
      case NewsSentiment.neutral:
        return '중립';
      case NewsSentiment.negative:
        return '부정';
      case NewsSentiment.veryNegative:
        return '매우 부정';
    }
  }

  String get emoji {
    switch (this) {
      case NewsSentiment.veryPositive:
        return '😄';
      case NewsSentiment.positive:
        return '🙂';
      case NewsSentiment.neutral:
        return '😐';
      case NewsSentiment.negative:
        return '😟';
      case NewsSentiment.veryNegative:
        return '😢';
    }
  }

  int get colorValue {
    switch (this) {
      case NewsSentiment.veryPositive:
        return 0xFF4CAF50;
      case NewsSentiment.positive:
        return 0xFF8BC34A;
      case NewsSentiment.neutral:
        return 0xFF9E9E9E;
      case NewsSentiment.negative:
        return 0xFFFF9800;
      case NewsSentiment.veryNegative:
        return 0xFFF44336;
    }
  }

  static NewsSentiment fromScore(double score) {
    if (score >= 0.6) return NewsSentiment.veryPositive;
    if (score >= 0.2) return NewsSentiment.positive;
    if (score >= -0.2) return NewsSentiment.neutral;
    if (score >= -0.6) return NewsSentiment.negative;
    return NewsSentiment.veryNegative;
  }
}
