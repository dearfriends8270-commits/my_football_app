import '../models/match.dart';

enum MatchdayMode {
  normal,    // 일반 모드
  hype,      // 경기 6시간 전 ~ 경기 시작
  live,      // 경기 중
  postMatch, // 경기 후 (스탯 카드 생성)
}

class MatchdayService {
  static final MatchdayService _instance = MatchdayService._internal();
  factory MatchdayService() => _instance;
  MatchdayService._internal();

  /// 현재 매치데이 모드 확인
  MatchdayMode getMatchdayMode(Match? match) {
    if (match == null) return MatchdayMode.normal;

    final now = DateTime.now();
    final matchTime = match.dateTime;
    final timeDiff = matchTime.difference(now);

    // 경기 중
    if (match.isLive) {
      return MatchdayMode.live;
    }

    // 경기 종료 후 2시간 이내
    if (timeDiff.isNegative && timeDiff.inHours >= -2) {
      return MatchdayMode.postMatch;
    }

    // 경기 6시간 전부터 Hype 모드
    if (timeDiff.inHours <= 6 && timeDiff.inHours > 0) {
      return MatchdayMode.hype;
    }

    return MatchdayMode.normal;
  }

  /// 모드별 테마 색상
  Map<String, dynamic> getThemeForMode(MatchdayMode mode, {String? teamColor}) {
    switch (mode) {
      case MatchdayMode.hype:
        return {
          'primaryColor': teamColor ?? '#004170', // PSG Blue
          'accentColor': '#FFD700', // Gold
          'backgroundColor': '#001428',
          'textColor': '#FFFFFF',
          'animationIntensity': 0.7,
        };
      case MatchdayMode.live:
        return {
          'primaryColor': '#ED174B', // 강렬한 레드
          'accentColor': '#FFD700',
          'backgroundColor': '#1A0A10',
          'textColor': '#FFFFFF',
          'animationIntensity': 1.0,
        };
      case MatchdayMode.postMatch:
        return {
          'primaryColor': '#1E4A6E',
          'accentColor': '#4CAF50', // 그린 (완료)
          'backgroundColor': '#0A1A28',
          'textColor': '#FFFFFF',
          'animationIntensity': 0.3,
        };
      default:
        return {
          'primaryColor': '#1E4A6E',
          'accentColor': '#5B9BD5',
          'backgroundColor': '#FFFFFF',
          'textColor': '#1A1A1A',
          'animationIntensity': 0.0,
        };
    }
  }

  /// Hype 모드 메시지 생성
  String getHypeMessage(Match match, WeatherInfo? weather) {
    final messages = <String>[];

    // 현지 날씨 정보
    if (weather != null) {
      if (weather.isRaining) {
        messages.add('현재 ${match.stadiumCity ?? "현지"}는 비가 옵니다. 수중전이 예상되네요! 🌧️');
      } else if (weather.temperature < 5) {
        messages.add('현재 ${match.stadiumCity ?? "현지"}는 ${weather.temperature}°C! 추운 날씨 속 열정 경기! ❄️');
      } else if (weather.temperature > 25) {
        messages.add('현재 ${match.stadiumCity ?? "현지"}는 ${weather.temperature}°C! 뜨거운 열기! 🔥');
      } else {
        messages.add('${match.stadiumCity ?? "현지"} 날씨 ${weather.temperature}°C, 완벽한 축구 날씨! ⚽');
      }
    }

    // 경기장 정보
    if (match.stadium != null) {
      messages.add('🏟️ ${match.stadium}의 조명이 켜지고 있습니다!');
    }

    return messages.isNotEmpty ? messages.first : '경기 준비 중입니다! ⚽';
  }

  /// 카운트다운 텍스트
  String getCountdownText(Match match) {
    final now = DateTime.now();
    final diff = match.dateTime.difference(now);

    if (diff.isNegative) {
      if (match.isLive) {
        return '🔴 LIVE';
      }
      return '경기 종료';
    }

    if (diff.inDays > 0) {
      return 'D-${diff.inDays}';
    } else if (diff.inHours > 0) {
      return '${diff.inHours}시간 ${diff.inMinutes % 60}분 후';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes}분 후';
    } else {
      return '곧 시작!';
    }
  }

  /// Live 모드 실시간 평점 (시뮬레이션)
  double getLiveRating(String playerId) {
    // 실제로는 API에서 실시간 데이터를 받아옴
    // 여기서는 랜덤 시뮬레이션
    final baseRating = 7.0;
    final variation = (DateTime.now().second % 10) / 10.0 - 0.5;
    return (baseRating + variation).clamp(5.0, 10.0);
  }
}

class WeatherInfo {
  final double temperature;
  final String condition;
  final String icon;
  final bool isRaining;
  final int humidity;
  final double windSpeed;

  WeatherInfo({
    required this.temperature,
    required this.condition,
    required this.icon,
    this.isRaining = false,
    this.humidity = 50,
    this.windSpeed = 0,
  });

  factory WeatherInfo.mock({String city = 'Paris'}) {
    // Mock 데이터
    return WeatherInfo(
      temperature: 12,
      condition: '맑음',
      icon: '☀️',
      isRaining: false,
      humidity: 65,
      windSpeed: 12,
    );
  }
}
