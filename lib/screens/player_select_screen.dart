import 'package:flutter/material.dart';
import 'player_profile_screen.dart';
import 'admin/admin_dashboard_screen.dart';
import '../models/player.dart';

class PlayerSelectScreen extends StatelessWidget {
  const PlayerSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final players = [
      Player(
        id: '1',
        name: 'LEE KANG IN',
        team: 'Paris Saint-Germain',
        number: 19,
        position: 'Midfielder',
        nationality: 'South Korea',
      ),
      Player(
        id: '2',
        name: 'SON HEUNG MIN',
        team: 'Tottenham Hotspur',
        number: 7,
        position: 'Forward',
        nationality: 'South Korea',
      ),
      Player(
        id: '3',
        name: 'KIM MIN JAE',
        team: 'Bayern Munich',
        number: 3,
        position: 'Defender',
        nationality: 'South Korea',
      ),
      Player(
        id: '4',
        name: 'HWANG HEE CHAN',
        team: 'Wolverhampton',
        number: 11,
        position: 'Forward',
        nationality: 'South Korea',
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4A6E),
        title: const Text(
          'Select Player',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        actions: [
          // 관리자 버튼 (개발 모드에서만 표시)
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const AdminDashboardScreen(),
                ),
              );
            },
            tooltip: 'Admin Dashboard',
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 배너
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Color(0xFF1E4A6E),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.sports_soccer,
                  color: Colors.white,
                  size: 40,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Choose your favorite player',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Track their stats, matches and news',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // 선수 목록 타이틀
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Korean Players',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // 선수 목록
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return _PlayerCard(
                  player: player,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PlayerProfileScreen(
                          player: player,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _PlayerCard extends StatelessWidget {
  final Player player;
  final VoidCallback onTap;

  const _PlayerCard({
    required this.player,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // 선수 아바타
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  player.number.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E4A6E),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            // 선수 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    player.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    player.team,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      player.position,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1E4A6E),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // 화살표
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
