import 'package:flutter/material.dart';
import 'dart:math' as math;

/// 패스 마스터 맵 - 선수간 연결관계를 인포그래픽으로 시각화
/// "오늘은 음바페와 호흡이 좋았네요!" 같은 인사이트 제공
class PassMasterMapWidget extends StatefulWidget {
  final String mainPlayerId;
  final String mainPlayerName;
  final List<PassConnection> connections;
  final String? highlightInsight;

  const PassMasterMapWidget({
    super.key,
    required this.mainPlayerId,
    required this.mainPlayerName,
    required this.connections,
    this.highlightInsight,
  });

  @override
  State<PassMasterMapWidget> createState() => _PassMasterMapWidgetState();
}

class _PassMasterMapWidgetState extends State<PassMasterMapWidget>
    with TickerProviderStateMixin {
  late AnimationController _connectionController;
  late AnimationController _pulseController;
  late Animation<double> _connectionAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _connectionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _connectionAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _connectionController, curve: Curves.easeOutCubic),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _connectionController.forward();
  }

  @override
  void dispose() {
    _connectionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sortedConnections = List<PassConnection>.from(widget.connections)
      ..sort((a, b) => b.passCount.compareTo(a.passCount));
    final topConnection = sortedConnections.isNotEmpty ? sortedConnections.first : null;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.mainPlayerName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '패스 네트워크',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.compare_arrows,
                            size: 16,
                            color: Color(0xFF1E4A6E),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${_getTotalPasses()}회',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E4A6E),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                // 인사이트 메시지
                if (widget.highlightInsight != null || topConnection != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFD700).withValues(alpha: 0.2),
                          const Color(0xFFFF6B6B).withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFFFD700).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Text('💡', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.highlightInsight ??
                                '오늘은 ${topConnection?.partnerName ?? "팀원"}과(와) 호흡이 좋았네요!',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 패스 네트워크 맵
          AspectRatio(
            aspectRatio: 1.2,
            child: AnimatedBuilder(
              animation: _connectionAnimation,
              builder: (context, child) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B5E20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: CustomPaint(
                      painter: _PassNetworkPainter(
                        mainPlayerName: widget.mainPlayerName,
                        connections: widget.connections,
                        animationValue: _connectionAnimation.value,
                        pulseValue: _pulseAnimation.value,
                      ),
                      child: const SizedBox.expand(),
                    ),
                  ),
                );
              },
            ),
          ),

          // 연결 상세
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주요 패스 연결',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                ...sortedConnections.take(3).map((conn) => _buildConnectionItem(conn)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionItem(PassConnection connection) {
    final maxCount = widget.connections.isNotEmpty
        ? widget.connections.map((c) => c.passCount).reduce(math.max)
        : 1;
    final progress = connection.passCount / maxCount;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          // 선수 아바타
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: connection.teamColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: connection.teamColor,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                connection.partnerName.substring(0, 1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: connection.teamColor,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      connection.partnerName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      '${connection.passCount}회',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: connection.teamColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(2),
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(connection.teamColor),
                    minHeight: 4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  int _getTotalPasses() {
    return widget.connections.fold(0, (sum, conn) => sum + conn.passCount);
  }
}

/// 패스 연결 데이터
class PassConnection {
  final String partnerId;
  final String partnerName;
  final int passCount;
  final double partnerX; // 0.0 ~ 1.0 (필드 상 위치)
  final double partnerY; // 0.0 ~ 1.0
  final Color teamColor;

  const PassConnection({
    required this.partnerId,
    required this.partnerName,
    required this.passCount,
    required this.partnerX,
    required this.partnerY,
    this.teamColor = const Color(0xFF1E4A6E),
  });
}

/// 패스 네트워크 Painter
class _PassNetworkPainter extends CustomPainter {
  final String mainPlayerName;
  final List<PassConnection> connections;
  final double animationValue;
  final double pulseValue;

