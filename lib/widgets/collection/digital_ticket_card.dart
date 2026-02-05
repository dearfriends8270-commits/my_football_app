import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/digital_ticket.dart';

/// 디지털 티켓 카드 위젯 - 수집 가능한 경기 티켓
class DigitalTicketCard extends StatefulWidget {
  final DigitalTicket ticket;
  final VoidCallback? onTap;
  final VoidCallback? onCollect;
  final bool showDetails;

  const DigitalTicketCard({
    super.key,
    required this.ticket,
    this.onTap,
    this.onCollect,
    this.showDetails = false,
  });

  @override
  State<DigitalTicketCard> createState() => _DigitalTicketCardState();
}

class _DigitalTicketCardState extends State<DigitalTicketCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    // 레전드리, 에픽 티켓은 빛나는 효과
    if (widget.ticket.rarity == TicketRarity.legendary ||
        widget.ticket.rarity == TicketRarity.epic) {
      _shimmerController.repeat();
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: _buildTicketCard(),
      ),
    );
  }

  Widget _buildTicketCard() {
    final rarityColor = Color(widget.ticket.rarity.colorValue);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: widget.ticket.isCollected
                ? rarityColor.withValues(alpha: 0.3)
                : Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // 배경
            _buildBackground(rarityColor),

            // 미수집 오버레이
            if (!widget.ticket.isCollected) _buildLockedOverlay(),

            // 컨텐츠
            _buildContent(rarityColor),

            // 홀로그래픽 효과 (레전드리/에픽)
            if (widget.ticket.isCollected &&
                (widget.ticket.rarity == TicketRarity.legendary ||
                    widget.ticket.rarity == TicketRarity.epic))
              _buildHolographicEffect(),

            // 희귀도 배지
            Positioned(
              top: 12,
              right: 12,
              child: _buildRarityBadge(rarityColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackground(Color rarityColor) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: _getBackgroundColors(widget.ticket.design, rarityColor),
        ),
      ),
    );
  }

  List<Color> _getBackgroundColors(TicketDesign design, Color rarityColor) {
    switch (design) {
      case TicketDesign.classic:
        return [const Color(0xFF2C3E50), const Color(0xFF1A252F)];
      case TicketDesign.modern:
        return [const Color(0xFF667eea), const Color(0xFF764ba2)];
      case TicketDesign.retro:
        return [const Color(0xFFf093fb), const Color(0xFFf5576c)];
      case TicketDesign.holographic:
        return [rarityColor.withValues(alpha: 0.8), const Color(0xFF1A1A2E)];
      case TicketDesign.premium:
        return [const Color(0xFFB8860B), const Color(0xFF2C1810)];
    }
  }

  Widget _buildLockedOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.lock,
              color: Colors.white54,
              size: 40,
            ),
            const SizedBox(height: 8),
            const Text(
              '미수집',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (widget.onCollect != null) ...[
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: widget.onCollect,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                ),
                child: const Text('수집하기'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContent(Color rarityColor) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.ticket.competition,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 팀 vs 팀
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 홈팀
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.ticket.homeTeamLogo,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.ticket.homeTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 스코어
              Column(
                children: [
                  if (widget.ticket.score != null)
                    Text(
                      widget.ticket.score!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  else
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),

              // 원정팀
              Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.ticket.awayTeamLogo,
                      style: const TextStyle(fontSize: 32),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.ticket.awayTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const Spacer(),

          // 특별 순간
          if (widget.ticket.specialMoment != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: rarityColor.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: rarityColor.withValues(alpha: 0.5),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 14)),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      widget.ticket.specialMoment!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],

          // 하단 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 경기장 & 날짜
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.stadium,
                        color: Colors.white54,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.ticket.stadium,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(widget.ticket.matchDate),
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),

              // 평점
              if (widget.ticket.playerRating != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getRatingColor(widget.ticket.playerRating!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    widget.ticket.playerRating!.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHolographicEffect() {
    return AnimatedBuilder(
      animation: _shimmerController,
      builder: (context, child) {
        return CustomPaint(
          painter: _HolographicPainter(
            animationValue: _shimmerController.value,
          ),
          child: const SizedBox.expand(),
        );
      },
    );
  }

  Widget _buildRarityBadge(Color rarityColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rarityColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: rarityColor.withValues(alpha: 0.5),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.ticket.rarity.icon,
            style: const TextStyle(fontSize: 10),
          ),
          const SizedBox(width: 4),
          Text(
            widget.ticket.rarity.displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  Color _getRatingColor(double rating) {
    if (rating >= 8.5) return const Color(0xFF4CAF50);
    if (rating >= 7.5) return const Color(0xFF8BC34A);
    if (rating >= 6.5) return const Color(0xFFFFEB3B);
    if (rating >= 5.5) return const Color(0xFFFF9800);
    return const Color(0xFFF44336);
  }
}

/// 홀로그래픽 효과 Painter
class _HolographicPainter extends CustomPainter {
  final double animationValue;

  _HolographicPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;

    // 빛나는 라인 효과
    final lineX = size.width * 2 * animationValue - size.width * 0.5;

    paint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.transparent,
        Colors.white.withValues(alpha: 0.1),
        Colors.white.withValues(alpha: 0.3),
        Colors.white.withValues(alpha: 0.1),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
      transform: GradientRotation(math.pi / 4),
    ).createShader(
      Rect.fromLTWH(lineX - 50, 0, 100, size.height),
    );

    canvas.drawRect(
      Rect.fromLTWH(lineX - 50, 0, 100, size.height),
      paint,
    );

    // 무지개 효과
    final rainbowPaint = Paint()
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.overlay;

    rainbowPaint.shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        Colors.red.withValues(alpha: 0.05),
        Colors.orange.withValues(alpha: 0.05),
        Colors.yellow.withValues(alpha: 0.05),
        Colors.green.withValues(alpha: 0.05),
        Colors.blue.withValues(alpha: 0.05),
        Colors.purple.withValues(alpha: 0.05),
      ],
      transform: GradientRotation(animationValue * math.pi * 2),
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      rainbowPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HolographicPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue;
  }
}
