import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glass_widgets.dart';
import '../../utils/app_validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  UserRole _selectedRole = UserRole.participant;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _mobileController = TextEditingController();
  final _enrollmentController = TextEditingController();
  String _selectedDepartment = 'Computer Science & Engineering';

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
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _mobileController.dispose();
    _enrollmentController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final isStaff = _selectedRole == UserRole.organizer;

    final success = await auth.register(

      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      role: _selectedRole,
      department: _selectedDepartment,
      mobile: _mobileController.text.trim(),
      enrollmentNo: _selectedRole == UserRole.participant ? _enrollmentController.text.trim() : null,
      collegeIdProof: _selectedRole == UserRole.participant ? 'https://images.unsplash.com/photo-1571260899304-425eee4c7efc?w=600' : null,
    );

    if (mounted) {
      if (success) {
        if (isStaff) {
          showDialog(
            context: context,
            builder: (ctx) => Dialog(
              backgroundColor: Colors.transparent,
              child: GlassContainer(
                borderRadius: 24,
                blurSigma: 20,
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.statusPending.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.hourglass_top_rounded, color: AppColors.statusPending, size: 32),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Registration Submitted',
                      style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your staff registration has been submitted. In accordance with institutional policies, staff accounts are verified before accessing full administrative privileges.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12.5, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 20),
                    GlassButton(
                      label: 'Back to Sign In',
                      icon: Icons.arrow_back_rounded,
                      height: 44,
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.statusLive,
              content: Text('🎉 Welcome to FusionFiesta! Your account has been created.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(auth.errorMessage ?? 'Registration failed. Please try again.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return AmbientGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            'Create Account',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w800),
          ),
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: GlassContainer(
                  borderRadius: 28,
                  blurSigma: 24,
                  padding: const EdgeInsets.all(26),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Center(child: AppLogo(size: 52)),
                        const SizedBox(height: 8),
                        Text(
                          'Join the campus event management ecosystem',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w500),
                        ),

                        const SizedBox(height: 22),

                        // Role Selector Tabs
                        Text(
                          'Select Your Account Role *',
                          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildRoleSelectCard(
                              role: UserRole.participant,
                              title: 'Student\nParticipant',
                              icon: Icons.school_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildRoleSelectCard(
                              role: UserRole.visitor,
                              title: 'Student\nVisitor',
                              icon: Icons.visibility_rounded,
                            ),
                            const SizedBox(width: 8),
                            _buildRoleSelectCard(
                              role: UserRole.organizer,
                              title: 'Event\nOrganizer',
                              icon: Icons.assignment_ind_rounded,
                            ),
                          ],
                        ),


                        const SizedBox(height: 18),

                        // Full Name
                        Text('Full Name *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        GlassTextField(
                          controller: _nameController,
                          hintText: 'e.g. John Doe',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (v) => AppValidators.requiredField(v, 'Full name'),
                        ),

                        const SizedBox(height: 14),

                        // Email Address
                        Text(
                          _selectedRole == UserRole.organizer
                              ? 'Institutional Email *'
                              : 'Email Address *',
                          style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700),
                        ),

                        const SizedBox(height: 6),
                        GlassTextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          hintText: 'e.g. user@college.edu',
                          prefixIcon: Icons.email_outlined,
                          validator: AppValidators.email,
                        ),

                        const SizedBox(height: 14),

                        // Password
                        Text('Password *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        GlassTextField(
                          controller: _passwordController,
                          obscureText: true,
                          hintText: '•••••••• (min 6 chars)',
                          prefixIcon: Icons.lock_outline_rounded,
                          validator: AppValidators.password,
                        ),

                        const SizedBox(height: 14),

                        // Mobile Number
                        Text('Mobile Number (Optional)', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        GlassTextField(
                          controller: _mobileController,
                          keyboardType: TextInputType.phone,
                          hintText: 'e.g. +1 555-0199',
                          prefixIcon: Icons.phone_outlined,
                          validator: AppValidators.phone,
                        ),

                        const SizedBox(height: 14),

                        // Department Dropdown
                        Text('Department *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        GlassDropdown<String>(
                          value: _selectedDepartment,
                          prefixIcon: Icons.business_outlined,
                          items: _departments
                              .map((d) => DropdownMenuItem(
                                    value: d,
                                    child: Text(d, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                                  ))
                              .toList(),
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedDepartment = val);
                          },
                        ),

                        // Participant-only specific fields
                        if (_selectedRole == UserRole.participant) ...[
                          const SizedBox(height: 14),
                          Text('Enrollment / Student ID Number *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          GlassTextField(
                            controller: _enrollmentController,
                            hintText: 'e.g. CS-2024-001',
                            prefixIcon: Icons.badge_outlined,
                            validator: AppValidators.enrollmentNo,
                          ),
                        ],


                        // Staff approval notice
                        if (_selectedRole == UserRole.organizer) ...[
                          const SizedBox(height: 14),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.statusPending.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: AppColors.statusPending.withOpacity(0.4)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.info_outline_rounded, color: AppColors.statusPending),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Organizer accounts require Admin verification before event creation tools are unlocked.',
                                    style: TextStyle(fontSize: 11, color: AppColors.deepNavy),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],


                        const SizedBox(height: 24),

                        // Submit Button
                        GlassButton(
                          label: 'Complete Registration',
                          icon: Icons.check_circle_rounded,
                          isLoading: auth.isLoading,
                          onPressed: auth.isLoading ? null : _handleRegister,
                          height: 52,
                        ),

                        const SizedBox(height: 16),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(
                              'Already have an account? Sign In',
                              style: GoogleFonts.inter(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectCard({
    required UserRole role,
    required String title,
    required IconData icon,
  }) {
    final isSelected = _selectedRole == role;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _selectedRole = role),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF0284C7)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : Colors.white.withOpacity(0.70),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.4) : Colors.white.withOpacity(0.85),
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.35),
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
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                size: 22,
              ),
              const SizedBox(height: 5),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10.5,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
