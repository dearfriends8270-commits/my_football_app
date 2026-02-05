import 'package:flutter/material.dart';
import '../../models/match.dart';

class LiveEventsWidget extends StatelessWidget {
  final List<MatchEvent> events;

  const LiveEventsWidget({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.fiber_manual_record,
                          color: Colors.white, size: 8),
                      SizedBox(width: 4),
                      Text(
                        'LIVE',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  '실시간 이벤트',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // 이벤트 목록
          if (events.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.sports_soccer,
                      size: 48,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '아직 이벤트가 없습니다',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: events.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final event = events[events.length - 1 - index]; // 최신 순
                return _buildEventItem(event);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildEventItem(MatchEvent event) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // 시간
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _getEventColor(event.type).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "${event.minute}'",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _getEventColor(event.type),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // 이벤트 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      event.type.emoji,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      event.type.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: _getEventColor(event.type),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  event.playerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (event.assistPlayerName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    '어시스트: ${event.assistPlayerName}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          // 팀
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              event.team,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getEventColor(MatchEventType type) {
    switch (type) {
      case MatchEventType.goal:
      case MatchEventType.penaltyScored:
        return Colors.green;
      case MatchEventType.assist:
        return Colors.blue;
      case MatchEventType.yellowCard:
        return Colors.amber.shade700;
      case MatchEventType.redCard:
        return Colors.red;
      case MatchEventType.substitution:
        return Colors.purple;
      case MatchEventType.penaltyMissed:
      case MatchEventType.ownGoal:
        return Colors.red.shade300;
    }
  }
}
