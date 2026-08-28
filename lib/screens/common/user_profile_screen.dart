import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';
import '../../widgets/role_upgrade_dialog.dart';
import '../sitemap/sitemap_screen.dart';
import 'about_us_screen.dart';
import 'contact_us_screen.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _emailNotifs = true;
  bool _pushNotifs = true;
  bool _eventReminders = true;

  void _showEditProfileDialog(BuildContext context, UserModel user) {
    final nameController = TextEditingController(text: user.fullName);
    final mobileController = TextEditingController(text: user.mobile);
    final deptController = TextEditingController(text: user.department);
    final enrollmentController = TextEditingController(text: user.enrollmentNo ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blurSigma: 20,
          padding: const EdgeInsets.all(22),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Profile Information', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
                const SizedBox(height: 16),
                GlassTextField(
                  controller: nameController,
                  labelText: 'Full Name',
                  prefixIcon: Icons.person_outline_rounded,
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: mobileController,
                  labelText: 'Mobile Number',
                  prefixIcon: Icons.phone_android_rounded,
                ),
                const SizedBox(height: 12),
                GlassTextField(
                  controller: deptController,
                  labelText: 'Department',
                  prefixIcon: Icons.domain_rounded,
                ),
                if (user.role == UserRole.participant) ...[
                  const SizedBox(height: 12),
                  GlassTextField(
                    controller: enrollmentController,
                    labelText: 'Enrollment Number',
                    prefixIcon: Icons.badge_outlined,
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: GlassButton(
                        label: 'Save Changes',
                        icon: Icons.check_rounded,
                        height: 44,
                        onPressed: () async {
                          await context.read<AuthProvider>().updateProfile(
                                fullName: nameController.text.trim(),
                                mobile: mobileController.text.trim(),
                                department: deptController.text.trim(),
                                enrollmentNo: enrollmentController.text.trim().isNotEmpty ? enrollmentController.text.trim() : null,
                              );
                          if (ctx.mounted) Navigator.pop(ctx);
                        },
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

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassContainer(
          borderRadius: 24,
          blurSigma: 20,
          padding: const EdgeInsets.all(22),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Change Password', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 16),
              GlassTextField(
                controller: oldPassController,
                obscureText: true,
                labelText: 'Current Password',
                prefixIcon: Icons.lock_outline_rounded,
              ),
              const SizedBox(height: 12),
              GlassTextField(
                controller: newPassController,
                obscureText: true,
                labelText: 'New Password (min 6 characters)',
                prefixIcon: Icons.lock_rounded,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: GlassButton(
                      label: 'Update Password',
                      icon: Icons.check_rounded,
                      height: 44,
                      onPressed: () async {
                        final newPass = newPassController.text.trim();
                        if (newPass.length < 6) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(backgroundColor: AppColors.error, content: Text('Password must be at least 6 characters.')),
                          );
                          return;
                        }
                        try {
                          await context.read<AuthProvider>().changePassword(newPass);
                          if (ctx.mounted) {
                            Navigator.pop(ctx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(backgroundColor: AppColors.statusLive, content: Text('✅ Password updated successfully in Firebase Auth.')),
                            );
                          }
                        } catch (e) {
                          if (ctx.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(backgroundColor: AppColors.error, content: Text(e.toString().replaceAll('Exception: ', ''))),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(backgroundColor: Colors.transparent, body: Center(child: Text('No active user logged in.')));
    }

    final regProvider = context.watch<RegistrationProvider>();
    final certProvider = context.watch<CertificateProvider>();

    final myRegistrations = regProvider.getRegistrationsForStudent(user.uid);
    final myCertificates = certProvider.getCertificatesForStudent(user.uid);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('My Profile & Settings', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: [
          GlassIconButton(
            tooltip: 'Edit Profile',
            icon: Icons.edit_rounded,
            iconColor: AppColors.primary,
            size: 38,
            iconSize: 18,
            onPressed: () => _showEditProfileDialog(context, user),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 85),
        child: Column(
          children: [
            // User Header Glass Card
            GlassContainer(
              borderRadius: 26,
              blurSigma: 18,
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppColors.heroGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.35),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 44,
                          backgroundColor: Colors.white,
                          child: Text(
                            user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : 'U',
                            style: GoogleFonts.outfit(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Avatar image update picker opened.')),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              gradient: AppColors.cardGradient,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.deepNavy),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: GoogleFonts.inter(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.35)),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: GoogleFonts.inter(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),

                  // Upgrade button if visitor
                  if (user.role == UserRole.visitor) ...[
                    const SizedBox(height: 14),
                    GlassButton(
                      label: 'Upgrade to Student Participant',
                      icon: Icons.upgrade_rounded,
                      color: AppColors.statusLive,
                      height: 42,
                      onPressed: () => RoleUpgradeDialog.show(context),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Personal Credentials Summary (Frosted Glass Card)
            GlassContainer(
              borderRadius: 22,
              blurSigma: 14,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Personal Credentials',
                    style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                  ),
                  const SizedBox(height: 12),
                  _buildProfileRow(Icons.domain_rounded, 'Department', user.department),
                  Divider(height: 18, color: isDark ? Colors.white12 : AppColors.borderLight),
                  _buildProfileRow(Icons.phone_android_rounded, 'Mobile', user.mobile.isNotEmpty ? user.mobile : 'Not set'),
                  if (user.enrollmentNo != null) ...[
                    Divider(height: 18, color: isDark ? Colors.white12 : AppColors.borderLight),
                    _buildProfileRow(Icons.badge_rounded, 'Enrollment Number', user.enrollmentNo!),
                  ],
                  if (user.collegeIdProof != null) ...[
                    Divider(height: 18, color: isDark ? Colors.white12 : AppColors.borderLight),
                    _buildProfileRow(Icons.verified_user_rounded, 'College ID Proof Status', 'Verified on File'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Role Activities Overview (Frosted Glass Card)
            GlassContainer(
              borderRadius: 22,
              blurSigma: 14,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Activity & Engagement Stats',
                    style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildActivityStat('Events', '${myRegistrations.length}', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildActivityStat('Certs', '${myCertificates.length}', AppColors.accentGold),
                      const SizedBox(width: 8),
                      _buildActivityStat('Saved', '${user.bookmarkedEventIds.length}', AppColors.secondaryDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notification Preferences (Frosted Glass Card)
            GlassContainer(
              borderRadius: 22,
              blurSigma: 14,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notification Preferences',
                    style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: Text('Event Schedule Reminders', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('Receive alerts 1 hour before registered events', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                    value: _eventReminders,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _eventReminders = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: Text('Push Announcements', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    subtitle: Text('Live organizer updates & results', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                    value: _pushNotifs,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _pushNotifs = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Quick App Links (Sitemap, About Us, Contact Us)
            GlassContainer(
              borderRadius: 22,
              blurSigma: 14,
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_tree_outlined, color: AppColors.primary),
                    title: Text('App Flowchart & Sitemap', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.info_outline_rounded, color: AppColors.secondaryDark),
                    title: Text('About FusionFiesta & Team', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.contact_support_outlined, color: AppColors.accentOrange),
                    title: Text('Contact Support & FAQs', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                  ),
                  Divider(height: 1, color: isDark ? Colors.white12 : AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: AppColors.deepNavy),
                    title: Text('Change Password', style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right_rounded, size: 20),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            GlassButton(
              label: 'Sign Out',
              icon: Icons.logout_rounded,
              isPrimary: false,
              color: AppColors.error,
              height: 48,
              onPressed: () async {
                await auth.logout();
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileRow(IconData icon, String label, String val) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: AppColors.primary),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: GoogleFonts.inter(fontSize: 10, color: AppColors.textSecondaryLight)),
            Text(val, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Column(
          children: [
            Text(value, style: GoogleFonts.outfit(fontSize: 19, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: GoogleFonts.inter(fontSize: 9.5, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
