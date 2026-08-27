import 'dart:typed_data';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../models/certificate_model.dart';

class CertificatePdfService {
  /// Generates a high-quality vector PDF certificate document
  static Future<Uint8List> generateCertificatePdf(CertificateModel cert) async {
    final pdf = pw.Document();

    // PDF Color Palette: Sapphire Blue, Navy, Cyan, Amber Gold (STRICTLY NO PURPLE)
    const primaryBlue = PdfColor.fromInt(0xFF1D4ED8);
    const deepNavy = PdfColor.fromInt(0xFF0F172A);
    const brightCyan = PdfColor.fromInt(0xFF06B6D4);
    const goldAccent = PdfColor.fromInt(0xFFF59E0B);
    const mutedSlate = PdfColor.fromInt(0xFF64748B);

    final fontRegular = await PdfGoogleFonts.interRegular();
    final fontBold = await PdfGoogleFonts.interBold();
    final fontTitle = await PdfGoogleFonts.outfitBold();

    final formattedDate = DateFormat('MMMM dd, yyyy').format(cert.eventDate);
    final issuedDate = DateFormat('MMMM dd, yyyy').format(cert.issuedOn);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return pw.Container(
            decoration: pw.BoxDecoration(
              color: PdfColors.white,
              border: pw.Border.all(color: primaryBlue, width: 4),
              borderRadius: pw.BorderRadius.circular(12),
            ),
            child: pw.Container(
              margin: const pw.EdgeInsets.all(8),
              padding: const pw.EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: goldAccent, width: 1.5),
                borderRadius: pw.BorderRadius.circular(8),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
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
                            style: pw.TextStyle(
                              font: fontTitle,
                              fontSize: 18,
                              color: primaryBlue,
                              letterSpacing: 2,
                            ),
                          ),
                          pw.Text(
                            'College Event Information & Management System',
                            style: pw.TextStyle(font: fontRegular, fontSize: 9, color: mutedSlate),
                          ),
                        ],
                      ),
                      pw.Container(
                        padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: pw.BoxDecoration(
                          color: const PdfColor.fromInt(0xFFEFF6FF),
                          borderRadius: pw.BorderRadius.circular(6),
                          border: pw.Border.all(color: primaryBlue, width: 0.5),
                        ),
                        child: pw.Text(
                          'ID: ${cert.certificateNumber}',
                          style: pw.TextStyle(font: fontBold, fontSize: 10, color: primaryBlue),
                        ),
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  // Main Certificate Title
                  pw.Column(
                    children: [
                      pw.Text(
                        cert.certificateType == CertificateType.winnerFirst
                            ? 'CERTIFICATE OF EXCELLENCE'
                            : (cert.certificateType == CertificateType.winnerSecond || cert.certificateType == CertificateType.winnerThird)
                                ? 'CERTIFICATE OF MERIT'
                                : 'CERTIFICATE OF PARTICIPATION',
                        style: pw.TextStyle(
                          font: fontTitle,
                          fontSize: 26,
                          color: deepNavy,
                          letterSpacing: 1.5,
                        ),
                      ),
                      pw.Container(
                        margin: const pw.EdgeInsets.only(top: 4),
                        height: 2,
                        width: 140,
                        color: goldAccent,
                      ),
                    ],
                  ),

                  pw.SizedBox(height: 10),

                  // Presented to text
                  pw.Text(
                    'THIS CERTIFICATE IS PROUDLY PRESENTED TO',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 11,
                      color: mutedSlate,
                      letterSpacing: 1.5,
                    ),
                  ),

                  // Participant Name
                  pw.Text(
                    cert.studentName.toUpperCase(),
                    style: pw.TextStyle(
                      font: fontTitle,
                      fontSize: 24,
                      color: primaryBlue,
                      letterSpacing: 1,
                    ),
                  ),

                  // Details line
                  pw.Text(
                    'Enrollment No: ${cert.enrollmentNo}  |  Department: ${cert.department}',
                    style: pw.TextStyle(
                      font: fontRegular,
                      fontSize: 11,
                      color: deepNavy,
                    ),
                  ),

                  // Citation
                  pw.Padding(
                    padding: const pw.EdgeInsets.symmetric(horizontal: 30),
                    child: pw.Text(
                      'for outstanding active participation and performance in "${cert.eventTitle}" (${cert.eventCategory}) held on $formattedDate at FusionFiesta Campus Events.',
                      textAlign: pw.TextAlign.center,
                      style: pw.TextStyle(
                        font: fontRegular,
                        fontSize: 11,
                        color: deepNavy,
                        lineSpacing: 3,
                      ),
                    ),
                  ),

                  pw.SizedBox(height: 10),

                  // Footer: Signatures & QR Code
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      // Organizer Signature
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Prof. Elena Rostova',
                            style: pw.TextStyle(font: fontBold, fontSize: 11, color: deepNavy),
                          ),
                          pw.Container(height: 1, width: 140, color: mutedSlate, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
                          pw.Text(
                            'Event Convener',
                            style: pw.TextStyle(font: fontRegular, fontSize: 9, color: mutedSlate),
                          ),
                        ],
                      ),

                      // Verification QR Box
                      pw.Container(
                        padding: const pw.EdgeInsets.all(6),
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: brightCyan, width: 1),
                          borderRadius: pw.BorderRadius.circular(6),
                          color: const PdfColor.fromInt(0xFFF8FAFC),
                        ),
                        child: pw.Column(
                          children: [
                            pw.BarcodeWidget(
                              barcode: pw.Barcode.qrCode(),
                              data: cert.verificationQrData,
                              width: 48,
                              height: 48,
                              color: deepNavy,
                            ),
                            pw.SizedBox(height: 2),
                            pw.Text(
                              'Scan to Verify',
                              style: pw.TextStyle(font: fontRegular, fontSize: 7, color: mutedSlate),
                            ),
                          ],
                        ),
                      ),

                      // Principal / Admin Signature
                      pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          pw.Text(
                            'Dr. Arthur Vance',
                            style: pw.TextStyle(font: fontBold, fontSize: 11, color: deepNavy),
                          ),
                          pw.Container(height: 1, width: 140, color: mutedSlate, margin: const pw.EdgeInsets.symmetric(vertical: 2)),
                          pw.Text(
                            'Dean of Student Affairs',
                            style: pw.TextStyle(font: fontRegular, fontSize: 9, color: mutedSlate),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  /// Trigger print or save dialog directly
  static Future<void> downloadOrPrintCertificate(CertificateModel cert) async {
    final pdfBytes = await generateCertificatePdf(cert);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'Certificate_${cert.certificateNumber}_${cert.studentName.replaceAll(' ', '_')}.pdf',
    );
  }
}
