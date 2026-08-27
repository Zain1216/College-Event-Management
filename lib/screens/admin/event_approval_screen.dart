import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/event_model.dart';
import '../../providers/event_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class EventApprovalScreen extends StatelessWidget {
  const EventApprovalScreen({super.key});

  void _showRejectDialog(BuildContext context, EventModel event, EventProvider provider) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blurSigma: 20,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Decline Event Proposal', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 10),
              Text('Specify reason for declining "${event.title}":', style: GoogleFonts.inter(fontSize: 12.5)),
              const SizedBox(height: 12),
              GlassTextField(
                controller: reasonController,
                maxLines: 3,
                hintText: 'e.g. Schedule clashes with university examination period / Budget clarification needed',
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  const SizedBox(width: 8),
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
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final pendingEvents = eventProvider.pendingApprovalEvents;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Event Proposal Approvals', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: pendingEvents.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: GlassContainer(
                  borderRadius: 24,
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: AppColors.statusLive.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.check_circle_outline_rounded, size: 54, color: AppColors.statusLive),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'All Proposals Reviewed!',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'There are no pending organizer event submissions requiring administrative review at this time.',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassContainer(
      borderRadius: 22,
      blurSigma: 16,
      margin: const EdgeInsets.only(bottom: 16),
      glowColor: AppColors.statusPending,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.statusPending.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.hourglass_top_rounded, size: 14, color: AppColors.statusPending),
                    const SizedBox(width: 4),
                    Text(
                      'AWAITING APPROVAL',
                      style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.statusPending),
                    ),
                  ],
                ),
              ),
              Text(
                event.category.displayName,
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.primary),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            event.title,
            style: GoogleFonts.outfit(fontSize: 17, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.textPrimaryLight),
          ),
          const SizedBox(height: 4),
          Text(
            'Submitted by ${event.organizerName} (${event.department})',
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
          ),

          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.6),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.8)),
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
            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight, height: 1.35),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 16),
          Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
          const SizedBox(height: 12),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _showRejectDialog(context, event, provider),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error, width: 1.2),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16),
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
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Approve Event'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String val) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
        Text(val, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepNavy)),
      ],
    );
  }
}
