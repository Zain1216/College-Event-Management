import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

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
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Row(
                children: [
                  Icon(Icons.hourglass_top, color: AppColors.statusPending),
                  SizedBox(width: 8),
                  Text('Registration Pending', style: TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
              content: const Text(
                'Your staff registration has been submitted. In accordance with SRS Section 1.6 #1, staff accounts must be verified and approved by the System Administrator before accessing event management features.',
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Login'),
                ),
              ],
            ),
          );
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              backgroundColor: AppColors.statusLive,
              content: Text('🎉 Welcome to FusionFiesta! Your account is created.'),
            ),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Text(auth.errorMessage ?? 'Registration failed.'),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: AppLogo(size: 48)),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text(
                        'Join the campus event management ecosystem',
                        style: TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Role Selector Tabs (SRS 1.6 #1)
                    const Text('Select Your Account Role *',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildRoleSelectCard(
                          role: UserRole.participant,
                          title: 'Student\nParticipant',
                          icon: Icons.school,
                        ),
                        const SizedBox(width: 8),
                        _buildRoleSelectCard(
                          role: UserRole.visitor,
                          title: 'Student\nVisitor',
                          icon: Icons.remove_red_eye,
                        ),
                        const SizedBox(width: 8),
                        _buildRoleSelectCard(
                          role: UserRole.organizer,
                          title: 'Staff\nOrganizer',
                          icon: Icons.assignment_ind,
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Full Name
                    const Text('Full Name *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Zain Ahmed',
                        prefixIcon: Icon(Icons.person_outline, color: AppColors.primary),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                    ),

                    const SizedBox(height: 14),

                    // Email Address
                    Text(
                      _selectedRole == UserRole.organizer || _selectedRole == UserRole.admin
                          ? 'Institutional Staff Email *'
                          : 'Email Address *',
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: _selectedRole == UserRole.organizer
                            ? 'faculty@fusionfiesta.edu'
                            : 'student@fusionfiesta.edu',
                        prefixIcon: const Icon(Icons.email_outlined, color: AppColors.primary),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Email is required';
                        if (!v.contains('@')) return 'Enter a valid email';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Password
                    const Text('Password *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        hintText: '••••••••',
                        prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),

                    const SizedBox(height: 14),

                    // Department Dropdown
                    const Text('Department *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _selectedDepartment,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.business_outlined, color: AppColors.primary),
                      ),
                      items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedDepartment = val);
                      },
                    ),

                    // Participant-only specific fields
                    if (_selectedRole == UserRole.participant) ...[
                      const SizedBox(height: 14),
                      const Text('Enrollment / Student ID Number *', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _enrollmentController,
                        decoration: const InputDecoration(
                          hintText: 'e.g. CS-2023-089',
                          prefixIcon: Icon(Icons.badge_outlined, color: AppColors.primary),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Enrollment number is required for participant registration';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      // ID Proof Document Notice
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer.withOpacity(0.4),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.attachment, color: AppColors.primary),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'College ID Proof document will be attached to your profile for event entry validation.',
                                style: TextStyle(fontSize: 11, color: AppColors.deepNavy),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Staff approval notice
                    if (_selectedRole == UserRole.organizer) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.statusPending.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.statusPending.withOpacity(0.4)),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.info_outline, color: AppColors.statusPending),
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
                    SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: auth.isLoading ? null : _handleRegister,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Complete Registration', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      ),
                    ),

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Already have an account? Sign In'),
                      ),
                    ),
                  ],
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
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
              Icon(
                icon,
                color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.primaryDark : AppColors.textSecondaryLight,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
