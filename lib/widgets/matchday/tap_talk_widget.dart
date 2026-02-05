import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/matchday_provider.dart';

/// 탭톡 (Tap-Talk) - 경기 중 인스턴트 응원 위젯
class TapTalkWidget extends ConsumerStatefulWidget {
  const TapTalkWidget({super.key});

  @override
  ConsumerState<TapTalkWidget> createState() => _TapTalkWidgetState();
}

class _TapTalkWidgetState extends ConsumerState<TapTalkWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  String? _lastTappedEmotion;

  final List<Map<String, String>> _emotions = [
    {'key': 'wow', 'emoji': '😲', 'label': '와!'},
    {'key': 'amazing', 'emoji': '🔥', 'label': '대박'},
    {'key': 'sad', 'emoji': '😢', 'label': '아쉽다'},
    {'key': 'angry', 'emoji': '😡', 'label': '화난다'},
    {'key': 'happy', 'emoji': '😄', 'label': '좋아요'},
    {'key': 'goal', 'emoji': '⚽', 'label': '골!'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onEmotionTap(String emotionKey) {
    HapticFeedback.mediumImpact();
    ref.read(tapTalkProvider.notifier).addEmotion(emotionKey);

    setState(() {
      _lastTappedEmotion = emotionKey;
    });

    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    // 플로팅 이모지 효과
    _showFloatingEmoji(emotionKey);
  }

  void _showFloatingEmoji(String emotionKey) {
    final emoji = _emotions.firstWhere((e) => e['key'] == emotionKey)['emoji'];

    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _FloatingEmoji(
        emoji: emoji ?? '👍',
        onComplete: () => overlayEntry.remove(),
      ),
    );

    overlay.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    final tapTalkState = ref.watch(tapTalkProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFED174B), Color(0xFFFF6B6B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text(
                      '탭톡',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                '${tapTalkState.totalCount}명 참여 중',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 감정 버튼들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: _emotions.map((emotion) {
              final isLast = _lastTappedEmotion == emotion['key'];
              return _EmotionButton(
                emoji: emotion['emoji']!,
                label: emotion['label']!,
                isHighlighted: isLast,
                onTap: () => _onEmotionTap(emotion['key']!),
              );
            }).toList(),
          ),

          const SizedBox(height: 20),

          // 감정 히트맵
          _EmotionHeatmap(emotions: tapTalkState.emotions),
        ],
      ),
    );
  }
}

class _EmotionButton extends StatefulWidget {
  final String emoji;
  final String label;
  final bool isHighlighted;
  final VoidCallback onTap;

  const _EmotionButton({
    required this.emoji,
    required this.label,
    required this.isHighlighted,
    required this.onTap,
  });

  @override
  State<_EmotionButton> createState() => _EmotionButtonState();
}

class _EmotionButtonState extends State<_EmotionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Column(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: widget.isHighlighted
                        ? const Color(0xFFED174B).withValues(alpha: 0.2)
                        : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: widget.isHighlighted
                          ? const Color(0xFFED174B)
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      widget.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    color: widget.isHighlighted
                        ? const Color(0xFFED174B)
                        : Colors.grey.shade700,
                    fontWeight: widget.isHighlighted
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EmotionHeatmap extends StatelessWidget {
  final List<TapTalkEmotion> emotions;

  const _EmotionHeatmap({required this.emotions});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '실시간 감정 게이지',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        // 히트맵 바
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 24,
            child: Row(
              children: emotions.map((emotion) {
                final color = _getColorForEmotion(emotion.emoji);
                return Expanded(
                  flex: (emotion.percentage * 10).toInt().clamp(1, 100),
                  child: Container(
                    color: color,
                    child: emotion.percentage > 10
                        ? Center(
                            child: Text(
                              emotion.emoji,
                              style: const TextStyle(fontSize: 12),
                            ),
                          )
                        : null,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 범례
        Wrap(
          spacing: 12,
          runSpacing: 4,
          children: emotions.map((emotion) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _getColorForEmotion(emotion.emoji),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  '${emotion.emoji} ${emotion.percentage.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }

  Color _getColorForEmotion(String emoji) {
    switch (emoji) {
      case '😲':
        return const Color(0xFF4FC3F7);
      case '🔥':
        return const Color(0xFFFF7043);
      case '😢':
        return const Color(0xFF90A4AE);
      case '😡':
        return const Color(0xFFEF5350);
      case '😄':
        return const Color(0xFF66BB6A);
      case '⚽':
        return const Color(0xFFFFD54F);
      default:
        return Colors.grey;
    }
  }
}

class _FloatingEmoji extends StatefulWidget {
  final String emoji;
  final VoidCallback onComplete;

  const _FloatingEmoji({
    required this.emoji,
    required this.onComplete,
  });

  @override
  State<_FloatingEmoji> createState() => _FloatingEmojiState();
}

class _FloatingEmojiState extends State<_FloatingEmoji>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _translateAnimation;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _translateAnimation = Tween<double>(begin: 0, end: -100).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 1, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward().then((_) => widget.onComplete());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Positioned(
      left: screenSize.width / 2 - 20,
      top: screenSize.height / 2,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _translateAnimation.value),
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: Text(
                  widget.emoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
