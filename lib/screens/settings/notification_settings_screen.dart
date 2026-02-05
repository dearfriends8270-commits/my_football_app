import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 알림 설정 화면 - 피로도 관리 기능 포함
class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  // 알림 설정 상태
  bool _masterSwitch = true;
  bool _matchNotifications = true;
  bool _newsNotifications = true;
  bool _rumorNotifications = true;
  bool _communityNotifications = false;

  // 피로도 관리 설정
  bool _fatigueManagement = true;
  int _maxDailyNotifications = 20;
  int _quietHoursStart = 23;
  int _quietHoursEnd = 7;
  bool _groupSimilarNews = true;
  NotificationPriority _minimumPriority = NotificationPriority.medium;

  // 시간대별 설정
  final Map<String, bool> _timeSlotNotifications = {
    'morning': true, // 06:00 - 12:00
    'afternoon': true, // 12:00 - 18:00
    'evening': true, // 18:00 - 23:00
    'night': false, // 23:00 - 06:00
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E4A6E),
        title: const Text(
          '알림 설정',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 마스터 스위치
            _buildMasterSwitch(),

            if (_masterSwitch) ...[
              // 피로도 관리 섹션
              _buildFatigueManagementSection(),

              // 알림 유형별 설정
              _buildNotificationTypesSection(),

              // 시간대별 설정
              _buildTimeSlotSection(),

              // 알림 미리보기
              _buildNotificationPreview(),

              // 알림 통계
              _buildNotificationStats(),
            ],

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildMasterSwitch() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _masterSwitch
              ? [const Color(0xFF1E4A6E), const Color(0xFF2E6A8E)]
              : [Colors.grey.shade400, Colors.grey.shade500],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (_masterSwitch ? const Color(0xFF1E4A6E) : Colors.grey)
                .withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _masterSwitch ? Icons.notifications_active : Icons.notifications_off,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '푸시 알림',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _masterSwitch ? '모든 알림이 활성화되어 있습니다' : '모든 알림이 꺼져 있습니다',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _masterSwitch,
            onChanged: (value) => setState(() => _masterSwitch = value),
            activeColor: Colors.white,
            activeTrackColor: Colors.white.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildFatigueManagementSection() {
    return _buildSection(
      title: '피로도 관리',
      icon: Icons.psychology,
      description: '알림 과부하를 방지하여 중요한 정보만 받아보세요',
      children: [
        // 피로도 관리 활성화
        SwitchListTile(
          title: const Text('스마트 알림 관리'),
          subtitle: const Text('AI가 알림 빈도를 최적화합니다'),
          value: _fatigueManagement,
          onChanged: (value) => setState(() => _fatigueManagement = value),
          activeColor: const Color(0xFF1E4A6E),
        ),

        if (_fatigueManagement) ...[
          const Divider(),

          // 일일 최대 알림 수
          ListTile(
            title: const Text('일일 최대 알림'),
            subtitle: Text('$_maxDailyNotifications개 / 일'),
            trailing: SizedBox(
              width: 200,
              child: Slider(
                value: _maxDailyNotifications.toDouble(),
                min: 5,
                max: 50,
                divisions: 9,
                label: '$_maxDailyNotifications개',
                activeColor: const Color(0xFF1E4A6E),
                onChanged: (value) =>
                    setState(() => _maxDailyNotifications = value.toInt()),
              ),
            ),
          ),

          // 최소 우선순위
          ListTile(
            title: const Text('최소 알림 우선순위'),
            subtitle: Text(_minimumPriority.displayName),
            trailing: DropdownButton<NotificationPriority>(
              value: _minimumPriority,
              underline: const SizedBox(),
              items: NotificationPriority.values
                  .map((p) => DropdownMenuItem(
                        value: p,
                        child: Row(
                          children: [
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(p.colorValue),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(p.displayName),
                          ],
                        ),
                      ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _minimumPriority = value);
                }
              },
            ),
          ),

          // 유사 뉴스 그룹화
          SwitchListTile(
            title: const Text('유사 뉴스 그룹화'),
            subtitle: const Text('비슷한 내용의 알림을 하나로 묶습니다'),
            value: _groupSimilarNews,
            onChanged: (value) => setState(() => _groupSimilarNews = value),
            activeColor: const Color(0xFF1E4A6E),
          ),
        ],
      ],
    );
  }

  Widget _buildNotificationTypesSection() {
    return _buildSection(
      title: '알림 유형',
      icon: Icons.category,
      children: [
        _buildNotificationTypeItem(
          title: '경기 알림',
          subtitle: '경기 시작, 골, 하프타임, 종료',
          icon: Icons.sports_soccer,
          value: _matchNotifications,
          onChanged: (value) => setState(() => _matchNotifications = value),
          priority: NotificationPriority.high,
        ),
        const Divider(),
        _buildNotificationTypeItem(
          title: '뉴스 알림',
          subtitle: '선수 관련 새 뉴스',
          icon: Icons.article,
          value: _newsNotifications,
          onChanged: (value) => setState(() => _newsNotifications = value),
          priority: NotificationPriority.medium,
        ),
        const Divider(),
        _buildNotificationTypeItem(
          title: '이적 루머',
          subtitle: '이적 및 계약 관련 소식',
          icon: Icons.swap_horiz,
          value: _rumorNotifications,
          onChanged: (value) => setState(() => _rumorNotifications = value),
          priority: NotificationPriority.low,
        ),
        const Divider(),
        _buildNotificationTypeItem(
          title: '커뮤니티',
          subtitle: '댓글, 좋아요, 멘션',
          icon: Icons.people,
          value: _communityNotifications,
          onChanged: (value) => setState(() => _communityNotifications = value),
          priority: NotificationPriority.low,
        ),
      ],
    );
  }

  Widget _buildNotificationTypeItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    required NotificationPriority priority,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF1E4A6E).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: const Color(0xFF1E4A6E), size: 20),
      ),
      title: Row(
        children: [
          Text(title),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Color(priority.colorValue).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              priority.shortName,
              style: TextStyle(
                fontSize: 10,
                color: Color(priority.colorValue),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E4A6E),
      ),
    );
  }

  Widget _buildTimeSlotSection() {
    return _buildSection(
      title: '시간대별 설정',
      icon: Icons.schedule,
      description: '시간대별로 알림 수신 여부를 설정하세요',
      children: [
        _buildTimeSlotItem('morning', '오전', '06:00 - 12:00', Icons.wb_sunny),
        const Divider(),
        _buildTimeSlotItem('afternoon', '오후', '12:00 - 18:00', Icons.wb_cloudy),
        const Divider(),
        _buildTimeSlotItem('evening', '저녁', '18:00 - 23:00', Icons.nights_stay),
        const Divider(),
        _buildTimeSlotItem('night', '심야', '23:00 - 06:00', Icons.bedtime),

        const SizedBox(height: 16),

        // 방해 금지 시간 설정
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.orange.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(Icons.do_not_disturb, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '방해 금지 시간',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$_quietHoursStart:00 - $_quietHoursEnd:00',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: _showQuietHoursDialog,
                child: const Text('변경'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotItem(
    String key,
    String title,
    String timeRange,
    IconData icon,
  ) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFF1E4A6E)),
      title: Text(title),
      subtitle: Text(timeRange),
      trailing: Switch(
        value: _timeSlotNotifications[key] ?? false,
        onChanged: (value) {
          setState(() {
            _timeSlotNotifications[key] = value;
          });
        },
        activeColor: const Color(0xFF1E4A6E),
      ),
    );
  }

  Widget _buildNotificationPreview() {
    return _buildSection(
      title: '알림 미리보기',
      icon: Icons.preview,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              _buildPreviewNotification(
                title: '⚽ 경기 시작!',
                body: 'PSG vs Monaco 경기가 곧 시작됩니다',
                time: '지금',
                priority: NotificationPriority.high,
              ),
              const SizedBox(height: 8),
              _buildPreviewNotification(
                title: '📰 새 뉴스',
                body: '이강인, 모나코전 1골 1도움 맹활약',
                time: '10분 전',
                priority: NotificationPriority.medium,
              ),
              const SizedBox(height: 8),
              _buildPreviewNotification(
                title: '🔄 이적 루머',
                body: 'PSG, 이강인과 재계약 협상 중',
                time: '1시간 전',
                priority: NotificationPriority.low,
                isGrouped: _groupSimilarNews,
                groupCount: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPreviewNotification({
    required String title,
    required String body,
    required String time,
    required NotificationPriority priority,
    bool isGrouped = false,
    int groupCount = 0,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: Color(priority.colorValue),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    if (isGrouped && groupCount > 1) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '+$groupCount',
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  body,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationStats() {
    return _buildSection(
      title: '알림 통계',
      icon: Icons.analytics,
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: '오늘 받은 알림',
                value: '12',
                subValue: '/ $_maxDailyNotifications',
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: '이번 주 평균',
                value: '18',
                subValue: '/ 일',
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                label: '그룹화된 알림',
                value: '45%',
                subValue: '',
                color: Colors.orange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                label: '차단된 알림',
                value: '8',
                subValue: '개',
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required String subValue,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (subValue.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 4),
                  child: Text(
                    subValue,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    String? description,
    required List<Widget> children,
  }) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
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
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: const Color(0xFF1E4A6E), size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  void _showQuietHoursDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('방해 금지 시간 설정'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('시작 시간'),
              trailing: DropdownButton<int>(
                value: _quietHoursStart,
                items: List.generate(24, (i) => i)
                    .map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('$h:00'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _quietHoursStart = value);
                    Navigator.pop(context);
                    _showQuietHoursDialog();
                  }
                },
              ),
            ),
            ListTile(
              title: const Text('종료 시간'),
              trailing: DropdownButton<int>(
                value: _quietHoursEnd,
                items: List.generate(24, (i) => i)
                    .map((h) => DropdownMenuItem(
                          value: h,
                          child: Text('$h:00'),
                        ))
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _quietHoursEnd = value);
                    Navigator.pop(context);
                    _showQuietHoursDialog();
                  }
                },
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}

/// 알림 우선순위
enum NotificationPriority {
  high,
  medium,
  low,
}

extension NotificationPriorityExtension on NotificationPriority {
  String get displayName {
    switch (this) {
      case NotificationPriority.high:
        return '높음';
      case NotificationPriority.medium:
        return '보통';
      case NotificationPriority.low:
        return '낮음';
    }
  }

  String get shortName {
    switch (this) {
      case NotificationPriority.high:
        return '높음';
      case NotificationPriority.medium:
        return '보통';
      case NotificationPriority.low:
        return '낮음';
    }
  }

  int get colorValue {
    switch (this) {
      case NotificationPriority.high:
        return 0xFFF44336;
      case NotificationPriority.medium:
        return 0xFFFF9800;
      case NotificationPriority.low:
        return 0xFF4CAF50;
    }
  }
}
