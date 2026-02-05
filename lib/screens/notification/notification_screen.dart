import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/theme_provider.dart';

/// 알림 화면
class NotificationScreen extends ConsumerStatefulWidget {
  const NotificationScreen({super.key});

  @override
  ConsumerState<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends ConsumerState<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock 알림 데이터
  final List<AppNotification> _allNotifications = [
    // 경기 알림
    AppNotification(
      id: '1',
      type: NotificationType.matchStart,
      title: '경기 시작 알림',
      message: '손흥민 선수가 출전하는 토트넘 vs 맨유 경기가 30분 후 시작됩니다!',
      playerName: '손흥민',
      playerImage: 'https://media.api-sports.io/football/players/186.png',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
      isRead: false,
    ),
    AppNotification(
      id: '2',
      type: NotificationType.goal,
      title: '⚽ 골!',
      message: '이강인 선수가 PSG 경기에서 골을 기록했습니다!',
      playerName: '이강인',
      playerImage: 'https://media.api-sports.io/football/players/184432.png',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
    ),
    AppNotification(
      id: '3',
      type: NotificationType.assist,
      title: '🅰️ 어시스트!',
      message: '손흥민 선수가 어시스트를 기록했습니다!',
      playerName: '손흥민',
      playerImage: 'https://media.api-sports.io/football/players/186.png',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: true,
    ),
    // 뉴스 알림
    AppNotification(
      id: '4',
      type: NotificationType.news,
      title: '새로운 뉴스',
      message: '"이강인, PSG 시즌 최고의 경기력 평가" - L\'Equipe',
      playerName: '이강인',
      playerImage: 'https://media.api-sports.io/football/players/184432.png',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      isRead: true,
    ),
    AppNotification(
      id: '5',
      type: NotificationType.news,
      title: '새로운 뉴스',
      message: '"김민재, 분데스리가 이달의 수비수 후보 선정"',
      playerName: '김민재',
      playerImage: 'https://media.api-sports.io/football/players/50096.png',
      createdAt: DateTime.now().subtract(const Duration(hours: 8)),
      isRead: true,
    ),
    // 커뮤니티 알림
    AppNotification(
      id: '6',
      type: NotificationType.comment,
      title: '새 댓글',
      message: '내 게시글에 새로운 댓글이 달렸습니다: "완전 공감해요!"',
      createdAt: DateTime.now().subtract(const Duration(hours: 12)),
      isRead: false,
    ),
    AppNotification(
      id: '7',
      type: NotificationType.like,
      title: '좋아요',
      message: '내 게시글이 50개의 좋아요를 받았습니다!',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
    ),
    // 이적 루머 알림
    AppNotification(
      id: '8',
      type: NotificationType.rumor,
      title: '🔥 새로운 이적 루머',
      message: '황희찬 선수, 프리미어리그 빅클럽 이적설 부상',
      playerName: '황희찬',
      playerImage: 'https://media.api-sports.io/football/players/38908.png',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      isRead: false,
    ),
    // 시스템 알림
    AppNotification(
      id: '9',
      type: NotificationType.system,
      title: '앱 업데이트',
      message: '새로운 기능이 추가되었습니다! AI 요약 기능을 확인해보세요.',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<AppNotification> get _unreadNotifications =>
      _allNotifications.where((n) => !n.isRead).toList();

  List<AppNotification> get _matchNotifications =>
      _allNotifications.where((n) => n.type.isMatch).toList();

  List<AppNotification> get _newsNotifications =>
      _allNotifications.where((n) => n.type == NotificationType.news || n.type == NotificationType.rumor).toList();

  List<AppNotification> get _communityNotifications =>
      _allNotifications.where((n) => n.type == NotificationType.comment || n.type == NotificationType.like).toList();

  @override
  Widget build(BuildContext context) {
    final themeState = ref.watch(appThemeProvider);
    final primaryColor = themeState.primaryColor;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          '알림',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (_unreadNotifications.isNotEmpty)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                '모두 읽음',
                style: TextStyle(color: primaryColor),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.black87),
            onPressed: () => _showNotificationSettings(context, primaryColor),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryColor,
          tabs: [
            Tab(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('전체'),
                  if (_unreadNotifications.isNotEmpty) ...[
                    const SizedBox(width: 4),
                    _buildBadge(_unreadNotifications.length, primaryColor),
                  ],
                ],
              ),
            ),
            const Tab(text: '경기'),
            const Tab(text: '뉴스'),
            const Tab(text: '커뮤니티'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildNotificationList(_allNotifications, primaryColor),
          _buildNotificationList(_matchNotifications, primaryColor),
          _buildNotificationList(_newsNotifications, primaryColor),
          _buildNotificationList(_communityNotifications, primaryColor),
        ],
      ),
    );
  }

  Widget _buildBadge(int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        count > 99 ? '99+' : count.toString(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildNotificationList(List<AppNotification> notifications, Color primaryColor) {
    if (notifications.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_off_outlined,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              '알림이 없습니다',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    // 날짜별 그룹화
    final grouped = _groupNotificationsByDate(notifications);

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final group = grouped[index];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                group.dateLabel,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ...group.notifications.map((notification) =>
                _buildNotificationItem(notification, primaryColor)),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(AppNotification notification, Color primaryColor) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        setState(() {
          _allNotifications.removeWhere((n) => n.id == notification.id);
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('알림이 삭제되었습니다'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: GestureDetector(
        onTap: () => _onNotificationTap(notification),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: notification.isRead ? Colors.white : primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: notification.isRead ? Colors.grey.shade200 : primaryColor.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 아이콘 또는 선수 이미지
              _buildNotificationIcon(notification, primaryColor),
              const SizedBox(width: 12),
              // 내용
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: notification.type.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            notification.type.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: notification.type.color,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: notification.isRead ? FontWeight.w500 : FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
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
              // 읽지 않음 표시
              if (!notification.isRead)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.only(left: 8),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(AppNotification notification, Color primaryColor) {
    if (notification.playerImage != null) {
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: primaryColor.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(22),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: Image.network(
            notification.playerImage!,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(
              notification.type.icon,
              color: notification.type.color,
              size: 24,
            ),
          ),
        ),
      );
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: notification.type.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Icon(
        notification.type.icon,
        color: notification.type.color,
        size: 24,
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) {
      return '방금 전';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes}분 전';
    } else if (diff.inHours < 24) {
      return '${diff.inHours}시간 전';
    } else if (diff.inDays < 7) {
      return '${diff.inDays}일 전';
    } else {
      return DateFormat('MM.dd').format(dateTime);
    }
  }

  List<NotificationGroup> _groupNotificationsByDate(List<AppNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final groups = <NotificationGroup>[];
    final todayList = <AppNotification>[];
    final yesterdayList = <AppNotification>[];
    final olderList = <AppNotification>[];

    for (final notification in notifications) {
      final notificationDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      if (notificationDate == today) {
        todayList.add(notification);
      } else if (notificationDate == yesterday) {
        yesterdayList.add(notification);
      } else {
        olderList.add(notification);
      }
    }

    if (todayList.isNotEmpty) {
      groups.add(NotificationGroup(dateLabel: '오늘', notifications: todayList));
    }
    if (yesterdayList.isNotEmpty) {
      groups.add(NotificationGroup(dateLabel: '어제', notifications: yesterdayList));
    }
    if (olderList.isNotEmpty) {
      groups.add(NotificationGroup(dateLabel: '이전', notifications: olderList));
    }

    return groups;
  }

  void _markAllAsRead() {
    setState(() {
      for (final notification in _allNotifications) {
        notification.isRead = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('모든 알림을 읽음 처리했습니다'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _onNotificationTap(AppNotification notification) {
    setState(() {
      notification.isRead = true;
    });

    // 알림 타입에 따라 다른 화면으로 이동
    switch (notification.type) {
      case NotificationType.matchStart:
      case NotificationType.goal:
      case NotificationType.assist:
        // 경기 상세 또는 매치데이 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('경기 화면으로 이동합니다')),
        );
        break;
      case NotificationType.news:
      case NotificationType.rumor:
        // 뉴스 상세 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('뉴스 화면으로 이동합니다')),
        );
        break;
      case NotificationType.comment:
      case NotificationType.like:
        // 게시글 상세 화면으로 이동
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('게시글 화면으로 이동합니다')),
        );
        break;
      case NotificationType.system:
        // 시스템 알림은 별도 처리 없음
        break;
    }
  }

  void _showNotificationSettings(BuildContext context, Color primaryColor) {
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
                      '알림 설정',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildSettingSwitch(
                      '경기 시작 알림',
                      '팔로우 중인 선수의 경기 시작 알림',
                      true,
                      (value) {},
                      primaryColor,
                    ),
                    _buildSettingSwitch(
                      '골/어시스트 알림',
                      '실시간 골, 어시스트 알림',
                      true,
                      (value) {},
                      primaryColor,
                    ),
                    _buildSettingSwitch(
                      '뉴스 알림',
                      '새로운 뉴스 및 기사 알림',
                      true,
                      (value) {},
                      primaryColor,
                    ),
                    _buildSettingSwitch(
                      '커뮤니티 알림',
                      '댓글, 좋아요 알림',
                      false,
                      (value) {},
                      primaryColor,
                    ),
                    _buildSettingSwitch(
                      '이적 루머 알림',
                      '새로운 이적 루머 알림',
                      true,
                      (value) {},
                      primaryColor,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSettingSwitch(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    Color primaryColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: primaryColor,
          ),
        ],
      ),
    );
  }
}

// 알림 타입
enum NotificationType {
  matchStart,
  goal,
  assist,
  news,
  rumor,
  comment,
  like,
  system,
}

extension NotificationTypeExtension on NotificationType {
  String get label {
    switch (this) {
      case NotificationType.matchStart:
        return '경기';
      case NotificationType.goal:
        return '골';
      case NotificationType.assist:
        return '어시스트';
      case NotificationType.news:
        return '뉴스';
      case NotificationType.rumor:
        return '루머';
      case NotificationType.comment:
        return '댓글';
      case NotificationType.like:
        return '좋아요';
      case NotificationType.system:
        return '시스템';
    }
  }

  IconData get icon {
    switch (this) {
      case NotificationType.matchStart:
        return Icons.sports_soccer;
      case NotificationType.goal:
        return Icons.sports_soccer;
      case NotificationType.assist:
        return Icons.assistant;
      case NotificationType.news:
        return Icons.article;
      case NotificationType.rumor:
        return Icons.trending_up;
      case NotificationType.comment:
        return Icons.comment;
      case NotificationType.like:
        return Icons.favorite;
      case NotificationType.system:
        return Icons.info;
    }
  }

  Color get color {
    switch (this) {
      case NotificationType.matchStart:
        return Colors.blue;
      case NotificationType.goal:
        return Colors.green;
      case NotificationType.assist:
        return Colors.purple;
      case NotificationType.news:
        return Colors.indigo;
      case NotificationType.rumor:
        return Colors.orange;
      case NotificationType.comment:
        return Colors.teal;
      case NotificationType.like:
        return Colors.red;
      case NotificationType.system:
        return Colors.grey;
    }
  }

  bool get isMatch {
    return this == NotificationType.matchStart ||
        this == NotificationType.goal ||
        this == NotificationType.assist;
  }
}

// 알림 모델
class AppNotification {
  final String id;
  final NotificationType type;
  final String title;
  final String message;
  final String? playerName;
  final String? playerImage;
  final DateTime createdAt;
  bool isRead;

  AppNotification({
    required this.id,
    required this.type,
    required this.title,
    required this.message,
    this.playerName,
    this.playerImage,
    required this.createdAt,
    this.isRead = false,
  });
}

// 알림 그룹 (날짜별)
class NotificationGroup {
  final String dateLabel;
  final List<AppNotification> notifications;

  NotificationGroup({
    required this.dateLabel,
    required this.notifications,
  });
}
