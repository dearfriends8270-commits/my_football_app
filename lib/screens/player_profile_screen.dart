import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/player_header.dart';
import '../widgets/next_match_card.dart';
import '../widgets/season_stats.dart';
import '../widgets/play_style_tags.dart';
import '../widgets/latest_talk_card.dart';
import '../widgets/shop_card.dart';
import '../widgets/bottom_nav_bar.dart';
import '../models/player.dart';
import '../models/match.dart';
import 'talk/athlete_talk_screen.dart';
import 'search/search_screen.dart';
import 'settings/settings_screen.dart';
import 'matchday/matchday_screen.dart';

class PlayerProfileScreen extends ConsumerStatefulWidget {
  final Player? player;

  const PlayerProfileScreen({super.key, this.player});

  @override
  ConsumerState<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends ConsumerState<PlayerProfileScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final player = widget.player;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(player),
      body: _buildBody(player),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(Player? player) {
    final titles = ['홈', '일정', '통계', '뉴스', '설정'];

    return AppBar(
      backgroundColor: const Color(0xFF1E4A6E),
      leading: _currentIndex == 0
          ? IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            )
          : IconButton(
              icon: const Icon(Icons.home, color: Colors.white),
              onPressed: () {
                setState(() {
                  _currentIndex = 0;
                });
              },
            ),
      title: Text(
        _currentIndex == 0 ? (player?.name ?? 'Player Profile') : titles[_currentIndex],
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      centerTitle: true,
      elevation: 0,
      actions: [
        if (_currentIndex == 0) ...[
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => SearchScreen(
                    playerId: player?.id ?? 'lee_kangin',
                    playerName: player?.name ?? '이강인',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.notifications_outlined, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('알림 기능 준비 중입니다')),
              );
            },
          ),
        ],
      ],
    );
  }

  Widget _buildBody(Player? player) {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab(player);
      case 1:
        return _buildScheduleTab(player);
      case 2:
        return _buildStatsTab(player);
      case 3:
        return _buildNewsTab(player);
      case 4:
        return const SettingsScreen();
      default:
        return _buildHomeTab(player);
    }
  }

  // 홈 탭
  Widget _buildHomeTab(Player? player) {
    // 샘플 경기 데이터 생성
    final sampleMatch = Match(
      id: 'match_1',
      homeTeam: 'Paris Saint-Germain',
      awayTeam: 'Olympique Marseille',
      homeTeamLogo: 'https://media.api-sports.io/football/teams/85.png',
      awayTeamLogo: 'https://media.api-sports.io/football/teams/81.png',
      kickoffTime: DateTime.now().add(const Duration(days: 3, hours: 5)),
      competition: 'Ligue 1',
      venue: 'Parc des Princes',
      venueCity: 'Paris',
      playerId: player?.id ?? 'lee_kangin',
      broadcastChannel: 'SPOTV ON',
      weatherCondition: '맑음',
      temperature: 12.5,
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlayerHeader(
            name: player?.name ?? 'LEE KANG IN',
            team: player?.team ?? 'Paris Saint-Germain',
            number: player?.number ?? 19,
            isLive: false,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    // 매치데이 모드로 이동
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => MatchDayScreen(match: sampleMatch),
                      ),
                    );
                  },
                  child: const NextMatchCard(
                    homeTeam: 'PSG',
                    awayTeam: 'OM',
                    dateTime: 'Feb 09, 04:45 (KST)',
                  ),
                ),
                const SizedBox(height: 24),
                SeasonStats(
                  goals: player?.goals ?? 4,
                  assists: player?.assists ?? 7,
                  rating: player?.rating ?? 7.2,
                ),
                const SizedBox(height: 24),
                const PlayStyleTags(
                  tags: ['#드리블러', '#비전', '#키패스', '#창의성'],
                ),
                const SizedBox(height: 24),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => AthleteTalkScreen(
                          athleteId: player?.id ?? 'lee_kangin',
                          athleteName: player?.name ?? '이강인',
                          teamColor: const Color(0xFF001C58),
                        ),
                      ),
                    );
                  },
                  child: const LatestTalkCard(
                    title: '[Talk] 이강인 이적설?! 레알 마드리드 관심 보인다는 루머!',
                    subtitle: '커뮤니티 바로가기 >',
                  ),
                ),
                const SizedBox(height: 16),
                ShopCard(
                  title: "${player?.name ?? '이강인'} 유니폼 & 축구화",
                  linkText: '공식 스토어 바로가기 >',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 일정 탭
  Widget _buildScheduleTab(Player? player) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '다가오는 경기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildMatchListItem(
            homeTeam: 'PSG',
            awayTeam: 'Marseille',
            competition: 'Ligue 1',
            date: '2월 9일 (일) 04:45',
            isNext: true,
          ),
          _buildMatchListItem(
            homeTeam: 'Barcelona',
            awayTeam: 'PSG',
            competition: 'Champions League',
            date: '2월 15일 (토) 05:00',
            isNext: false,
          ),
          _buildMatchListItem(
            homeTeam: 'PSG',
            awayTeam: 'Lyon',
            competition: 'Ligue 1',
            date: '2월 22일 (토) 04:45',
            isNext: false,
          ),
          const SizedBox(height: 32),
          const Text(
            '최근 경기',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPastMatchItem(
            homeTeam: 'PSG',
            awayTeam: 'Monaco',
            homeScore: 3,
            awayScore: 1,
            competition: 'Ligue 1',
            date: '2월 2일',
            playerStats: '1골 1어시스트',
          ),
          _buildPastMatchItem(
            homeTeam: 'Lille',
            awayTeam: 'PSG',
            homeScore: 1,
            awayScore: 2,
            competition: 'Ligue 1',
            date: '1월 26일',
            playerStats: '1어시스트',
          ),
        ],
      ),
    );
  }

  Widget _buildMatchListItem({
    required String homeTeam,
    required String awayTeam,
    required String competition,
    required String date,
    required bool isNext,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isNext ? const Color(0xFF1E4A6E).withValues(alpha: 0.05) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isNext ? Border.all(color: const Color(0xFF1E4A6E), width: 2) : null,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$homeTeam vs $awayTeam',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  competition,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isNext)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E4A6E),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: isNext ? const Color(0xFF1E4A6E) : Colors.grey.shade600,
                  fontWeight: isNext ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPastMatchItem({
    required String homeTeam,
    required String awayTeam,
    required int homeScore,
    required int awayScore,
    required String competition,
    required String date,
    required String playerStats,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      homeTeam,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$homeScore - $awayScore',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      awayTeam,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '$competition · $date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              playerStats,
              style: TextStyle(
                fontSize: 12,
                color: Colors.green.shade700,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 통계 탭
  Widget _buildStatsTab(Player? player) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '2024-25 시즌 통계',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          // 주요 통계 카드
          Row(
            children: [
              Expanded(
                child: _buildStatCard('골', '${player?.goals ?? 4}', Colors.red),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('어시스트', '${player?.assists ?? 7}', Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard('평점', '${player?.rating ?? 7.2}', Colors.amber),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            '상세 통계',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailStatRow('출전 경기', '24'),
          _buildDetailStatRow('선발 출전', '18'),
          _buildDetailStatRow('출전 시간', '1,620분'),
          _buildDetailStatRow('슈팅', '42'),
          _buildDetailStatRow('유효 슈팅', '18'),
          _buildDetailStatRow('키 패스', '56'),
          _buildDetailStatRow('드리블 성공', '38'),
          _buildDetailStatRow('패스 성공률', '86%'),
          _buildDetailStatRow('경기당 패스', '52.3'),
          _buildDetailStatRow('옐로카드', '3'),
          _buildDetailStatRow('레드카드', '0'),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStatRow(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // 뉴스 탭
  Widget _buildNewsTab(Player? player) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '최신 뉴스',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AthleteTalkScreen(
                        athleteId: player?.id ?? 'lee_kangin',
                        athleteName: player?.name ?? '이강인',
                        teamColor: const Color(0xFF001C58),
                      ),
                    ),
                  );
                },
                child: const Text('Talk 바로가기 >'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildNewsCard(
            title: '이강인, PSG 주간 MVP 선정',
            source: 'L\'Équipe',
            time: '6시간 전',
            isPinned: true,
          ),
          _buildNewsCard(
            title: 'Lee Kang-in shows world-class form',
            source: 'ESPN',
            time: '1일 전',
            isPinned: false,
          ),
          _buildNewsCard(
            title: 'PSG, 챔피언스리그 우승을 향해',
            source: 'Goal.com',
            time: '2일 전',
            isPinned: false,
          ),
          _buildNewsCard(
            title: '이강인 인터뷰: "더 성장하고 싶다"',
            source: 'OSEN',
            time: '3일 전',
            isPinned: false,
          ),
        ],
      ),
    );
  }

  Widget _buildNewsCard({
    required String title,
    required String source,
    required String time,
    required bool isPinned,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isPinned ? const Color(0xFF1E4A6E).withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPinned ? const Color(0xFF1E4A6E) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.article, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (isPinned)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4A6E),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      '📌 주요 뉴스',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '$source · $time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
