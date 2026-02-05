import 'package:flutter/material.dart';

class WeatherWidget extends StatelessWidget {
  final String condition;
  final double temperature;
  final String city;

  const WeatherWidget({
    super.key,
    required this.condition,
    required this.temperature,
    required this.city,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // 날씨 아이콘
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                _getWeatherEmoji(),
                style: const TextStyle(fontSize: 32),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // 날씨 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  city,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '${temperature.round()}°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _getConditionText(),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 현지 시간
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '현지 시간',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getCurrentLocalTime(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getBackgroundColor() {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return const Color(0xFF4A90D9);
      case 'clouds':
      case 'cloudy':
        return const Color(0xFF6B7B8C);
      case 'rain':
      case 'drizzle':
        return const Color(0xFF5C6B7D);
      case 'snow':
        return const Color(0xFF8BA5B5);
      case 'thunderstorm':
        return const Color(0xFF4A5568);
      default:
        return const Color(0xFF1E4A6E);
    }
  }

  String _getWeatherEmoji() {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return '☀️';
      case 'clouds':
      case 'cloudy':
        return '☁️';
      case 'rain':
        return '🌧️';
      case 'drizzle':
        return '🌦️';
      case 'snow':
        return '❄️';
      case 'thunderstorm':
        return '⛈️';
      case 'fog':
      case 'mist':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  String _getConditionText() {
    switch (condition.toLowerCase()) {
      case 'clear':
      case 'sunny':
        return '맑음';
      case 'clouds':
      case 'cloudy':
        return '흐림';
      case 'rain':
        return '비';
      case 'drizzle':
        return '이슬비';
      case 'snow':
        return '눈';
      case 'thunderstorm':
        return '뇌우';
      case 'fog':
      case 'mist':
        return '안개';
      default:
        return condition;
    }
  }

  String _getCurrentLocalTime() {
    // TODO: 실제 현지 시간 계산
    final now = DateTime.now();
    return '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  }
}
