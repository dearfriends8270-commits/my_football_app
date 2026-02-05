import 'package:flutter/material.dart';

class LineupWidget extends StatefulWidget {
  final String homeTeam;
  final String awayTeam;

  const LineupWidget({
    super.key,
    required this.homeTeam,
    required this.awayTeam,
  });

  @override
  State<LineupWidget> createState() => _LineupWidgetState();
}

class _LineupWidgetState extends State<LineupWidget>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          // 헤더
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  color: Color(0xFF1E4A6E),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  '예상 라인업',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '예상',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // 탭 바
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: const Color(0xFF1E4A6E),
                borderRadius: BorderRadius.circular(8),
              ),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey.shade600,
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              tabs: [
                Tab(text: widget.homeTeam),
                Tab(text: widget.awayTeam),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // 라인업 (간단한 표시)
          SizedBox(
            height: 300,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildLineupField(isHome: true),
                _buildLineupField(isHome: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildLineupField({required bool isHome}) {
    // 샘플 라인업 데이터 (4-3-3 포메이션)
    final formation = isHome
        ? [
            ['GK'],
            ['RB', 'CB', 'CB', 'LB'],
            ['CM', 'CM', 'CM'],
            ['RW', 'ST', 'LW'],
          ]
        : [
            ['GK'],
            ['RB', 'CB', 'CB', 'LB'],
            ['CDM', 'CM', 'CM'],
            ['RW', 'ST', 'LW'],
          ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.green.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          // 필드 마킹
          Positioned.fill(
            child: CustomPaint(
              painter: FieldPainter(),
            ),
          ),
          // 선수 배치
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: formation.reversed.map((line) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: line.map((position) {
                  return _buildPlayerDot(position);
                }).toList(),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerDot(String position) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.person,
              size: 20,
              color: Color(0xFF1E4A6E),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            position,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class FieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // 중앙선
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      paint,
    );

    // 중앙 원
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      40,
      paint,
    );

    // 페널티 에리어 (상단)
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        0,
        size.width * 0.6,
        size.height * 0.15,
      ),
      paint,
    );

    // 페널티 에리어 (하단)
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.2,
        size.height * 0.85,
        size.width * 0.6,
        size.height * 0.15,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
