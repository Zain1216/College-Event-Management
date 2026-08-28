import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/app_validators.dart';
import 'glass_widgets.dart';

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
      backgroundColor: Colors.transparent,
      child: GlassContainer(
        borderRadius: 28,
        blurSigma: 24,
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
                        gradient: AppColors.heroGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school_rounded, color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Upgrade to Participant',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textPrimaryLight,
                            ),
                          ),
                          Text(
                            'Unlock event registrations & e-certificates',
                            style: GoogleFonts.inter(
                              fontSize: 12,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                Divider(color: Colors.white.withOpacity(0.6)),
                const SizedBox(height: 14),

                // Notice
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryContainer.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.secondary.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.secondaryDark, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Visitors have browse-only access. Complete your student verification details below to enable 1-click event seat registration.',
                          style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.deepNavy),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                // Enrollment Number
                Text('College Enrollment / Student ID *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                GlassTextField(
                  controller: _enrollmentController,
                  hintText: 'e.g. CS-2024-001',
                  prefixIcon: Icons.badge_outlined,
                  validator: AppValidators.enrollmentNo,
                ),

                const SizedBox(height: 14),

                // Department Selector
                Text('Academic Department *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                GlassDropdown<String>(
                  value: _departments.contains(_departmentController.text) ? _departmentController.text : _departments.first,
                  prefixIcon: Icons.domain_rounded,
                  items: _departments
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(d, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) setState(() => _departmentController.text = val);
                  },
                ),

                const SizedBox(height: 14),

                // Mobile Number
                Text('Mobile Number *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                const SizedBox(height: 6),
                GlassTextField(
                  controller: _mobileController,
                  hintText: 'e.g. +92 300 1234567',
                  prefixIcon: Icons.phone_android_rounded,
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final req = AppValidators.requiredField(v, 'Mobile number');
                    if (req != null) return req;
                    return AppValidators.phone(v);
                  },
                ),


                const SizedBox(height: 14),

                // College ID proof preview
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.white.withOpacity(0.8)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attachment_rounded, color: AppColors.primary),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _idProofAttached ? 'Default College ID Card proof attached' : 'No document selected',
                          style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ),
                      Checkbox(
                        value: _idProofAttached,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _idProofAttached = v ?? false),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: _isSubmitting ? null : () => Navigator.pop(context, false),
                        child: Text('Cancel', style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: GlassButton(
                        label: 'Submit & Upgrade',
                        icon: Icons.check_circle_rounded,
                        isLoading: _isSubmitting,
                        onPressed: _isSubmitting ? null : _submitUpgrade,
                      ),
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
