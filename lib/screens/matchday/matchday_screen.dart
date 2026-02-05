import 'package:flutter/material.dart';
import '../../models/match.dart';
import '../../widgets/matchday/countdown_widget.dart';
import '../../widgets/matchday/weather_widget.dart';
import '../../widgets/matchday/live_events_widget.dart';
import '../../widgets/matchday/lineup_widget.dart';
import '../../services/share_service.dart';

class MatchDayScreen extends StatefulWidget {
  final Match match;

  const MatchDayScreen({super.key, required this.match});

  @override
  State<MatchDayScreen> createState() => _MatchDayScreenState();
}

class _MatchDayScreenState extends State<MatchDayScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  final ShareService _shareService = ShareService();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final match = widget.match;
    final isLive = match.isLive;

    return Scaffold(
      backgroundColor: isLive ? const Color(0xFF1A1A2E) : const Color(0xFF1E4A6E),
      body: CustomScrollView(
        slivers: [
          // 헤더
          SliverAppBar(
            expandedHeight: 300,
            floating: false,
            pinned: true,
            backgroundColor: isLive ? const Color(0xFF1A1A2E) : const Color(0xFF1E4A6E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () => _shareMatch(match),
              ),
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                onPressed: () => _showMatchNotificationSettings(context),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildMatchHeader(match, isLive),
            ),
          ),

          // 컨텐츠
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),

                  // 경기 시작 전: 카운트다운
                  if (!isLive && !match.isFinished) ...[
                    CountdownWidget(kickoffTime: match.kickoffTime),
                    const SizedBox(height: 24),
                  ],

                  // 날씨 정보
                  if (match.weatherCondition != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: WeatherWidget(
                        condition: match.weatherCondition!,
                        temperature: match.temperature ?? 0,
                        city: match.venueCity ?? match.venue,
                      ),
                    ),

                  const SizedBox(height: 24),

                  // LIVE 중: 실시간 이벤트
                  if (isLive) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: LiveEventsWidget(events: match.events),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // 예상 라인업
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: LineupWidget(
                      homeTeam: match.homeTeam,
                      awayTeam: match.awayTeam,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // 방송 정보
                  if (match.broadcastChannel != null)
                    _buildBroadcastInfo(match.broadcastChannel!),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchHeader(Match match, bool isLive) {
    return Stack(
      children: [
        // 배경 그라데이션
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isLive
                  ? [const Color(0xFF1A1A2E), const Color(0xFF16213E)]
                  : [const Color(0xFF1E4A6E), const Color(0xFF2D6A9E)],
            ),
          ),
        ),

        // LIVE 배지
        if (isLive)
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.5),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.fiber_manual_record,
                              color: Colors.white, size: 12),
                          SizedBox(width: 6),
                          Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

        // 팀 정보
        Positioned(
          bottom: 40,
          left: 20,
          right: 20,
          child: Row(
            children: [
              // 홈 팀
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_soccer,
                          size: 36,
                          color: Color(0xFF1E4A6E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      match.homeTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // 스코어 또는 VS
              Column(
                children: [
                  if (isLive || match.isFinished) ...[
                    Text(
                      '${match.homeScore ?? 0} - ${match.awayScore ?? 0}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 36,
                      ),
                    ),
                    if (isLive)
                      Text(
                        '${match.events.isNotEmpty ? "${match.events.last.minute}'" : "0'"}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                  ] else ...[
                    const Text(
                      'VS',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatKickoffTime(match.kickoffTime),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.8),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ],
              ),

              // 원정 팀
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.sports_soccer,
                          size: 36,
                          color: Color(0xFF1E4A6E),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      match.awayTeam,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // 대회명
        Positioned(
          bottom: 10,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                match.competition,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBroadcastInfo(String channel) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E4A6E),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.tv, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '중계 채널',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  channel,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _openBroadcastLink(channel),
            child: const Text('바로가기'),
          ),
        ],
      ),
    );
  }

  String _formatKickoffTime(DateTime time) {
    return '${time.month}/${time.day} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  // 경기 정보 공유
  Future<void> _shareMatch(Match match) async {
    await _shareService.shareMatch(
      homeTeam: match.homeTeam,
      awayTeam: match.awayTeam,
      competition: match.competition,
      kickoffTime: match.kickoffTime,
      venue: match.venue,
    );
  }

  // 중계 링크 열기
  Future<void> _openBroadcastLink(String channel) async {
    final success = await _shareService.openBroadcastLink(channel);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$channel 링크를 열 수 없습니다'),
          action: SnackBarAction(
            label: '확인',
            onPressed: () {},
          ),
        ),
      );
    }
  }

  // 경기 알림 설정
  void _showMatchNotificationSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          '경기 알림 설정',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildNotificationOption(
                      icon: Icons.notifications_active,
                      title: '경기 시작 알림',
                      subtitle: '경기 시작 30분 전 알림',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildNotificationOption(
                      icon: Icons.sports_soccer,
                      title: '골 알림',
                      subtitle: '실시간 득점 알림',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildNotificationOption(
                      icon: Icons.scoreboard,
                      title: '경기 종료 알림',
                      subtitle: '최종 스코어 알림',
                      value: true,
                      onChanged: (value) {},
                    ),
                    _buildNotificationOption(
                      icon: Icons.warning_amber,
                      title: '주요 이벤트 알림',
                      subtitle: '레드카드, VAR 등 주요 이벤트',
                      value: false,
                      onChanged: (value) {},
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('알림 설정이 저장되었습니다'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4A6E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '저장',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF1E4A6E), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: const Color(0xFF1E4A6E),
          ),
        ],
      ),
    );
  }
}
