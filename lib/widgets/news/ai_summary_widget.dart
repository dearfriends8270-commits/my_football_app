import 'package:flutter/material.dart';
import '../../models/news_summary.dart';

/// AI 3줄 요약 위젯 - 현지 언론 뉴스를 AI가 요약
class AiSummaryWidget extends StatefulWidget {
  final NewsSummary summary;
  final VoidCallback? onReadMore;
  final VoidCallback? onShare;
  final bool isExpanded;

  const AiSummaryWidget({
    super.key,
    required this.summary,
    this.onReadMore,
    this.onShare,
    this.isExpanded = false,
  });

  @override
  State<AiSummaryWidget> createState() => _AiSummaryWidgetState();
}

class _AiSummaryWidgetState extends State<AiSummaryWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    if (widget.isExpanded) {
      _animationController.forward();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sentiment = NewsSentimentExtension.fromScore(widget.summary.sentimentScore);
    final sentimentColor = Color(sentiment.colorValue);

    return Container(
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
          _buildHeader(sentimentColor, sentiment),

          // 3줄 요약
          _buildSummaryLines(),

          // 키워드
          if (widget.summary.keywords.isNotEmpty) _buildKeywords(),

          // 선수 관련성
          if (widget.summary.playerRelevance != null) _buildPlayerRelevance(),

          // 원문 토글
          _buildOriginalToggle(),

          // 원문 (접힘)
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: _showOriginal ? _buildOriginalContent() : const SizedBox.shrink(),
          ),

          // 액션 버튼
          _buildActions(),
        ],
      ),
    );
  }

  Widget _buildHeader(Color sentimentColor, NewsSentiment sentiment) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 출처 & 언어
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _getLanguageFlag(widget.summary.originalLanguage),
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.summary.originalSource,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF1E4A6E),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.summary.summarySource.icon,
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.summary.summarySource.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              // 감정 분석
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: sentimentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(sentiment.emoji, style: const TextStyle(fontSize: 14)),
                    const SizedBox(width: 4),
                    Text(
                      sentiment.displayName,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: sentimentColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // 제목
          Text(
            widget.summary.originalTitle,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 8),

          // 시간
          Text(
            _formatRelativeTime(widget.summary.publishedAt),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryLines() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFD700).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '📝',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                '3줄 요약',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E4A6E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...widget.summary.summaryLines.asMap().entries.map((entry) {
            final index = entry.key;
            final line = entry.value;
            return _buildSummaryLine(index + 1, line);
          }),
        ],
      ),
    );
  }

  Widget _buildSummaryLine(int number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: const Color(0xFF1E4A6E),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Center(
              child: Text(
                '$number',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeywords() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.summary.keywords.map((keyword) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '#$keyword',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.blue,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPlayerRelevance() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Text('⚽', style: TextStyle(fontSize: 18)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              widget.summary.playerRelevance!,
              style: const TextStyle(
                fontSize: 13,
                color: Colors.green,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOriginalToggle() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _showOriginal = !_showOriginal;
        });
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
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
              _showOriginal ? '원문 접기' : '원문 보기',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(width: 4),
            AnimatedRotation(
              turns: _showOriginal ? 0.5 : 0,
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

  Widget _buildOriginalContent() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                _getLanguageFlag(widget.summary.originalLanguage),
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(width: 4),
              Text(
                '원문 (${_getLanguageName(widget.summary.originalLanguage)})',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            widget.summary.originalContent,
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: Colors.grey.shade800,
            ),
            maxLines: 10,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Row(
        children: [
          // 검증 상태
          if (widget.summary.isVerified)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    '검증됨',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          const Spacer(),

          // 공유
          if (widget.onShare != null)
            IconButton(
              onPressed: widget.onShare,
              icon: Icon(
                Icons.share_outlined,
                color: Colors.grey.shade600,
                size: 20,
              ),
            ),

          // 원문 읽기
          if (widget.onReadMore != null)
            TextButton.icon(
              onPressed: widget.onReadMore,
              icon: const Icon(Icons.open_in_new, size: 16),
              label: const Text('원문 읽기'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF1E4A6E),
              ),
            ),
        ],
      ),
    );
  }

  String _getLanguageFlag(String language) {
    switch (language.toLowerCase()) {
      case 'fr':
        return '🇫🇷';
      case 'es':
        return '🇪🇸';
      case 'de':
        return '🇩🇪';
      case 'en':
        return '🇬🇧';
      case 'it':
        return '🇮🇹';
      case 'ko':
        return '🇰🇷';
      default:
        return '🌍';
    }
  }

  String _getLanguageName(String language) {
    switch (language.toLowerCase()) {
      case 'fr':
        return '프랑스어';
      case 'es':
        return '스페인어';
      case 'de':
        return '독일어';
      case 'en':
        return '영어';
      case 'it':
        return '이탈리아어';
      case 'ko':
        return '한국어';
      default:
        return '외국어';
    }
  }

  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return '${dateTime.month}/${dateTime.day}';
    }
  }
}

