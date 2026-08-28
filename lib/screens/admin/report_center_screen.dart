import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/admin_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_widgets.dart';

class ReportCenterScreen extends StatefulWidget {
  const ReportCenterScreen({super.key});

  @override
  State<ReportCenterScreen> createState() => _ReportCenterScreenState();
}

class _ReportCenterScreenState extends State<ReportCenterScreen> {
  String _selectedDepartment = 'All';
  bool _isExporting = false;

  final List<String> _departments = [
    'All',
    'Computer Science & Engineering',
    'Fine Arts & Music Society',
    'Mechanical & Robotics',
    'Physical Education',
    'Research & Development Wing',
  ];

  Future<void> _exportPdf() async {
    setState(() => _isExporting = true);
    final adminProvider = context.read<AdminProvider>();

    await adminProvider.exportPdfReport(department: _selectedDepartment);
    setState(() => _isExporting = false);
  }

  void _exportExcel() {
    final adminProvider = context.read<AdminProvider>();
    final excelBytes = adminProvider.exportExcelReport();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusLive,
        content: Text('📊 Excel spreadsheet generated successfully (${excelBytes.length} bytes ready).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text('Administrative Report Center', style: GoogleFonts.outfit(fontWeight: FontWeight.w800)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 85),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Glass Banner
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
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
                    child: const Icon(Icons.analytics_rounded, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On-Demand Executive Reporting',
                          style: GoogleFonts.outfit(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Generate complete audit records, event participation statistics, and feedback scores in PDF and Excel formats (SRS Section 1.6 #7).',
                          style: GoogleFonts.inter(color: Colors.white.withOpacity(0.85), fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Department Scope Filter
            GlassContainer(
              borderRadius: 20,
              blurSigma: 14,
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Select Department Scope for Report', style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 8),
                  GlassDropdown<String>(
                    value: _selectedDepartment,
                    prefixIcon: Icons.domain_rounded,
                    items: _departments
                        .map((d) => DropdownMenuItem(
                              value: d,
                              child: Text(d, style: GoogleFonts.inter(fontSize: 12.5, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis),
                            ))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDepartment = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // Export Formats Section
            Text(
              'Available Export Formats',
              style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w800, color: isDark ? Colors.white : AppColors.deepNavy),
            ),
            const SizedBox(height: 12),

            // PDF Option
            GlassContainer(
              borderRadius: 20,
              blurSigma: 14,
              glowColor: AppColors.error,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Executive PDF Report Document', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Print-ready analytics with summary metrics, events table, and attendee logs.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassButton(
                    label: 'Export PDF',
                    icon: Icons.download_rounded,
                    height: 40,
                    borderRadius: 12,
                    isLoading: _isExporting,
                    onPressed: _isExporting ? null : _exportPdf,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Excel Option
            GlassContainer(
              borderRadius: 20,
              blurSigma: 14,
              glowColor: AppColors.statusLive,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusLive.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.table_chart_rounded, color: AppColors.statusLive, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Excel Spreadsheet (.xlsx)', style: GoogleFonts.outfit(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Multi-sheet workbook containing Events, Registrations, and Certificates data.', style: GoogleFonts.inter(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GlassButton(
                    label: 'Export Excel',
                    icon: Icons.file_download_rounded,
                    color: AppColors.statusLive,
                    height: 40,
                    borderRadius: 12,
                    onPressed: _exportExcel,
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
}
