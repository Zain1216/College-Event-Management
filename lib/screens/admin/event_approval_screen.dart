import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';

class EventApprovalScreen extends StatelessWidget {
  const EventApprovalScreen({super.key});

  void _showRejectDialog(BuildContext context, EventModel event, EventProvider provider) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Decline Event Proposal'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Specify reason for declining "${event.title}":', style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'e.g. Schedule clashes with university examination period / Budget clarification needed',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () async {
              final reason = reasonController.text.trim().isEmpty
                  ? 'Event proposal did not meet current university scheduling guidelines.'
                  : reasonController.text.trim();
              await provider.rejectEvent(event.id, reason);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Reject Proposal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final pendingEvents = eventProvider.pendingApprovalEvents;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Event Proposal Approvals'),
      ),
      body: pendingEvents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.statusLive.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.check_circle_outline, size: 54, color: AppColors.statusLive),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'All Proposals Reviewed!',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'There are no pending organizer event submissions requiring administrative review at this time.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: pendingEvents.length,
              itemBuilder: (context, index) {
                final event = pendingEvents[index];
                return _buildApprovalCard(context, event, eventProvider);
              },
            ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, EventModel event, EventProvider provider) {
    final formattedDate = DateFormat('EEEE, MMM dd, yyyy').format(event.date);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(color: AppColors.statusPending, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.statusPending.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.hourglass_top, size: 14, color: AppColors.statusPending),
                      SizedBox(width: 4),
                      Text(
                        'AWAITING APPROVAL',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.statusPending),
                      ),
                    ],
                  ),
                ),
                Text(
                  event.category.displayName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Text(
              event.title,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Submitted by ${event.organizerName} (${event.department})',
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),

            const SizedBox(height: 10),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Scheduled Time', '$formattedDate • ${event.time}'),
                  const SizedBox(height: 4),
                  _buildDetailRow('Venue', event.venue),
                  const SizedBox(height: 4),
                  _buildDetailRow('Max Slots', '${event.maxParticipants} Attendees'),
                  const SizedBox(height: 4),
                  _buildDetailRow('Cert Fee', '\$${event.certificateFee.toStringAsFixed(2)}'),
                ],
              ),
            ),

            const SizedBox(height: 10),
            Text(
              event.description,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.3),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),

            const SizedBox(height: 16),
            const Divider(height: 1, color: AppColors.borderLight),
            const SizedBox(height: 12),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showRejectDialog(context, event, provider),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.error,
                      side: const BorderSide(color: AppColors.error),
                    ),
                    icon: const Icon(Icons.close, size: 16),
                    label: const Text('Decline'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await provider.approveEvent(event.id);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.statusLive,
                            content: Text('🎉 Event "${event.title}" Approved and Published to all students!'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.statusLive,
                    ),
                    icon: const Icon(Icons.check, size: 16),
                    label: const Text('Approve Event'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepNavy)),
      ],
    );
  }
}
