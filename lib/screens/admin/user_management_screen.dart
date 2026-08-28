import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  String _searchQuery = '';
  String _roleFilter = 'All'; // 'All', 'Participant', 'Visitor', 'Organizer', 'Admin'

  @override
  Widget build(BuildContext context) {
    final adminProvider = context.watch<AdminProvider>();
    final users = adminProvider.allUsers;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredUsers = users.where((u) {
      if (_roleFilter != 'All' && u.role.displayName.toLowerCase() != _roleFilter.toLowerCase()) {
        return false;
      }
      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return u.fullName.toLowerCase().contains(q) ||
            u.email.toLowerCase().contains(q) ||
            u.department.toLowerCase().contains(q) ||
            (u.enrollmentNo != null && u.enrollmentNo!.toLowerCase().contains(q));
      }
      return true;
    }).toList();

    final pendingStaff = adminProvider.pendingStaffApprovals;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('User Accounts & Roles', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Staff Approvals Section (SRS 1.6 #1 & #7)
            if (pendingStaff.isNotEmpty) ...[
              GlassContainer(
                borderRadius: 22,
                blurSigma: 14,
                glowColor: AppColors.statusPending,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.statusPending.withOpacity(0.18),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.person_add_rounded, color: AppColors.statusPending, size: 20),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Staff Registration Approvals (${pendingStaff.length})',
                          style: GoogleFonts.outfit(fontSize: 14.5, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Staff members must be validated by admin before accessing event management privileges.',
                      style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 12),
                    ...pendingStaff.map((staff) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.85)),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Text(staff.fullName.substring(0, 1), style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(staff.fullName, style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13)),
                                    Text('${staff.email} • ${staff.department}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  ],
                                ),
                              ),
                              GlassButton(
                                label: 'Approve',
                                icon: Icons.verified_user_rounded,
                                color: AppColors.statusLive,
                                height: 36,
                                borderRadius: 12,
                                onPressed: () async {
                                  await adminProvider.toggleUserApproval(staff.uid, true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(backgroundColor: AppColors.statusLive, content: Text('Verified staff account for ${staff.fullName}')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Search Bar
            GlassTextField(
              hintText: 'Search user by name, email, department...',
              prefixIcon: Icons.search_rounded,
              onChanged: (val) => setState(() => _searchQuery = val),
            ),

            const SizedBox(height: 12),

            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildRoleFilterChip('All', users.length),
                  _buildRoleFilterChip('Participant', users.where((u) => u.role == UserRole.participant).length),
                  _buildRoleFilterChip('Visitor', users.where((u) => u.role == UserRole.visitor).length),
                  _buildRoleFilterChip('Organizer', users.where((u) => u.role == UserRole.organizer).length),
                  _buildRoleFilterChip('Admin', users.where((u) => u.role == UserRole.admin).length),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // User Roster List
            Text(
              'User Directory (${filteredUsers.length} Users)',
              style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
            ),
            const SizedBox(height: 10),

            if (filteredUsers.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(child: Text('No users match current search criteria.', style: GoogleFonts.inter(color: AppColors.textSecondaryLight))),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredUsers.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, idx) {
                  final u = filteredUsers[idx];
                  return _buildUserTile(context, u, adminProvider);
                },
              ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleFilterChip(String role, int count) {
    final isSelected = _roleFilter == role;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _roleFilter = role),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.heroGradient : null,
            color: isSelected ? null : Colors.white.withOpacity(0.65),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? Colors.white.withOpacity(0.6) : Colors.white.withOpacity(0.8),
              width: 1.2,
            ),
          ),
          child: Text(
            '$role ($count)',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel u, AdminProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    Color roleColor;
    switch (u.role) {
      case UserRole.admin:
        roleColor = AppColors.accentOrange;
        break;
      case UserRole.organizer:
        roleColor = AppColors.secondaryDark;
        break;
      case UserRole.participant:
        roleColor = AppColors.primary;
        break;
      case UserRole.visitor:
      default:
        roleColor = AppColors.textSecondaryLight;
    }

    return GlassContainer(
      borderRadius: 20,
      blurSigma: 12,
      padding: const EdgeInsets.all(14),
      glowColor: u.isActive ? roleColor : AppColors.error,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: roleColor.withOpacity(0.18),
                child: Text(
                  u.fullName.isNotEmpty ? u.fullName.substring(0, 1).toUpperCase() : 'U',
                  style: GoogleFonts.outfit(color: roleColor, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            u.fullName,
                            style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!u.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.18), borderRadius: BorderRadius.circular(6)),
                            child: const Text('DEACTIVATED', style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Text('${u.email}  •  ${u.department}', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: roleColor.withOpacity(0.3)),
                ),
                child: Text(
                  u.role.displayName,
                  style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.w800, color: roleColor),
                ),
              ),
            ],
          ),

          if (u.enrollmentNo != null) ...[
            const SizedBox(height: 6),
            Text('Enrollment ID: ${u.enrollmentNo}', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
          ],

          Divider(height: 16, color: isDark ? Colors.white12 : AppColors.borderLight),

          // Actions Row (Role modifier & Deactivate toggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Change Role
              PopupMenuButton<UserRole>(
                onSelected: (newRole) => provider.changeUserRole(u.uid, newRole),
                itemBuilder: (context) => UserRole.values.map((r) => PopupMenuItem(
                  value: r,
                  child: Text('Change to ${r.displayName}', style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600)),
                )).toList(),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz_rounded, size: 16, color: AppColors.primary),
                    const SizedBox(width: 4),
                    Text('Change Role', style: GoogleFonts.inter(fontSize: 11.5, color: AppColors.primary, fontWeight: FontWeight.w800)),
                  ],
                ),
              ),

              // Active / Deactive Switch
              Row(
                children: [
                  Text(
                    u.isActive ? 'Active' : 'Suspended',
                    style: GoogleFonts.inter(fontSize: 11, color: u.isActive ? AppColors.statusLive : AppColors.error, fontWeight: FontWeight.w800),
                  ),
                  Switch(
                    value: u.isActive,
                    activeColor: AppColors.statusLive,
                    onChanged: (val) => provider.toggleUserActive(u.uid, val),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
