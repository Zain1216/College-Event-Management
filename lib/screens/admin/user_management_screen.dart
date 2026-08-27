import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';

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
      appBar: AppBar(
        title: const Text('User Accounts & Role Governance'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Pending Staff Approvals Section (SRS 1.6 #1 & #7)
            if (pendingStaff.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.statusPending.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.statusPending),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.person_add, color: AppColors.statusPending, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Staff Registration Approvals (${pendingStaff.length})',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Staff members must be validated by admin before accessing event management privileges.',
                      style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                    const SizedBox(height: 12),
                    ...pendingStaff.map((staff) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppColors.primaryContainer,
                                child: Text(staff.fullName.substring(0, 1), style: const TextStyle(fontWeight: FontWeight.bold)),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(staff.fullName, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                                    Text('${staff.email} • ${staff.department}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  await adminProvider.toggleUserApproval(staff.uid, true);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(backgroundColor: AppColors.statusLive, content: Text('Verified staff account for ${staff.fullName}')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.statusLive,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                child: const Text('Approve', style: TextStyle(fontSize: 11)),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Search Bar & Filter Chips
            TextField(
              decoration: const InputDecoration(
                hintText: 'Search user by name, email, department, or enrollment...',
                prefixIcon: Icon(Icons.search, color: AppColors.primary),
              ),
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
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 10),

            if (filteredUsers.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No users match current search criteria.'),
                ),
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
      child: FilterChip(
        label: Text('$role ($count)'),
        selected: isSelected,
        selectedColor: AppColors.primaryContainer,
        onSelected: (val) => setState(() => _roleFilter = role),
      ),
    );
  }

  Widget _buildUserTile(BuildContext context, UserModel u, AdminProvider provider) {
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

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: u.isActive ? AppColors.borderLight : AppColors.error.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: roleColor.withOpacity(0.15),
                child: Text(
                  u.fullName.isNotEmpty ? u.fullName.substring(0, 1).toUpperCase() : 'U',
                  style: TextStyle(color: roleColor, fontWeight: FontWeight.bold),
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
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (!u.isActive)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(color: AppColors.error.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                            child: const Text('DEACTIVATED', style: TextStyle(color: AppColors.error, fontSize: 9, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    Text('${u.email}  •  ${u.department}', style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: roleColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  u.role.displayName,
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: roleColor),
                ),
              ),
            ],
          ),

          if (u.enrollmentNo != null) ...[
            const SizedBox(height: 6),
            Text('Enrollment ID: ${u.enrollmentNo}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary)),
          ],

          const Divider(height: 16, color: AppColors.borderLight),

          // Actions Row (Role modifier & Deactivate toggle)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Change Role
              PopupMenuButton<UserRole>(
                onSelected: (newRole) => provider.changeUserRole(u.uid, newRole),
                itemBuilder: (context) => UserRole.values.map((r) => PopupMenuItem(
                  value: r,
                  child: Text('Change to ${r.displayName}', style: const TextStyle(fontSize: 12)),
                )).toList(),
                child: Row(
                  children: [
                    const Icon(Icons.swap_horiz, size: 14, color: AppColors.primary),
                    const SizedBox(width: 4),
                    const Text('Change Role', style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),

              // Active / Deactive Switch
              Row(
                children: [
                  Text(
                    u.isActive ? 'Active Account' : 'Suspended',
                    style: TextStyle(fontSize: 11, color: u.isActive ? AppColors.statusLive : AppColors.error, fontWeight: FontWeight.bold),
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
