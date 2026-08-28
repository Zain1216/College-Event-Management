import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/registration_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../services/qr_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class MyTicketsScreen extends StatelessWidget {
  const MyTicketsScreen({super.key});

  void _showFullQrPass(BuildContext context, RegistrationModel reg) {
    final qrData = QrService.generatePassData(reg);

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 28,
          blurSigma: 24,
          constraints: const BoxConstraints(maxWidth: 380),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  gradient: AppColors.heroGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8),
                  ],
                ),
                child: Text(
                  'DIGITAL ENTRY PASS • ${reg.status.displayName.toUpperCase()}',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                reg.eventTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.deepNavy),
              ),
              const SizedBox(height: 4),
              Text(
                '${reg.eventCategory} • ${reg.eventVenue}',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 18),

              // Glowing Glass QR Code Graphic
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
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
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: SelectableText(
                  reg.qrPassCode,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primaryDark,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Student details
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.8)),
                ),
                child: Column(
                  children: [
                    _buildModalDetailRow('Student Name', reg.studentName),
                    const SizedBox(height: 5),
                    _buildModalDetailRow('Enrollment No', reg.enrollmentNo),
                    const SizedBox(height: 5),
                    _buildModalDetailRow('Department', reg.department),
                    const SizedBox(height: 5),
                    _buildModalDetailRow('Event Date', DateFormat('MMM dd, yyyy').format(reg.eventDate)),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              GlassButton(
                label: 'Close Pass',
                onPressed: () => Navigator.pop(ctx),
                height: 44,
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
        Text(label, style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
        Text(value, style: GoogleFonts.inter(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.deepNavy)),
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('My Event Passes & Tickets', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: registrations.isEmpty
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
                          color: AppColors.primaryContainer.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.qr_code_scanner_rounded, size: 50, color: AppColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Event Passes Yet',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Browse upcoming events in the catalog and register with 1-click to get your instant QR entry passes.',
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

    return GlassContainer(
      borderRadius: 22,
      blurSigma: 16,
      margin: const EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.zero,
      glowColor: isAttended ? AppColors.statusLive : (isCancelled ? Colors.grey : AppColors.primary),
      child: Column(
        children: [
          // Ticket Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: isCancelled
                  ? null
                  : (isAttended ? AppColors.liveGradient : AppColors.heroGradient),
              color: isCancelled ? Colors.grey.withOpacity(0.25) : null,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      isAttended ? Icons.verified_rounded : (isCancelled ? Icons.cancel_rounded : Icons.confirmation_number_rounded),
                      color: Colors.white,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      reg.eventCategory.toUpperCase(),
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.4)),
                  ),
                  child: Text(
                    reg.status.displayName.toUpperCase(),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
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
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.12),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          QrImageView(
                            data: QrService.generatePassData(reg),
                            version: QrVersions.auto,
                            size: 64,
                            foregroundColor: AppColors.deepNavy,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Enlarge 🔍',
                            style: GoogleFonts.inter(fontSize: 8.5, color: AppColors.primary, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
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
                        style: GoogleFonts.outfit(
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
                          const Icon(Icons.calendar_today_outlined, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Text(
                            DateFormat('MMM dd, yyyy').format(reg.eventDate),
                            style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSecondaryLight),
                          ),
                          const SizedBox(width: 10),
                          const Icon(Icons.schedule_rounded, size: 12, color: AppColors.primary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reg.eventTime,
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 12, color: AppColors.secondaryDark),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              reg.eventVenue,
                              style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
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

          // Cancel / Show QR Actions Footer
          if (!isCancelled && !isAttended) ...[
            Divider(height: 1, color: Colors.white.withOpacity(0.6)),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton.icon(
                    onPressed: () => _showFullQrPass(context, reg),
                    icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                    label: Text('Open Full Pass', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 12.5)),
                  ),
                  TextButton.icon(
                    onPressed: () async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          title: Text('Cancel Registration?', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
                          content: const Text('Are you sure you want to cancel your seat registration for this event?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep Seat')),
                            GlassButton(
                              label: 'Yes, Cancel Seat',
                              icon: Icons.cancel_outlined,
                              color: AppColors.error,
                              height: 40,
                              onPressed: () => Navigator.pop(ctx, true),
                            ),
                          ],
                        ),
                      );
                      if (confirm == true) {
                        await provider.cancelRegistration(reg.id);
                      }
                    },
                    icon: const Icon(Icons.cancel_outlined, size: 15, color: AppColors.error),
                    label: Text('Cancel Seat', style: GoogleFonts.inter(color: AppColors.error, fontSize: 12, fontWeight: FontWeight.w700)),
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
