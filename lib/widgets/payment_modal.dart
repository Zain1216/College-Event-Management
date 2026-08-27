import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/certificate_model.dart';
import '../providers/certificate_provider.dart';
import '../theme/app_theme.dart';

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

  final _cardNumberController = TextEditingController(text: '•••• •••• •••• 4242');
  final _upiIdController = TextEditingController(text: 'student@collegeupi');

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

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
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
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
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
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.verified_outlined, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Certificate Fee Clearance',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Text(
                        'Unlock official verified PDF certificate',
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(color: AppColors.borderLight),
            const SizedBox(height: 14),

            // Certificate Info summary
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Event', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      Text(
                        widget.certificate.eventTitle,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Recipient', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      Text(
                        '${widget.certificate.studentName} (${widget.certificate.enrollmentNo})',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Certificate Type', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                      Text(
                        widget.certificate.certificateType.displayName,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                  const Divider(height: 16, color: AppColors.borderLight),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable Fee',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                      ),
                      Text(
                        '\$${fee.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.statusLive,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Text('Select Payment Method', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),

            // Payment Options
            Row(
              children: [
                _buildMethodOption('Card', Icons.credit_card, 'Credit/Debit Card'),
                const SizedBox(width: 8),
                _buildMethodOption('UPI', Icons.qr_code_scanner, 'Instant UPI / QR'),
                const SizedBox(width: 8),
                _buildMethodOption('Wallet', Icons.account_balance_wallet, 'Campus Wallet'),
              ],
            ),

            const SizedBox(height: 16),

            // Method inputs
            if (_selectedMethod == 'Card') ...[
              TextFormField(
                controller: _cardNumberController,
                decoration: const InputDecoration(
                  labelText: 'Card Number',
                  prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                ),
              ),
            ] else if (_selectedMethod == 'UPI') ...[
              TextFormField(
                controller: _upiIdController,
                decoration: const InputDecoration(
                  labelText: 'Virtual Payment Address (VPA / UPI ID)',
                  prefixIcon: Icon(Icons.alternate_email, color: AppColors.primary),
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.account_balance_wallet, color: AppColors.primary),
                    SizedBox(width: 8),
                    Text('Campus Student Wallet Balance: \$250.00', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 24),

            // Checkout Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.statusLive,
                  foregroundColor: Colors.white,
                ),
                icon: _isProcessing
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.lock_outline, size: 20),
                label: Text(
                  _isProcessing ? 'Processing Transaction...' : 'Pay \$${fee.toStringAsFixed(2)} & Download Certificate',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodOption(String key, IconData icon, String label) {
    final isSelected = _selectedMethod == key;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedMethod = key),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.borderLight,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, color: isSelected ? AppColors.primary : AppColors.textSecondaryLight, size: 22),
              const SizedBox(height: 4),
              Text(
                key,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
