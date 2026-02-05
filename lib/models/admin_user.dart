/// 관리자 사용자 모델
class AdminUser {
  final String id;
  final String email;
  final String displayName;
  final AdminRole role;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool isActive;
  final List<String> managedPlayerIds;

  AdminUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.lastLoginAt,
    this.isActive = true,
    this.managedPlayerIds = const [],
  });
}

/// 관리자 역할
enum AdminRole {
  superAdmin,   // 전체 관리자
  editor,       // 편집자 (뉴스 승인/거부)
  moderator,    // 모더레이터 (커뮤니티 관리)
  analyst,      // 분석가 (통계 조회만)
}

extension AdminRoleExtension on AdminRole {
  String get displayName {
    switch (this) {
      case AdminRole.superAdmin:
        return '슈퍼 관리자';
      case AdminRole.editor:
        return '편집자';
      case AdminRole.moderator:
        return '모더레이터';
      case AdminRole.analyst:
        return '분석가';
    }
  }

  List<AdminPermission> get permissions {
    switch (this) {
      case AdminRole.superAdmin:
        return AdminPermission.values;
      case AdminRole.editor:
        return [
          AdminPermission.viewNews,
          AdminPermission.approveNews,
          AdminPermission.rejectNews,
          AdminPermission.editNews,
          AdminPermission.viewStats,
        ];
      case AdminRole.moderator:
        return [
          AdminPermission.viewCommunity,
          AdminPermission.deletePosts,
          AdminPermission.banUsers,
          AdminPermission.viewReports,
        ];
      case AdminRole.analyst:
        return [
          AdminPermission.viewStats,
          AdminPermission.viewNews,
        ];
    }
  }
}

/// 관리자 권한
enum AdminPermission {
  viewNews,
  approveNews,
  rejectNews,
  editNews,
  deleteNews,
  viewCommunity,
  deletePosts,
  banUsers,
  viewReports,
  viewStats,
  manageAdmins,
  managePlayers,
  manageSettings,
}
