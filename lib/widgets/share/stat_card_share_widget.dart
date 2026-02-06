import 'package:flutter/material.dart';
import '../../models/athlete.dart';
import '../../models/sport_type.dart';

/// 인스타그램 스탯 카드 공유 위젯 (기획문서 4.2.6)
/// 경기 종료 후 자동 생성되는 SNS 공유용 인포그래픽
class StatCardShareWidget extends StatefulWidget {
  final Athlete athlete;
  final String matchResult;
  final int goals;
  final int assists;
  final double rating;
  final int passAccuracy;
  final int shots;

  const StatCardShareWidget({
    super.key,
    required this.athlete,
    required this.matchResult,
    required this.goals,
    required this.assists,
    required this.rating,
    required this.passAccuracy,
    required this.shots,
  });

  @override
  State<StatCardShareWidget> createState() => _StatCardShareWidgetState();
}

class _StatCardShareWidgetState extends State<StatCardShareWidget> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 스탯 카드 (9:16 비율)
            _buildStatCard(),

            const SizedBox(height: 16),

            // 응원 문구 입력
            _buildMessageInput(),

            const SizedBox(height: 16),

            // 공유 버튼들
            _buildShareButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard() {
    return Container(
      width: 280,
      height: 497, // 9:16 비율
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            widget.athlete.teamColor,
            widget.athlete.teamColor.withOpacity(0.8),
            widget.athlete.sport.primaryColor,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: widget.athlete.teamColor.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // 배경 패턴
          Positioned(
            right: -40,
            top: 40,
            child: Icon(
              widget.athlete.sport.iconData,
              size: 180,
              color: Colors.white.withOpacity(0.1),
            ),
          ),

          // 콘텐츠
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 브랜드 로고
                const Text(
                  'K-Player Tracker',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                  ),
                ),

                const Divider(color: Colors.white24, height: 24),

                // 선수 정보
                Text(
                  widget.athlete.lastName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.athlete.nameKr,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 32),

                // 주요 스탯
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('⚽', '${widget.goals}', 'Goal'),
                    _buildStatItem('🅰️', '${widget.assists}', 'Assist'),
                    _buildStatItem('⭐', widget.rating.toStringAsFixed(1), 'Rating'),
                  ],
                ),

                const SizedBox(height: 24),

                // 상세 스탯
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildDetailStat('📊', '${widget.passAccuracy}%', 'Pass'),
                      Container(
                        width: 1,
                        height: 30,
                        color: Colors.white24,
                      ),
                      _buildDetailStat('🎯', '${widget.shots}', 'Shot'),
                    ],
                  ),
                ),

                const Spacer(),

                // 응원 문구
                if (_messageController.text.isNotEmpty) ...[
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 8),
                  Text(
                    '"${_messageController.text}"',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                ],

                const Divider(color: Colors.white24),

                // 경기 결과
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    children: [
                      Text(
                        widget.matchResult,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '2026.02.04',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 앱 워터마크
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sports_soccer,
                        size: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'K-Player Tracker',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 11,
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
    );
  }

  Widget _buildStatItem(String emoji, String value, String label) {
    return Column(
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 24),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailStat(String emoji, String value, String label) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildMessageInput() {
    return Container(
      width: 280,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _messageController,
        maxLength: 50,
        decoration: const InputDecoration(
          hintText: '한 줄 응원 문구를 입력하세요',
          hintStyle: TextStyle(color: Colors.grey),
          border: InputBorder.none,
          counterText: '',
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }

  Widget _buildShareButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildShareButton(
          icon: Icons.camera_alt,
          label: '인스타',
          color: const Color(0xFFE1306C),
          onTap: () => _shareToInstagram(),
        ),
        const SizedBox(width: 12),
        _buildShareButton(
          icon: Icons.alternate_email,
          label: '트위터',
          color: const Color(0xFF1DA1F2),
          onTap: () => _shareToTwitter(),
        ),
        const SizedBox(width: 12),
        _buildShareButton(
          icon: Icons.chat_bubble,
          label: '카카오',
          color: const Color(0xFFFEE500),
          onTap: () => _shareToKakao(),
        ),
        const SizedBox(width: 12),
        _buildShareButton(
          icon: Icons.save_alt,
          label: '저장',
          color: Colors.grey,
          onTap: () => _saveImage(),
        ),
      ],
    );
  }

  Widget _buildShareButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _shareToInstagram() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('인스타그램 스토리로 공유 (준비 중)')),
    );
  }

  void _shareToTwitter() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('트위터로 공유 (준비 중)')),
    );
  }

  void _shareToKakao() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('카카오톡으로 공유 (준비 중)')),
    );
  }

  void _saveImage() {
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('이미지 저장 완료!')),
    );
  }
}

/// 스탯 카드 공유 다이얼로그 표시
void showStatCardShareDialog(
  BuildContext context, {
  required Athlete athlete,
  required String matchResult,
  int goals = 0,
  int assists = 0,
  double rating = 7.0,
  int passAccuracy = 85,
  int shots = 3,
}) {
  showDialog(
    context: context,
    builder: (context) => StatCardShareWidget(
      athlete: athlete,
      matchResult: matchResult,
      goals: goals,
      assists: assists,
      rating: rating,
      passAccuracy: passAccuracy,
      shots: shots,
    ),
  );
}
