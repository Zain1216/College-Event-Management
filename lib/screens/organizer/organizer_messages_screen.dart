import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class OrganizerMessagesScreen extends StatefulWidget {
  const OrganizerMessagesScreen({super.key});

  @override
  State<OrganizerMessagesScreen> createState() => _OrganizerMessagesScreenState();
}

class _OrganizerMessagesScreenState extends State<OrganizerMessagesScreen> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  String _selectedEventId = 'all';
  bool _isSending = false;

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _broadcastAnnouncement() async {
    if (_titleController.text.trim().isEmpty || _messageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill out both title and announcement message.')),
      );
      return;
    }

    setState(() => _isSending = true);
    final notifProvider = context.read<NotificationProvider>();

    await notifProvider.broadcastAnnouncement(
      title: _titleController.text.trim(),
      message: _messageController.text.trim(),
      eventId: _selectedEventId == 'all' ? null : _selectedEventId,
      targetRole: 'participant',
    );

    _titleController.clear();
    _messageController.clear();
    setState(() => _isSending = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.statusLive,
          content: Text('📢 Announcement broadcasted to all registered participants!'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final myEvents = eventProvider.allEvents;

    final announcements = notifProvider.allNotifications
        .where((n) => n.recipientRole == 'all' || n.recipientRole == 'participant')
        .toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Broadcasts & Alerts', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Broadcast Composer Glass Card
            GlassContainer(
              borderRadius: 24,
              blurSigma: 16,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: AppColors.heroGradient,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.campaign_rounded, color: Colors.white, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Broadcast Live Update',
                        style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Target Event Selector
                  GlassDropdown<String>(
                    value: _selectedEventId,
                    labelText: 'Target Event Audience',
                    prefixIcon: Icons.group_rounded,
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Registered Students (Campus-wide)', overflow: TextOverflow.ellipsis)),
                      ...myEvents.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedEventId = val);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Announcement Title
                  GlassTextField(
                    controller: _titleController,
                    labelText: 'Announcement Headline',
                    hintText: 'e.g. Schedule Update / Venue Changed to Hall C',
                    prefixIcon: Icons.title_rounded,
                  ),

                  const SizedBox(height: 12),

                  // Announcement Body
                  GlassTextField(
                    controller: _messageController,
                    maxLines: 3,
                    labelText: 'Detailed Broadcast Message',
                    hintText: 'Important instructions, time extensions, or live stream links...',
                  ),

                  const SizedBox(height: 16),

                  GlassButton(
                    label: 'Send Instant Push Broadcast',
                    icon: Icons.send_rounded,
                    isLoading: _isSending,
                    onPressed: _isSending ? null : _broadcastAnnouncement,
                    height: 48,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Live Broadcast Feed History
            Text(
              'Recent Broadcast History',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
            ),
            const SizedBox(height: 10),

            if (announcements.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('No announcements broadcasted yet.', style: GoogleFonts.inter(color: AppColors.textSecondaryLight))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final notif = announcements[idx];
                  return GlassContainer(
                    borderRadius: 18,
                    blurSigma: 12,
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryDark.withOpacity(0.14),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign_rounded, color: AppColors.secondaryDark, size: 20),
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
                                      notif.title,
                                      style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd • hh:mm a').format(notif.createdAt),
                                    style: GoogleFonts.inter(fontSize: 10, color: AppColors.textMutedLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
