import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/digital_ticket.dart';
import '../../providers/ticket_collection_provider.dart';
import '../../widgets/collection/digital_ticket_card.dart';

/// 티켓 컬렉션 화면 - 수집한 경기 티켓 갤러리
class TicketCollectionScreen extends ConsumerStatefulWidget {
  const TicketCollectionScreen({super.key});

  @override
  ConsumerState<TicketCollectionScreen> createState() =>
      _TicketCollectionScreenState();
}

class _TicketCollectionScreenState extends ConsumerState<TicketCollectionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  TicketRarity? _selectedRarity;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketCollectionProvider);
    final stats = ref.watch(collectionStatsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: CustomScrollView(
        slivers: [
          // 앱바
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: const Color(0xFF1E4A6E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                '티켓 컬렉션',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: _buildHeaderBackground(stats),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: Colors.white,
              indicatorWeight: 3,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white60,
              tabs: const [
                Tab(text: '컬렉션'),
                Tab(text: '통계'),
              ],
            ),
          ),

          // 탭 콘텐츠
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildCollectionTab(state),
                _buildStatsTab(stats),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBackground(TicketCollectionStats stats) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E4A6E),
            Color(0xFF2E6A8E),
          ],
        ),
      ),
      child: Stack(
        children: [
          // 패턴
          Positioned(
            right: -30,
            top: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.05),
              ),
            ),
          ),
          Positioned(
            left: -50,
            bottom: 50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.03),
              ),
            ),
          ),

          // 수집 진행률
          Positioned(
            left: 20,
            bottom: 60,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${stats.collectedTickets} / ${stats.totalTickets}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 150,
                      height: 6,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        widthFactor: stats.collectionProgress,
                        alignment: Alignment.centerLeft,
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFD700),
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(stats.collectionProgress * 100).toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionTab(TicketCollectionState state) {
    return Column(
      children: [
        // 필터 & 정렬
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // 희귀도 필터
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(null, '전체'),
                      ...TicketRarity.values.map(
                        (rarity) => _buildFilterChip(rarity, rarity.displayName),
                      ),
                    ],
                  ),
                ),
              ),
              // 정렬
              PopupMenuButton<TicketSortOption>(
                icon: const Icon(Icons.sort, color: Color(0xFF1E4A6E)),
                onSelected: (option) {
                  ref.read(ticketCollectionProvider.notifier).setSortOption(option);
                },
                itemBuilder: (context) => TicketSortOption.values
                    .map(
                      (option) => PopupMenuItem(
                        value: option,
                        child: Row(
                          children: [
                            if (state.sortOption == option)
                              const Icon(Icons.check, size: 18),
                            if (state.sortOption != option) const SizedBox(width: 18),
                            const SizedBox(width: 8),
                            Text(option.displayName),
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),

        // 티켓 그리드
        Expanded(
          child: _buildTicketGrid(state),
        ),
      ],
    );
  }

  Widget _buildFilterChip(TicketRarity? rarity, String label) {
    final isSelected = _selectedRarity == rarity;
    final color = rarity != null ? Color(rarity.colorValue) : Colors.grey;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedRarity = rarity);
          ref.read(ticketCollectionProvider.notifier).setFilterRarity(rarity);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (rarity != null) ...[
                Text(rarity.icon, style: const TextStyle(fontSize: 12)),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketGrid(TicketCollectionState state) {
    var tickets = state.tickets;

    // 필터 적용
    if (_selectedRarity != null) {
      tickets = tickets.where((t) => t.rarity == _selectedRarity).toList();
    }

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tickets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.confirmation_number_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 수집된 티켓이 없습니다',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 1,
        childAspectRatio: 1.4,
        mainAxisSpacing: 16,
      ),
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final ticket = tickets[index];
        return Center(
          child: DigitalTicketCard(
            ticket: ticket,
            onTap: () => _showTicketDetail(ticket),
            onCollect: ticket.isCollected
                ? null
                : () => _collectTicket(ticket.id),
          ),
        );
      },
    );
  }

  Widget _buildStatsTab(TicketCollectionStats stats) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 희귀도별 통계
          _buildSectionCard(
            title: '희귀도별 수집',
            child: Column(
              children: TicketRarity.values.map((rarity) {
                final count = stats.rarityCount[rarity] ?? 0;
                final color = Color(rarity.colorValue);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            rarity.icon,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              rarity.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: count > 0 ? count / 10 : 0,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation(color),
                                minHeight: 4,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        '$count장',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // 컬렉션 요약
          _buildSectionCard(
            title: '컬렉션 요약',
            child: Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    '경기장',
                    '${stats.uniqueStadiums}개',
                    Icons.stadium,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    '대회',
                    '${stats.uniqueCompetitions}개',
                    Icons.emoji_events,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 최애 팀
          if (stats.favoriteTeam != null)
            _buildSectionCard(
              title: '최애 팀',
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '⚽',
                        style: TextStyle(fontSize: 24),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stats.favoriteTeam!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        '가장 많이 관람한 팀',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 16),

          // 컬렉션 기간
          _buildSectionCard(
            title: '컬렉션 기간',
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('첫 티켓'),
                    Text(
                      stats.firstTicketDate != null
                          ? _formatDate(stats.firstTicketDate!)
                          : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('최근 티켓'),
                    Text(
                      stats.latestTicketDate != null
                          ? _formatDate(stats.latestTicketDate!)
                          : '-',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E4A6E), size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E4A6E),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  void _showTicketDetail(DigitalTicket ticket) {
    ref.read(ticketCollectionProvider.notifier).incrementViewCount(ticket.id);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 핸들
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // 티켓 카드
              Padding(
                padding: const EdgeInsets.all(24),
                child: DigitalTicketCard(ticket: ticket),
              ),

              // 상세 정보
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 태그
                      if (ticket.tags.isNotEmpty) ...[
                        const Text(
                          '태그',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: ticket.tags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '#$tag',
                                style: const TextStyle(
                                  color: Color(0xFF1E4A6E),
                                  fontSize: 12,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // 조회수
                      Row(
                        children: [
                          const Icon(Icons.visibility, size: 16, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${ticket.viewCount}회 조회',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _collectTicket(String ticketId) {
    ref.read(ticketCollectionProvider.notifier).collectTicket(ticketId);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('티켓이 컬렉션에 추가되었습니다!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}
