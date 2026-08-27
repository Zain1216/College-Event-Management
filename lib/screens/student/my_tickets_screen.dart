import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/registration_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../services/qr_service.dart';
import '../../theme/app_theme.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  void _showFullQrPass(BuildContext context, RegistrationModel reg) {
    final qrData = QrService.generatePassData(reg);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'ENTRY PASS • ${reg.status.displayName.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                reg.eventTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 4),
              Text(
                '${reg.eventCategory} • ${reg.eventVenue}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 18),

              // QR Code Graphic
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.borderLight, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 200,
                  foregroundColor: AppColors.deepNavy,
                ),
              ),

              const SizedBox(height: 14),
              SelectableText(
                reg.qrPassCode,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 14),

              // Student details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildModalDetailRow('Student Name', reg.studentName),
                    const SizedBox(height: 4),
                    _buildModalDetailRow('Enrollment No', reg.enrollmentNo),
                    const SizedBox(height: 4),
                    _buildModalDetailRow('Department', reg.department),
                    const SizedBox(height: 4),
                    _buildModalDetailRow('Event Date', DateFormat('MMM dd, yyyy').format(reg.eventDate)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                ),
                child: const Text('Close Pass'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildModalDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
        Text(value, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.deepNavy)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final regProvider = context.watch<RegistrationProvider>();

    final user = auth.currentUser;
    final registrations = user != null ? regProvider.getRegistrationsForStudent(user.uid) : <RegistrationModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Event Passes & Tickets'),
      ),
      body: registrations.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.qr_code_scanner, size: 54, color: AppColors.primary),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Event Passes Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Browse upcoming events in the catalog and register with 1-click to get your instant QR entry passes.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: registrations.length,
              itemBuilder: (context, index) {
                final reg = registrations[index];
                return _buildTicketCard(context, reg, regProvider);
              },
            ),
    );
  }

  Widget _buildTicketCard(BuildContext context, RegistrationModel reg, RegistrationProvider provider) {
    final isCancelled = reg.status == RegistrationStatus.cancelled;
    final isAttended = reg.status == RegistrationStatus.attended;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isCancelled
              ? AppColors.borderLight
              : (isAttended ? AppColors.statusLive.withOpacity(0.5) : AppColors.primary.withOpacity(0.3)),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          // Ticket Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isCancelled
                  ? Colors.grey.shade100
                  : (isAttended ? AppColors.statusLive.withOpacity(0.1) : AppColors.primaryContainer.withOpacity(0.4)),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isAttended ? Icons.verified : (isCancelled ? Icons.cancel : Icons.confirmation_number),
                      color: isCancelled
                          ? Colors.grey
                          : (isAttended ? AppColors.statusLive : AppColors.primary),
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reg.eventCategory.toUpperCase(),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isCancelled ? Colors.grey : AppColors.primaryDark,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isCancelled
                        ? Colors.grey.withOpacity(0.2)
                        : (isAttended ? AppColors.statusLive.withOpacity(0.2) : AppColors.primary.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    reg.status.displayName,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isCancelled
                          ? Colors.grey
                          : (isAttended ? AppColors.statusLive : AppColors.primaryDark),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Ticket Body
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mini QR Preview Tapable
                if (!isCancelled)
                  InkWell(
                    onTap: () => _showFullQrPass(context, reg),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: QrService.generatePassData(reg),
                            version: QrVersions.auto,
                            size: 64,
                            foregroundColor: AppColors.deepNavy,
                          ),
                          const SizedBox(height: 2),
                          const Text('Enlarge 🔍', style: TextStyle(fontSize: 8, color: AppColors.primary, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.block, color: Colors.grey),
                  ),

                const SizedBox(width: 14),

                // Event details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reg.eventTitle,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: isCancelled ? Colors.grey : AppColors.textPrimaryLight,
                          decoration: isCancelled ? TextDecoration.lineThrough : null,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.calendar_today, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(reg.eventDate),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reg.eventTime,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 12, color: AppColors.secondaryDark),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reg.eventVenue,
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Cancel before deadline / Action Footer (SRS 1.6 #4)
          if (!isCancelled && !isAttended) ...[
            const Divider(height: 1, color: AppColors.borderLight),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _showFullQrPass(context, reg),
                    icon: const Icon(Icons.qr_code_2, size: 16),
                    label: const Text('Show QR Pass at Gate'),
                  ),
                  TextButton(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Cancel Registration?'),
                          content: const Text('Are you sure you want to cancel your seat registration for this event?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('No')),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                              onPressed: () => Navigator.pop(ctx, true),
                              child: const Text('Yes, Cancel Seat'),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await provider.cancelRegistration(reg.id);
                      }
                    },
                    child: const Text('Cancel Registration', style: TextStyle(color: AppColors.error, fontSize: 12)),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
