import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/match.dart';
import '../services/matchday_service.dart';

// Matchday Service Provider
final matchdayServiceProvider = Provider<MatchdayService>((ref) {
  return MatchdayService();
});

// 현재 매치데이 모드 Provider
final matchdayModeProvider = Provider.family<MatchdayMode, Match?>((ref, match) {
  final service = ref.watch(matchdayServiceProvider);
  return service.getMatchdayMode(match);
});

// 테마 Provider
final matchdayThemeProvider = Provider.family<Map<String, dynamic>, MatchdayMode>((ref, mode) {
  final service = ref.watch(matchdayServiceProvider);
  return service.getThemeForMode(mode);
});

// 날씨 정보 Provider (Mock)
final weatherInfoProvider = FutureProvider.family<WeatherInfo, String>((ref, city) async {
  // 실제로는 OpenWeatherMap API 호출
  await Future.delayed(const Duration(milliseconds: 500));
  return WeatherInfo.mock(city: city);
});

// Hype 메시지 Provider
final hypeMessageProvider = Provider.family<String, Match>((ref, match) {
  final service = ref.watch(matchdayServiceProvider);
  final weatherAsync = ref.watch(weatherInfoProvider(match.stadiumCity ?? 'Paris'));

  final weather = weatherAsync.whenOrNull(data: (data) => data);
  return service.getHypeMessage(match, weather);
});

// 카운트다운 Provider
final countdownProvider = Provider.family<String, Match>((ref, match) {
  final service = ref.watch(matchdayServiceProvider);
  return service.getCountdownText(match);
});

// 실시간 평점 Provider (경기 중)
final liveRatingProvider = StreamProvider.family<double, String>((ref, playerId) async* {
  final service = ref.watch(matchdayServiceProvider);

  // 5초마다 평점 업데이트 (시뮬레이션)
  while (true) {
    yield service.getLiveRating(playerId);
    await Future.delayed(const Duration(seconds: 5));
  }
});

// 탭톡 감정 데이터
class TapTalkEmotion {
  final String emoji;
  final String label;
  final int count;
  final double percentage;

  TapTalkEmotion({
    required this.emoji,
    required this.label,
    required this.count,
    required this.percentage,
  });
}

// 탭톡 상태 관리
class TapTalkState {
  final Map<String, int> emotionCounts;
  final int totalCount;

  TapTalkState({
    this.emotionCounts = const {},
    this.totalCount = 0,
  });

  TapTalkState copyWith({
    Map<String, int>? emotionCounts,
    int? totalCount,
  }) {
    return TapTalkState(
      emotionCounts: emotionCounts ?? this.emotionCounts,
      totalCount: totalCount ?? this.totalCount,
    );
  }

  List<TapTalkEmotion> get emotions {
    final result = <TapTalkEmotion>[];
    final emotions = {
      'wow': {'emoji': '😲', 'label': '와!'},
      'amazing': {'emoji': '🔥', 'label': '대박'},
      'sad': {'emoji': '😢', 'label': '아쉽다'},
      'angry': {'emoji': '😡', 'label': '화난다'},
      'happy': {'emoji': '😄', 'label': '좋아요'},
      'goal': {'emoji': '⚽', 'label': '골!'},
    };

    for (final entry in emotions.entries) {
      final count = emotionCounts[entry.key] ?? 0;
      final percentage = totalCount > 0 ? count / totalCount * 100 : 0.0;
      result.add(TapTalkEmotion(
        emoji: entry.value['emoji']!,
        label: entry.value['label']!,
        count: count,
        percentage: percentage,
      ));
    }

    return result;
  }
}

// 탭톡 Notifier
class TapTalkNotifier extends StateNotifier<TapTalkState> {
  TapTalkNotifier() : super(TapTalkState(
    emotionCounts: {
      'wow': 245,
      'amazing': 389,
      'sad': 56,
      'angry': 23,
      'happy': 178,
      'goal': 412,
    },
    totalCount: 1303,
  ));

  void addEmotion(String emotionKey) {
    final newCounts = Map<String, int>.from(state.emotionCounts);
    newCounts[emotionKey] = (newCounts[emotionKey] ?? 0) + 1;

    state = state.copyWith(
      emotionCounts: newCounts,
      totalCount: state.totalCount + 1,
    );
  }

  void reset() {
    state = TapTalkState();
  }
}

final tapTalkProvider = StateNotifierProvider<TapTalkNotifier, TapTalkState>((ref) {
  return TapTalkNotifier();
});