  _PassNetworkPainter({
    required this.mainPlayerName,
    required this.connections,
    required this.animationValue,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 필드 라인
    _drawFieldLines(canvas, size);

    // 메인 선수 위치 (중앙 우측)
    final mainX = size.width * 0.7;
    final mainY = size.height * 0.5;

    // 패스 연결선 그리기
    for (final conn in connections) {
      _drawPassConnection(canvas, size, mainX, mainY, conn);
    }

    // 팀원 노드 그리기
    for (final conn in connections) {
      _drawPlayerNode(
        canvas,
        size,
        conn.partnerX * size.width,
        conn.partnerY * size.height,
        conn.partnerName,
        conn.teamColor,
        false,
      );
    }

    // 메인 선수 노드 (가장 위에)
    _drawPlayerNode(
      canvas,
      size,
      mainX,
      mainY,
      mainPlayerName,
      const Color(0xFFFFD700),
      true,
    );
  }

  void _drawFieldLines(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // 외곽선
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // 중앙선
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      paint,
    );

    // 중앙 원
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.height * 0.12,
      paint,
    );
  }

  void _drawPassConnection(
    Canvas canvas,
    Size size,
    double mainX,
    double mainY,
    PassConnection conn,
  ) {
    final endX = conn.partnerX * size.width;
    final endY = conn.partnerY * size.height;

    // 패스 강도에 따른 선 두께
    final maxCount = connections.isNotEmpty
        ? connections.map((c) => c.passCount).reduce(math.max)
        : 1;
    final strength = conn.passCount / maxCount;
    final lineWidth = 2.0 + strength * 4.0;

    // 애니메이션 적용된 끝점
    final animatedEndX = mainX + (endX - mainX) * animationValue;
    final animatedEndY = mainY + (endY - mainY) * animationValue;

    // 그라데이션 효과
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          const Color(0xFFFFD700).withValues(alpha: 0.8 * animationValue),
          conn.teamColor.withValues(alpha: 0.6 * animationValue),
        ],
      ).createShader(Rect.fromPoints(
        Offset(mainX, mainY),
        Offset(animatedEndX, animatedEndY),
      ))
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    // 곡선 패스 라인
    final path = Path()
      ..moveTo(mainX, mainY);

    // 컨트롤 포인트로 곡선 생성
    final controlX = (mainX + animatedEndX) / 2;
    final controlY = (mainY + animatedEndY) / 2 - 20;

    path.quadraticBezierTo(controlX, controlY, animatedEndX, animatedEndY);

    canvas.drawPath(path, paint);

    // 패스 카운트 표시 (강한 연결만)
    if (strength > 0.5 && animationValue > 0.8) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: '${conn.passCount}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: animationValue),
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      final textX = (mainX + endX) / 2 - textPainter.width / 2;
      final textY = (mainY + endY) / 2 - textPainter.height / 2 - 15;

      // 배경
      final bgPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.5 * animationValue);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            textX - 4,
            textY - 2,
            textPainter.width + 8,
            textPainter.height + 4,
          ),
          const Radius.circular(4),
        ),
        bgPaint,
      );

      textPainter.paint(canvas, Offset(textX, textY));
    }
  }

  void _drawPlayerNode(
    Canvas canvas,
    Size size,
    double x,
    double y,
    String name,
    Color color,
    bool isMain,
  ) {
    final radius = isMain ? 22.0 * pulseValue : 18.0;

    // 글로우 효과
    final glowPaint = Paint()
      ..color = color.withValues(alpha: 0.3 * animationValue)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(Offset(x, y), radius + 5, glowPaint);

    // 노드 배경
    final bgPaint = Paint()
      ..color = color.withValues(alpha: animationValue)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(x, y), radius, bgPaint);

    // 테두리
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: animationValue)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    canvas.drawCircle(Offset(x, y), radius, borderPaint);

    // 이름 이니셜
    final textPainter = TextPainter(
      text: TextSpan(
        text: name.split(' ').last.substring(0, math.min(3, name.split(' ').last.length)),
        style: TextStyle(
          color: isMain ? Colors.black : Colors.white,
          fontSize: isMain ? 10 : 8,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant _PassNetworkPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.pulseValue != pulseValue;
  }
}

/// 샘플 패스 연결 데이터 생성 (PSG 팀 기준)
List<PassConnection> generateSamplePassConnections(String playerId) {
  return [
    const PassConnection(
      partnerId: 'mbappe',
      partnerName: 'Mbappé',
      passCount: 28,
      partnerX: 0.85,
      partnerY: 0.3,
      teamColor: Color(0xFF004170),
    ),
    const PassConnection(
      partnerId: 'dembele',
      partnerName: 'Dembélé',
      passCount: 22,
      partnerX: 0.75,
      partnerY: 0.75,
      teamColor: Color(0xFF004170),
    ),
    const PassConnection(
      partnerId: 'vitinha',
      partnerName: 'Vitinha',
      passCount: 18,
      partnerX: 0.5,
      partnerY: 0.45,
      teamColor: Color(0xFF004170),
    ),
    const PassConnection(
      partnerId: 'hakimi',
      partnerName: 'Hakimi',
      passCount: 15,
      partnerX: 0.6,
      partnerY: 0.15,
      teamColor: Color(0xFF004170),
    ),
    const PassConnection(
      partnerId: 'ruiz',
      partnerName: 'F. Ruiz',
      passCount: 12,
      partnerX: 0.45,
      partnerY: 0.6,
      teamColor: Color(0xFF004170),
    ),
    const PassConnection(
      partnerId: 'marquinhos',
      partnerName: 'Marquinhos',
      passCount: 8,
      partnerX: 0.25,
      partnerY: 0.5,
      teamColor: Color(0xFF004170),
    ),
  ];
}
