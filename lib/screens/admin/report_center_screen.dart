import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import '../../providers/admin_provider.dart';
import '../../providers/event_provider.dart';
import '../../services/report_export_service.dart';
import '../../theme/app_theme.dart';

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

    // Trigger download/save notification
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.statusLive,
        content: Text('📊 Excel spreadsheet generated successfully (${excelBytes.length} bytes ready).'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administrative Report Center'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Banner
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: AppColors.heroGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Row(
                children: [
                  Icon(Icons.analytics_outlined, color: Colors.white, size: 36),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'On-Demand Executive Reporting',
                          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Generate complete audit records, event participation statistics, certificates log, and multi-criteria feedback scores in PDF and Excel formats (SRS Section 1.6 #7).',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Department Scope Filter
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
                  const Text('Select Department Scope for Report', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    value: _selectedDepartment,
                    decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.domain, color: AppColors.primary),
                    ),
                    items: _departments.map((d) => DropdownMenuItem(value: d, child: Text(d, style: const TextStyle(fontSize: 12)))).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedDepartment = val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Export Formats Section
            const Text(
              'Available Export Formats',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.deepNavy),
            ),
            const SizedBox(height: 12),

            // PDF Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.picture_as_pdf, color: AppColors.error, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Executive PDF Report Document', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Print-ready analytics with summary metrics, events table, attendee logs, and rating highlights.', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _isExporting ? null : _exportPdf,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
                    icon: _isExporting
                        ? const SizedBox(width: 14, height: 14, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Icon(Icons.download, size: 16),
                    label: const Text('Export PDF', style: TextStyle(fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Excel Option
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.statusLive.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_chart, color: AppColors.statusLive, size: 28),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Excel Spreadsheet (.xlsx Workbook)', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
                        Text('Multi-sheet workbook containing Events, Registrations, Issued Certificates, and Feedback Analysis data.', style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight)),
                      ],
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _exportExcel,
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.statusLive),
                    icon: const Icon(Icons.file_download, size: 16),
                    label: const Text('Export Excel', style: TextStyle(fontSize: 12)),
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
