import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/notification_sheet.dart';
import '../sitemap/sitemap_screen.dart';
import 'event_approval_screen.dart';
import 'user_management_screen.dart';
import 'report_center_screen.dart';
import 'content_moderation_screen.dart';

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final adminProvider = context.watch<AdminProvider>();
    final feedbackProvider = context.watch<FeedbackProvider>();
    final notifProvider = context.watch<NotificationProvider>();

    final user = auth.currentUser;
    final pendingEvents = eventProvider.pendingApprovalEvents;
    final pendingStaff = adminProvider.pendingStaffApprovals;
    final flaggedFeedbacks = feedbackProvider.flaggedFeedbacks;
    final deptStats = adminProvider.departmentEventCounts;
    final unreadNotifs = notifProvider.getUnreadCount(user?.uid ?? '', 'admin');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Operations & Control'),
        actions: [
          IconButton(
            tooltip: 'App Sitemap & Flow',
            icon: const Icon(Icons.account_tree_outlined, color: AppColors.primary),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: const Icon(Icons.notifications_outlined, color: AppColors.primary),
                onPressed: () => NotificationSheet.show(context),
              ),
              if (unreadNotifs > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '$unreadNotifs',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepNavy, Color(0xFF1E3A8A), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${user?.fullName ?? "Administrator"}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SYSTEM ADMIN',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricTile('Pending Events', '${pendingEvents.length}', Icons.pending_actions, AppColors.accentGold),
                      const SizedBox(width: 8),
                      _buildMetricTile('Staff Signups', '${pendingStaff.length}', Icons.person_add, AppColors.secondaryLight),
                      const SizedBox(width: 8),
                      _buildMetricTile('Active Users', '${adminProvider.totalActiveUsers}', Icons.verified_user, AppColors.statusLive),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // System Security & Alerts Monitor (SRS 1.6 #7 & #10)
            if (pendingEvents.isNotEmpty || pendingStaff.isNotEmpty || flaggedFeedbacks.isNotEmpty || adminProvider.simulatedFailedLogins > 0) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.error.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.shield_outlined, color: AppColors.error, size: 22),
                        SizedBox(width: 8),
                        Text(
                          'System Security & Action Alerts',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    if (pendingEvents.isNotEmpty)
                      _buildAlertRow(
                        '${pendingEvents.length} new event proposals require compliance review.',
                        Icons.event,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventApprovalScreen())),
                      ),
                    if (pendingStaff.isNotEmpty)
                      _buildAlertRow(
                        '${pendingStaff.length} staff registration requests awaiting verification.',
                        Icons.badge,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                      ),
                    if (flaggedFeedbacks.isNotEmpty)
                      _buildAlertRow(
                        '${flaggedFeedbacks.length} feedback submissions flagged for inappropriate content.',
                        Icons.flag,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentModerationScreen())),
                      ),
                    _buildAlertRow(
                      '${adminProvider.simulatedFailedLogins} blocked failed login attempts in last 24h (Normal security threshold).',
                      Icons.lock_clock,
                      null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Core Admin Modules Grid
            const Text(
              'Administrative Governance Modules',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _buildAdminNavTile(
                  context,
                  title: 'Event Approvals',
                  subtitle: '${pendingEvents.length} Pending',
                  icon: Icons.fact_check_outlined,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventApprovalScreen())),
                ),
                const SizedBox(width: 10),
                _buildAdminNavTile(
                  context,
                  title: 'User Management',
                  subtitle: '${adminProvider.allUsers.length} Accounts',
                  icon: Icons.manage_accounts_outlined,
                  color: AppColors.secondaryDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildAdminNavTile(
                  context,
                  title: 'Report Center',
                  subtitle: 'PDF & Excel Export',
                  icon: Icons.file_download_outlined,
                  color: AppColors.statusLive,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportCenterScreen())),
                ),
                const SizedBox(width: 10),
                _buildAdminNavTile(
                  context,
                  title: 'Moderation Hub',
                  subtitle: 'Reviews & Gallery',
                  icon: Icons.security_outlined,
                  color: AppColors.accentOrange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentModerationScreen())),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Department-wise Statistics Chart (SRS 1.6 #7)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Department-wise Event Distribution',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                      ),
                      Icon(Icons.bar_chart, color: AppColors.primary),
                    ],
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 180,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: 6,
                        barTouchData: BarTouchData(enabled: true),
                        titlesData: FlTitlesData(
                          show: true,
                          leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, meta) {
                                switch (val.toInt()) {
                                  case 0:
                                    return const Text('CS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                                  case 1:
                                    return const Text('Arts', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                                  case 2:
                                    return const Text('Mech', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                                  case 3:
                                    return const Text('Sports', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                                  case 4:
                                    return const Text('R&D', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold));
                                  default:
                                    return const Text('');
                                }
                              },
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: AppColors.primary, width: 18, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1, color: AppColors.secondary, width: 18, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1, color: AppColors.accentOrange, width: 18, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1, color: AppColors.statusLive, width: 18, borderRadius: BorderRadius.circular(4))]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1, color: AppColors.primaryDark, width: 18, borderRadius: BorderRadius.circular(4))]),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Reset DB Button
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset Demo Data?'),
                      content: const Text('This will restore all sample users, events, registrations, certificates, and reviews to default factory seed state.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Reset Database'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await adminProvider.resetDatabase();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Database reset to original seed dataset.')),
                      );
                    }
                  }
                },
                icon: const Icon(Icons.restore, color: AppColors.textSecondaryLight, size: 16),
                label: const Text('Restore Default Seed Dataset', style: TextStyle(color: AppColors.textSecondaryLight, fontSize: 12)),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 9)),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertRow(String text, IconData icon, VoidCallback? onTap) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Icon(icon, size: 14, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 11, color: AppColors.deepNavy, fontWeight: FontWeight.w600),
              ),
            ),
            if (onTap != null)
              const Icon(Icons.arrow_forward_ios, size: 10, color: AppColors.error),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminNavTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.deepNavy)),
                    Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
