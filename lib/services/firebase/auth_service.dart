import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart';

/// Firebase 인증 서비스
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  /// 현재 사용자
  User? get currentUser => _auth.currentUser;

  /// 인증 상태 스트림
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// 로그인 상태 확인
  bool get isLoggedIn => currentUser != null;

  /// 이메일/비밀번호로 회원가입
  Future<AuthResult> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 사용자 이름 설정
      if (displayName != null && credential.user != null) {
        await credential.user!.updateDisplayName(displayName);
      }

      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('회원가입 중 오류가 발생했습니다: $e');
    }
  }

  /// 이메일/비밀번호로 로그인
  Future<AuthResult> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return AuthResult.success(credential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('로그인 중 오류가 발생했습니다: $e');
    }
  }

  /// Google 로그인
  Future<AuthResult> signInWithGoogle() async {
    try {
      // Google 로그인 플로우 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        return AuthResult.failure('Google 로그인이 취소되었습니다.');
      }

      // 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Firebase 자격증명 생성
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Firebase에 로그인
      final userCredential = await _auth.signInWithCredential(credential);
      return AuthResult.success(userCredential.user);
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      debugPrint('Google 로그인 오류: $e');
      return AuthResult.failure('Google 로그인 중 오류가 발생했습니다.');
    }
  }

  /// 비밀번호 재설정 이메일 전송
  Future<AuthResult> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return AuthResult.success(null, message: '비밀번호 재설정 이메일이 전송되었습니다.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('이메일 전송 중 오류가 발생했습니다.');
    }
  }

  /// 이메일 인증 전송
  Future<AuthResult> sendEmailVerification() async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('로그인이 필요합니다.');
      }

      await user.sendEmailVerification();
      return AuthResult.success(null, message: '인증 이메일이 전송되었습니다.');
    } catch (e) {
      return AuthResult.failure('이메일 전송 중 오류가 발생했습니다.');
    }
  }

  /// 프로필 업데이트
  Future<AuthResult> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('로그인이 필요합니다.');
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }
      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();
      return AuthResult.success(_auth.currentUser);
    } catch (e) {
      return AuthResult.failure('프로필 업데이트 중 오류가 발생했습니다.');
    }
  }

  /// 비밀번호 변경
  Future<AuthResult> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = currentUser;
      if (user == null || user.email == null) {
        return AuthResult.failure('로그인이 필요합니다.');
      }

      // 재인증
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // 비밀번호 변경
      await user.updatePassword(newPassword);
      return AuthResult.success(null, message: '비밀번호가 변경되었습니다.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('비밀번호 변경 중 오류가 발생했습니다.');
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      _googleSignIn.signOut(),
    ]);
  }

  /// 계정 삭제
  Future<AuthResult> deleteAccount({String? password}) async {
    try {
      final user = currentUser;
      if (user == null) {
        return AuthResult.failure('로그인이 필요합니다.');
      }

      // 비밀번호가 제공된 경우 재인증
      if (password != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }

      await user.delete();
      return AuthResult.success(null, message: '계정이 삭제되었습니다.');
    } on FirebaseAuthException catch (e) {
      return AuthResult.failure(_getErrorMessage(e.code));
    } catch (e) {
      return AuthResult.failure('계정 삭제 중 오류가 발생했습니다.');
    }
  }

  /// 에러 메시지 변환
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return '이미 사용 중인 이메일입니다.';
      case 'invalid-email':
        return '올바른 이메일 형식이 아닙니다.';
      case 'operation-not-allowed':
        return '이메일/비밀번호 로그인이 비활성화되어 있습니다.';
      case 'weak-password':
        return '비밀번호가 너무 약합니다. 6자 이상 입력해주세요.';
      case 'user-disabled':
        return '비활성화된 계정입니다.';
      case 'user-not-found':
        return '존재하지 않는 계정입니다.';
      case 'wrong-password':
        return '비밀번호가 일치하지 않습니다.';
      case 'invalid-credential':
        return '이메일 또는 비밀번호가 올바르지 않습니다.';
      case 'too-many-requests':
        return '요청이 너무 많습니다. 잠시 후 다시 시도해주세요.';
      case 'network-request-failed':
        return '네트워크 오류가 발생했습니다.';
      case 'requires-recent-login':
        return '보안을 위해 다시 로그인해주세요.';
      default:
        return '오류가 발생했습니다. ($code)';
    }
  }
}

/// 인증 결과
class AuthResult {
  final bool isSuccess;
  final User? user;
  final String? errorMessage;
  final String? successMessage;

  AuthResult._({
    required this.isSuccess,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  factory AuthResult.success(User? user, {String? message}) {
    return AuthResult._(
      isSuccess: true,
      user: user,
      successMessage: message,
    );
  }

  factory AuthResult.failure(String message) {
    return AuthResult._(
      isSuccess: false,
      errorMessage: message,
    );
  }
}
