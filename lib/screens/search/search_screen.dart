import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/news_article.dart';
import '../../models/talk_post.dart';
import '../../providers/storage_provider.dart';
import '../../providers/talk_provider.dart';
import '../../providers/news_provider.dart';
import '../talk/talk_post_detail_screen.dart';

class SearchScreen extends ConsumerStatefulWidget {
  final String playerId;
  final String playerName;

  const SearchScreen({
    super.key,
    required this.playerId,
    required this.playerName,
  });

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  String _searchQuery = '';
  DateRange _selectedDateRange = DateRange.all;
  bool _isSearching = false;

  // 검색 결과
  List<NewsArticle> _newsResults = [];
  List<TalkPost> _talkResults = [];

  // 인기 검색어
  final List<PopularSearch> _popularSearches = [
    PopularSearch(keyword: '골', change: '+12%'),
    PopularSearch(keyword: '어시스트', change: '+8%'),
    PopularSearch(keyword: '인터뷰', change: '+5%'),
    PopularSearch(keyword: 'PSG 경기일정', change: 'NEW'),
    PopularSearch(keyword: '시즌 통계', change: '-2%'),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    final recentSearches = ref.watch(recentSearchesProvider);

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
            },
            onSubmitted: (value) {
              if (value.trim().isNotEmpty) {
                _performSearch(value.trim());
              }
            },
            decoration: InputDecoration(
              hintText: '${widget.playerName} 관련 검색...',
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
              child: const Text('검색'),
            )
          else
            IconButton(
              icon: const Icon(Icons.filter_list, color: Colors.black87),
              onPressed: _showFilterBottomSheet,
            ),
        ],
      ),
      body: Column(
        children: [
          // 필터 탭
          if (_searchQuery.isNotEmpty && (_newsResults.isNotEmpty || _talkResults.isNotEmpty))
            Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: TabBar(
                controller: _tabController,
                labelColor: const Color(0xFF1E4A6E),
                unselectedLabelColor: Colors.grey,
                indicatorColor: const Color(0xFF1E4A6E),
                tabs: [
                  Tab(text: '전체 (${_newsResults.length + _talkResults.length})'),
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
                    ? _buildRecentSearches(recentSearches)
                    : _buildSearchResults(),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSearches(List<String> recentSearches) {
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
                return GestureDetector(
                  onTap: () {
                    _searchController.text = search;
                    setState(() {
                      _searchQuery = search;
                    });
                    _performSearch(search);
                  },
                  onLongPress: () {
                    _showDeleteSearchDialog(search);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 14,
                          color: Colors.grey.shade600,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          search,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            ref.read(recentSearchesProvider.notifier).removeSearch(search);
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
          ],

          // 인기 검색어
          const Text(
            '인기 검색어',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ..._popularSearches.asMap().entries.map((entry) {
            return _buildPopularSearchItem(entry.key + 1, entry.value);
          }),

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
            children: ['#골', '#어시스트', '#맨오브더매치', '#인터뷰', '#연습', '#국가대표', '#이적', '#부상']
                .map((tag) {
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
                    color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF1E4A6E),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularSearchItem(int rank, PopularSearch search) {
    final isNew = search.change == 'NEW';
    final isUp = search.change.startsWith('+');

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: GestureDetector(
        onTap: () {
          _searchController.text = search.keyword;
          setState(() {
            _searchQuery = search.keyword;
          });
          _performSearch(search.keyword);
        },
        child: Row(
          children: [
            SizedBox(
              width: 30,
              child: Text(
                rank.toString(),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: rank <= 3 ? const Color(0xFF1E4A6E) : Colors.grey,
                ),
              ),
            ),
            Expanded(
              child: Text(
                search.keyword,
                style: const TextStyle(
                  fontSize: 14,
                ),
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

  Widget _buildSearchResults() {
    final hasResults = _newsResults.isNotEmpty || _talkResults.isNotEmpty;

    if (!hasResults) {
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

    return TabBarView(
      controller: _tabController,
      children: [
        _buildAllResults(),
        _buildNewsResultList(),
        _buildTalkResultList(),
      ],
    );
  }

  Widget _buildAllResults() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_newsResults.isNotEmpty) ...[
          _buildSectionHeader('뉴스', _newsResults.length),
          ...(_newsResults.take(3).map((news) => _buildNewsItem(news))),
          if (_newsResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(1),
              child: Text('뉴스 ${_newsResults.length - 3}개 더보기'),
            ),
          const SizedBox(height: 16),
        ],
        if (_talkResults.isNotEmpty) ...[
          _buildSectionHeader('Talk', _talkResults.length),
          ...(_talkResults.take(3).map((post) => _buildTalkItem(post))),
          if (_talkResults.length > 3)
            TextButton(
              onPressed: () => _tabController.animateTo(2),
              child: Text('Talk ${_talkResults.length - 3}개 더보기'),
            ),
        ],
      ],
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($count)',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsResultList() {
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

  Widget _buildTalkResultList() {
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
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      dateFormat.format(news.publishedAt),
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
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
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        dateFormat.format(post.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    post.title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    post.content,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
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
      // 뉴스 검색
      final newsService = ref.read(newsServiceProvider);
      final newsResults = await newsService.searchNews(
        playerId: widget.playerId,
        query: query,
      );

      // Talk 검색
      final talkService = ref.read(talkServiceProvider);
      final talkResults = await talkService.searchPosts(
        playerId: widget.playerId,
        query: query,
      );

      setState(() {
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

  void _showFilterBottomSheet() {
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
                    const Text(
                      '검색 필터',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      '기간',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: DateRange.values.map((range) {
                        final isSelected = _selectedDateRange == range;
                        return GestureDetector(
                          onTap: () {
                            setModalState(() {
                              _selectedDateRange = range;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFF1E4A6E)
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              range.displayName,
                              style: TextStyle(
                                fontSize: 13,
                                color: isSelected ? Colors.white : Colors.black87,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          if (_searchQuery.isNotEmpty) {
                            _performSearch(_searchQuery);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E4A6E),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          '적용',
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
}

// 기간 필터
enum DateRange {
  all,
  today,
  week,
  month,
  year,
}

extension DateRangeExtension on DateRange {
  String get displayName {
    switch (this) {
      case DateRange.all:
        return '전체';
      case DateRange.today:
        return '오늘';
      case DateRange.week:
        return '1주일';
      case DateRange.month:
        return '1개월';
      case DateRange.year:
        return '1년';
    }
  }
}

// 인기 검색어 모델
class PopularSearch {
  final String keyword;
  final String change;

  PopularSearch({required this.keyword, required this.change});
}
