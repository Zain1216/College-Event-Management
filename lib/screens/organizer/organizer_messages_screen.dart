import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/notification_provider.dart';
import '../../theme/app_theme.dart';

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
    final myEvents = eventProvider.allEvents;

    final announcements = notifProvider.allNotifications
        .where((n) => n.recipientRole == 'all' || n.recipientRole == 'participant')
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participant Messages & Broadcasts'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Broadcast Composer Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.campaign, color: AppColors.primary, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Broadcast Live Update / Announcement',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Target Event Selector
                  DropdownButtonFormField<String>(
                    value: _selectedEventId,
                    decoration: const InputDecoration(
                      labelText: 'Select Target Event Audience',
                      prefixIcon: Icon(Icons.group, color: AppColors.primary),
                    ),
                    items: [
                      const DropdownMenuItem(value: 'all', child: Text('All Registered Students (Campus-wide)')),
                      ...myEvents.map((e) => DropdownMenuItem(value: e.id, child: Text(e.title, overflow: TextOverflow.ellipsis))),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedEventId = val);
                    },
                  ),

                  const SizedBox(height: 12),

                  // Announcement Title
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Announcement Headline',
                      hintText: 'e.g. Schedule Update / Venue Changed to Hall C',
                      prefixIcon: Icon(Icons.title, color: AppColors.primary),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Announcement Body
                  TextField(
                    controller: _messageController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Detailed Broadcast Message',
                      hintText: 'Important instructions, time extensions, or live stream links...',
                    ),
                  ),

                  const SizedBox(height: 16),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: _isSending ? null : _broadcastAnnouncement,
                      icon: _isSending
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Icon(Icons.send, size: 16),
                      label: const Text('Send Instant Push Broadcast', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Live Broadcast Feed History
            const Text(
              'Recent Broadcast History',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 10),

            if (announcements.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: Text('No announcements broadcasted yet.')),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: announcements.length,
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemBuilder: (context, idx) {
                  final notif = announcements[idx];
                  return Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.secondaryContainer,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.campaign, color: AppColors.secondaryDark, size: 20),
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
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                                    ),
                                  ),
                                  Text(
                                    DateFormat('MMM dd • hh:mm a').format(notif.createdAt),
                                    style: const TextStyle(fontSize: 10, color: AppColors.textMutedLight),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.message,
                                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
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
