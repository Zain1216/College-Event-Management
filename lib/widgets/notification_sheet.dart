import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/notification_model.dart';
import '../providers/auth_provider.dart';
import '../providers/notification_provider.dart';
import '../theme/app_theme.dart';

class NotificationSheet extends StatefulWidget {
  const NotificationSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const NotificationSheet(),
    );
  }

  @override
  State<NotificationSheet> createState() => _NotificationSheetState();
}

class _NotificationSheetState extends State<NotificationSheet> {
  bool _onlyUnread = false;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final userId = auth.currentUser?.uid ?? 'visitor';
    final userRole = auth.currentUser?.role.key ?? 'visitor';

    var notifications = notifProvider.getNotificationsForUser(userId, userRole);
    if (_onlyUnread) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.notifications_active, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Notifications & Alerts',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimaryLight,
                    ),
                  ),
                ],
              ),
              TextButton.icon(
                onPressed: () => notifProvider.markAllAsRead(userId),
                icon: const Icon(Icons.done_all, size: 16),
                label: const Text('Mark All Read', style: TextStyle(fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Filter chips
          Row(
            children: [
              FilterChip(
                label: Text('All (${notifProvider.getNotificationsForUser(userId, userRole).length})'),
                selected: !_onlyUnread,
                onSelected: (val) => setState(() => _onlyUnread = false),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text('Unread Only (${notifProvider.getUnreadCount(userId, userRole)})'),
                selected: _onlyUnread,
                onSelected: (val) => setState(() => _onlyUnread = true),
              ),
            ],
          ),

          const Divider(height: 20, color: AppColors.borderLight),

          // List
          Expanded(
            child: notifications.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.notifications_none, size: 48, color: AppColors.textMutedLight),
                        const SizedBox(height: 10),
                        const Text(
                          'No notifications found',
                          style: TextStyle(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    itemCount: notifications.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.borderLight),
                    itemBuilder: (context, index) {
                      final n = notifications[index];
                      return _buildNotificationTile(n, notifProvider);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel n, NotificationProvider provider) {
    IconData icon;
    Color iconColor;

    switch (n.type) {
      case NotificationType.eventApproval:
        icon = Icons.verified;
        iconColor = AppColors.primary;
        break;
      case NotificationType.registrationConfirmed:
        icon = Icons.confirmation_number;
        iconColor = AppColors.statusLive;
        break;
      case NotificationType.certificateReady:
        icon = Icons.school;
        iconColor = AppColors.accentGold;
        break;
      case NotificationType.securityAlert:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.error;
        break;
      case NotificationType.announcement:
        icon = Icons.campaign;
        iconColor = AppColors.secondaryDark;
        break;
      default:
        icon = Icons.info_outline;
        iconColor = AppColors.primary;
    }

    final formattedDate = DateFormat('MMM dd, hh:mm a').format(n.createdAt);

    return InkWell(
      onTap: () => provider.markAsRead(n.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        color: n.isRead ? Colors.transparent : AppColors.primaryContainer.withOpacity(0.2),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.3),
                  ),
                ],
              ),
            ),
            if (!n.isRead) ...[
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
