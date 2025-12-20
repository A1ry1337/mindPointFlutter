class ManagerRequest {
  final String requestId;
  final String managerUsername;
  final String status; // "pending", "approved", "rejected"
  final String createdAt; // ISO строка

  ManagerRequest({
    required this.requestId,
    required this.managerUsername,
    required this.status,
    required this.createdAt,
  });

  factory ManagerRequest.fromJson(Map<String, dynamic> json) {
    return ManagerRequest(
      requestId: json['request_id'],
      managerUsername: json['manager_username'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  String get displayStatus {
    switch (status) {
      case 'approved': return 'Одобрено';
      case 'rejected': return 'Отклонено';
      default: return 'На рассмотрении';
    }
  }
}