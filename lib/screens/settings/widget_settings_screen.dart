import 'package:flutter/material.dart';

class WidgetSettingsScreen extends StatefulWidget {
  const WidgetSettingsScreen({super.key});

  @override
  State<WidgetSettingsScreen> createState() => _WidgetSettingsScreenState();
}

class _WidgetSettingsScreenState extends State<WidgetSettingsScreen> {
  WidgetSize _selectedSize = WidgetSize.medium;
  WidgetType _selectedType = WidgetType.nextMatch;
  bool _showCountdown = true;
  bool _showStats = true;
  bool _showLiveBadge = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4A6E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '홈 화면 위젯',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 위젯 미리보기
            _buildSectionTitle('미리보기'),
            const SizedBox(height: 12),
            _buildWidgetPreview(),
            const SizedBox(height: 24),

            // 위젯 크기 선택
            _buildSectionTitle('위젯 크기'),
            const SizedBox(height: 12),
            _buildSizeSelector(),
            const SizedBox(height: 24),

            // 위젯 타입 선택
            _buildSectionTitle('위젯 유형'),
            const SizedBox(height: 12),
            _buildTypeSelector(),
            const SizedBox(height: 24),

            // 표시 옵션
            _buildSectionTitle('표시 옵션'),
            const SizedBox(height: 12),
            _buildDisplayOptions(),
            const SizedBox(height: 24),

            // 위젯 추가 버튼
            _buildAddWidgetButton(),
            const SizedBox(height: 16),

            // 안내 텍스트
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '위젯 추가 방법',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '1. 홈 화면을 길게 눌러 편집 모드 진입\n'
                          '2. 위젯 추가 버튼 탭\n'
                          '3. "K-Player Tracker" 검색\n'
                          '4. 원하는 크기의 위젯 선택',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue.shade700,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildWidgetPreview() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: Column(
        children: [
          // 위젯 샘플
          Container(
            width: _getWidgetWidth(),
            height: _getWidgetHeight(),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1E4A6E), Color(0xFF2D6A9E)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: _buildWidgetContent(),
          ),
          const SizedBox(height: 12),
          Text(
            '${_selectedSize.displayName} 위젯',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  double _getWidgetWidth() {
    switch (_selectedSize) {
      case WidgetSize.small:
        return 100;
      case WidgetSize.medium:
        return 200;
      case WidgetSize.large:
        return double.infinity;
    }
  }

  double _getWidgetHeight() {
    switch (_selectedSize) {
      case WidgetSize.small:
        return 100;
      case WidgetSize.medium:
        return 120;
      case WidgetSize.large:
        return 180;
    }
  }

  Widget _buildWidgetContent() {
    switch (_selectedType) {
      case WidgetType.nextMatch:
        return _buildNextMatchWidget();
      case WidgetType.liveScore:
        return _buildLiveScoreWidget();
      case WidgetType.stats:
        return _buildStatsWidget();
    }
  }

  Widget _buildNextMatchWidget() {
    final isSmall = _selectedSize == WidgetSize.small;

    if (isSmall) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_showLiveBadge)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'D-1',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          const SizedBox(height: 8),
          const Text(
            'PSG',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'vs OM',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.sports_soccer, color: Colors.white, size: 16),
            const SizedBox(width: 6),
            const Text(
              'NEXT MATCH',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            if (_showLiveBadge)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'D-1',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
          ],
        ),
        const Spacer(),
        const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'PSG',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                'vs',
                style: TextStyle(color: Colors.white60, fontSize: 14),
              ),
            ),
            Text(
              'OM',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (_showCountdown)
          const Center(
            child: Text(
              '02:15:30',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildLiveScoreWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (_showLiveBadge)
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
        const Spacer(),
        const Text(
          '2 - 1',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const Spacer(),
        const Text(
          "67'",
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.bar_chart, color: Colors.white, size: 16),
            SizedBox(width: 6),
            Text(
              'SEASON STATS',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const Spacer(),
        if (_showStats) ...[
          _buildStatRow('Goals', '3'),
          _buildStatRow('Assists', '3'),
          _buildStatRow('Rating', '7.2'),
        ],
      ],
    );
  }

  Widget _buildStatRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSizeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: WidgetSize.values.map((size) {
          final isSelected = _selectedSize == size;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSize = size;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E4A6E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      size.icon,
                      color: isSelected ? Colors.white : Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      size.displayName,
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white : Colors.grey.shade700,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: WidgetType.values.map((type) {
          final isSelected = _selectedType == type;
          return ListTile(
            onTap: () {
              setState(() {
                _selectedType = type;
              });
            },
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF1E4A6E).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                type.icon,
                color: isSelected ? const Color(0xFF1E4A6E) : Colors.grey,
              ),
            ),
            title: Text(
              type.displayName,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              type.description,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
            trailing: Radio<WidgetType>(
              value: type,
              groupValue: _selectedType,
              onChanged: (value) {
                setState(() {
                  _selectedType = value!;
                });
              },
              activeColor: const Color(0xFF1E4A6E),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDisplayOptions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('카운트다운 표시'),
            subtitle: const Text('경기 시작까지 남은 시간'),
            value: _showCountdown,
            onChanged: (value) {
              setState(() {
                _showCountdown = value;
              });
            },
            activeThumbColor: const Color(0xFF1E4A6E),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('시즌 통계 표시'),
            subtitle: const Text('골, 어시스트, 평점'),
            value: _showStats,
            onChanged: (value) {
              setState(() {
                _showStats = value;
              });
            },
            activeThumbColor: const Color(0xFF1E4A6E),
          ),
          const Divider(height: 1),
          SwitchListTile(
            title: const Text('LIVE 배지 표시'),
            subtitle: const Text('경기 중 실시간 표시'),
            value: _showLiveBadge,
            onChanged: (value) {
              setState(() {
                _showLiveBadge = value;
              });
            },
            activeThumbColor: const Color(0xFF1E4A6E),
          ),
        ],
      ),
    );
  }

  Widget _buildAddWidgetButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('위젯 설정이 저장되었습니다. 홈 화면에서 위젯을 추가해주세요!'),
              backgroundColor: Colors.green,
            ),
          );
        },
        icon: const Icon(Icons.widgets, color: Colors.white),
        label: const Text(
          '위젯 설정 저장',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E4A6E),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

