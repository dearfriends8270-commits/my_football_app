import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/rumor.dart';

/// 루머 신뢰도 계산기 위젯
class RumorReliabilityWidget extends StatefulWidget {
  final Rumor rumor;
  final VoidCallback? onTap;

  const RumorReliabilityWidget({
    super.key,
    required this.rumor,
    this.onTap,
  });

  @override
  State<RumorReliabilityWidget> createState() => _RumorReliabilityWidgetState();
}

class _RumorReliabilityWidgetState extends State<RumorReliabilityWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scoreAnimation;
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _scoreAnimation = Tween<double>(
      begin: 0.0,
      end: widget.rumor.reliabilityScore,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final level = widget.rumor.reliabilityLevel;
    final levelColor = Color(level.colorValue);

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(levelColor),

            // 신뢰도 게이지
            _buildReliabilityGauge(levelColor, level),

            // 요소별 분석
            _buildFactorsSection(),

            // 출처 정보
            _buildSourcesSection(),

            // 상세 보기 토글
            _buildDetailsToggle(),

            // 상세 정보 (접힘)
            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              child: _showDetails ? _buildDetailedAnalysis() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Color levelColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: levelColor.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 타입 & 상태
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.rumor.type.icon,
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.rumor.type.displayName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(widget.rumor.status.colorValue),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  widget.rumor.status.displayName,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              // 시간
              Text(
                _formatRelativeTime(widget.rumor.lastUpdatedAt),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 제목
          Text(
            widget.rumor.title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),

          const SizedBox(height: 8),

          // 팀 이동 정보
          if (widget.rumor.currentTeam != null && widget.rumor.targetTeam != null)
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.rumor.currentTeam!,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward, size: 16, color: Colors.grey),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: levelColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.rumor.targetTeam!,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ),
                if (widget.rumor.transferFee != null) ...[
                  const Spacer(),
                  Text(
                    '€${widget.rumor.transferFee!.toStringAsFixed(0)}M',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: levelColor,
                    ),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildReliabilityGauge(Color levelColor, ReliabilityLevel level) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              const Text(
                '신뢰도',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              AnimatedBuilder(
                animation: _scoreAnimation,
                builder: (context, child) {
                  return Row(
                    children: [
                      Text(
                        level.emoji,
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${(_scoreAnimation.value * 100).toInt()}%',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: levelColor,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 게이지 바
          AnimatedBuilder(
            animation: _scoreAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // 배경
                  Container(
                    height: 12,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                  // 진행바
                  FractionallySizedBox(
                    widthFactor: _scoreAnimation.value,
                    child: Container(
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            levelColor.withValues(alpha: 0.7),
                            levelColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: levelColor.withValues(alpha: 0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 8),

          // 레벨 표시
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: ReliabilityLevel.values.map((l) {
              final isActive = l == level;
              return Text(
                l.displayName,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? Color(l.colorValue) : Colors.grey.shade400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFactorsSection() {
    final topFactors = widget.rumor.factors.take(3).toList();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '주요 요소',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...topFactors.map((factor) => _buildFactorItem(factor)),
        ],
      ),
    );
  }

  Widget _buildFactorItem(ReliabilityFactor factor) {
    final color = factor.isPositive ? Colors.green : Colors.red;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            factor.isPositive ? Icons.add_circle : Icons.remove_circle,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              factor.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${factor.isPositive ? '+' : '-'}${(factor.score * 100).toInt()}%',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourcesSection() {
    final topSources = widget.rumor.sources.take(3).toList();

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                '📰',
                style: TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              const Text(
                '출처',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '${widget.rumor.sources.length}개 매체',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: topSources.map((source) {
              final tierColor = _getTierColor(source.tierScore);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: tierColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: tierColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      source.name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: tierColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        source.tierLabel,
                        style: const TextStyle(
                          fontSize: 8,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsToggle() {
    return GestureDetector(
      onTap: () => setState(() => _showDetails = !_showDetails),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _showDetails ? '간략히 보기' : '상세 분석 보기',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _showDetails ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: Icon(
                Icons.keyboard_arrow_down,
                size: 20,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedAnalysis() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 전체 요소
          const Text(
            '신뢰도 계산 요소',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.rumor.factors.map((factor) => _buildDetailedFactorItem(factor)),

          const SizedBox(height: 16),

          // 출처 상세
          const Text(
            '출처 상세',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...widget.rumor.sources.map((source) => _buildDetailedSourceItem(source)),

          const SizedBox(height: 16),

          // 타임라인
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '최초 보도',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _formatDate(widget.rumor.firstReportedAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '마지막 업데이트',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      _formatDate(widget.rumor.lastUpdatedAt),
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedFactorItem(ReliabilityFactor factor) {
    final color = factor.isPositive ? Colors.green : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                factor.isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 6),
              Text(
                factor.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                '가중치: ${(factor.weight * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            factor.description,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedSourceItem(RumorSource source) {
    final tierColor = _getTierColor(source.tierScore);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                source.name,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: tierColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  source.tierLabel,
                  style: const TextStyle(
                    fontSize: 9,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                _formatRelativeTime(source.reportedAt),
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          if (source.quote != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Text(
                '"${source.quote}"',
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getTierColor(double tierScore) {
    if (tierScore >= 0.9) return Colors.green;
    if (tierScore >= 0.7) return Colors.blue;
    if (tierScore >= 0.5) return Colors.orange;
    return Colors.grey;
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    if (diff.inHours < 24) return '${diff.inHours}시간 전';
    if (diff.inDays < 7) return '${diff.inDays}일 전';
    return '${dateTime.month}/${dateTime.day}';
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.year}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.day.toString().padLeft(2, '0')}';
  }
}

/// 샘플 루머 데이터 생성
List<Rumor> generateSampleRumors() {
  return [
    Rumor(
      id: 'rumor_1',
      playerId: 'lee_kangin',
      playerName: 'Lee Kang-In',
      title: '이강인, PSG와 2029년까지 재계약 협상 중',
      description: 'PSG가 이강인과의 재계약을 추진하고 있으며, 2029년까지 연장하는 것을 목표로 하고 있다.',
      type: RumorType.contractRenewal,
      targetTeam: 'PSG',
      currentTeam: 'PSG',
      sources: [
        RumorSource(
          id: 's1',
          name: 'Fabrizio Romano',
          type: 'journalist',
          tierScore: 0.95,
          country: 'Italy',
          reportedAt: DateTime.now().subtract(const Duration(hours: 2)),
          quote: 'PSG are in talks with Lee Kang-in for contract extension until 2029.',
        ),
        RumorSource(
          id: 's2',
          name: 'L\'Équipe',
          type: 'media',
          tierScore: 0.85,
          country: 'France',
          reportedAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        RumorSource(
          id: 's3',
          name: 'RMC Sport',
          type: 'media',
          tierScore: 0.75,
          country: 'France',
          reportedAt: DateTime.now().subtract(const Duration(hours: 8)),
        ),
      ],
      reliabilityScore: 0.82,
      factors: [
        const ReliabilityFactor(
          name: 'Tier 1 기자 보도',
          description: 'Fabrizio Romano가 직접 확인한 정보',
          weight: 0.35,
          score: 0.95,
          isPositive: true,
        ),
        const ReliabilityFactor(
          name: '복수 매체 확인',
          description: '3개 이상의 신뢰할 수 있는 매체에서 보도',
          weight: 0.25,
          score: 0.90,
          isPositive: true,
        ),
        const ReliabilityFactor(
          name: '구단 공식 발표 없음',
          description: '아직 공식 발표가 이루어지지 않음',
          weight: 0.15,
          score: 0.30,
          isPositive: false,
        ),
        const ReliabilityFactor(
          name: '선수 측 확인',
          description: '선수 에이전트의 간접적 확인',
          weight: 0.25,
          score: 0.70,
          isPositive: true,
        ),
      ],
      firstReportedAt: DateTime.now().subtract(const Duration(days: 2)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      status: RumorStatus.active,
    ),
    Rumor(
      id: 'rumor_2',
      playerId: 'lee_kangin',
      playerName: 'Lee Kang-In',
      title: '레알 마드리드, 이강인 영입 관심설',
      description: '레알 마드리드가 이강인에게 관심을 보이고 있다는 소문이 돌고 있다.',
      type: RumorType.transfer,
      targetTeam: 'Real Madrid',
      currentTeam: 'PSG',
      transferFee: 80,
      sources: [
        RumorSource(
          id: 's4',
          name: 'Sport',
          type: 'media',
          tierScore: 0.45,
          country: 'Spain',
          reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        RumorSource(
          id: 's5',
          name: 'Twitter 루머',
          type: 'social',
          tierScore: 0.20,
          reportedAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
      ],
      reliabilityScore: 0.25,
      factors: [
        const ReliabilityFactor(
          name: '신뢰도 낮은 출처',
          description: 'Tier 3 이하 매체에서만 보도',
          weight: 0.40,
          score: 0.80,
          isPositive: false,
        ),
        const ReliabilityFactor(
          name: '복수 매체 미확인',
          description: '신뢰할 수 있는 매체에서 확인되지 않음',
          weight: 0.30,
          score: 0.70,
          isPositive: false,
        ),
        const ReliabilityFactor(
          name: '최근 재계약 협상 진행 중',
          description: 'PSG와 재계약 협상이 진행 중이라 이적 가능성 낮음',
          weight: 0.30,
          score: 0.85,
          isPositive: false,
        ),
      ],
      firstReportedAt: DateTime.now().subtract(const Duration(days: 3)),
      lastUpdatedAt: DateTime.now().subtract(const Duration(days: 1)),
      status: RumorStatus.active,
    ),
  ];
}
