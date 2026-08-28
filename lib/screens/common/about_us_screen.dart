import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/glass_widgets.dart';
import '../sitemap/sitemap_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('About FusionFiesta', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Banner Hero
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 76, showText: false),
                  const SizedBox(height: 12),
                  Text(
                    'FusionFiesta 2026',
                    style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: isDark ? Colors.white : AppColors.deepNavy),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'TechWiz 6 Global Tech Competition Edition',
                      style: GoogleFonts.inter(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Purpose & Vision (SRS 1.6 #12)
            _buildSection(
              title: 'Purpose of the Application',
              content:
                  'Managing college fests, technical hackathons, cultural galas, and athletic championships manually often leads to miscommunication, scheduling overlaps, and poor student engagement. FusionFiesta provides an all-in-one cross-platform digital platform powered by Google Firebase to streamline the entire event lifecycle—from proposal, automated scheduling, and 1-click digital pass registration to live camera QR attendance, verified PDF certificates, and multi-criteria feedback.',
              icon: Icons.lightbulb_rounded,
              color: AppColors.primary,
            ),

            const SizedBox(height: 16),

            // Benefits for Students & Staff (SRS 1.6 #12)
            _buildSection(
              title: 'Key Benefits for Students & Faculty',
              content:
                  '• For Students: Single-click registrations, digital QR tickets on smartphones, permanent PDF certificate vault, real-time schedule notifications, and campus venue GPS routing.\n• For Faculty & Organizers: Rapid event proposals, instant camera QR check-ins, automated results publishing, and attendee communication channels.\n• For Administrators: Transparent proposal oversight, user account management, and on-demand PDF/Excel analytics.',
              icon: Icons.auto_awesome_rounded,
              color: AppColors.secondaryDark,
            ),

            const SizedBox(height: 16),

            // Development Team Behind FusionFiesta (SRS 1.6 #12)
            _buildSection(
              title: 'Development Team & Technology Stack',
              content:
                  'Developed with modern Flutter 3.44+ and Google Cloud Firebase NoSQL Architecture strictly incorporating Material 3 design principles without purple hues, high-performance offline persistence, and PDF vector engines.',
              icon: Icons.group_work_rounded,
              color: AppColors.accentOrange,
            ),

            const SizedBox(height: 20),

            // Sitemap Roadmap Shortcut
            GlassContainer(
              borderRadius: 22,
              blurSigma: 14,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore System Flowchart', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 13.5)),
                        Text('View the interactive sitemap mandated on SRS Page 14.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassButton(
                    label: 'Sitemap',
                    icon: Icons.account_tree_outlined,
                    height: 38,
                    borderRadius: 12,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required IconData icon,
    required Color color,
  }) {
    return GlassContainer(
      borderRadius: 22,
      blurSigma: 14,
      glowColor: color,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.14),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: GoogleFonts.inter(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.55),
          ),
        ],
      ),
    );
  }
}
