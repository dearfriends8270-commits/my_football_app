import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 아트 히트맵 - 선수의 포지션 활동을 예술적으로 시각화
/// 워터컬러/네온 스타일로 경기 중 활동 영역을 표현
class ArtHeatmapWidget extends StatefulWidget {
  final String playerId;
  final String playerName;
  final List<HeatmapPoint> heatmapData;
  final HeatmapStyle style;

  const ArtHeatmapWidget({
    super.key,
    required this.playerId,
    required this.playerName,
    required this.heatmapData,
    this.style = HeatmapStyle.watercolor,
  });

  @override
  State<ArtHeatmapWidget> createState() => _ArtHeatmapWidgetState();
}

class _ArtHeatmapWidgetState extends State<ArtHeatmapWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.playerName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '포지션 히트맵',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                _buildStyleSelector(),
              ],
            ),
          ),

          // 히트맵 필드
          AspectRatio(
            aspectRatio: 1.5,
            child: AnimatedBuilder(
              animation: _fadeAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1B5E20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: _ArtHeatmapPainter(
                          heatmapData: widget.heatmapData,
                          style: widget.style,
                          animationValue: _fadeAnimation.value,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // 범례
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('낮음', Colors.blue.withValues(alpha: 0.3)),
                const SizedBox(width: 16),
                _buildLegendItem('중간', Colors.yellow.withValues(alpha: 0.6)),
                const SizedBox(width: 16),
                _buildLegendItem('높음', Colors.red.withValues(alpha: 0.8)),
              ],
            ),
          ),

          // 통계 요약
          Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('총 이동거리', '${_calculateTotalDistance()}km'),
                _buildStatItem('최다 활동구역', _getMostActiveZone()),
                _buildStatItem('스프린트', '${_getSprintCount()}회'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStyleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.style == HeatmapStyle.watercolor
                ? Icons.water_drop
                : Icons.flash_on,
            size: 16,
            color: const Color(0xFF1E4A6E),
          ),
          const SizedBox(width: 4),
          Text(
            widget.style == HeatmapStyle.watercolor ? '워터컬러' : '네온',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1E4A6E),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E4A6E),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  String _calculateTotalDistance() {
    // 시뮬레이션된 데이터
    final random = math.Random(widget.playerId.hashCode);
    return (8.0 + random.nextDouble() * 4).toStringAsFixed(1);
  }

  String _getMostActiveZone() {
    // 시뮬레이션된 데이터
    final zones = ['좌측 윙', '중앙', '우측 윙', '박스 내', '미드필드'];
    final random = math.Random(widget.playerId.hashCode);
    return zones[random.nextInt(zones.length)];
  }

  int _getSprintCount() {
    final random = math.Random(widget.playerId.hashCode);
    return 15 + random.nextInt(20);
  }
}

/// 히트맵 스타일
enum HeatmapStyle {
  watercolor, // 워터컬러 스타일
  neon, // 네온 스타일
}

/// 히트맵 데이터 포인트
class HeatmapPoint {
  final double x; // 0.0 ~ 1.0
  final double y; // 0.0 ~ 1.0
  final double intensity; // 0.0 ~ 1.0

  const HeatmapPoint({
    required this.x,
    required this.y,
    required this.intensity,
  });
}

/// 아트 히트맵 Painter
class _ArtHeatmapPainter extends CustomPainter {
  final List<HeatmapPoint> heatmapData;
  final HeatmapStyle style;
  final double animationValue;

  _ArtHeatmapPainter({
    required this.heatmapData,
    required this.style,
    required this.animationValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 필드 라인 그리기
    _drawFieldLines(canvas, size);

    // 히트맵 포인트 그리기
    for (final point in heatmapData) {
      _drawHeatPoint(canvas, size, point);
    }
  }

  void _drawFieldLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    // 외곽선
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      paint,
    );

    // 중앙선
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // 중앙 원
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.15,
      paint,
    );

    // 좌측 페널티 박스
    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.2, size.width * 0.15, size.height * 0.6),
      paint,
    );

    // 우측 페널티 박스
    canvas.drawRect(
      Rect.fromLTWH(
          size.width * 0.85, size.height * 0.2, size.width * 0.15, size.height * 0.6),
      paint,
    );
  }

  void _drawHeatPoint(Canvas canvas, Size size, HeatmapPoint point) {
    final centerX = point.x * size.width;
    final centerY = point.y * size.height;
    final radius = 30.0 + point.intensity * 40;

    if (style == HeatmapStyle.watercolor) {
      // 워터컬러 스타일
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20);

      // 강도에 따른 색상
      Color color;
      if (point.intensity > 0.7) {
        color = Colors.red.withValues(alpha: 0.4 * animationValue);
      } else if (point.intensity > 0.4) {
        color = Colors.yellow.withValues(alpha: 0.35 * animationValue);
      } else {
        color = Colors.blue.withValues(alpha: 0.3 * animationValue);
      }

      paint.color = color;
      canvas.drawCircle(Offset(centerX, centerY), radius * animationValue, paint);
    } else {
      // 네온 스타일
      final paint = Paint()
        ..style = PaintingStyle.fill;

      // 글로우 효과
      for (var i = 3; i >= 1; i--) {
        Color glowColor;
        if (point.intensity > 0.7) {
          glowColor = Colors.pinkAccent.withValues(alpha: 0.15 * i * animationValue);
        } else if (point.intensity > 0.4) {
          glowColor = Colors.cyanAccent.withValues(alpha: 0.15 * i * animationValue);
        } else {
          glowColor = Colors.purpleAccent.withValues(alpha: 0.1 * i * animationValue);
        }

        paint.color = glowColor;
        paint.maskFilter = MaskFilter.blur(BlurStyle.normal, 15.0 * i);
        canvas.drawCircle(
            Offset(centerX, centerY), radius * animationValue * (1 + i * 0.2), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _ArtHeatmapPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.style != style;
  }
}

/// 샘플 히트맵 데이터 생성 (이강인 스타일 - 우측 공격형)
List<HeatmapPoint> generateSampleHeatmapData(String playerId) {
  final random = math.Random(playerId.hashCode);
  final points = <HeatmapPoint>[];

  // 우측 윙 영역에 집중
  for (var i = 0; i < 15; i++) {
    points.add(HeatmapPoint(
      x: 0.6 + random.nextDouble() * 0.35,
      y: 0.2 + random.nextDouble() * 0.3,
      intensity: 0.5 + random.nextDouble() * 0.5,
    ));
  }

  // 중앙 공격 영역
  for (var i = 0; i < 10; i++) {
    points.add(HeatmapPoint(
      x: 0.5 + random.nextDouble() * 0.3,
      y: 0.35 + random.nextDouble() * 0.3,
      intensity: 0.3 + random.nextDouble() * 0.5,
    ));
  }

  // 미드필드 활동
  for (var i = 0; i < 8; i++) {
    points.add(HeatmapPoint(
      x: 0.3 + random.nextDouble() * 0.4,
      y: 0.3 + random.nextDouble() * 0.4,
      intensity: 0.2 + random.nextDouble() * 0.3,
    ));
  }

  return points;
}
