import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/certificate_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/payment_modal.dart';

class CertificateVaultScreen extends StatelessWidget {
  const CertificateVaultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final certProvider = context.watch<CertificateProvider>();

    final user = auth.currentUser;
    final certificates = user != null
        ? certProvider.getCertificatesForStudent(user.uid)
        : <CertificateModel>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My E-Certificates Vault'),
      ),
      body: certificates.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.accentGold.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.school_outlined, size: 54, color: AppColors.accentGold),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No Certificates Issued Yet',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Attend college events and competitions to receive your official digital certificates of participation and merit awards.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return _buildCertificateCard(context, cert, certProvider);
              },
            ),
    );
  }

  Widget _buildCertificateCard(BuildContext context, CertificateModel cert, CertificateProvider provider) {
    final isWinner = cert.certificateType == CertificateType.winnerFirst ||
        cert.certificateType == CertificateType.winnerSecond ||
        cert.certificateType == CertificateType.winnerThird;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: cert.isFeePaid ? AppColors.accentGold : AppColors.borderLight,
          width: cert.isFeePaid ? 1.5 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top badge row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isWinner ? AppColors.accentGold.withOpacity(0.15) : AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isWinner ? Icons.emoji_events : Icons.verified_outlined,
                        size: 14,
                        color: isWinner ? AppColors.accentGold : AppColors.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        cert.certificateType.displayName,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: isWinner ? AppColors.accentOrange : AppColors.primaryDark,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: cert.isFeePaid ? AppColors.statusLive.withOpacity(0.12) : AppColors.statusPending.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    cert.isFeePaid ? 'READY TO DOWNLOAD' : 'FEE PENDING (\$${cert.feeAmount.toStringAsFixed(0)})',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: cert.isFeePaid ? AppColors.statusLive : AppColors.statusPending,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Event Title & Certificate ID
            Text(
              cert.eventTitle,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimaryLight),
            ),
            const SizedBox(height: 4),
            Text(
              'Certificate ID: ${cert.certificateNumber}  •  Issued by: ${cert.issuedByOrganizer}',
              style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
            ),

            const SizedBox(height: 12),

            // Details Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Recipient', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                      Text(cert.studentName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Enrollment', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                      Text(cert.enrollmentNo, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Date Held', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                      Text(DateFormat('MMM dd, yyyy').format(cert.eventDate), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Action Button (Pay Fee OR Download PDF)
            if (!cert.isFeePaid) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, size: 16, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'As specified in SRS Section 1.4 & 1.6 #6, clearing the certificate fee (\$${cert.feeAmount.toStringAsFixed(2)}) permanently unlocks the high-resolution PDF download.',
                        style: const TextStyle(fontSize: 11, color: AppColors.deepNavy),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => PaymentModal.show(context, cert),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.statusLive,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.lock_open, size: 18),
                  label: Text('Pay \$${cert.feeAmount.toStringAsFixed(2)} & Unlock PDF Certificate', style: const TextStyle(fontWeight: FontWeight.w800)),
                ),
              ),
            ] else ...[
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => provider.downloadCertificate(cert),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                      ),
                      icon: const Icon(Icons.download, size: 18),
                      label: const Text('Download Official PDF Certificate', style: TextStyle(fontWeight: FontWeight.w800)),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
