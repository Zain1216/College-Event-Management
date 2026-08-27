import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/certificate_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/payment_modal.dart';

class CertificateVaultScreen extends StatelessWidget {
  const CertificateVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final certProvider = context.watch<CertificateProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final user = auth.currentUser;
    final certificates = user != null
        ? certProvider.getCertificatesForStudent(user.uid)
        : <CertificateModel>[];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('My E-Certificates Vault', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: certificates.isEmpty
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
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.accentGold.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.school_rounded, size: 54, color: AppColors.accentGold),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Certificates Issued Yet',
                        style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Attend college events and competitions to receive your official digital certificates of participation and merit awards.',
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
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return _buildCertificateCard(context, cert, certProvider);
              },
            ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, CertificateModel cert, CertificateProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isWinner = cert.certificateType == CertificateType.winnerFirst ||
        cert.certificateType == CertificateType.winnerSecond ||
        cert.certificateType == CertificateType.winnerThird;

    return GlassContainer(
      borderRadius: 22,
      blurSigma: 16,
      margin: const EdgeInsets.only(bottom: 16),
      glowColor: cert.isFeePaid ? AppColors.accentGold : AppColors.primary,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top badge row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isWinner ? AppColors.accentGold.withOpacity(0.18) : AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isWinner ? AppColors.accentGold.withOpacity(0.4) : AppColors.primary.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      isWinner ? Icons.emoji_events_rounded : Icons.verified_rounded,
                      size: 15,
                      color: isWinner ? AppColors.accentGold : AppColors.primary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      cert.certificateType.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: isWinner ? AppColors.accentOrange : AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: cert.isFeePaid ? AppColors.statusLive.withOpacity(0.16) : AppColors.statusPending.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: cert.isFeePaid ? AppColors.statusLive.withOpacity(0.4) : AppColors.statusPending.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  cert.isFeePaid ? 'READY TO DOWNLOAD' : 'FEE PENDING (\$${cert.feeAmount.toStringAsFixed(0)})',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: cert.isFeePaid ? AppColors.statusLive : AppColors.statusPending,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Event Title & Certificate ID
          Text(
            cert.eventTitle,
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: isDark ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Certificate ID: ${cert.certificateNumber}  •  Issued by: ${cert.issuedByOrganizer}',
            style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
          ),

          const SizedBox(height: 14),

          // Details Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.55),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.75)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Recipient', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight)),
                    Text(cert.studentName, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Enrollment', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight)),
                    Text(cert.enrollmentNo, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date Held', style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight)),
                    Text(DateFormat('MMM dd, yyyy').format(cert.eventDate), style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800)),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Button
          if (!cert.isFeePaid) ...[
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.primaryContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Clear certificate processing fee (\$${cert.feeAmount.toStringAsFixed(2)}) to permanently unlock the high-res PDF.',
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.deepNavy),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            GlassButton(
              label: 'Pay \$${cert.feeAmount.toStringAsFixed(2)} & Unlock PDF',
              icon: Icons.lock_open_rounded,
              color: AppColors.statusLive,
              onPressed: () => PaymentModal.show(context, cert),
              height: 46,
            ),
          ] else ...[
            GlassButton(
              label: 'Download Official PDF Certificate',
              icon: Icons.download_rounded,
              onPressed: () => provider.downloadCertificate(cert),
              height: 46,
            ),
          ],
        ],
      ),
    );
  }
}
