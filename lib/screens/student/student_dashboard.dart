import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/event_card.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/role_upgrade_dialog.dart';
import '../../widgets/notification_sheet.dart';
import '../sitemap/sitemap_screen.dart';
import '../common/campus_map_screen.dart';
import 'event_details_screen.dart';
import 'my_tickets_screen.dart';
import 'certificate_vault_screen.dart';

class StudentDashboard extends StatelessWidget {
  final VoidCallback? onNavigateToCatalog;
  final VoidCallback? onNavigateToTickets;
  final VoidCallback? onNavigateToCertificates;

  const StudentDashboard({
    super.key,
    this.onNavigateToCatalog,
    this.onNavigateToTickets,
    this.onNavigateToCertificates,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final certProvider = context.watch<CertificateProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.currentUser;
    final isVisitor = user?.role == UserRole.visitor;
    final unreadNotifs = notifProvider.getUnreadCount(user?.uid ?? '', user?.role.key ?? 'visitor');

    // My active registered events
    final myRegistrations = user != null ? regProvider.getActiveRegistrationsForStudent(user.uid) : [];
    final registeredEventIds = myRegistrations.map((r) => r.eventId).toSet();
    final registeredEvents = eventProvider.allEvents.where((e) => registeredEventIds.contains(e.id)).toList();

    // Featured & Upcoming events for discovery
    final liveEvents = eventProvider.liveEvents;
    final upcomingEvents = eventProvider.publicEvents.take(5).toList();

    // Bookmarked events
    final bookmarkedEvents = user != null
        ? eventProvider.allEvents.where((e) => user.bookmarkedEventIds.contains(e.id)).toList()
        : [];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const AppLogo(size: 34),
        actions: [
          IconButton(
            tooltip: 'App Sitemap & Flow',
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.8)),
              ),
              child: const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 20),
            ),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
          ),
          Stack(
            children: [
              IconButton(
                tooltip: 'Notifications',
                icon: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                  ),
                  child: const Icon(Icons.notifications_outlined, color: AppColors.primary, size: 20),
                ),
                onPressed: () => NotificationSheet.show(context),
              ),
              if (unreadNotifs > 0)
                Positioned(
                  right: 8,
                  top: 6,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.error,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: AppColors.error.withOpacity(0.4), blurRadius: 6),
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
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 400)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Glowing Glass Hero Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(26),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.32),
                      blurRadius: 22,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(26),
                  child: Stack(
                    children: [
                      // Gradient Background
                      Container(
                        padding: const EdgeInsets.all(22),
                        decoration: const BoxDecoration(
                          gradient: AppColors.heroGradient,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Welcome back, ${user?.fullName.split(' ').first ?? 'Student'}! 👋',
                                    style: GoogleFonts.outfit(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.3,
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.22),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.2),
                                  ),
                                  child: Text(
                                    user?.role.displayName ?? 'Student',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              isVisitor
                                  ? 'Browse technical fests, cultural concerts, and robotics championships. Upgrade to 1-click register!'
                                  : 'You currently have ${myRegistrations.length} active registered event passes and ${certProvider.getCertificatesForStudent(user!.uid).length} verifiable certificates.',
                              style: GoogleFonts.inter(
                                color: Colors.white.withOpacity(0.92),
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            if (isVisitor) ...[
                              const SizedBox(height: 14),
                              ElevatedButton.icon(
                                onPressed: () => RoleUpgradeDialog.show(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: AppColors.primary,
                                  elevation: 2,
                                  shadowColor: Colors.black26,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                icon: const Icon(Icons.upgrade_rounded, size: 18),
                                label: Text(
                                  'Upgrade to Student Participant',
                                  style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 13),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      // Light shimmer accent on top edge
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: 1.5,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.white.withOpacity(0.7),
                                Colors.white.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),

              // Quick Action Shortcuts Grid (SRS 1.6 #2)
              Row(
                children: [
                  _buildQuickActionTile(
                    context,
                    title: 'Digital Passes',
                    subtitle: '${myRegistrations.length} Active',
                    icon: Icons.qr_code_2_rounded,
                    color: AppColors.primary,
                    onTap: onNavigateToTickets ??
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTicketsScreen())),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionTile(
                    context,
                    title: 'E-Certificates',
                    subtitle: 'Vault & PDFs',
                    icon: Icons.school_rounded,
                    color: AppColors.secondaryDark,
                    onTap: onNavigateToCertificates ??
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificateVaultScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildQuickActionTile(
                    context,
                    title: 'Campus Map',
                    subtitle: 'GPS Venues',
                    icon: Icons.map_rounded,
                    color: AppColors.accentOrange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CampusMapScreen())),
                  ),
                  const SizedBox(width: 12),
                  _buildQuickActionTile(
                    context,
                    title: 'App Flow',
                    subtitle: 'Visual Roadmap',
                    icon: Icons.account_tree_rounded,
                    color: AppColors.statusLive,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
                  ),
                ],
              ),

              // Live Events Spotlight
              if (liveEvents.isNotEmpty) ...[
                const SizedBox(height: 24),
                Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: AppColors.statusLive,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: AppColors.statusLive.withOpacity(0.6), blurRadius: 6, spreadRadius: 1),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'HAPPENING RIGHT NOW (LIVE)',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.statusLive,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...liveEvents.map((e) => EventCard(
                      event: e,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e))),
                    )),
              ],

              // Registered Events & Reminders (SRS 1.6 #2)
              if (registeredEvents.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'My Registered Events & Reminders',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 135,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: registeredEvents.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, idx) {
                      final e = registeredEvents[idx];
                      return _buildRegisteredReminderCard(context, e);
                    },
                  ),
                ),
              ],

              // Bookmarked Favorites
              if (bookmarkedEvents.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Bookmarked Events',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.deepNavy,
                  ),
                ),
                const SizedBox(height: 12),
                ...bookmarkedEvents.map((e) => EventCard(
                      event: e,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e))),
                    )),
              ],

              // Recommended / Upcoming Events Feed
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Upcoming College Events',
                    style: GoogleFonts.outfit(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : AppColors.deepNavy,
                    ),
                  ),
                  if (onNavigateToCatalog != null)
                    TextButton(
                      onPressed: onNavigateToCatalog,
                      child: Text(
                        'View All',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (upcomingEvents.isEmpty)
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text('No upcoming events currently scheduled.'),
                  ),
                )
              else
                ...upcomingEvents.map((e) => EventCard(
                      event: e,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e))),
                    )),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionTile(
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        glowColor: color,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.14),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.35), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.18),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisteredReminderCard(BuildContext context, EventModel e) {
    return GlassContainer(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e))),
      width: 240,
      borderRadius: 18,
      blurSigma: 14,
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.alarm_on_rounded, size: 14, color: AppColors.primary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  DateFormat('MMM dd • hh:mm a').format(e.date),
                  style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.primary),
                ),
              ),
            ],
          ),
          Text(
            e.title,
            style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, size: 12, color: AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  e.venue,
                  style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondaryLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
