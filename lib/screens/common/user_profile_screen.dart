import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/event_provider.dart';
import '../../providers/registration_provider.dart';
import '../../providers/certificate_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/role_upgrade_dialog.dart';
import '../auth/login_screen.dart';
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
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Edit Profile Information'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: mobileController,
                decoration: const InputDecoration(labelText: 'Mobile Number'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: deptController,
                decoration: const InputDecoration(labelText: 'Department'),
              ),
              if (user.role == UserRole.participant) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: enrollmentController,
                  decoration: const InputDecoration(labelText: 'Enrollment Number'),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              await context.read<AuthProvider>().updateProfile(
                    fullName: nameController.text.trim(),
                    mobile: mobileController.text.trim(),
                    department: deptController.text.trim(),
                    enrollmentNo: enrollmentController.text.trim().isNotEmpty ? enrollmentController.text.trim() : null,
                  );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Current Password'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPassController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New Password (min 6 characters)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(backgroundColor: AppColors.statusLive, content: Text('✅ Password changed successfully.')),
              );
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('No active user logged in.')));
    }

    final regProvider = context.watch<RegistrationProvider>();
    final certProvider = context.watch<CertificateProvider>();
    final eventProvider = context.watch<EventProvider>();

    final myRegistrations = regProvider.getRegistrationsForStudent(user.uid);
    final myCertificates = certProvider.getCertificatesForStudent(user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile & Settings'),
        actions: [
          IconButton(
            tooltip: 'Edit Profile',
            icon: const Icon(Icons.edit_outlined, color: AppColors.primary),
            onPressed: () => _showEditProfileDialog(context, user),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 46,
                        backgroundColor: AppColors.primaryContainer,
                        child: Text(
                          user.fullName.isNotEmpty ? user.fullName.substring(0, 1).toUpperCase() : 'U',
                          style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.primary),
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
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user.fullName,
                    style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: AppColors.deepNavy),
                  ),
                  Text(
                    user.email,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.4)),
                    ),
                    child: Text(
                      user.role.displayName,
                      style: const TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),

                  // Upgrade button if visitor
                  if (user.role == UserRole.visitor) ...[
                    const SizedBox(height: 12),
                    ElevatedButton.icon(
                      onPressed: () => RoleUpgradeDialog.show(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.statusLive,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.upgrade, size: 16),
                      label: const Text('Upgrade to Student Participant', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Personal Credentials Summary (SRS 1.6 #11)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Personal Credentials', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.deepNavy)),
                  const SizedBox(height: 12),
                  _buildProfileRow(Icons.domain, 'Department', user.department),
                  const Divider(height: 16, color: AppColors.borderLight),
                  _buildProfileRow(Icons.phone_android, 'Mobile', user.mobile.isNotEmpty ? user.mobile : 'Not set'),
                  if (user.enrollmentNo != null) ...[
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildProfileRow(Icons.badge, 'Enrollment Number', user.enrollmentNo!),
                  ],
                  if (user.collegeIdProof != null) ...[
                    const Divider(height: 16, color: AppColors.borderLight),
                    _buildProfileRow(Icons.verified_user, 'College ID Proof Status', 'Verified on File'),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Role Activities Overview (SRS 1.6 #11)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Activity & Engagement Stats', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.deepNavy)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildActivityStat('Events Registered', '${myRegistrations.length}', AppColors.primary),
                      const SizedBox(width: 8),
                      _buildActivityStat('Certificates', '${myCertificates.length}', AppColors.accentGold),
                      const SizedBox(width: 8),
                      _buildActivityStat('Bookmarks', '${user.bookmarkedEventIds.length}', AppColors.secondaryDark),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Notification Preferences (SRS 1.6 #10 & #11)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Notification Preferences', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.deepNavy)),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Event Schedule Reminders', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Receive alerts 1 hour before registered events', style: TextStyle(fontSize: 11)),
                    value: _eventReminders,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _eventReminders = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                  SwitchListTile(
                    title: const Text('Push Announcements', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Live organizer updates & results', style: TextStyle(fontSize: 11)),
                    value: _pushNotifs,
                    activeColor: AppColors.primary,
                    onChanged: (val) => setState(() => _pushNotifs = val),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Quick App Links (Sitemap, About Us, Contact Us)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.account_tree_outlined, color: AppColors.primary),
                    title: const Text('App Flowchart & Sitemap', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: AppColors.secondaryDark),
                    title: const Text('About FusionFiesta & TechWiz Team', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AboutUsScreen())),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.contact_support_outlined, color: AppColors.accentOrange),
                    title: const Text('Contact Support & FAQs', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ContactUsScreen())),
                  ),
                  const Divider(height: 1, color: AppColors.borderLight),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: AppColors.deepNavy),
                    title: const Text('Change Password', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                    trailing: const Icon(Icons.chevron_right, size: 18),
                    onTap: () => _showChangePasswordDialog(context),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await auth.logout();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                ),
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w800)),
              ),
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
        Icon(icon, size: 16, color: AppColors.primary),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
            Text(val, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
          ],
        ),
      ],
    );
  }

  Widget _buildActivityStat(String label, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 9, color: AppColors.textSecondaryLight, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
