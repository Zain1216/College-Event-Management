import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/user_model.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_widgets.dart';
import 'auth/login_screen.dart';

// Student Screens
import 'student/student_dashboard.dart';
import 'student/my_tickets_screen.dart';
import 'student/certificate_vault_screen.dart';

// Organizer Screens
import 'organizer/organizer_dashboard.dart';
import 'organizer/qr_attendance_scanner_screen.dart';
import 'organizer/results_and_certificates_screen.dart';

// Admin Screens
import 'admin/admin_dashboard.dart';
import 'admin/event_approval_screen.dart';
import 'admin/user_management_screen.dart';
import 'admin/report_center_screen.dart';

// Common Screens
import 'common/event_catalog_screen.dart';
import 'common/media_gallery_screen.dart';
import 'common/user_profile_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // If not authenticated, redirect to Login
    if (!auth.isAuthenticated || auth.currentUser == null) {
      return const LoginScreen();
    }

    final role = auth.currentUser!.role;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Build role-tailored navigation items and screen list
    List<Widget> screens;
    List<_GlassNavItem> navItems;

    if (role == UserRole.admin) {
      screens = const [
        AdminDashboard(),
        EventApprovalScreen(),
        UserManagementScreen(),
        ReportCenterScreen(),
        MediaGalleryScreen(),
        UserProfileScreen(),
      ];
      navItems = const [
        _GlassNavItem(icon: Icons.shield_outlined, activeIcon: Icons.shield_rounded, label: 'Control'),
        _GlassNavItem(icon: Icons.fact_check_outlined, activeIcon: Icons.fact_check_rounded, label: 'Approvals'),
        _GlassNavItem(icon: Icons.group_outlined, activeIcon: Icons.group_rounded, label: 'Users'),
        _GlassNavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics_rounded, label: 'Reports'),
        _GlassNavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: 'Gallery'),
        _GlassNavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
      ];
    } else if (role == UserRole.organizer) {
      screens = const [
        OrganizerDashboard(),
        EventCatalogScreen(),
        QrAttendanceScannerScreen(),
        ResultsAndCertificatesScreen(),
        MediaGalleryScreen(),
        UserProfileScreen(),
      ];
      navItems = const [
        _GlassNavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard_rounded, label: 'Studio'),
        _GlassNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Events'),
        _GlassNavItem(icon: Icons.qr_code_scanner_rounded, activeIcon: Icons.qr_code_scanner_rounded, label: 'Scan'),
        _GlassNavItem(icon: Icons.emoji_events_outlined, activeIcon: Icons.emoji_events_rounded, label: 'Results'),
        _GlassNavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: 'Gallery'),
        _GlassNavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
      ];
    } else {
      // Student Participant & Student Visitor
      screens = [
        StudentDashboard(
          onNavigateToCatalog: () => setState(() => _currentIndex = 1),
          onNavigateToTickets: () => setState(() => _currentIndex = 2),
          onNavigateToCertificates: () => setState(() => _currentIndex = 3),
        ),
        const EventCatalogScreen(),
        const MyTicketsScreen(),
        const CertificateVaultScreen(),
        const MediaGalleryScreen(),
        const UserProfileScreen(),
      ];
      navItems = const [
        _GlassNavItem(icon: Icons.home_outlined, activeIcon: Icons.home_rounded, label: 'Home'),
        _GlassNavItem(icon: Icons.explore_outlined, activeIcon: Icons.explore_rounded, label: 'Catalog'),
        _GlassNavItem(icon: Icons.qr_code_2_rounded, activeIcon: Icons.qr_code_2_rounded, label: 'Passes'),
        _GlassNavItem(icon: Icons.school_outlined, activeIcon: Icons.school_rounded, label: 'Vault'),
        _GlassNavItem(icon: Icons.photo_library_outlined, activeIcon: Icons.photo_library_rounded, label: 'Gallery'),
        _GlassNavItem(icon: Icons.account_circle_outlined, activeIcon: Icons.account_circle_rounded, label: 'Profile'),
      ];
    }

    // Guard index overflow if role switches
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return AmbientGlassBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
        bottomNavigationBar: SafeArea(
          child: Container(
            margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
            height: 64,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : AppColors.primary).withOpacity(isDark ? 0.45 : 0.12),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F172A).withOpacity(0.75)
                        : Colors.white.withOpacity(0.82),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.18)
                          : Colors.white.withOpacity(0.90),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(navItems.length, (index) {
                      final item = navItems[index];
                      final isSelected = _currentIndex == index;

                      return Expanded(
                        child: InkWell(
                          onTap: () => setState(() => _currentIndex = index),
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 220),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: isSelected
                                  ? BoxDecoration(
                                      color: AppColors.primary.withOpacity(0.14),
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: AppColors.primary.withOpacity(0.35),
                                        width: 1.2,
                                      ),
                                    )
                                  : null,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isSelected ? item.activeIcon : item.icon,
                                    size: isSelected ? 22 : 20,
                                    color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.label,
                                    style: GoogleFonts.inter(
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                                      color: isSelected ? AppColors.primary : AppColors.textSecondaryLight,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlassNavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _GlassNavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}