/// AI 요약 리스트 위젯
class AiSummaryListWidget extends StatelessWidget {
  final List<NewsSummary> summaries;
  final void Function(NewsSummary)? onItemTap;

  const AiSummaryListWidget({
    super.key,
    required this.summaries,
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.article_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              '요약된 뉴스가 없습니다',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: summaries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final summary = summaries[index];
        return AiSummaryWidget(
          summary: summary,
          onReadMore: onItemTap != null ? () => onItemTap!(summary) : null,
        );
      },
    );
  }
}

/// 샘플 뉴스 요약 데이터 생성
List<NewsSummary> generateSampleNewsSummaries() {
  return [
    NewsSummary(
      id: 'summary_1',
      newsId: 'news_1',
      originalTitle: 'Lee Kang-in brille face à Monaco avec un but et une passe décisive',
      originalContent:
          'Lee Kang-in a été l\'homme du match lors de la victoire du PSG contre Monaco (3-1). Le milieu offensif sud-coréen a ouvert le score d\'une magnifique frappe enroulée avant de délivrer une passe décisive pour Mbappé. Luis Enrique a salué sa performance exceptionnelle en conférence de presse.',
      originalSource: 'L\'Équipe',
      originalLanguage: 'fr',
      summaryLines: [
        '이강인이 모나코전에서 1골 1도움으로 맹활약하며 PSG의 3-1 승리를 이끌었습니다.',
        '감아차기로 선제골을 넣은 후, 음바페에게 결정적인 패스를 연결했습니다.',
        '루이스 엔리게 감독은 기자회견에서 이강인의 뛰어난 경기력을 칭찬했습니다.',
      ],
      sentiment: '긍정',
      sentimentScore: 0.85,
      keywords: ['이강인', 'PSG', '모나코', '골', '도움'],
      playerRelevance: '이강인의 직접적인 활약에 대한 기사입니다',
      publishedAt: DateTime.now().subtract(const Duration(hours: 3)),
      summarizedAt: DateTime.now().subtract(const Duration(hours: 2)),
      summarySource: SummarySource.ai,
      isVerified: true,
    ),
    NewsSummary(
      id: 'summary_2',
      newsId: 'news_2',
      originalTitle: 'Enrique: "Kang-in est l\'un des joueurs les plus talentueux que j\'ai entraînés"',
      originalContent:
          'En conférence de presse, Luis Enrique a fait l\'éloge de Lee Kang-in. "C\'est l\'un des joueurs les plus talentueux que j\'ai eu la chance d\'entraîner. Sa vision du jeu et sa technique sont exceptionnelles. Il progresse chaque semaine et je suis très satisfait de son adaptation."',
      originalSource: 'Le Parisien',
      originalLanguage: 'fr',
      summaryLines: [
        '엔리게 감독이 이강인을 "내가 지도한 선수 중 가장 재능 있는 선수 중 한 명"이라고 극찬했습니다.',
        '그의 경기 비전과 테크닉이 뛰어나다고 평가했습니다.',
        '매주 성장하고 있으며 팀 적응에 매우 만족한다고 밝혔습니다.',
      ],
      sentiment: '매우 긍정',
      sentimentScore: 0.95,
      keywords: ['이강인', '엔리게', '칭찬', '재능'],
      playerRelevance: '감독의 이강인 평가에 관한 인터뷰입니다',
      publishedAt: DateTime.now().subtract(const Duration(hours: 5)),
      summarizedAt: DateTime.now().subtract(const Duration(hours: 4)),
      summarySource: SummarySource.ai,
      isVerified: true,
    ),
    NewsSummary(
      id: 'summary_3',
      newsId: 'news_3',
      originalTitle: 'PSG busca renovar contrato con Lee Kang-in hasta 2029',
      originalContent:
          'Según fuentes cercanas al club, el Paris Saint-Germain está en conversaciones con el entorno de Lee Kang-in para extender su contrato hasta 2029. El club parisino considera al surcoreano como una pieza fundamental del proyecto deportivo de Luis Enrique.',
      originalSource: 'Marca',
      originalLanguage: 'es',
      summaryLines: [
        'PSG가 이강인과 2029년까지 재계약 협상을 진행 중입니다.',
        '구단은 이강인을 엔리게 감독 프로젝트의 핵심 선수로 보고 있습니다.',
        '구단 관계자에 따르면 협상이 긍정적으로 진행되고 있다고 합니다.',
      ],
      sentiment: '긍정',
      sentimentScore: 0.75,
      keywords: ['이강인', 'PSG', '재계약', '2029'],
      playerRelevance: '이강인의 계약 연장에 관한 이적시장 소식입니다',
      publishedAt: DateTime.now().subtract(const Duration(hours: 8)),
      summarizedAt: DateTime.now().subtract(const Duration(hours: 7)),
      summarySource: SummarySource.ai,
      isVerified: false,
    ),
  ];
}
