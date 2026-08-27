import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glass_widgets.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Application Flow & Sitemap', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppLogo(size: 32, showText: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Glass Hero
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.account_tree_rounded, color: Colors.white, size: 30),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FusionFiesta Architecture & Flow',
                          style: GoogleFonts.outfit(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Roadmap of screens, navigation hierarchy, and role permissions (SRS Section 1.6 & 1.7).',
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Role Branches
            _buildRoleSection(
              title: '1. Student Visitor (Browse-Only)',
              subtitle: 'Guests and newly registered students exploring campus events',
              badgeColor: AppColors.primary,
              icon: Icons.person_outline_rounded,
              nodes: [
                _SitemapNode('Public Event Catalog', 'Filter by category, search with auto-suggest, sort by date/popularity', Icons.view_list_rounded),
                _SitemapNode('Event Details & Rules', 'View venue, countdown, guideline attachments (registration disabled)', Icons.info_outline_rounded),
                _SitemapNode('Media Gallery Lightbox', 'View past fest photos & short clips, filter by department', Icons.photo_library_rounded),
                _SitemapNode('Interactive Campus Map', 'Explore college building pins with GPS navigation pointers', Icons.map_rounded),
                _SitemapNode('About Us & Contact Form', 'Submit queries, FAQ knowledgebase, college committee details', Icons.contact_support_rounded),
                _SitemapNode('Role Upgrade Trigger', 'Prompt to enter enrollment number & ID proof to become Participant', Icons.upgrade_rounded),
              ],
            ),

            const SizedBox(height: 18),

            _buildRoleSection(
              title: '2. Student Participant (Active Registrations & Certs)',
              subtitle: 'Verified college students with enrollment credentials',
              badgeColor: AppColors.statusLive,
              icon: Icons.school_rounded,
              nodes: [
                _SitemapNode('Student Dashboard', 'Personalized registered countdowns, favorites, reminder alerts', Icons.dashboard_rounded),
                _SitemapNode('1-Click Event Registration', 'Instant slot confirmation with capacity validation', Icons.touch_app_rounded),
                _SitemapNode('Digital Pass Vault (QR)', 'High-resolution encrypted QR ticket for entrance check-in', Icons.qr_code_2_rounded),
                _SitemapNode('Certificate Vault', 'Simulated fee payment clearing & instant official PDF certificate download', Icons.verified_rounded),
                _SitemapNode('Multi-Parameter Feedback', 'Rate Organization, Relevance, Coordination, Overall (1-5 stars)', Icons.rate_review_rounded),
                _SitemapNode('Student Profile & ID Proof', 'Manage enrollment info, view certificate records, toggle alerts', Icons.account_circle_rounded),
              ],
            ),

            const SizedBox(height: 18),

            _buildRoleSection(
              title: '3. Event Organizer (Management & Execution)',
              subtitle: 'Faculty and student council leads managing event lifecycles',
              badgeColor: AppColors.secondaryDark,
              icon: Icons.campaign_rounded,
              nodes: [
                _SitemapNode('Organizer Dashboard', 'Live metrics, active event statuses, interactive calendar view', Icons.speed_rounded),
                _SitemapNode('Event Creation & Proposal', 'Structured form with banner, guideline PDF attachment, and volunteer selector', Icons.add_circle_outline_rounded),
                _SitemapNode('Live QR Attendance Scanner', 'Camera QR code scanner with instant validation + manual student roster', Icons.qr_code_scanner_rounded),
                _SitemapNode('Results & Winner Designation', '1st, 2nd, 3rd place rankings, trigger bulk verified e-certificates', Icons.emoji_events_rounded),
                _SitemapNode('Broadcast Announcements', 'Send real-time alerts & schedule updates to all registered attendees', Icons.notification_important_rounded),
                _SitemapNode('Attendee Queries & Reviews', 'View participant feedback breakdowns and resolve inquiries', Icons.forum_rounded),
              ],
            ),

            const SizedBox(height: 18),

            _buildRoleSection(
              title: '4. System Administrator (Governance & Analytics)',
              subtitle: 'Institutional control panel with system-wide oversight',
              badgeColor: AppColors.accentOrange,
              icon: Icons.admin_panel_settings_rounded,
              nodes: [
                _SitemapNode('Executive Admin Dashboard', 'Pending approvals counter, department bar/pie charts, security alerts', Icons.insights_rounded),
                _SitemapNode('Event Proposal Review', 'Approve or reject organizer proposals with feedback justification', Icons.fact_check_rounded),
                _SitemapNode('User Account & Role Control', 'Approve staff signups, toggle active/deactive status, role switcher', Icons.manage_accounts_rounded),
                _SitemapNode('Report Center (PDF & Excel)', 'Export on-demand PDF summaries & formatted Excel .xlsx spreadsheets', Icons.download_rounded),
                _SitemapNode('Content Moderation Hub', 'Review flagged user feedback and moderate media gallery uploads', Icons.security_rounded),
                _SitemapNode('Support Query Inbox', 'View and reply directly to Contact Us inquiries', Icons.mark_email_read_rounded),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleSection({
    required String title,
    required String subtitle,
    required Color badgeColor,
    required IconData icon,
    required List<_SitemapNode> nodes,
  }) {
    return GlassContainer(
      borderRadius: 24,
      blurSigma: 14,
      glowColor: badgeColor,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: badgeColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: badgeColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.outfit(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: Colors.white.withOpacity(0.6)),
          const SizedBox(height: 10),
          ...nodes.map((node) => _buildNodeTile(node, badgeColor)),
        ],
      ),
    );
  }

  Widget _buildNodeTile(_SitemapNode node, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(node.icon, size: 16, color: accentColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  node.title,
                  style: GoogleFonts.inter(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  node.description,
                  style: GoogleFonts.inter(fontSize: 10.5, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SitemapNode {
  final String title;
  final String description;
  final IconData icon;
  _SitemapNode(this.title, this.description, this.icon);
}
