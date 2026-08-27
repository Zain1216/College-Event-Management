import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
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
      appBar: AppBar(
        title: const Text('Organizer Control Suite'),
        actions: [
          IconButton(
            tooltip: 'App Sitemap',
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
            // Welcome & Key Statistics (SRS 1.6 #2)
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
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
                        '${user?.fullName ?? "Organizer"}',
                        style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          user?.department ?? 'Department Head',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _buildStatMetric('Events Created', '${myEvents.length}', Icons.event_note),
                      const SizedBox(width: 10),
                      _buildStatMetric('Total Attendees', '$totalRegistrations', Icons.people_alt_outlined),
                      const SizedBox(width: 10),
                      _buildStatMetric('Pending Approval', '$pendingCount', Icons.hourglass_empty),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Organizer Quick Action Tiles
            Row(
              children: [
                _buildActionTile(
                  title: 'Propose Event',
                  subtitle: 'Submit for Admin Approval',
                  icon: Icons.add_circle_outline,
                  color: AppColors.primary,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreateEditScreen())),
                ),
                const SizedBox(width: 10),
                _buildActionTile(
                  title: 'QR Attendance',
                  subtitle: 'Live Check-in Scanner',
                  icon: Icons.qr_code_scanner,
                  color: AppColors.statusLive,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const QrAttendanceScannerScreen())),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                _buildActionTile(
                  title: 'Results & Certs',
                  subtitle: 'Winners & Bulk PDF Issue',
                  icon: Icons.emoji_events_outlined,
                  color: AppColors.accentGold,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ResultsAndCertificatesScreen())),
                ),
                const SizedBox(width: 10),
                _buildActionTile(
                  title: 'Messages & Alerts',
                  subtitle: 'Participant Broadcasts',
                  icon: Icons.chat_bubble_outline,
                  color: AppColors.secondaryDark,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OrganizerMessagesScreen())),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Header & Calendar Toggle (SRS 1.6 #2 & #8)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Event Portfolio & Schedules',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                ),
                IconButton(
                  tooltip: _showCalendarView ? 'Show List View' : 'Show Calendar View',
                  icon: Icon(
                    _showCalendarView ? Icons.view_agenda_outlined : Icons.calendar_month_outlined,
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
              Container(
                padding: const EdgeInsets.all(32),
                alignment: Alignment.center,
                child: const Text('No events matching selected status.', style: TextStyle(color: AppColors.textSecondaryLight)),
              )
            else
              ...filteredEvents.map((e) => _buildOrganizerEventCard(context, e, eventProvider)),

            const SizedBox(height: 40),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreateEditScreen())),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Create New Event', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 4),
            Text(value, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900)),
            Text(label, textAlign: TextAlign.center, style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 10)),
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
                    Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.deepNavy)),
                    Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight), maxLines: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, int count) {
    final isSelected = _statusFilter == label;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text('$label ($count)'),
        selected: isSelected,
        selectedColor: AppColors.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
          color: isSelected ? AppColors.primaryDark : AppColors.textPrimaryLight,
        ),
        onSelected: (val) => setState(() => _statusFilter = label),
      ),
    );
  }

  Widget _buildInteractiveCalendar(List<EventModel> events) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Schedule: ${DateFormat('MMMM yyyy').format(_selectedCalendarDate)}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left, size: 20),
                    onPressed: () => setState(() => _selectedCalendarDate = _selectedCalendarDate.subtract(const Duration(days: 30))),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right, size: 20),
                    onPressed: () => setState(() => _selectedCalendarDate = _selectedCalendarDate.add(const Duration(days: 30))),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Event date dots preview
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
                    Text(DateFormat('MMM dd').format(e.date), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                    const SizedBox(width: 8),
                    Expanded(child: Text(e.title, style: const TextStyle(fontSize: 12), overflow: TextOverflow.ellipsis)),
                    Text(e.status.displayName, style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildOrganizerEventCard(BuildContext context, EventModel e, EventProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
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
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(e.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight)),
            const SizedBox(height: 4),
            Text('${DateFormat("EEE, MMM dd, yyyy").format(e.date)} • ${e.time} • ${e.venue}', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),

            const Divider(height: 20, color: AppColors.borderLight),

            // Action toolbar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Edit
                TextButton.icon(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventCreateEditScreen(existingEvent: e))),
                  icon: const Icon(Icons.edit, size: 14),
                  label: const Text('Edit Event', style: TextStyle(fontSize: 11)),
                ),

                // Make Live toggle
                if (e.status == EventStatus.approved)
                  ElevatedButton.icon(
                    onPressed: () => provider.setEventLive(e.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusLive,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.play_arrow, size: 14),
                    label: const Text('Start (Make Live)', style: TextStyle(fontSize: 11)),
                  )
                else if (e.status == EventStatus.live)
                  ElevatedButton.icon(
                    onPressed: () => provider.completeEvent(e.id),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusCompleted,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.stop, size: 14),
                    label: const Text('End Event', style: TextStyle(fontSize: 11)),
                  ),

                // Scan / Check in shortcut
                IconButton(
                  tooltip: 'Scan Attendee QRs',
                  icon: const Icon(Icons.qr_code_scanner, color: AppColors.primary),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => QrAttendanceScannerScreen(initialEventId: e.id)),
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
