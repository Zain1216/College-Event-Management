import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_logo.dart';
import '../sitemap/sitemap_screen.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About FusionFiesta'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // App Banner Hero
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 72, showText: false),
                  const SizedBox(height: 12),
                  const Text(
                    'FusionFiesta 2026',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.deepNavy),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'TechWiz 6 Global Tech Competition Edition',
                      style: TextStyle(color: AppColors.primaryDark, fontSize: 11, fontWeight: FontWeight.w800),
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
              icon: Icons.lightbulb_outline,
              color: AppColors.primary,
            ),

            const SizedBox(height: 16),

            // Benefits for Students & Staff (SRS 1.6 #12)
            _buildSection(
              title: 'Key Benefits for Students & Faculty',
              content:
                  '• For Students: Single-click registrations, digital QR tickets on smartphones, permanent PDF certificate vault, real-time schedule notifications, and campus venue GPS routing.\n• For Faculty & Organizers: Rapid event proposals, instant camera QR check-ins, automated results publishing, and attendee communication channels.\n• For Administrators: Transparent proposal oversight, user account management, and on-demand PDF/Excel analytics.',
              icon: Icons.auto_awesome,
              color: AppColors.secondaryDark,
            ),

            const SizedBox(height: 16),

            // Development Team Behind FusionFiesta (SRS 1.6 #12)
            _buildSection(
              title: 'Development Team & Technology Stack',
              content:
                  'Developed with modern Flutter 3.44+ and Google Cloud Firebase NoSQL Architecture strictly incorporating Material 3 design principles without purple hues, high-performance offline persistence, and PDF vector engines.',
              icon: Icons.group_work_outlined,
              color: AppColors.accentOrange,
            ),

            const SizedBox(height: 24),

            // Sitemap Roadmap Shortcut
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  const Icon(Icons.account_tree_outlined, color: AppColors.primary, size: 28),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Explore System Flowchart', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                        Text('View the interactive sitemap mandated on SRS Page 14.', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SitemapScreen())),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                    child: const Text('View Sitemap', style: TextStyle(fontSize: 11)),
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight, height: 1.5),
          ),
        ],
      ),
    );
  }
}
