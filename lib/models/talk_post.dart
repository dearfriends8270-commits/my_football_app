import 'package:cloud_firestore/cloud_firestore.dart';

/// Talk 게시글 모델
class TalkPost {
  final String id;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String playerId;
  final TalkCategory category;
  final String title;
  final String content;
  final List<String> imageUrls;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final int likeCount;
  final int commentCount;
  final int viewCount;
  final bool isPinned;
  final bool isHot;
  final List<String> tags;
  final List<String> likedBy;

  TalkPost({
    required this.id,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.playerId,
    required this.category,
    required this.title,
    required this.content,
    this.imageUrls = const [],
    required this.createdAt,
    this.updatedAt,
    this.likeCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.isPinned = false,
    this.isHot = false,
    this.tags = const [],
    this.likedBy = const [],
  });

  /// Firestore 문서에서 변환
  factory TalkPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TalkPost(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorName: data['authorName'] as String? ?? '',
      authorAvatar: data['authorAvatar'] as String?,
      playerId: data['playerId'] as String? ?? data['athleteId'] as String? ?? '',
      category: TalkCategory.values.firstWhere(
        (c) => c.name == data['category'],
        orElse: () => TalkCategory.free,
      ),
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: data['updatedAt'] != null ? _parseDateTime(data['updatedAt']) : null,
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      viewCount: data['viewCount'] as int? ?? 0,
      isPinned: data['isPinned'] as bool? ?? false,
      isHot: data['isHot'] as bool? ?? false,
      tags: List<String>.from(data['tags'] ?? []),
      likedBy: List<String>.from(data['likedBy'] ?? []),
    );
  }

  /// Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'playerId': playerId,
      'athleteId': playerId, // 호환성을 위해 추가
      'category': category.name,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'isPinned': isPinned,
      'isHot': isHot,
      'tags': tags.map((t) => t.toLowerCase()).toList(),
      'likedBy': likedBy,
    };
  }

  /// JSON에서 변환 (로컬 저장용)
  factory TalkPost.fromJson(Map<String, dynamic> json) {
    return TalkPost(
      id: json['id'] as String,
      authorId: json['authorId'] as String,
      authorName: json['authorName'] as String,
      authorAvatar: json['authorAvatar'] as String?,
      playerId: json['playerId'] as String? ?? json['athleteId'] as String? ?? '',
      category: TalkCategory.values.firstWhere(
        (c) => c.name == json['category'],
        orElse: () => TalkCategory.free,
      ),
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrls: List<String>.from(json['imageUrls'] ?? []),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      likeCount: json['likeCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      viewCount: json['viewCount'] as int? ?? 0,
      isPinned: json['isPinned'] as bool? ?? false,
      isHot: json['isHot'] as bool? ?? false,
      tags: List<String>.from(json['tags'] ?? []),
      likedBy: List<String>.from(json['likedBy'] ?? []),
    );
  }

  /// JSON으로 변환 (로컬 저장용)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'playerId': playerId,
      'category': category.name,
      'title': title,
      'content': content,
      'imageUrls': imageUrls,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'likeCount': likeCount,
      'commentCount': commentCount,
      'viewCount': viewCount,
      'isPinned': isPinned,
      'isHot': isHot,
      'tags': tags,
      'likedBy': likedBy,
    };
  }

  /// 복사본 생성
  TalkPost copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorAvatar,
    String? playerId,
    TalkCategory? category,
    String? title,
    String? content,
    List<String>? imageUrls,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? likeCount,
    int? commentCount,
    int? viewCount,
    bool? isPinned,
    bool? isHot,
    List<String>? tags,
    List<String>? likedBy,
  }) {
    return TalkPost(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorAvatar: authorAvatar ?? this.authorAvatar,
      playerId: playerId ?? this.playerId,
      category: category ?? this.category,
      title: title ?? this.title,
      content: content ?? this.content,
      imageUrls: imageUrls ?? this.imageUrls,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      viewCount: viewCount ?? this.viewCount,
      isPinned: isPinned ?? this.isPinned,
      isHot: isHot ?? this.isHot,
      tags: tags ?? this.tags,
      likedBy: likedBy ?? this.likedBy,
    );
  }

  /// 특정 사용자가 좋아요했는지 확인
  bool isLikedBy(String userId) => likedBy.contains(userId);

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

/// Talk 카테고리
enum TalkCategory {
  all,        // 전체
  rumor,      // 루머/이적설
  liveChat,   // 경기 중 실시간
  fanArt,     // 팬아트/밈
  news,       // 뉴스/기사
  question,   // 질문
  free,       // 자유
}

extension TalkCategoryExtension on TalkCategory {
  String get displayName {
    switch (this) {
      case TalkCategory.all:
        return '전체';
      case TalkCategory.rumor:
        return '루머/이적설';
      case TalkCategory.liveChat:
        return '실시간 채팅';
      case TalkCategory.fanArt:
        return '팬아트/밈';
      case TalkCategory.news:
        return '뉴스/기사';
      case TalkCategory.question:
        return '질문';
      case TalkCategory.free:
        return '자유';
    }
  }

  String get emoji {
    switch (this) {
      case TalkCategory.all:
        return '📋';
      case TalkCategory.rumor:
        return '🔥';
      case TalkCategory.liveChat:
        return '⚡';
      case TalkCategory.fanArt:
        return '🎨';
      case TalkCategory.news:
        return '📰';
      case TalkCategory.question:
        return '❓';
      case TalkCategory.free:
        return '💬';
    }
  }

  String get description {
    switch (this) {
      case TalkCategory.all:
        return '모든 게시글을 볼 수 있어요';
      case TalkCategory.rumor:
        return '이적설, 계약 관련 소식을 공유해요';
      case TalkCategory.liveChat:
        return '경기 중 실시간으로 이야기해요';
      case TalkCategory.fanArt:
        return '직접 만든 팬아트를 공유해요';
      case TalkCategory.news:
        return '공식 뉴스와 기사를 공유해요';
      case TalkCategory.question:
        return '궁금한 것을 물어보세요';
      case TalkCategory.free:
        return '자유롭게 이야기해요';
    }
  }
}

/// Talk 댓글 모델
class TalkComment {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String? authorAvatar;
  final String content;
  final DateTime createdAt;
  final int likeCount;
  final String? parentCommentId; // 대댓글인 경우

  TalkComment({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    this.authorAvatar,
    required this.content,
    required this.createdAt,
    this.likeCount = 0,
    this.parentCommentId,
  });

  /// Firestore 문서에서 변환
  factory TalkComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return TalkComment(
      id: doc.id,
      postId: data['postId'] as String,
      authorId: data['authorId'] as String,
      authorName: data['authorName'] as String,
      authorAvatar: data['authorAvatar'] as String?,
      content: data['content'] as String,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      likeCount: data['likeCount'] as int? ?? 0,
      parentCommentId: data['parentCommentId'] as String?,
    );
  }

  /// Firestore 문서로 변환
  Map<String, dynamic> toFirestore() {
    return {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorAvatar': authorAvatar,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': likeCount,
      'parentCommentId': parentCommentId,
    };
  }
}
