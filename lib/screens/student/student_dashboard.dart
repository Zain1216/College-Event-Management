import 'package:flutter/material.dart';
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
      appBar: AppBar(
        title: const AppLogo(size: 34),
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
      body: RefreshIndicator(
        onRefresh: () async => await Future.delayed(const Duration(milliseconds: 400)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Hero Welcome Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.3),
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
                          'Welcome back, ${user?.fullName.split(' ').first ?? 'Student'}! 👋',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            user?.role.displayName ?? 'Student',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isVisitor
                          ? 'Browse tech fests, cultural band wars, and sports. Upgrade to 1-click register!'
                          : 'You have ${myRegistrations.length} active registered event passes and ${certProvider.getCertificatesForStudent(user!.uid).length} certificates.',
                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                    ),
                    if (isVisitor) ...[
                      const SizedBox(height: 14),
                      ElevatedButton.icon(
                        onPressed: () => RoleUpgradeDialog.show(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primary,
                        ),
                        icon: const Icon(Icons.upgrade, size: 18),
                        label: const Text('Upgrade to Student Participant', style: TextStyle(fontWeight: FontWeight.w800)),
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Quick Action Shortcuts Grid (SRS 1.6 #2)
              Row(
                children: [
                  _buildQuickActionTile(
                    context,
                    title: 'Digital Passes',
                    subtitle: '${myRegistrations.length} Passes',
                    icon: Icons.qr_code_2,
                    color: AppColors.primary,
                    onTap: onNavigateToTickets ??
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MyTicketsScreen())),
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionTile(
                    context,
                    title: 'E-Certificates',
                    subtitle: 'Vault & PDFs',
                    icon: Icons.school_outlined,
                    color: AppColors.secondaryDark,
                    onTap: onNavigateToCertificates ??
                        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CertificateVaultScreen())),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  _buildQuickActionTile(
                    context,
                    title: 'Campus Map',
                    subtitle: 'GPS Venues',
                    icon: Icons.map_outlined,
                    color: AppColors.accentOrange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CampusMapScreen())),
                  ),
                  const SizedBox(width: 10),
                  _buildQuickActionTile(
                    context,
                    title: 'App Flow & Sitemap',
                    subtitle: 'Visual Roadmap',
                    icon: Icons.account_tree_outlined,
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
                      decoration: const BoxDecoration(
                        color: AppColors.statusLive,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'HAPPENING RIGHT NOW (LIVE)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppColors.statusLive,
                        letterSpacing: 0.5,
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'My Registered Events & Reminders',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 130,
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
                const Text(
                  'Bookmarked Events',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
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
                  const Text(
                    'Upcoming College Events',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                  ),
                  if (onNavigateToCatalog != null)
                    TextButton(
                      onPressed: onNavigateToCatalog,
                      child: const Text('View All'),
                    ),
                ],
              ),
              const SizedBox(height: 10),

              if (upcomingEvents.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
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
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.borderLight),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
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
                    Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.textPrimaryLight),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisteredReminderCard(BuildContext context, EventModel e) {
    return InkWell(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(event: e))),
      child: Container(
        width: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.alarm_on, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    DateFormat('MMM dd • hh:mm a').format(e.date),
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary),
                  ),
                ),
              ],
            ),
            Text(
              e.title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Row(
              children: [
                const Icon(Icons.location_on, size: 12, color: AppColors.textSecondaryLight),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    e.venue,
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
