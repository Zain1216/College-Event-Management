import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/admin_provider.dart';
import '../../providers/feedback_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.currentUser;
    final pendingEvents = eventProvider.pendingApprovalEvents;
    final pendingStaff = adminProvider.pendingStaffApprovals;
    final flaggedFeedbacks = feedbackProvider.flaggedFeedbacks;
    final unreadNotifs = notifProvider.getUnreadCount(user?.uid ?? '', 'admin');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Admin Operations & Control', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: [
          GlassIconButton(
            tooltip: 'App Sitemap & Flow',
            icon: Icons.account_tree_outlined,
            iconColor: AppColors.primary,
            size: 38,
            iconSize: 18,
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
          ),

          const SizedBox(width: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              GlassIconButton(
                tooltip: 'Notifications',
                icon: Icons.notifications_outlined,
                iconColor: AppColors.primary,
                size: 38,
                iconSize: 18,
                onPressed: () => NotificationSheet.show(context),
              ),
              if (unreadNotifs > 0)
                Positioned(
                  right: 0,
                  top: -2,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(color: AppColors.error.withOpacity(0.5), blurRadius: 6),
                      ],
                    ),
                    child: Text(
                      '$unreadNotifs',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Executive Glass Hero
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.deepNavy, Color(0xFF1E3A8A), AppColors.primary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deepNavy.withOpacity(0.35),
                    blurRadius: 20,
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
                        user?.fullName ?? 'Administrator',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.accentOrange.withOpacity(0.9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SYSTEM ADMIN',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 0.6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildMetricTile('Pending Events', '${pendingEvents.length}', Icons.pending_actions_rounded, AppColors.accentGold),
                      const SizedBox(width: 8),
                      _buildMetricTile('Staff Signups', '${pendingStaff.length}', Icons.person_add_rounded, AppColors.secondaryLight),
                      const SizedBox(width: 8),
                      _buildMetricTile('Active Users', '${adminProvider.totalActiveUsers}', Icons.verified_user_rounded, AppColors.statusLive),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // System Security & Action Alerts (Frosted Glass Alert)
            if (pendingEvents.isNotEmpty || pendingStaff.isNotEmpty || flaggedFeedbacks.isNotEmpty || adminProvider.simulatedFailedLogins > 0) ...[
              GlassContainer(
                borderRadius: 20,
                glowColor: AppColors.error,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.error.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.shield_rounded, color: AppColors.error, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'System Security & Action Alerts',
                          style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.error),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (pendingEvents.isNotEmpty)
                      _buildAlertRow(
                        '${pendingEvents.length} new event proposals require compliance review.',
                        Icons.event_rounded,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventApprovalScreen())),
                      ),
                    if (pendingStaff.isNotEmpty)
                      _buildAlertRow(
                        '${pendingStaff.length} staff registration requests awaiting verification.',
                        Icons.badge_rounded,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                      ),
                    if (flaggedFeedbacks.isNotEmpty)
                      _buildAlertRow(
                        '${flaggedFeedbacks.length} feedback submissions flagged for inappropriate content.',
                        Icons.flag_rounded,
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentModerationScreen())),
                      ),
                    _buildAlertRow(
                      '${adminProvider.simulatedFailedLogins} blocked failed login attempts in last 24h (Normal security threshold).',
                      Icons.lock_clock_rounded,
                      null,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
            ],

            // Core Admin Modules Grid
            Text(
              'Administrative Governance Modules',
              style: GoogleFonts.outfit(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.deepNavy,
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                _buildAdminNavTile(
                  context,
                  title: 'Event Approvals',
                  subtitle: '${pendingEvents.length} Pending',
                  icon: Icons.fact_check_rounded,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventApprovalScreen())),
                ),
                const SizedBox(width: 12),
                _buildAdminNavTile(
                  context,
                  title: 'User Management',
                  subtitle: '${adminProvider.allUsers.length} Accounts',
                  icon: Icons.manage_accounts_rounded,
                  color: AppColors.secondaryDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const UserManagementScreen())),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildAdminNavTile(
                  context,
                  title: 'Report Center',
                  subtitle: 'PDF & Excel Export',
                  icon: Icons.file_download_rounded,
                  color: AppColors.statusLive,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReportCenterScreen())),
                ),
                const SizedBox(width: 12),
                _buildAdminNavTile(
                  context,
                  title: 'Moderation Hub',
                  subtitle: 'Reviews & Gallery',
                  icon: Icons.security_rounded,
                  color: AppColors.accentOrange,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContentModerationScreen())),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Department-wise Statistics Chart (Frosted Glass Container)
            GlassContainer(
              borderRadius: 22,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Department-wise Event Distribution',
                        style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800),
                      ),
                      const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
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
                          BarChartGroupData(x: 0, barRods: [BarChartRodData(toY: 3, color: AppColors.primary, width: 18, borderRadius: BorderRadius.circular(6))]),
                          BarChartGroupData(x: 1, barRods: [BarChartRodData(toY: 1, color: AppColors.secondary, width: 18, borderRadius: BorderRadius.circular(6))]),
                          BarChartGroupData(x: 2, barRods: [BarChartRodData(toY: 1, color: AppColors.accentOrange, width: 18, borderRadius: BorderRadius.circular(6))]),
                          BarChartGroupData(x: 3, barRods: [BarChartRodData(toY: 1, color: AppColors.statusLive, width: 18, borderRadius: BorderRadius.circular(6))]),
                          BarChartGroupData(x: 4, barRods: [BarChartRodData(toY: 1, color: AppColors.primaryDark, width: 18, borderRadius: BorderRadius.circular(6))]),
                        ],
                      ),
                    ),
                  ),
                ],
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
          color: Colors.white.withOpacity(0.16),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 9, fontWeight: FontWeight.w600)),
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
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            children: [
              Icon(icon, size: 15, color: AppColors.error),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.deepNavy, fontWeight: FontWeight.w600),
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded, size: 10, color: AppColors.error),
            ],
          ),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GlassContainer(
        onTap: onTap,
        borderRadius: 20,
        blurSigma: 14,
        padding: const EdgeInsets.all(14),
        glowColor: color,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.35), width: 1.2),
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.deepNavy,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


