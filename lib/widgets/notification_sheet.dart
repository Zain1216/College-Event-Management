import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final userId = auth.currentUser?.uid ?? 'visitor';
    final userRole = auth.currentUser?.role.key ?? 'visitor';

    var notifications = notifProvider.getNotificationsForUser(userId, userRole);
    if (_onlyUnread) {
      notifications = notifications.where((n) => !n.isRead).toList();
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.85) : Colors.white.withOpacity(0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.14),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.notifications_active_rounded, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Notifications & Alerts',
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => notifProvider.markAllAsRead(userId),
                    icon: const Icon(Icons.done_all_rounded, size: 16),
                    label: Text('Mark Read', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Filter chips
              Row(
                children: [
                  FilterChip(
                    label: Text('All (${notifProvider.getNotificationsForUser(userId, userRole).length})'),
                    selected: !_onlyUnread,
                    selectedColor: AppColors.primaryContainer,
                    onSelected: (val) => setState(() => _onlyUnread = false),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text('Unread (${notifProvider.getUnreadCount(userId, userRole)})'),
                    selected: _onlyUnread,
                    selectedColor: AppColors.primaryContainer,
                    onSelected: (val) => setState(() => _onlyUnread = true),
                  ),
                ],
              ),

              Divider(height: 20, color: isDark ? Colors.white12 : AppColors.borderLight),

              // List
              Expanded(
                child: notifications.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.notifications_none_rounded, size: 48, color: AppColors.textMutedLight),
                            const SizedBox(height: 10),
                            Text(
                              'No notifications found',
                              style: GoogleFonts.inter(color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: notifications.length,
                        separatorBuilder: (_, __) => Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
                        itemBuilder: (context, index) {
                          final n = notifications[index];
                          return _buildNotificationTile(n, notifProvider);
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(NotificationModel n, NotificationProvider provider) {
    IconData icon;
    Color iconColor;

    switch (n.type) {
      case NotificationType.eventApproval:
        icon = Icons.verified_rounded;
        iconColor = AppColors.primary;
        break;
      case NotificationType.registrationConfirmed:
        icon = Icons.confirmation_number_rounded;
        iconColor = AppColors.statusLive;
        break;
      case NotificationType.certificateReady:
        icon = Icons.school_rounded;
        iconColor = AppColors.accentGold;
        break;
      case NotificationType.securityAlert:
        icon = Icons.warning_amber_rounded;
        iconColor = AppColors.error;
        break;
      case NotificationType.announcement:
        icon = Icons.campaign_rounded;
        iconColor = AppColors.secondaryDark;
        break;
      default:
        icon = Icons.info_outline_rounded;
        iconColor = AppColors.primary;
    }

    final formattedDate = DateFormat('MMM dd, hh:mm a').format(n.createdAt);

    return InkWell(
      onTap: () => provider.markAsRead(n.id),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: n.isRead ? Colors.transparent : AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.14),
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
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      Text(
                        formattedDate,
                        style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMutedLight),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    n.message,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.3),
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
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.5), blurRadius: 4),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
