import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/athlete.dart';
import '../../models/sport_type.dart';

/// 육각형 레이더 차트 위젯 (기획문서 4.2.8 데이터 시각화)
class RadarChartWidget extends StatelessWidget {
  final Athlete athlete;
  final double size;

  const RadarChartWidget({
    super.key,
    required this.athlete,
    this.size = 200,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: RadarChartPainter(
          athlete: athlete,
          primaryColor: athlete.teamColor,
        ),
      ),
    );
  }
}

class RadarChartPainter extends CustomPainter {
  final Athlete athlete;
  final Color primaryColor;

  RadarChartPainter({
    required this.athlete,
    required this.primaryColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 30;

    // 능력치 데이터 (0-100)
    final stats = _getStats();
    final labels = _getLabels();

    // 배경 그리드 그리기
    _drawBackground(canvas, center, radius);

    // 데이터 영역 그리기
    _drawDataArea(canvas, center, radius, stats);

    // 라벨 그리기
    _drawLabels(canvas, center, radius, labels);

    // 데이터 포인트 그리기
    _drawDataPoints(canvas, center, radius, stats);
  }

  List<double> _getStats() {
    // 종목별 스탯 기본값 (실제 데이터가 있으면 대체 가능)
    if (athlete.sport == SportType.football) {
      return [
        80.0, // 속도
        75.0, // 슈팅
        88.0, // 패스
        90.0, // 드리블
        45.0, // 수비
        65.0, // 피지컬
      ];
    } else if (athlete.sport == SportType.baseball) {
      return [
        75.0, // 파워
        88.0, // 컨택
        80.0, // 스피드
        85.0, // 수비
        70.0, // 어깨
        75.0, // 시야
      ];
    }
    // 기본값
    return [75, 70, 80, 85, 45, 65];
  }

  List<String> _getLabels() {
    if (athlete.sport == SportType.football) {
      return ['속도', '슈팅', '패스', '드리블', '수비', '피지컬'];
    } else if (athlete.sport == SportType.baseball) {
      return ['파워', '컨택', '스피드', '수비', '어깨', '시야'];
    }
    return ['스킬1', '스킬2', '스킬3', '스킬4', '스킬5', '스킬6'];
  }

  void _drawBackground(Canvas canvas, Offset center, double radius) {
    final backgroundPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 5개의 동심원 그리드
    for (int i = 1; i <= 5; i++) {
      final gridRadius = radius * i / 5;
      final path = _createHexagonPath(center, gridRadius);
      canvas.drawPath(path, i == 5 ? gridPaint : backgroundPaint);
      canvas.drawPath(path, gridPaint);
    }

    // 중심에서 각 꼭지점으로 선 그리기
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final endPoint = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      canvas.drawLine(center, endPoint, gridPaint);
    }
  }

  void _drawDataArea(Canvas canvas, Offset center, double radius, List<double> stats) {
    final fillPaint = Paint()
      ..color = primaryColor.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final strokePaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final path = Path();

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final value = stats[i] / 100;
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );

      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();

    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, strokePaint);
  }

  void _drawLabels(Canvas canvas, Offset center, double radius, List<String> labels) {
    final textStyle = TextStyle(
      color: Colors.grey[700],
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final labelRadius = radius + 20;
      final point = Offset(
        center.dx + labelRadius * math.cos(angle),
        center.dy + labelRadius * math.sin(angle),
      );

      final textSpan = TextSpan(text: labels[i], style: textStyle);
      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      final offset = Offset(
        point.dx - textPainter.width / 2,
        point.dy - textPainter.height / 2,
      );
      textPainter.paint(canvas, offset);
    }
  }

  void _drawDataPoints(Canvas canvas, Offset center, double radius, List<double> stats) {
    final pointPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.fill;

    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final value = stats[i] / 100;
      final point = Offset(
        center.dx + radius * value * math.cos(angle),
        center.dy + radius * value * math.sin(angle),
      );

      canvas.drawCircle(point, 6, whitePaint);
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  Path _createHexagonPath(Offset center, double radius) {
    final path = Path();
    for (int i = 0; i < 6; i++) {
      final angle = (i * 60 - 90) * math.pi / 180;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      if (i == 0) {
        path.moveTo(point.dx, point.dy);
      } else {
        path.lineTo(point.dx, point.dy);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
