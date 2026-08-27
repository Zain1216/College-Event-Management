import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glass_widgets.dart';

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
    final isStaff = _selectedRole == UserRole.organizer || _selectedRole == UserRole.admin;

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
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        Navigator.pop(context);
                      },
                      child: const Text('Back to Sign In'),
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
                            const SizedBox(width: 6),
                            _buildRoleSelectCard(
                              role: UserRole.visitor,
                              title: 'Student\nVisitor',
                              icon: Icons.visibility_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildRoleSelectCard(
                              role: UserRole.organizer,
                              title: 'Event\nOrganizer',
                              icon: Icons.assignment_ind_rounded,
                            ),
                            const SizedBox(width: 6),
                            _buildRoleSelectCard(
                              role: UserRole.admin,
                              title: 'System\nAdmin',
                              icon: Icons.shield_rounded,
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
                          validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                        ),

                        const SizedBox(height: 14),

                        // Email Address
                        Text(
                          _selectedRole == UserRole.organizer || _selectedRole == UserRole.admin
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
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) return 'Email is required';
                            if (!v.contains('@')) return 'Enter a valid email';
                            return null;
                          },
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
                          validator: (v) {
                            if (v == null || v.length < 6) return 'Password must be at least 6 characters';
                            return null;
                          },
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
                        ),

                        const SizedBox(height: 14),

                        // Department Dropdown
                        Text('Department *', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.72),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButtonFormField<String>(
                              value: _selectedDepartment,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                prefixIcon: Icon(Icons.business_outlined, color: AppColors.primary, size: 20),
                              ),
                              items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600)))).toList(),
                              onChanged: (val) {
                                if (val != null) setState(() => _selectedDepartment = val);
                              },
                            ),
                          ),
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
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) return 'Enrollment number is required for participant registration';
                              return null;
                            },
                          ),
                        ],

                        // Staff approval notice
                        if (_selectedRole == UserRole.organizer || _selectedRole == UserRole.admin) ...[
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
                                    'Staff accounts require Admin verification before event management tools are unlocked.',
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
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 2),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryContainer.withOpacity(0.85) : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.white.withOpacity(0.8),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondaryLight,
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
