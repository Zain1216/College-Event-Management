import '../models/registration_model.dart';
import '../models/certificate_model.dart';

class QrPassPayload {
  final String passCode;
  final String eventId;
  final String studentId;
  final String studentName;
  final String enrollmentNo;

  QrPassPayload({
    required this.passCode,
    required this.eventId,
    required this.studentId,
    required this.studentName,
    required this.enrollmentNo,
  });
}

class QrService {
  /// Encodes registration into a standard QR pass string
  static String generatePassData(RegistrationModel reg) {
    return 'FF-PASS|${reg.eventId}|${reg.studentId}|${reg.enrollmentNo}|${reg.studentName}|${reg.qrPassCode}';
  }

  /// Parses scanned QR string
  static QrPassPayload? parsePassData(String rawData) {
    try {
      if (!rawData.startsWith('FF-PASS|')) {
        // Fallback simple parsing
        if (rawData.startsWith('PASS-')) {
          final parts = rawData.split('-');
          return QrPassPayload(
            passCode: rawData,
            eventId: parts.length > 1 ? parts[1].toLowerCase() : '',
            studentId: '',
            studentName: parts.length > 3 ? parts[3] : '',
            enrollmentNo: parts.length > 2 ? parts[2] : '',
          );
        }
        return null;
      }

      final parts = rawData.split('|');
      if (parts.length >= 6) {
        return QrPassPayload(
          eventId: parts[1],
          studentId: parts[2],
          enrollmentNo: parts[3],
          studentName: parts[4],
          passCode: parts[5],
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Encodes certificate verification payload
  static String generateCertVerificationData(CertificateModel cert) {
    return 'FF-CERT|${cert.certificateNumber}|${cert.studentName}|${cert.eventTitle}|${cert.certificateType.name}';
  }
}
