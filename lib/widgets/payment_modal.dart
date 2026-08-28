import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/certificate_model.dart';
import '../providers/certificate_provider.dart';
import '../theme/app_theme.dart';
import 'glass_widgets.dart';

class PaymentModal extends StatefulWidget {
  final CertificateModel certificate;

  const PaymentModal({super.key, required this.certificate});

  static Future<bool?> show(BuildContext context, CertificateModel cert) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => PaymentModal(certificate: cert),
    );
  }

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  String _selectedMethod = 'Card'; // 'Card', 'UPI', 'Wallet'
  bool _isProcessing = false;

  final _cardNumberController = TextEditingController();
  final _upiIdController = TextEditingController();

  @override
  void dispose() {
    _cardNumberController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    final provider = context.read<CertificateProvider>();

    final success = await provider.payCertificateFee(
      certificateId: widget.certificate.id,
      paymentMethod: _selectedMethod,
    );

    setState(() => _isProcessing = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.statusLive,
            content: Text(
              '✅ Payment of \$${widget.certificate.feeAmount.toStringAsFixed(2)} Successful! Certificate unlocked.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(provider.errorMessage ?? 'Payment failed. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final fee = widget.certificate.feeAmount;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A).withOpacity(0.88) : Colors.white.withOpacity(0.90),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.2),
          ),
          padding: EdgeInsets.only(
            left: 22,
            right: 22,
            top: 16,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4.5,
                    decoration: BoxDecoration(
                      color: AppColors.borderLight,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.goldGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(color: AppColors.accentGold.withOpacity(0.4), blurRadius: 10),
                        ],
                      ),
                      child: const Icon(Icons.verified_rounded, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Certificate Clearance',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: isDark ? Colors.white : AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Unlock official verified PDF certificate',
                            style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: isDark ? Colors.white12 : AppColors.borderLight),
                const SizedBox(height: 12),

                // Certificate Info summary
                GlassContainer(
                  borderRadius: 18,
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Event', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
                          Text(
                            widget.certificate.eventTitle,
                            style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w800),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Fee Amount', style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight)),
                          Text(
                            '\$${fee.toStringAsFixed(2)}',
                            style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.statusLive),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Payment Method Selector
                Text('Select Payment Channel', style: GoogleFonts.outfit(fontSize: 13, fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),

                Row(
                  children: [
                    _buildMethodTab('Card', Icons.credit_card_rounded),
                    const SizedBox(width: 8),
                    _buildMethodTab('UPI', Icons.qr_code_2_rounded),
                    const SizedBox(width: 8),
                    _buildMethodTab('Wallet', Icons.account_balance_wallet_rounded),
                  ],
                ),

                const SizedBox(height: 16),

                // Method Input
                if (_selectedMethod == 'Card') ...[
                  GlassTextField(
                    controller: _cardNumberController,
                    labelText: 'Card Number',
                    prefixIcon: Icons.credit_card_rounded,
                  ),
                ] else if (_selectedMethod == 'UPI') ...[
                  GlassTextField(
                    controller: _upiIdController,
                    labelText: 'UPI ID / VPA',
                    prefixIcon: Icons.alternate_email_rounded,
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Text('Campus e-Wallet Balance: \$150.00', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 22),

                // Pay Button
                GlassButton(
                  label: 'Confirm & Pay \$${fee.toStringAsFixed(2)}',
                  icon: Icons.lock_rounded,
                  color: AppColors.statusLive,
                  isLoading: _isProcessing,
                  onPressed: _isProcessing ? null : _processPayment,
                  height: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMethodTab(String name, IconData icon) {
    final isSelected = _selectedMethod == name;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = name),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.heroGradient : null,
            color: isSelected ? null : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.85),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.32),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: isSelected ? Colors.white : AppColors.primary, size: 20),
              const SizedBox(height: 5),
              Text(
                name,
                style: GoogleFonts.inter(
                  fontSize: 11.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
