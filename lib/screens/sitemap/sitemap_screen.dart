import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';

class SitemapScreen extends StatelessWidget {
  const SitemapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Application Flow & Sitemap'),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: AppLogo(size: 32, showText: false),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(Icons.account_tree_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'FusionFiesta Architecture & Flowchart',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Interactive roadmap of screens, navigation hierarchy, and role-based permissions (SRS Section 1.6 & 1.7).',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Role Branches
            _buildRoleSection(
              title: '1. Student Visitor (Browse-Only)',
              subtitle: 'Guests and newly registered students exploring campus events',
              badgeColor: AppColors.textSecondaryLight,
              icon: Icons.person_outline,
              nodes: [
                _SitemapNode('Public Event Catalog', 'Filter by category, search with auto-suggest, sort by date/popularity', Icons.view_list),
                _SitemapNode('Event Details & Rules', 'View venue, countdown, guideline attachments (registration disabled)', Icons.info_outline),
                _SitemapNode('Media Gallery Lightbox', 'View past fest photos & short clips, filter by department', Icons.photo_library),
                _SitemapNode('Interactive Campus Map', 'Explore college building pins with GPS navigation pointers', Icons.map),
                _SitemapNode('About Us & Contact Form', 'Submit queries, FAQ knowledgebase, college committee details', Icons.contact_support),
                _SitemapNode('Role Upgrade Trigger', 'Prompt to enter enrollment number & ID proof to become Participant', Icons.upgrade),
              ],
            ),

            const SizedBox(height: 20),

            _buildRoleSection(
              title: '2. Student Participant (Active Registrations & Certificates)',
              subtitle: 'Verified college students with enrollment credentials',
              badgeColor: AppColors.primary,
              icon: Icons.school_outlined,
              nodes: [
                _SitemapNode('Student Dashboard', 'Personalized registered countdowns, favorites, reminder alerts', Icons.dashboard),
                _SitemapNode('1-Click Event Registration', 'Instant slot confirmation with capacity validation', Icons.touch_app),
                _SitemapNode('Digital Pass Vault (QR)', 'High-resolution encrypted QR ticket for entrance check-in', Icons.qr_code_2),
                _SitemapNode('Certificate Vault', 'Simulated fee payment clearing & instant official PDF certificate download', Icons.verified),
                _SitemapNode('Multi-Parameter Feedback', 'Rate Organization, Relevance, Coordination, Overall (1-5 stars)', Icons.rate_review),
                _SitemapNode('Student Profile & ID Proof', 'Manage enrollment info, view certificate records, toggle alerts', Icons.account_circle),
              ],
            ),

            const SizedBox(height: 20),

            _buildRoleSection(
              title: '3. Event Organizer (Management & Live Execution)',
              subtitle: 'Faculty and student council leads managing event lifecycles',
              badgeColor: AppColors.secondaryDark,
              icon: Icons.campaign_outlined,
              nodes: [
                _SitemapNode('Organizer Dashboard', 'Live metrics, active event statuses, interactive calendar view', Icons.speed),
                _SitemapNode('Event Creation & Proposal', 'Structured form with banner, guideline PDF attachment, and volunteer selector', Icons.add_circle_outline),
                _SitemapNode('Live QR Attendance Scanner', 'Camera QR code scanner with instant validation + manual student roster', Icons.qr_code_scanner),
                _SitemapNode('Results & Winner Designation', '1st, 2nd, 3rd place rankings, trigger bulk verified e-certificates', Icons.emoji_events),
                _SitemapNode('Broadcast Announcements', 'Send real-time alerts & schedule updates to all registered attendees', Icons.notification_important),
                _SitemapNode('Attendee Queries & Reviews', 'View participant feedback breakdowns and resolve inquiries', Icons.forum),
              ],
            ),

            const SizedBox(height: 20),

            _buildRoleSection(
              title: '4. System Administrator (System Governance & Analytics)',
              subtitle: 'Institutional control panel with system-wide oversight',
              badgeColor: AppColors.accentOrange,
              icon: Icons.admin_panel_settings_outlined,
              nodes: [
                _SitemapNode('Executive Admin Dashboard', 'Pending approvals counter, department bar/pie charts, security alerts', Icons.insights),
                _SitemapNode('Event Proposal Review', 'Approve or reject organizer proposals with feedback justification', Icons.fact_check),
                _SitemapNode('User Account & Role Control', 'Approve staff signups, toggle active/deactive status, role switcher', Icons.manage_accounts),
                _SitemapNode('Report Center (PDF & Excel)', 'Export on-demand PDF summaries & formatted Excel .xlsx spreadsheets', Icons.download),
                _SitemapNode('Content Moderation Hub', 'Review flagged user feedback and moderate media gallery uploads', Icons.security),
                _SitemapNode('Support Query Inbox', 'View and reply directly to Contact Us inquiries', Icons.mark_email_read),
              ],
            ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
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
                  borderRadius: BorderRadius.circular(10),
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1, color: AppColors.borderLight),
          const SizedBox(height: 12),
          ...nodes.map((node) => _buildNodeTile(node, badgeColor)),
        ],
      ),
    );
  }

  Widget _buildNodeTile(_SitemapNode node, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.borderLight),
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
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                Text(
                  node.description,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
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
