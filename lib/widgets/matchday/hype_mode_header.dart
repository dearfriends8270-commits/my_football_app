import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/match.dart';
import '../../providers/matchday_provider.dart';
import '../../services/matchday_service.dart';

/// Hype Mode 헤더 - 경기 6시간 전부터 활성화
class HypeModeHeader extends ConsumerStatefulWidget {
  final Match match;

  const HypeModeHeader({super.key, required this.match});

  @override
  ConsumerState<HypeModeHeader> createState() => _HypeModeHeaderState();
}

class _HypeModeHeaderState extends ConsumerState<HypeModeHeader>
    with TickerProviderStateMixin {
  late AnimationController _lightingController;
  late AnimationController _pulseController;
  late Animation<double> _lightingAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // 경기장 조명 애니메이션
    _lightingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _lightingAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _lightingController, curve: Curves.easeInOut),
    );

    // 펄스 애니메이션
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _lightingController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final weatherAsync = ref.watch(
      weatherInfoProvider(widget.match.stadiumCity ?? 'Paris'),
    );
    final hypeMessage = ref.watch(hypeMessageProvider(widget.match));
    final countdown = ref.watch(countdownProvider(widget.match));

    return Container(
      height: 350,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF001428),
            Color(0xFF002851),
            Color(0xFF004170),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 경기장 조명 효과
          AnimatedBuilder(
            animation: _lightingAnimation,
            builder: (context, child) {
              return CustomPaint(
                size: Size.infinite,
                painter: _StadiumLightsPainter(
                  intensity: _lightingAnimation.value,
                ),
              );
            },
          ),

          // 콘텐츠
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // 경기장 정보
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('🏟️', style: TextStyle(fontSize: 18)),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            widget.match.stadium ?? widget.match.venue,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 날씨 & 시간 정보
                  weatherAsync.when(
                    data: (weather) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            weather.icon,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${weather.temperature.toStringAsFixed(0)}°C',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '🕐 ${_formatLocalTime(widget.match.kickoffTime)}',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const Spacer(),

                  // Hype 메시지
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFFFD700).withValues(alpha: 0.3),
                                const Color(0xFFFF6B6B).withValues(alpha: 0.3),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFFFFD700).withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                hypeMessage,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 20,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFD700),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '⏱️ $countdown',
                                  style: const TextStyle(
                                    color: Color(0xFF001428),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatLocalTime(DateTime time) {
    // 현지 시간 표시 (시뮬레이션)
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')} (현지)';
  }
}

/// 경기장 조명 효과 Painter
class _StadiumLightsPainter extends CustomPainter {
  final double intensity;

  _StadiumLightsPainter({required this.intensity});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // 상단 조명들
    final lightPositions = [
      Offset(size.width * 0.2, 0),
      Offset(size.width * 0.4, 0),
      Offset(size.width * 0.6, 0),
      Offset(size.width * 0.8, 0),
    ];

    for (final pos in lightPositions) {
      // 빛 줄기
      paint.shader = RadialGradient(
        colors: [
          Color.fromRGBO(255, 255, 255, intensity * 0.3),
          Color.fromRGBO(255, 215, 0, intensity * 0.15),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromCircle(center: pos, radius: size.height * 0.6));

      canvas.drawCircle(pos, size.height * 0.6, paint);
    }

    // 바닥 반사광
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        Colors.transparent,
        Color.fromRGBO(255, 215, 0, intensity * 0.05),
        Colors.transparent,
      ],
    ).createShader(Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4));

    canvas.drawRect(
      Rect.fromLTWH(0, size.height * 0.6, size.width, size.height * 0.4),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _StadiumLightsPainter oldDelegate) {
    return oldDelegate.intensity != intensity;
  }
}

/// Live Mode 실시간 평점 위젯
class LiveRatingWidget extends ConsumerWidget {
  final String playerId;
  final String playerName;

  const LiveRatingWidget({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ratingAsync = ref.watch(liveRatingProvider(playerId));

    return ratingAsync.when(
      data: (rating) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              _getRatingColor(rating).withValues(alpha: 0.3),
              _getRatingColor(rating).withValues(alpha: 0.1),
            ],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRatingColor(rating).withValues(alpha: 0.5),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  playerName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  '실시간 평점',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 500),
              tween: Tween(begin: rating - 0.5, end: rating),
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(value),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    value.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.0) return const Color(0xFF4CAF50);
    if (rating >= 7.0) return const Color(0xFF8BC34A);
    if (rating >= 6.0) return const Color(0xFFFFEB3B);
    if (rating >= 5.0) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}
