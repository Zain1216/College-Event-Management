import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/firebase_datastore.dart';

class NotificationProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<NotificationModel> _notifications = [];
  StreamSubscription? _notifSub;

  NotificationProvider() {
    _init();
  }

  void _init() {
    _notifications = _dataStore.notifications;
    _notifSub = _dataStore.notificationsStream.listen((list) {
      _notifications = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _notifSub?.cancel();
    super.dispose();
  }

  List<NotificationModel> get allNotifications => _notifications;

  List<NotificationModel> getNotificationsForUser(String userId, String userRole) {
    return _notifications.where((n) {
      if (n.recipientId == 'all' || n.recipientRole == 'all') return true;
      if (n.recipientId == userId) return true;
      if (n.recipientRole == userRole || n.recipientId == 'role:$userRole') return true;
      return false;
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  int getUnreadCount(String userId, String userRole) {
    return getNotificationsForUser(userId, userRole).where((n) => !n.isRead).length;
  }

  Future<void> markAsRead(String notifId) async {
    await _dataStore.markNotificationRead(notifId);
  }

  Future<void> markAllAsRead(String userId) async {
    await _dataStore.markAllNotificationsRead(userId);
  }

  Future<void> broadcastAnnouncement({
    required String title,
    required String message,
    String? eventId,
    String targetRole = 'all',
  }) async {
    final notif = NotificationModel(
      id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
      recipientId: targetRole == 'all' ? 'all' : 'role:$targetRole',
      recipientRole: targetRole,
      title: title,
      message: message,
      eventId: eventId,
      type: NotificationType.announcement,
      createdAt: DateTime.now(),
    );
    await _dataStore.addNotification(notif);
  }
}
