import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

/// 공유 및 외부 링크 서비스
class ShareService {
  static final ShareService _instance = ShareService._();
  factory ShareService() => _instance;
  ShareService._();

  /// 텍스트 공유
  Future<void> shareText(String text, {String? subject}) async {
    await Share.share(text, subject: subject);
  }

  /// 게시글 공유
  Future<void> sharePost({
    required String title,
    required String content,
    String? url,
  }) async {
    final shareText = '''
$title

$content
${url != null ? '\n$url' : ''}

K-Player Tracker 앱에서 확인하세요!
''';
    await Share.share(shareText, subject: title);
  }

  /// 뉴스 공유
  Future<void> shareNews({
    required String title,
    required String source,
    String? url,
  }) async {
    final shareText = '''
$title

출처: $source
${url != null ? '\n$url' : ''}

K-Player Tracker 앱에서 확인하세요!
''';
    await Share.share(shareText, subject: title);
  }

  /// 경기 정보 공유
  Future<void> shareMatch({
    required String homeTeam,
    required String awayTeam,
    required String competition,
    required DateTime kickoffTime,
    String? venue,
  }) async {
    final formattedDate = '${kickoffTime.month}/${kickoffTime.day} ${kickoffTime.hour}:${kickoffTime.minute.toString().padLeft(2, '0')}';
    final shareText = '''
⚽ $homeTeam vs $awayTeam
🏆 $competition
📅 $formattedDate
${venue != null ? '📍 $venue' : ''}

K-Player Tracker 앱에서 확인하세요!
''';
    await Share.share(shareText, subject: '$homeTeam vs $awayTeam');
  }

  /// 선수 프로필 공유
  Future<void> sharePlayer({
    required String name,
    required String team,
    required int goals,
    required int assists,
  }) async {
    final shareText = '''
⭐ $name
🏟️ $team
⚽ $goals골 👟 $assists어시스트

K-Player Tracker 앱에서 더 많은 정보를 확인하세요!
''';
    await Share.share(shareText, subject: '$name 선수 프로필');
  }

  /// URL 열기
  Future<bool> openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// 중계 링크 열기
  Future<bool> openBroadcastLink(String channel) async {
    String? url;

    switch (channel.toLowerCase()) {
      case 'spotv on':
      case 'spotv':
        url = 'https://www.spotvnow.co.kr/';
        break;
      case 'tving':
        url = 'https://www.tving.com/';
        break;
      case 'coupang play':
      case 'coupangplay':
        url = 'https://www.coupangplay.com/';
        break;
      case 'sbs':
        url = 'https://www.sbs.co.kr/';
        break;
      case 'kbs':
        url = 'https://www.kbs.co.kr/';
        break;
      case 'mbc':
        url = 'https://www.imbc.com/';
        break;
      default:
        return false;
    }

    return await openUrl(url);
  }

  /// 앱 공유
  Future<void> shareApp() async {
    const shareText = '''
K-Player Tracker - 해외파 축구선수 추적기

좋아하는 선수의 모든 소식을 한눈에!
⚽ 경기 일정 및 실시간 스코어
📰 최신 뉴스 자동 번역
💬 팬 커뮤니티

지금 다운로드하세요!
''';
    await Share.share(shareText, subject: 'K-Player Tracker 앱 추천');
  }

  /// SNS 링크 열기
  Future<bool> openSocialMedia(String platform, String username) async {
    String url;

    switch (platform.toLowerCase()) {
      case 'instagram':
        url = 'https://www.instagram.com/$username';
        break;
      case 'twitter':
      case 'x':
        url = 'https://twitter.com/$username';
        break;
      case 'youtube':
        url = 'https://www.youtube.com/@$username';
        break;
      case 'facebook':
        url = 'https://www.facebook.com/$username';
        break;
      default:
        return false;
    }

    return await openUrl(url);
  }
}
