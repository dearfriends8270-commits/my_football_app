import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/player.dart';
import '../../models/news_article.dart';
import '../../models/talk_post.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';
import '../../providers/storage_provider.dart';
import '../../providers/talk_provider.dart';
import '../../providers/news_provider.dart';
import '../../providers/player_provider.dart';
import '../../providers/athlete_provider.dart';
import '../../providers/theme_provider.dart';
import '../talk/talk_post_detail_screen.dart';
// import '../player/player_profile_screen.dart';

/// 글로벌 검색 화면 - 선수, 뉴스, Talk 통합 검색
class GlobalSearchScreen extends ConsumerStatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  ConsumerState<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends ConsumerState<GlobalSearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  bool _isSearching = false;

  // 검색 결과
  List<Player> _playerResults = [];
  List<Athlete> _athleteResults = [];
  List<NewsArticle> _newsResults = [];
  List<TalkPost> _talkResults = [];

  // 인기 검색어
  final List<PopularSearch> _popularSearches = [
    PopularSearch(keyword: '손흥민', change: '+15%', rank: 1),
    PopularSearch(keyword: '이강인', change: '+12%', rank: 2),
    PopularSearch(keyword: '김민재', change: '+8%', rank: 3),
    PopularSearch(keyword: 'PSG', change: 'NEW', rank: 4),
    PopularSearch(keyword: '토트넘', change: '+3%', rank: 5),
    PopularSearch(keyword: '프리미어리그', change: '-2%', rank: 6),
  ];

  // 추천 태그
  final List<String> _recommendedTags = [
    '#골',
    '#어시스트',
    '#맨오브더매치',
    '#인터뷰',
    '#이적루머',
    '#국가대표',
    '#하이라이트',
    '#부상',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _searchFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  int get _totalResultCount =>
      _playerResults.length +
      _athleteResults.length +
      _newsResults.length +
      _talkResults.length;

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);
    final themeState = ref.watch(appThemeProvider);
    final primaryColor = themeState.primaryColor;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
              // 실시간 검색 (300ms 디바운스 효과)
              if (value.length >= 2) {
                Future.delayed(const Duration(milliseconds: 300), () {
                  if (_searchQuery == value && value.isNotEmpty) {
                    _performSearch(value.trim());
                  }
                });
              }
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _performSearch(value.trim());
              }
            },
            decoration: InputDecoration(
              hintText: '선수, 뉴스, 게시글 검색...',
              hintStyle: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
              prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _playerResults = [];
                          _athleteResults = [];
                          _newsResults = [];
                          _talkResults = [];
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        actions: [
          if (_searchQuery.isNotEmpty)
            TextButton(
              onPressed: () => _performSearch(_searchQuery.trim()),
              child: Text(
                '검색',
                style: TextStyle(color: primaryColor),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // 검색 결과 탭
          if (_searchQuery.isNotEmpty && _totalResultCount > 0)
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: primaryColor,
                isScrollable: true,
                tabs: [
                  Tab(text: '전체 ($_totalResultCount)'),
                  Tab(text: '선수 (${_playerResults.length + _athleteResults.length})'),
                  Tab(text: '뉴스 (${_newsResults.length})'),
                  Tab(text: 'Talk (${_talkResults.length})'),
                ],
              ),
            ),

          // 검색 결과 또는 최근 검색
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _searchQuery.isEmpty
                    ? _buildRecentSearches(recentSearches, primaryColor)
                    : _totalResultCount > 0
                        ? _buildSearchResults(primaryColor)
                        : _buildNoResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(List<String> recentSearches, Color primaryColor) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 최근 검색어
          if (recentSearches.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '최근 검색어',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    ref.read(recentSearchesProvider.notifier).clearAll();
                  },
                  child: Text(
                    '전체 삭제',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: recentSearches.map((search) {
                return _buildRecentSearchChip(search);
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // 인기 검색어
          const Text(
            '🔥 인기 검색어',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._popularSearches.map((search) => _buildPopularSearchItem(search, primaryColor)),

          const SizedBox(height: 32),

          // 추천 태그
          const Text(
            '추천 태그',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recommendedTags.map((tag) {
              return GestureDetector(
                onTap: () {
                  final searchTerm = tag.substring(1);
                  _searchController.text = searchTerm;
                  setState(() {
                    _searchQuery = searchTerm;
                  });
                  _performSearch(searchTerm);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: TextStyle(
                      fontSize: 13,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 32),

          // 빠른 선수 검색
          const Text(
            '⚽ 인기 선수',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildQuickPlayerSearch(primaryColor),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChip(String search) {
    return GestureDetector(
      onTap: () {
        _searchController.text = search;
        setState(() {
          _searchQuery = search;
        });
        _performSearch(search);
      },
      onLongPress: () => _showDeleteSearchDialog(search),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.history, size: 14, color: Colors.grey.shade600),
            const SizedBox(width: 6),
            Text(
              search,
              style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
            ),
            const SizedBox(width: 4),
            GestureDetector(
              onTap: () {
                ref.read(recentSearchesProvider.notifier).removeSearch(search);
              },
              child: Icon(Icons.close, size: 14, color: Colors.grey.shade500),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopularSearchItem(PopularSearch search, Color primaryColor) {
    final isNew = search.change == 'NEW';
    final isUp = search.change.startsWith('+');

    return GestureDetector(
      onTap: () {
        _searchController.text = search.keyword;
        setState(() {
          _searchQuery = search.keyword;
        });
        _performSearch(search.keyword);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                search.rank.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: search.rank <= 3 ? primaryColor : Colors.grey,
                ),
              ),
            ),
            if (search.rank <= 3)
              Container(
                margin: const EdgeInsets.only(right: 8),
                child: Icon(
                  search.rank == 1
                      ? Icons.looks_one
                      : search.rank == 2
                          ? Icons.looks_two
                          : Icons.looks_3,
                  color: search.rank == 1
                      ? Colors.amber
                      : search.rank == 2
                          ? Colors.grey.shade400
                          : Colors.brown.shade300,
                  size: 20,
                ),
              ),
            Expanded(
              child: Text(
                search.keyword,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isNew
                    ? Colors.red.shade50
                    : isUp
                        ? Colors.green.shade50
                        : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                search.change,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: isNew
                      ? Colors.red
                      : isUp
                          ? Colors.green
                          : Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPlayerSearch(Color primaryColor) {
    final players = [
      {'name': '손흥민', 'team': 'Tottenham', 'emoji': '⚽'},
      {'name': '이강인', 'team': 'PSG', 'emoji': '🎯'},
      {'name': '김민재', 'team': 'Bayern', 'emoji': '🛡️'},
      {'name': '황희찬', 'team': 'Wolves', 'emoji': '🐺'},
    ];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: players.length,
        itemBuilder: (context, index) {
          final player = players[index];
          return GestureDetector(
            onTap: () {
              _searchController.text = player['name']!;
              setState(() {
                _searchQuery = player['name']!;
              });
              _performSearch(player['name']!);
            },
            child: Container(
              width: 85,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    player['emoji']!,
                    style: const TextStyle(fontSize: 24),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    player['name']!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                  ),
                  Text(
                    player['team']!,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            '"$_searchQuery"에 대한 검색 결과가 없습니다',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '다른 검색어로 시도해보세요',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(Color primaryColor) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(primaryColor),
        _buildPlayerResultList(primaryColor),
        _buildNewsResultList(primaryColor),
        _buildTalkResultList(primaryColor),
      ],
    );
  }

  Widget _buildAllResults(Color primaryColor) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // 선수 결과
        if (_playerResults.isNotEmpty || _athleteResults.isNotEmpty) ...[
          _buildSectionHeader('선수', _playerResults.length + _athleteResults.length, primaryColor),
          ...(_playerResults.take(3).map((player) => _buildPlayerItem(player, primaryColor))),
          ...(_athleteResults.take(3).map((athlete) => _buildAthleteItem(athlete, primaryColor))),
          if (_playerResults.length + _athleteResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text(
                '선수 ${_playerResults.length + _athleteResults.length - 3}명 더보기',
                style: TextStyle(color: primaryColor),
              ),
            ),
          const SizedBox(height: 16),
        ],

        // 뉴스 결과
        if (_newsResults.isNotEmpty) ...[
          _buildSectionHeader('뉴스', _newsResults.length, primaryColor),
          ...(_newsResults.take(3).map((news) => _buildNewsItem(news))),
          if (_newsResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: Text(
                '뉴스 ${_newsResults.length - 3}개 더보기',
                style: TextStyle(color: primaryColor),
              ),
            ),
          const SizedBox(height: 16),
        ],

        // Talk 결과
        if (_talkResults.isNotEmpty) ...[
          _buildSectionHeader('Talk', _talkResults.length, primaryColor),
          ...(_talkResults.take(3).map((post) => _buildTalkItem(post))),
          if (_talkResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(3),
              child: Text(
                'Talk ${_talkResults.length - 3}개 더보기',
                style: TextStyle(color: primaryColor),
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: primaryColor,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$count건',
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerResultList(Color primaryColor) {
    if (_playerResults.isEmpty && _athleteResults.isEmpty) {
      return Center(
        child: Text(
          '선수 검색 결과가 없습니다',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ..._playerResults.map((player) => _buildPlayerItem(player, primaryColor)),
        ..._athleteResults.map((athlete) => _buildAthleteItem(athlete, primaryColor)),
      ],
    );
  }

  Widget _buildPlayerItem(Player player, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        // TODO: PlayerProfileScreen 구현 후 연결
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${player.name} 선수 상세 화면')),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // 선수 이미지
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(25),
              ),
              child: player.imageUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(25),
                      child: Image.network(
                        player.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.person,
                          color: primaryColor,
                          size: 28,
                        ),
                      ),
                    )
                  : Icon(Icons.person, color: primaryColor, size: 28),
            ),
            const SizedBox(width: 12),
            // 선수 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.blue.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          player.position,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${player.team} | #${player.number}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            // 스탯
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  children: [
                    const Text('⚽', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${player.goals}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    const Text('🅰️', style: TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      '${player.assists}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '⭐ ${player.rating.toStringAsFixed(1)}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAthleteItem(Athlete athlete, Color primaryColor) {
    return GestureDetector(
      onTap: () {
        // 선수 상세로 이동
        ref.read(athleteProvider.notifier).selectAthlete(athlete);
        Navigator.of(context).pop();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: athlete.sport.primaryColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(25),
              ),
              child: Center(
                child: Text(
                  athlete.sport.icon,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    athlete.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${athlete.sport.displayName} | ${athlete.team}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: athlete.sport.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                athlete.sport.icon,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNewsResultList(Color primaryColor) {
    if (_newsResults.isEmpty) {
      return Center(
        child: Text(
          '뉴스 검색 결과가 없습니다',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _newsResults.length,
      itemBuilder: (context, index) => _buildNewsItem(_newsResults[index]),
    );
  }

  Widget _buildTalkResultList(Color primaryColor) {
    if (_talkResults.isEmpty) {
      return Center(
        child: Text(
          'Talk 검색 결과가 없습니다',
          style: TextStyle(color: Colors.grey.shade500),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _talkResults.length,
      itemBuilder: (context, index) => _buildTalkItem(_talkResults[index]),
    );
  }

  Widget _buildNewsItem(NewsArticle news) {
    final dateFormat = DateFormat('MM.dd HH:mm');
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.article,
              color: Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        '뉴스',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      news.source,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(news.publishedAt),
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  news.translatedTitle ?? news.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  news.summary,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTalkItem(TalkPost post) {
    final dateFormat = DateFormat('MM.dd HH:mm');
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TalkPostDetailScreen(postId: post.id),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.chat_bubble,
                color: Colors.orange,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          post.category.displayName,
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.orange,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        post.authorName,
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                      const Spacer(),
                      Text(
                        dateFormat.format(post.createdAt),
                        style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.favorite_border, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likeCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.chat_bubble_outline, size: 14, color: Colors.grey.shade500),
                      const SizedBox(width: 4),
                      Text(
                        '${post.commentCount}',
                        style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isSearching = true;
    });

    // 최근 검색어에 추가
    ref.read(recentSearchesProvider.notifier).addSearch(query);

    try {
      // 선수 검색
      final playerService = ref.read(playerServiceProvider);
      final playerResults = await playerService.searchPlayers(query);

      // Athlete 검색
      final athleteState = ref.read(athleteProvider);
      final athleteResults = athleteState.allAthletes.where((athlete) {
        return athlete.name.toLowerCase().contains(query.toLowerCase()) ||
            athlete.team.toLowerCase().contains(query.toLowerCase()) ||
            athlete.sport.displayName.contains(query);
      }).toList();

      // 뉴스 검색
      final newsService = ref.read(newsServiceProvider);
      final newsResults = await newsService.searchNews(playerId: '', query: query);

      // Talk 검색
      final talkService = ref.read(talkServiceProvider);
      final talkResults = await talkService.searchPosts(playerId: '', query: query);

      setState(() {
        _playerResults = playerResults;
        _athleteResults = athleteResults;
        _newsResults = newsResults;
        _talkResults = talkResults;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('검색 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }

  void _showDeleteSearchDialog(String search) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('검색어 삭제'),
        content: Text('"$search"를 최근 검색어에서 삭제하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () {
              ref.read(recentSearchesProvider.notifier).removeSearch(search);
              Navigator.pop(context);
            },
            child: const Text('삭제'),
          ),
        ],
      ),
    );
  }
}

// 인기 검색어 모델
class PopularSearch {
  final String keyword;
  final String change;
  final int rank;

  PopularSearch({
    required this.keyword,
    required this.change,
    required this.rank,
  });
}
