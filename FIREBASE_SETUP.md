# Firebase 설정 가이드

## 1. Firebase 프로젝트 생성

1. [Firebase Console](https://console.firebase.google.com/)에 접속
2. "프로젝트 추가" 클릭
3. 프로젝트 이름 입력 (예: k-player-tracker)
4. Google Analytics 설정 (선택사항)
5. 프로젝트 생성 완료

## 2. Android 앱 등록

### 2.1 Firebase Console에서 Android 앱 추가
1. 프로젝트 개요 페이지에서 Android 아이콘 클릭
2. Android 패키지 이름 입력: `com.example.my_football_app`
   - `android/app/build.gradle`의 `applicationId` 확인
3. 앱 닉네임 입력 (선택): K-Player Tracker
4. SHA-1 인증서 지문 (Google 로그인 사용 시 필수)

### 2.2 SHA-1 키 생성
```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# macOS/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

### 2.3 google-services.json 다운로드
1. Firebase Console에서 google-services.json 다운로드
2. 파일을 `android/app/` 폴더에 복사

## 3. Android 설정

### 3.1 android/build.gradle 수정
```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

### 3.2 android/app/build.gradle 수정
```gradle
apply plugin: 'com.google.gms.google-services'

android {
    defaultConfig {
        minSdkVersion 21  // 최소 SDK 21 필요
    }
}
```

## 4. iOS 앱 등록 (선택사항)

### 4.1 Firebase Console에서 iOS 앱 추가
1. iOS 번들 ID 입력: `com.example.myFootballApp`
2. GoogleService-Info.plist 다운로드
3. 파일을 `ios/Runner/` 폴더에 복사

### 4.2 Xcode에서 GoogleService-Info.plist 추가
1. Xcode에서 프로젝트 열기
2. Runner 폴더에 GoogleService-Info.plist 드래그&드롭
3. "Copy items if needed" 체크

## 5. Firebase 서비스 활성화

### 5.1 Authentication 설정
1. Firebase Console > Authentication > Sign-in method
2. "이메일/비밀번호" 활성화
3. "Google" 활성화 (선택사항)

### 5.2 Firestore Database 설정
1. Firebase Console > Firestore Database
2. "데이터베이스 만들기" 클릭
3. "테스트 모드에서 시작" 선택 (개발용)
4. 위치 선택 (asia-northeast3 - 서울 권장)

### 5.3 Firestore 보안 규칙 (프로덕션용)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 사용자 프로필
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }

    // 게시물
    match /posts/{postId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        request.auth.uid == resource.data.authorId;
    }

    // 댓글
    match /comments/{commentId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null &&
        request.auth.uid == resource.data.authorId;
    }
  }
}
```

## 6. 빌드 및 테스트

```bash
# 패키지 설치
flutter pub get

# Android 빌드
flutter build apk --debug

# 실행
flutter run
```

## 7. 문제 해결

### google-services.json이 없는 경우
- Firebase Console에서 다시 다운로드
- `android/app/` 폴더에 복사되었는지 확인

### minSdkVersion 오류
- `android/app/build.gradle`에서 `minSdkVersion 21` 이상으로 설정

### Google 로그인 실패
- SHA-1 키가 Firebase Console에 등록되었는지 확인
- `google-services.json`이 최신 버전인지 확인

## 8. 무료 할당량

Firebase 무료 플랜 (Spark):
- Authentication: 월 50,000 MAU
- Firestore: 일일 읽기 50,000회, 쓰기 20,000회
- Storage: 5GB 저장, 일일 1GB 다운로드
- Hosting: 10GB 저장, 월 125K 요청
