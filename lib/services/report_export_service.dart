import 'dart:convert';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/certificate_model.dart';
import '../models/feedback_model.dart';

class ReportExportService {
  /// Generates a comprehensive PDF Administrative Report
  static Future<Uint8List> generatePdfReport({
    required List<EventModel> events,
    required List<RegistrationModel> registrations,
    required List<CertificateModel> certificates,
    required List<FeedbackModel> feedbacks,
    String filterDepartment = 'All',
  }) async {
    final pdf = pw.Document();

    const primaryBlue = PdfColor.fromInt(0xFF1D4ED8);
    const deepNavy = PdfColor.fromInt(0xFF0F172A);
    const brightCyan = PdfColor.fromInt(0xFF06B6D4);
    const mutedSlate = PdfColor.fromInt(0xFF64748B);

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontTitle = await PdfGoogleFonts.outfitBold();

    final generatedOn = DateFormat('MMMM dd, yyyy - hh:mm a').format(DateTime.now());

    final filteredEvents = filterDepartment == 'All'
        ? events
        : events.where((e) => e.department.toLowerCase() == filterDepartment.toLowerCase()).toList();

    final totalRegistrations = registrations.length;
    final totalCertificates = certificates.length;
    final totalFeedbacks = feedbacks.length;
    final avgRating = feedbacks.isEmpty
        ? 0.0
        : (feedbacks.map((f) => f.averageScore).reduce((a, b) => a + b) / feedbacks.length);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Header
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.center,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'FUSIONFIESTA 2026',
                      style: pw.TextStyle(font: fontTitle, fontSize: 20, color: primaryBlue),
                    ),
                    pw.Text(
                      'Executive Analytics & Participation Report',
                      style: pw.TextStyle(font: fontBold, fontSize: 12, color: deepNavy),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text('Generated: $generatedOn', style: pw.TextStyle(font: fontRegular, fontSize: 8, color: mutedSlate)),
                    pw.Text('Scope: $filterDepartment Departments', style: pw.TextStyle(font: fontBold, fontSize: 9, color: brightCyan)),
                  ],
                ),
              ],
            ),
            pw.Divider(color: primaryBlue, thickness: 1.5),
            pw.SizedBox(height: 12),

            // Summary Metrics Grid
            pw.Row(
              children: [
                _buildPdfMetricTile(fontBold, fontRegular, 'Total Events', '${filteredEvents.length}', primaryBlue),
                pw.SizedBox(width: 8),
                _buildPdfMetricTile(fontBold, fontRegular, 'Registrations', '$totalRegistrations', brightCyan),
                pw.SizedBox(width: 8),
                _buildPdfMetricTile(fontBold, fontRegular, 'Certificates Issued', '$totalCertificates', const PdfColor.fromInt(0xFF10B981)),
                pw.SizedBox(width: 8),
                _buildPdfMetricTile(fontBold, fontRegular, 'Average Rating', '${avgRating.toStringAsFixed(2)} / 5.0', const PdfColor.fromInt(0xFFF59E0B)),
              ],
            ),

            pw.SizedBox(height: 20),

            // Section 1: Events Overview Table
            pw.Text('1. Event Portfolio & Status Breakdown', style: pw.TextStyle(font: fontBold, fontSize: 13, color: deepNavy)),
            pw.SizedBox(height: 6),
            pw.Table.fromTextArray(
              headers: ['Event Title', 'Category', 'Department', 'Date', 'Capacity', 'Regs', 'Status'],
              data: filteredEvents.map((e) => [
                e.title,
                e.category.displayName,
                e.department,
                DateFormat('MMM dd').format(e.date),
                '${e.maxParticipants}',
                '${e.registeredCount}',
                e.status.displayName,
              ]).toList(),
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: primaryBlue),
              cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
              rowDecoration: const pw.BoxDecoration(border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey200, width: 0.5))),
            ),

            pw.SizedBox(height: 20),

            // Section 2: Recent Registrations & Passes
            pw.Text('2. Recent Student Registrations', style: pw.TextStyle(font: fontBold, fontSize: 13, color: deepNavy)),
            pw.SizedBox(height: 6),
            pw.Table.fromTextArray(
              headers: ['Pass ID', 'Student Name', 'Enrollment', 'Event', 'Registered Date', 'Status'],
              data: registrations.take(8).map((r) => [
                r.qrPassCode.split('-').take(2).join('-'),
                r.studentName,
                r.enrollmentNo,
                r.eventTitle,
                DateFormat('MMM dd, yyyy').format(r.registeredOn),
                r.status.displayName,
              ]).toList(),
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: deepNavy),
              cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 20),

            // Section 3: Feedback Highlights
            pw.Text('3. Multi-Criteria Feedback Summary', style: pw.TextStyle(font: fontBold, fontSize: 13, color: deepNavy)),
            pw.SizedBox(height: 6),
            pw.Table.fromTextArray(
              headers: ['Event', 'Participant', 'Org', 'Rel', 'Coord', 'Overall', 'Average'],
              data: feedbacks.take(6).map((f) => [
                f.eventTitle,
                f.studentName,
                '${f.organizationRating}★',
                '${f.relevanceRating}★',
                '${f.coordinationRating}★',
                '${f.overallRating}★',
                '${f.averageScore.toStringAsFixed(1)}★',
              ]).toList(),
              headerStyle: pw.TextStyle(font: fontBold, fontSize: 9, color: PdfColors.white),
              headerDecoration: const pw.BoxDecoration(color: brightCyan),
              cellStyle: pw.TextStyle(font: fontRegular, fontSize: 8),
              cellAlignment: pw.Alignment.centerLeft,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildPdfMetricTile(pw.Font fontBold, pw.Font fontRegular, String title, String val, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: const PdfColor.fromInt(0xFFF8FAFC),
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: color, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(title, style: pw.TextStyle(font: fontRegular, fontSize: 8, color: const PdfColor.fromInt(0xFF64748B))),
            pw.SizedBox(height: 4),
            pw.Text(val, style: pw.TextStyle(font: fontBold, fontSize: 14, color: color)),
          ],
        ),
      ),
    );
  }

  /// Downloads/Prints PDF report directly
  static Future<void> exportPdfReport({
    required List<EventModel> events,
    required List<RegistrationModel> registrations,
    required List<CertificateModel> certificates,
    required List<FeedbackModel> feedbacks,
    String filterDepartment = 'All',
  }) async {
    final pdfBytes = await generatePdfReport(
      events: events,
      registrations: registrations,
      certificates: certificates,
      feedbacks: feedbacks,
      filterDepartment: filterDepartment,
    );
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'FusionFiesta_Admin_Report_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
  }

  /// Generates Excel spreadsheet (.xlsx bytes)
  static Uint8List generateExcelReport({
    required List<EventModel> events,
    required List<RegistrationModel> registrations,
    required List<CertificateModel> certificates,
    required List<FeedbackModel> feedbacks,
  }) {
    final excel = Excel.createExcel();

    // Sheet 1: Events
    final Sheet eventSheet = excel['Events_Summary'];
    eventSheet.appendRow([
      TextCellValue('Event ID'),
      TextCellValue('Event Title'),
      TextCellValue('Category'),
      TextCellValue('Department'),
      TextCellValue('Date'),
      TextCellValue('Venue'),
      TextCellValue('Max Capacity'),
      TextCellValue('Registered Count'),
      TextCellValue('Status'),
      TextCellValue('Avg Rating'),
    ]);

    for (var e in events) {
      eventSheet.appendRow([
        TextCellValue(e.id),
        TextCellValue(e.title),
        TextCellValue(e.category.displayName),
        TextCellValue(e.department),
        TextCellValue(DateFormat('yyyy-MM-dd').format(e.date)),
        TextCellValue(e.venue),
        IntCellValue(e.maxParticipants),
        IntCellValue(e.registeredCount),
        TextCellValue(e.status.displayName),
        DoubleCellValue(e.averageRating),
      ]);
    }

    // Sheet 2: Registrations
    final Sheet regSheet = excel['Registrations'];
    regSheet.appendRow([
      TextCellValue('Registration ID'),
      TextCellValue('Event Title'),
      TextCellValue('Student Name'),
      TextCellValue('Student Email'),
      TextCellValue('Enrollment No'),
      TextCellValue('Department'),
      TextCellValue('Registration Date'),
      TextCellValue('Status'),
      TextCellValue('QR Pass Code'),
    ]);

    for (var r in registrations) {
      regSheet.appendRow([
        TextCellValue(r.id),
        TextCellValue(r.eventTitle),
        TextCellValue(r.studentName),
        TextCellValue(r.studentEmail),
        TextCellValue(r.enrollmentNo),
        TextCellValue(r.department),
        TextCellValue(DateFormat('yyyy-MM-dd').format(r.registeredOn)),
        TextCellValue(r.status.displayName),
        TextCellValue(r.qrPassCode),
      ]);
    }

    // Sheet 3: Certificates
    final Sheet certSheet = excel['Certificates'];
    certSheet.appendRow([
      TextCellValue('Certificate No'),
      TextCellValue('Event Title'),
      TextCellValue('Student Name'),
      TextCellValue('Enrollment No'),
      TextCellValue('Department'),
      TextCellValue('Type'),
      TextCellValue('Fee Amount'),
      TextCellValue('Fee Paid'),
      TextCellValue('Transaction ID'),
      TextCellValue('Issued On'),
    ]);

    for (var c in certificates) {
      certSheet.appendRow([
        TextCellValue(c.certificateNumber),
        TextCellValue(c.eventTitle),
        TextCellValue(c.studentName),
        TextCellValue(c.enrollmentNo),
        TextCellValue(c.department),
        TextCellValue(c.certificateType.displayName),
        DoubleCellValue(c.feeAmount),
        TextCellValue(c.isFeePaid ? 'YES' : 'NO'),
        TextCellValue(c.transactionId ?? 'N/A'),
        TextCellValue(DateFormat('yyyy-MM-dd').format(c.issuedOn)),
      ]);
    }

    // Sheet 4: Feedback
    final Sheet fbSheet = excel['Feedback_Analysis'];
    fbSheet.appendRow([
      TextCellValue('Event Title'),
      TextCellValue('Student Name'),
      TextCellValue('Organization (1-5)'),
      TextCellValue('Relevance (1-5)'),
      TextCellValue('Coordination (1-5)'),
      TextCellValue('Overall (1-5)'),
      TextCellValue('Average Score'),
      TextCellValue('Comments'),
      TextCellValue('Submitted Date'),
    ]);

    for (var f in feedbacks) {
      fbSheet.appendRow([
        TextCellValue(f.eventTitle),
        TextCellValue(f.studentName),
        IntCellValue(f.organizationRating),
        IntCellValue(f.relevanceRating),
        IntCellValue(f.coordinationRating),
        IntCellValue(f.overallRating),
        DoubleCellValue(f.averageScore),
        TextCellValue(f.comments),
        TextCellValue(DateFormat('yyyy-MM-dd').format(f.submittedOn)),
      ]);
    }

    // Remove default sheet
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    final fileBytes = excel.save();
    return Uint8List.fromList(fileBytes ?? []);
  }

  /// Generates CSV report string
  static String generateCsvSummary({
    required List<EventModel> events,
    required List<RegistrationModel> registrations,
    required List<CertificateModel> certificates,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('=== FUSIONFIESTA 2026 EVENT SUMMARY CSV ===');
    buffer.writeln('Event Title,Category,Department,Date,Venue,Capacity,Registered,Status,AvgRating');
    for (var e in events) {
      buffer.writeln('"${e.title}","${e.category.displayName}","${e.department}","${DateFormat('yyyy-MM-dd').format(e.date)}","${e.venue}",${e.maxParticipants},${e.registeredCount},"${e.status.displayName}",${e.averageRating}');
    }
    buffer.writeln('');
    buffer.writeln('=== REGISTRATIONS ===');
    buffer.writeln('PassCode,StudentName,Enrollment,EventTitle,Status');
    for (var r in registrations) {
      buffer.writeln('"${r.qrPassCode}","${r.studentName}","${r.enrollmentNo}","${r.eventTitle}","${r.status.displayName}"');
    }
    return buffer.toString();
  }
}
