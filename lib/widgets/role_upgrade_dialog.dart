import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class RoleUpgradeDialog extends StatefulWidget {
  const RoleUpgradeDialog({super.key});

  static Future<bool?> show(BuildContext context) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const RoleUpgradeDialog(),
    );
  }

  @override
  State<RoleUpgradeDialog> createState() => _RoleUpgradeDialogState();
}

class _RoleUpgradeDialogState extends State<RoleUpgradeDialog> {
  final _formKey = GlobalKey<FormState>();
  final _enrollmentController = TextEditingController();
  final _departmentController = TextEditingController();
  final _mobileController = TextEditingController();
  bool _idProofAttached = true;
  bool _isSubmitting = false;

  final List<String> _departments = [
    'Computer Science & Engineering',
    'Information Technology',
    'Mechanical & Robotics',
    'Fine Arts & Music Society',
    'Physical Education',
    'Research & Development Wing',
    'Business Administration',
  ];

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    if (auth.currentUser != null) {
      _departmentController.text = auth.currentUser!.department.isNotEmpty && auth.currentUser!.department != 'General'
          ? auth.currentUser!.department
          : _departments.first;
      _mobileController.text = auth.currentUser!.mobile;
    } else {
      _departmentController.text = _departments.first;
    }
  }

  @override
  void dispose() {
    _enrollmentController.dispose();
    _departmentController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _submitUpgrade() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    final auth = context.read<AuthProvider>();

    final success = await auth.upgradeToParticipant(
      enrollmentNo: _enrollmentController.text.trim(),
      department: _departmentController.text.trim(),
      mobile: _mobileController.text.trim(),
      idProof: _idProofAttached ? 'https://images.unsplash.com/photo-1571260899304-425eee4c7efc?w=600' : null,
    );

    setState(() => _isSubmitting = false);

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.statusLive,
            content: Text('🎉 Congratulations! Upgraded to Student Participant. You can now register for all events!'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(auth.errorMessage ?? 'Upgrade failed. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header icon & Title
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.school, color: AppColors.primary, size: 28),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upgrade to Participant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Unlock event registrations & e-certificates',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),
                const Divider(color: AppColors.borderLight),
                const SizedBox(height: 16),

                // Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: AppColors.secondaryDark, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Student Visitors can browse events. Complete your college credentials below for 1-click registration access.',
                          style: TextStyle(fontSize: 12, color: AppColors.deepNavy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Enrollment Number
                const Text('Enrollment / Student ID Number *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _enrollmentController,
                  decoration: const InputDecoration(
                    hintText: 'e.g. CS-2023-089',
                    prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enrollment number is required';
                    return null;
                  },
                ),

                const SizedBox(height: 14),

                // Department Dropdown
                const Text('Academic Department *',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                DropdownButtonFormField<String>(
                  value: _departments.contains(_departmentController.text)
                      ? _departmentController.text
                      : _departments.first,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.domain, color: AppColors.primary),
                  ),
                  items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _departmentController.text = val);
                  },
                ),

                const SizedBox(height: 14),

                // Mobile
                const Text('Contact Mobile Number',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _mobileController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: '+1 (555) 000-0000',
                    prefixIcon: Icon(Icons.phone_android, color: AppColors.primary),
                  ),
                ),

                const SizedBox(height: 14),

                // College ID Proof Attachment Simulation
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLight,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.borderLight),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attachment, color: AppColors.primary),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('College ID Proof Document',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            Text('Attached: Student_ID_Card.jpg',
                                style: TextStyle(fontSize: 11, color: AppColors.statusLive)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('ID proof file updated.')),
                          );
                        },
                        child: const Text('Change'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                      child: const Text('Cancel', style: TextStyle(color: AppColors.textSecondaryLight)),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _isSubmitting ? null : _submitUpgrade,
                      icon: _isSubmitting
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.verified_user, size: 18),
                      label: const Text('Verify & Upgrade'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
