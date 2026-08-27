import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/notification_sheet.dart';
import '../sitemap/sitemap_screen.dart';
import 'event_create_edit_screen.dart';
import 'qr_attendance_scanner_screen.dart';
import 'results_and_certificates_screen.dart';
import 'organizer_messages_screen.dart';

class OrganizerDashboard extends StatefulWidget {
  const OrganizerDashboard({super.key});

  @override
  State<OrganizerDashboard> createState() => _OrganizerDashboardState();
}

class _OrganizerDashboardState extends State<OrganizerDashboard> {
  String _statusFilter = 'All'; // 'All', 'Live', 'Upcoming', 'Completed', 'Pending'
  bool _showCalendarView = false;
  DateTime _selectedCalendarDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final eventProvider = context.watch<EventProvider>();
    final regProvider = context.watch<RegistrationProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.currentUser;
    final organizerId = user?.uid ?? '';
    final myEvents = eventProvider.getEventsByOrganizer(organizerId);

    final totalRegistrations = myEvents.fold<int>(0, (sum, e) => sum + e.registeredCount);
    final liveCount = myEvents.where((e) => e.status == EventStatus.live).length;
    final upcomingCount = myEvents.where((e) => e.status == EventStatus.approved).length;
    final pendingCount = myEvents.where((e) => e.status == EventStatus.pending).length;
    final completedCount = myEvents.where((e) => e.status == EventStatus.completed).length;

    var filteredEvents = myEvents;
    if (_statusFilter == 'Live') {
      filteredEvents = myEvents.where((e) => e.status == EventStatus.live).toList();
    } else if (_statusFilter == 'Upcoming') {
      filteredEvents = myEvents.where((e) => e.status == EventStatus.approved).toList();
    } else if (_statusFilter == 'Pending') {
      filteredEvents = myEvents.where((e) => e.status == EventStatus.pending).toList();
    } else if (_statusFilter == 'Completed') {
      filteredEvents = myEvents.where((e) => e.status == EventStatus.completed).toList();
    }

