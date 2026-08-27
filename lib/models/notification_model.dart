enum NotificationType {
  eventApproval,
  registrationConfirmed,
  announcement,
  certificateReady,
  securityAlert,
  feedbackAlert,
  general,
}

class NotificationModel {
  final String id;
  final String recipientId; // User UID, 'all', 'role:student', 'role:organizer', 'role:admin'
  final String recipientRole;
  final String title;
  final String message;
  final String? eventId;
  final NotificationType type;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.recipientId,
    this.recipientRole = 'all',
    required this.title,
    required this.message,
    this.eventId,
    this.type = NotificationType.general,
    this.isRead = false,
    required this.createdAt,
  });

  NotificationModel copyWith({
    String? id,
    String? recipientId,
    String? recipientRole,
    String? title,
    String? message,
    String? eventId,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      recipientId: recipientId ?? this.recipientId,
      recipientRole: recipientRole ?? this.recipientRole,
      title: title ?? this.title,
      message: message ?? this.message,
      eventId: eventId ?? this.eventId,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'recipientId': recipientId,
      'recipientRole': recipientRole,
      'title': title,
      'message': message,
      'eventId': eventId,
      'type': type.name,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    try {
      if (val.runtimeType.toString() == 'Timestamp') {
        return (val as dynamic).toDate() as DateTime;
      }
    } catch (_) {}
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    NotificationType parseType(String? t) {
      switch (t) {
        case 'eventApproval':
          return NotificationType.eventApproval;
        case 'registrationConfirmed':
          return NotificationType.registrationConfirmed;
        case 'announcement':
          return NotificationType.announcement;
        case 'certificateReady':
          return NotificationType.certificateReady;
        case 'securityAlert':
          return NotificationType.securityAlert;
        case 'feedbackAlert':
          return NotificationType.feedbackAlert;
        default:
          return NotificationType.general;
      }
    }

    return NotificationModel(
      id: map['id'] as String? ?? '',
      recipientId: map['recipientId'] as String? ?? 'all',
      recipientRole: map['recipientRole'] as String? ?? 'all',
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      eventId: map['eventId'] as String?,
      type: parseType(map['type'] as String?),
      isRead: map['isRead'] as bool? ?? false,
      createdAt: _parseDate(map['createdAt']),
    );
  }
}
