import 'package:flutter/material.dart';

/// 지원하는 스포츠 종목
enum SportType {
  football,
  baseball,
  badminton,
  swimming,
  golf,
  basketball,
}

extension SportTypeExtension on SportType {
  String get displayName {
    switch (this) {
      case SportType.football:
        return '축구';
      case SportType.baseball:
        return '야구';
      case SportType.badminton:
        return '배드민턴';
      case SportType.swimming:
        return '수영';
      case SportType.golf:
        return '골프';
      case SportType.basketball:
        return '농구';
    }
  }

  String get englishName {
    switch (this) {
      case SportType.football:
        return 'FOOTBALL';
      case SportType.baseball:
        return 'BASEBALL';
      case SportType.badminton:
        return 'BADMINTON';
      case SportType.swimming:
        return 'SWIMMING';
      case SportType.golf:
        return 'GOLF';
      case SportType.basketball:
        return 'BASKETBALL';
    }
  }

  String get icon {
    switch (this) {
      case SportType.football:
        return '⚽';
      case SportType.baseball:
        return '⚾';
      case SportType.badminton:
        return '🏸';
      case SportType.swimming:
        return '🏊';
      case SportType.golf:
        return '⛳';
      case SportType.basketball:
        return '🏀';
    }
  }

  IconData get iconData {
    switch (this) {
      case SportType.football:
        return Icons.sports_soccer;
      case SportType.baseball:
        return Icons.sports_baseball;
      case SportType.badminton:
        return Icons.sports_tennis;
      case SportType.swimming:
        return Icons.pool;
      case SportType.golf:
        return Icons.golf_course;
      case SportType.basketball:
        return Icons.sports_basketball;
    }
  }

  /// 종목별 메인 컬러
  Color get primaryColor {
    switch (this) {
      case SportType.football:
        return const Color(0xFF001C58); // Navy
      case SportType.baseball:
        return const Color(0xFF1E4D2B); // Green
      case SportType.badminton:
        return const Color(0xFF6B21A8); // Purple
      case SportType.swimming:
        return const Color(0xFF0284C7); // Blue
      case SportType.golf:
        return const Color(0xFF10B981); // Emerald
      case SportType.basketball:
        return const Color(0xFFEA580C); // Orange
    }
  }

  /// 종목별 서브 컬러
  Color get secondaryColor {
    switch (this) {
      case SportType.football:
        return const Color(0xFFED174B); // Red
      case SportType.baseball:
        return const Color(0xFFFFD700); // Gold
      case SportType.badminton:
        return const Color(0xFF06B6D4); // Cyan
      case SportType.swimming:
        return const Color(0xFFFFFFFF); // White
      case SportType.golf:
        return const Color(0xFFFEF3C7); // Cream
      case SportType.basketball:
        return const Color(0xFF171717); // Black
    }
  }

  /// 종목별 스탯 라벨
  List<String> get statLabels {
    switch (this) {
      case SportType.football:
        return ['골', '어시스트', '평점'];
      case SportType.baseball:
        return ['타율', '홈런', '타점'];
      case SportType.badminton:
        return ['세계랭킹', '시즌 승', '승률'];
      case SportType.swimming:
        return ['주종목', '기록', '세계랭킹'];
      case SportType.golf:
        return ['세계랭킹', '시즌 승', '상금'];
      case SportType.basketball:
        return ['득점', '리바운드', '어시스트'];
    }
  }
}
