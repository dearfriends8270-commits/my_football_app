import 'package:cloud_firestore/cloud_firestore.dart';

/// 사용자 프로필 모델
class UserProfile {
  final String id;
  final String email;
  final String nickname;
  final String? photoUrl;
  final String? bio;
  final List<String> favoriteAthletes;
  final UserStats stats;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isEmailVerified;
  final String? fcmToken;

  UserProfile({
    required this.id,
    required this.email,
    required this.nickname,
    this.photoUrl,
    this.bio,
    this.favoriteAthletes = const [],
    UserStats? stats,
    DateTime? createdAt,
    this.updatedAt,
    this.isEmailVerified = false,
    this.fcmToken,
  })  : stats = stats ?? UserStats(),
        createdAt = createdAt ?? DateTime.now();

  /// Firebase User로부터 프로필 생성
  factory UserProfile.fromFirebaseUser({
    required String uid,
    required String email,
    String? displayName,
    String? photoURL,
  }) {
    return UserProfile(
      id: uid,
      email: email,
      nickname: displayName ?? email.split('@').first,
      photoUrl: photoURL,
    );
  }

  /// JSON에서 변환
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      email: json['email'] as String,
      nickname: json['nickname'] as String,
      photoUrl: json['photoUrl'] as String?,
      bio: json['bio'] as String?,
      favoriteAthletes: List<String>.from(json['favoriteAthletes'] ?? []),
      stats: UserStats.fromJson(json['stats'] as Map<String, dynamic>? ?? {}),
      createdAt: _parseDateTime(json['createdAt']),
      updatedAt: _parseDateTime(json['updatedAt']),
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  /// JSON으로 변환
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nickname': nickname,
      'photoUrl': photoUrl,
      'bio': bio,
      'favoriteAthletes': favoriteAthletes,
      'stats': stats.toJson(),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'isEmailVerified': isEmailVerified,
      'fcmToken': fcmToken,
    };
  }

  /// 복사본 생성
  UserProfile copyWith({
    String? id,
    String? email,
    String? nickname,
    String? photoUrl,
    String? bio,
    List<String>? favoriteAthletes,
    UserStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? fcmToken,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      favoriteAthletes: favoriteAthletes ?? this.favoriteAthletes,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      fcmToken: fcmToken ?? this.fcmToken,
    );
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }
}

/// 사용자 활동 통계
class UserStats {
  final int postCount;
  final int commentCount;
  final int likeReceived;
  final int likeGiven;

  UserStats({
    this.postCount = 0,
    this.commentCount = 0,
    this.likeReceived = 0,
    this.likeGiven = 0,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      postCount: json['postCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      likeReceived: json['likeReceived'] as int? ?? 0,
      likeGiven: json['likeGiven'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'postCount': postCount,
      'commentCount': commentCount,
      'likeReceived': likeReceived,
      'likeGiven': likeGiven,
    };
  }

  UserStats copyWith({
    int? postCount,
    int? commentCount,
    int? likeReceived,
    int? likeGiven,
  }) {
    return UserStats(
      postCount: postCount ?? this.postCount,
      commentCount: commentCount ?? this.commentCount,
      likeReceived: likeReceived ?? this.likeReceived,
      likeGiven: likeGiven ?? this.likeGiven,
    );
  }
}
