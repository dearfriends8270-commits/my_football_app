import 'package:flutter/material.dart';
import '../models/match.dart';
import '../screens/matchday/matchday_screen.dart';

class NextMatchCard extends StatelessWidget {
  final String homeTeam;
  final String awayTeam;
  final String dateTime;
  final VoidCallback? onTap;
  final bool isMatchDay;

  const NextMatchCard({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
    required this.dateTime,
    this.onTap,
    this.isMatchDay = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () {
        // 기본 동작: 매치데이 화면으로 이동
        final sampleMatch = Match(
          id: '1',
          homeTeam: homeTeam,
          awayTeam: awayTeam,
          kickoffTime: DateTime.now().add(const Duration(hours: 2)),
          competition: 'Ligue 1',
          venue: 'Parc des Princes',
          venueCity: 'Paris',
          weatherCondition: 'Clear',
          temperature: 12.0,
          broadcastChannel: 'SPOTV',
          events: [
            MatchEvent(
              id: '1',
              minute: 23,
              type: MatchEventType.goal,
              playerName: 'Lee Kang-in',
              assistPlayerName: 'Mbappé',
              team: homeTeam,
            ),
            MatchEvent(
              id: '2',
              minute: 45,
              type: MatchEventType.yellowCard,
              playerName: 'Opponent Player',
              team: awayTeam,
            ),
          ],
        );

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => MatchDayScreen(match: sampleMatch),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isMatchDay
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1E4A6E), Color(0xFF2D6A9E)],
                )
              : null,
          color: isMatchDay ? null : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: isMatchDay
              ? null
              : Border.all(
                  color: Colors.grey.shade300,
                  width: 1,
                ),
          boxShadow: [
            BoxShadow(
              color: isMatchDay
                  ? const Color(0xFF1E4A6E).withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.05),
              blurRadius: isMatchDay ? 15 : 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (isMatchDay) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_manual_record, color: Colors.white, size: 8),
                        SizedBox(width: 4),
                        Text(
                          'MATCH DAY',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Text(
                    'NEXT MATCH',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isMatchDay ? Colors.white70 : Colors.black87,
                      letterSpacing: 1.0,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  homeTeam,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isMatchDay ? Colors.white : const Color(0xFF1E4A6E),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'vs',
                    style: TextStyle(
                      fontSize: 16,
                      color: isMatchDay ? Colors.white60 : Colors.grey,
                    ),
                  ),
                ),
                Text(
                  awayTeam,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isMatchDay ? Colors.white : const Color(0xFF5B9BD5),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              dateTime,
              style: TextStyle(
                fontSize: 14,
                color: isMatchDay ? Colors.white70 : Colors.grey.shade600,
              ),
            ),
            if (isMatchDay) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.touch_app, color: Colors.white, size: 16),
                    SizedBox(width: 8),
                    Text(
                      '탭하여 매치데이 모드로 이동',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
