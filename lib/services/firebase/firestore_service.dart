import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/talk_post.dart';
import '../../models/user_profile.dart';

/// Firestore 데이터베이스 서비스
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ==================== 컬렉션 참조 ====================
  CollectionReference<Map<String, dynamic>> get _usersCollection =>
      _db.collection('users');

  CollectionReference<Map<String, dynamic>> get _postsCollection =>
      _db.collection('posts');

  CollectionReference<Map<String, dynamic>> get _commentsCollection =>
      _db.collection('comments');

  // ==================== 사용자 관련 ====================

  /// 사용자 프로필 생성
  Future<void> createUserProfile(UserProfile profile) async {
    await _usersCollection.doc(profile.id).set(profile.toJson());
  }

  /// 사용자 프로필 조회
  Future<UserProfile?> getUserProfile(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return null;
    return UserProfile.fromJson({...doc.data()!, 'id': doc.id});
  }

  /// 사용자 프로필 업데이트
  Future<void> updateUserProfile(String userId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _usersCollection.doc(userId).update(data);
  }

  /// 사용자 프로필 스트림
  Stream<UserProfile?> getUserProfileStream(String userId) {
    return _usersCollection.doc(userId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromJson({...doc.data()!, 'id': doc.id});
    });
  }

  /// 닉네임 중복 확인
  Future<bool> isNicknameAvailable(String nickname) async {
    final query = await _usersCollection
        .where('nickname', isEqualTo: nickname)
        .limit(1)
        .get();
    return query.docs.isEmpty;
  }

  // ==================== Talk 게시물 관련 ====================

  /// 게시물 생성
  Future<String> createPost(TalkPost post) async {
    final docRef = await _postsCollection.add(post.toFirestore());
    return docRef.id;
  }

  /// 게시물 조회
  Future<TalkPost?> getPost(String postId) async {
    final doc = await _postsCollection.doc(postId).get();
    if (!doc.exists) return null;
    return TalkPost.fromFirestore(doc);
  }

  /// 게시물 목록 조회 (페이지네이션)
  Future<List<TalkPost>> getPosts({
    String? athleteId,
    String? category,
    int limit = 20,
    DocumentSnapshot? lastDocument,
  }) async {
    Query<Map<String, dynamic>> query = _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (athleteId != null) {
      query = query.where('athleteId', isEqualTo: athleteId);
    }

    if (category != null) {
      query = query.where('category', isEqualTo: category);
    }

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snapshot = await query.get();
    return snapshot.docs.map((doc) => TalkPost.fromFirestore(doc)).toList();
  }

  /// 게시물 스트림 (실시간 업데이트)
  Stream<List<TalkPost>> getPostsStream({
    String? athleteId,
    int limit = 20,
  }) {
    Query<Map<String, dynamic>> query = _postsCollection
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (athleteId != null) {
      query = query.where('athleteId', isEqualTo: athleteId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => TalkPost.fromFirestore(doc)).toList();
    });
  }

  /// 게시물 업데이트
  Future<void> updatePost(String postId, Map<String, dynamic> data) async {
    data['updatedAt'] = FieldValue.serverTimestamp();
    await _postsCollection.doc(postId).update(data);
  }

  /// 게시물 삭제
  Future<void> deletePost(String postId) async {
    // 관련 댓글도 함께 삭제
    final commentsQuery = await _commentsCollection
        .where('postId', isEqualTo: postId)
        .get();

    final batch = _db.batch();
    for (final doc in commentsQuery.docs) {
      batch.delete(doc.reference);
    }
    batch.delete(_postsCollection.doc(postId));
    await batch.commit();
  }

  /// 좋아요 토글
  Future<bool> toggleLike(String postId, String userId) async {
    final postRef = _postsCollection.doc(postId);

    return _db.runTransaction<bool>((transaction) async {
      final postDoc = await transaction.get(postRef);
      if (!postDoc.exists) throw Exception('게시물이 존재하지 않습니다.');

      final data = postDoc.data()!;
      final likedBy = List<String>.from(data['likedBy'] ?? []);
      final isLiked = likedBy.contains(userId);

      if (isLiked) {
        likedBy.remove(userId);
      } else {
        likedBy.add(userId);
      }

      transaction.update(postRef, {
        'likedBy': likedBy,
        'likeCount': likedBy.length,
      });

      return !isLiked; // 새로운 좋아요 상태 반환
    });
  }

  // ==================== 댓글 관련 ====================

  /// 댓글 생성
  Future<String> createComment({
    required String postId,
    required String authorId,
    required String authorName,
    required String content,
    String? authorPhotoUrl,
  }) async {
    final commentData = {
      'postId': postId,
      'authorId': authorId,
      'authorName': authorName,
      'authorPhotoUrl': authorPhotoUrl,
      'content': content,
      'createdAt': FieldValue.serverTimestamp(),
      'likeCount': 0,
      'likedBy': <String>[],
    };

    // 댓글 추가
    final docRef = await _commentsCollection.add(commentData);

    // 게시물의 댓글 수 증가
    await _postsCollection.doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });

    return docRef.id;
  }

  /// 댓글 목록 조회
  Future<List<Map<String, dynamic>>> getComments(String postId) async {
    final snapshot = await _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .get();

    return snapshot.docs.map((doc) => {
      ...doc.data(),
      'id': doc.id,
    }).toList();
  }

  /// 댓글 스트림
  Stream<List<Map<String, dynamic>>> getCommentsStream(String postId) {
    return _commentsCollection
        .where('postId', isEqualTo: postId)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {
        ...doc.data(),
        'id': doc.id,
      }).toList();
    });
  }

  /// 댓글 삭제
  Future<void> deleteComment(String commentId, String postId) async {
    final batch = _db.batch();

    batch.delete(_commentsCollection.doc(commentId));
    batch.update(_postsCollection.doc(postId), {
      'commentCount': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  // ==================== 즐겨찾기 선수 관련 ====================

  /// 즐겨찾기 선수 저장
  Future<void> saveFavoriteAthletes(String userId, List<String> athleteIds) async {
    await _usersCollection.doc(userId).update({
      'favoriteAthletes': athleteIds,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// 즐겨찾기 선수 조회
  Future<List<String>> getFavoriteAthletes(String userId) async {
    final doc = await _usersCollection.doc(userId).get();
    if (!doc.exists) return [];

    final data = doc.data();
    return List<String>.from(data?['favoriteAthletes'] ?? []);
  }

  // ==================== 검색 관련 ====================

  /// 게시물 검색
  Future<List<TalkPost>> searchPosts(String query, {int limit = 20}) async {
    // Firestore는 전문 검색을 지원하지 않으므로
    // 실제 프로덕션에서는 Algolia나 Elasticsearch를 사용해야 함
    // 여기서는 태그 기반 검색만 구현
    final snapshot = await _postsCollection
        .where('tags', arrayContains: query.toLowerCase())
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) => TalkPost.fromFirestore(doc)).toList();
  }

  /// 사용자 검색
  Future<List<UserProfile>> searchUsers(String query, {int limit = 20}) async {
    final snapshot = await _usersCollection
        .where('nickname', isGreaterThanOrEqualTo: query)
        .where('nickname', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit)
        .get();

    return snapshot.docs.map((doc) {
      return UserProfile.fromJson({...doc.data(), 'id': doc.id});
    }).toList();
  }

  // ==================== 통계 관련 ====================

  /// 사용자 통계 업데이트
  Future<void> updateUserStats(String userId, {
    int? postCount,
    int? commentCount,
    int? likeReceived,
  }) async {
    final updates = <String, dynamic>{};

    if (postCount != null) {
      updates['stats.postCount'] = FieldValue.increment(postCount);
    }
    if (commentCount != null) {
      updates['stats.commentCount'] = FieldValue.increment(commentCount);
    }
    if (likeReceived != null) {
      updates['stats.likeReceived'] = FieldValue.increment(likeReceived);
    }

    if (updates.isNotEmpty) {
      await _usersCollection.doc(userId).update(updates);
    }
  }
}