    final unreadNotifs = notifProvider.getUnreadCount(user?.uid ?? '', 'organizer');

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Organizer Control Suite', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'App Sitemap',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome & Key Statistics Glass Hero
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.32),
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
                        user?.fullName ?? 'Organizer',
                        style: GoogleFonts.outfit(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.22),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.white.withOpacity(0.4)),
                        ),
                        child: Text(
                          user?.department ?? 'Department Head',
                          style: GoogleFonts.inter(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatMetric('Events Created', '${myEvents.length}', Icons.event_note_rounded),
                      const SizedBox(width: 10),
                      _buildStatMetric('Total Attendees', '$totalRegistrations', Icons.people_alt_rounded),
                      const SizedBox(width: 10),
                      _buildStatMetric('Pending Approval', '$pendingCount', Icons.hourglass_top_rounded),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Organizer Quick Action Tiles
            Row(
              children: [
                _buildActionTile(
                  title: 'Propose Event',
                  subtitle: 'Submit for Admin Approval',
                  icon: Icons.add_circle_outline_rounded,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreateEditScreen())),
                ),
                const SizedBox(width: 12),
                _buildActionTile(
                  title: 'QR Attendance',
                  subtitle: 'Live Check-in Scanner',
                  icon: Icons.qr_code_scanner_rounded,
                  color: AppColors.statusLive,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrAttendanceScannerScreen())),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildActionTile(
                  title: 'Results & Certs',
                  subtitle: 'Winners & Bulk PDF Issue',
                  icon: Icons.emoji_events_rounded,
                  color: AppColors.accentGold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsAndCertificatesScreen())),
                ),
                const SizedBox(width: 12),
                _buildActionTile(
                  title: 'Messages & Alerts',
                  subtitle: 'Broadcast to Attendees',
                  icon: Icons.chat_bubble_outline_rounded,
                  color: AppColors.secondaryDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerMessagesScreen())),
                ),
              ],
            ),

            const SizedBox(height: 22),

            // Header & Calendar Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Event Portfolio & Schedules',
                  style: GoogleFonts.outfit(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.deepNavy,
                  ),
                ),
                IconButton(
                  tooltip: _showCalendarView ? 'Show List View' : 'Show Calendar View',
                  icon: Icon(
                    _showCalendarView ? Icons.view_agenda_rounded : Icons.calendar_month_rounded,
                    color: AppColors.primary,
                  ),
                  onPressed: () => setState(() => _showCalendarView = !_showCalendarView),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Calendar View if toggled
            if (_showCalendarView) ...[
              _buildInteractiveCalendar(myEvents),
              const SizedBox(height: 16),
            ],

            // Status Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildStatusChip('All', myEvents.length),
                  _buildStatusChip('Live', liveCount),
                  _buildStatusChip('Upcoming', upcomingCount),
                  _buildStatusChip('Pending', pendingCount),
                  _buildStatusChip('Completed', completedCount),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Event List
            if (filteredEvents.isEmpty)
              GlassContainer(
                borderRadius: 20,
                padding: const EdgeInsets.all(28),
                child: const Center(
                  child: Text('No events matching selected status.', style: TextStyle(color: AppColors.textSecondaryLight)),
                ),
              )
            else
              ...filteredEvents.map((e) => _buildOrganizerEventCard(context, e, eventProvider)),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 60),
        child: FloatingActionButton.extended(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreateEditScreen())),
          backgroundColor: AppColors.primary,
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          label: Text('Create New Event', style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.w800)),
        ),
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: GoogleFonts.outfit(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(color: Colors.white.withOpacity(0.9), fontSize: 10, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count) {
    final isSelected = _statusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _statusFilter = label),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.heroGradient : null,
            color: isSelected ? null : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
              width: 1.2,
            ),
          ),
          child: Text(
            '$label ($count)',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInteractiveCalendar(List<EventModel> events) {
    return GlassContainer(
      borderRadius: 20,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule: ${DateFormat('MMMM yyyy').format(_selectedCalendarDate)}',
                style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, size: 22),
                    onPressed: () => setState(() => _selectedCalendarDate = _selectedCalendarDate.subtract(const Duration(days: 30))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, size: 22),
                    onPressed: () => setState(() => _selectedCalendarDate = _selectedCalendarDate.add(const Duration(days: 30))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...events.take(4).map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: e.status == EventStatus.live ? AppColors.statusLive : AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(DateFormat('MMM dd').format(e.date), style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.title, style: GoogleFonts.inter(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Text(e.status.displayName, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrganizerEventCard(BuildContext context, EventModel e, EventProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: 20,
      blurSigma: 14,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              StatusBadge(status: e.status.displayName, isLive: e.status == EventStatus.live),
              Text(
                '${e.registeredCount}/${e.maxParticipants} Registered',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            e.title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${DateFormat("EEE, MMM dd, yyyy").format(e.date)} • ${e.time} • ${e.venue}',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
          ),

          Divider(height: 20, color: isDark ? Colors.white12 : AppColors.borderLight),

          // Action toolbar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Edit
              TextButton.icon(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventCreateEditScreen(existingEvent: e))),
                icon: const Icon(Icons.edit_rounded, size: 15),
                label: Text('Edit', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
              ),

              // Make Live toggle
              if (e.status == EventStatus.approved)
                ElevatedButton.icon(
                  onPressed: () => provider.setEventLive(e.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusLive,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.play_arrow_rounded, size: 16),
                  label: const Text('Start (Live)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                )
              else if (e.status == EventStatus.live)
                ElevatedButton.icon(
                  onPressed: () => provider.completeEvent(e.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusCompleted,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  ),
                  icon: const Icon(Icons.stop_rounded, size: 16),
                  label: const Text('End Event', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                ),

              // Scan / Check in shortcut
              IconButton(
                tooltip: 'Scan Attendee QRs',
                icon: const Icon(Icons.qr_code_scanner_rounded, color: AppColors.primary),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QrAttendanceScannerScreen(initialEventId: e.id)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