enum WidgetSize {
  small,
  medium,
  large,
}

extension WidgetSizeExtension on WidgetSize {
  String get displayName {
    switch (this) {
      case WidgetSize.small:
        return '소형';
      case WidgetSize.medium:
        return '중형';
      case WidgetSize.large:
        return '대형';
    }
  }

  IconData get icon {
    switch (this) {
      case WidgetSize.small:
        return Icons.crop_square;
      case WidgetSize.medium:
        return Icons.rectangle_outlined;
      case WidgetSize.large:
        return Icons.panorama_wide_angle_select;
    }
  }
}

enum WidgetType {
  nextMatch,
  liveScore,
  stats,
}

extension WidgetTypeExtension on WidgetType {
  String get displayName {
    switch (this) {
      case WidgetType.nextMatch:
        return '다음 경기';
      case WidgetType.liveScore:
        return '실시간 스코어';
      case WidgetType.stats:
        return '시즌 통계';
    }
  }

  String get description {
    switch (this) {
      case WidgetType.nextMatch:
        return '다음 경기 정보와 카운트다운';
      case WidgetType.liveScore:
        return '경기 중 실시간 스코어';
      case WidgetType.stats:
        return '시즌 골, 어시스트, 평점';
    }
  }

  IconData get icon {
    switch (this) {
      case WidgetType.nextMatch:
        return Icons.calendar_today;
      case WidgetType.liveScore:
        return Icons.sports_soccer;
      case WidgetType.stats:
        return Icons.bar_chart;
    }
  }
}
