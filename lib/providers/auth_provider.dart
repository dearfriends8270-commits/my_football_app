import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firebase/auth_service.dart';
import '../services/firebase/firestore_service.dart';
import '../models/user_profile.dart';

/// 인증 상태
enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
}

/// 인증 상태 모델
class AuthState {
  final AuthStatus status;
  final User? firebaseUser;
  final UserProfile? userProfile;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.firebaseUser,
    this.userProfile,
    this.errorMessage,
  });

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isLoading => status == AuthStatus.loading;

  AuthState copyWith({
    AuthStatus? status,
    User? firebaseUser,
    UserProfile? userProfile,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      firebaseUser: firebaseUser ?? this.firebaseUser,
      userProfile: userProfile ?? this.userProfile,
      errorMessage: errorMessage,
    );
  }
}

/// 인증 Notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;
  final FirestoreService _firestoreService;
  StreamSubscription<User?>? _authSubscription;

  AuthNotifier({
    required AuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService,
        super(const AuthState()) {
    _init();
  }

  void _init() {
    _authSubscription = _authService.authStateChanges.listen((user) async {
      if (user != null) {
        // 사용자 프로필 로드
        final profile = await _firestoreService.getUserProfile(user.uid);
        state = AuthState(
          status: AuthStatus.authenticated,
          firebaseUser: user,
          userProfile: profile,
        );
      } else {
        state = const AuthState(status: AuthStatus.unauthenticated);
      }
    });
  }

  /// 이메일 회원가입
  Future<bool> signUpWithEmail({
    required String email,
    required String password,
    required String nickname,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    // 닉네임 중복 확인
    final isAvailable = await _firestoreService.isNicknameAvailable(nickname);
    if (!isAvailable) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: '이미 사용 중인 닉네임입니다.',
      );
      return false;
    }

    final result = await _authService.signUpWithEmail(
      email: email,
      password: password,
      displayName: nickname,
    );

    if (result.isSuccess && result.user != null) {
      // 사용자 프로필 생성
      final profile = UserProfile.fromFirebaseUser(
        uid: result.user!.uid,
        email: email,
        displayName: nickname,
      );
      await _firestoreService.createUserProfile(profile);

      state = AuthState(
        status: AuthStatus.authenticated,
        firebaseUser: result.user,
        userProfile: profile,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// 이메일 로그인
  Future<bool> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.signInWithEmail(
      email: email,
      password: password,
    );

    if (result.isSuccess && result.user != null) {
      final profile = await _firestoreService.getUserProfile(result.user!.uid);
      state = AuthState(
        status: AuthStatus.authenticated,
        firebaseUser: result.user,
        userProfile: profile,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// Google 로그인
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);

    final result = await _authService.signInWithGoogle();

    if (result.isSuccess && result.user != null) {
      // 기존 프로필 확인 또는 새로 생성
      var profile = await _firestoreService.getUserProfile(result.user!.uid);

      if (profile == null) {
        profile = UserProfile.fromFirebaseUser(
          uid: result.user!.uid,
          email: result.user!.email!,
          displayName: result.user!.displayName,
          photoURL: result.user!.photoURL,
        );
        await _firestoreService.createUserProfile(profile);
      }

      state = AuthState(
        status: AuthStatus.authenticated,
        firebaseUser: result.user,
        userProfile: profile,
      );
      return true;
    } else {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        errorMessage: result.errorMessage,
      );
      return false;
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<bool> sendPasswordResetEmail(String email) async {
    final result = await _authService.sendPasswordResetEmail(email);
    if (!result.isSuccess) {
      state = state.copyWith(errorMessage: result.errorMessage);
    }
    return result.isSuccess;
  }

  /// 프로필 업데이트
  Future<bool> updateProfile({
    String? nickname,
    String? bio,
    String? photoUrl,
  }) async {
    if (state.userProfile == null) return false;

    final updates = <String, dynamic>{};
    if (nickname != null) updates['nickname'] = nickname;
    if (bio != null) updates['bio'] = bio;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    try {
      await _firestoreService.updateUserProfile(
        state.userProfile!.id,
        updates,
      );

      // 로컬 상태 업데이트
      state = state.copyWith(
        userProfile: state.userProfile!.copyWith(
          nickname: nickname ?? state.userProfile!.nickname,
          bio: bio ?? state.userProfile!.bio,
          photoUrl: photoUrl ?? state.userProfile!.photoUrl,
        ),
      );
      return true;
    } catch (e) {
      state = state.copyWith(errorMessage: '프로필 업데이트에 실패했습니다.');
      return false;
    }
  }

  /// 즐겨찾기 선수 저장
  Future<void> saveFavoriteAthletes(List<String> athleteIds) async {
    if (state.userProfile == null) return;

    await _firestoreService.saveFavoriteAthletes(
      state.userProfile!.id,
      athleteIds,
    );

    state = state.copyWith(
      userProfile: state.userProfile!.copyWith(
        favoriteAthletes: athleteIds,
      ),
    );
  }

  /// 로그아웃
  Future<void> signOut() async {
    await _authService.signOut();
    state = const AuthState(status: AuthStatus.unauthenticated);
  }

  /// 계정 삭제
  Future<bool> deleteAccount({String? password}) async {
    final result = await _authService.deleteAccount(password: password);
    if (result.isSuccess) {
      state = const AuthState(status: AuthStatus.unauthenticated);
      return true;
    } else {
      state = state.copyWith(errorMessage: result.errorMessage);
      return false;
    }
  }

  /// 에러 메시지 클리어
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// AuthService Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

/// FirestoreService Provider
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

/// Auth State Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    authService: ref.watch(authServiceProvider),
    firestoreService: ref.watch(firestoreServiceProvider),
  );
});

/// 현재 사용자 프로필 Provider
final currentUserProfileProvider = Provider<UserProfile?>((ref) {
  return ref.watch(authProvider).userProfile;
});

/// 로그인 상태 Provider
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
