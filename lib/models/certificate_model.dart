enum CertificateType {
  participation('Certificate of Participation'),
  winnerFirst('Certificate of Excellence (1st Place)'),
  winnerSecond('Certificate of Merit (2nd Place)'),
  winnerThird('Certificate of Merit (3rd Place)'),
  specialAppreciation('Special Appreciation Certificate');

  final String displayName;
  const CertificateType(this.displayName);

  static CertificateType fromString(String type) {
    switch (type.toLowerCase()) {
      case 'winnerfirst':
      case '1st':
      case 'first':
        return CertificateType.winnerFirst;
      case 'winnersecond':
      case '2nd':
      case 'second':
        return CertificateType.winnerSecond;
      case 'winnerthird':
      case '3rd':
      case 'third':
        return CertificateType.winnerThird;
      case 'specialappreciation':
        return CertificateType.specialAppreciation;
      case 'participation':
      default:
        return CertificateType.participation;
    }
  }
}

class CertificateModel {
  final String id;
  final String certificateNumber; // e.g. FF-2026-CS-0042
  final String eventId;
  final String eventTitle;
  final String eventCategory;
  final DateTime eventDate;
  final String studentId;
  final String studentName;
  final String enrollmentNo;
  final String department;
  final CertificateType certificateType;
  final double feeAmount;
  final bool isFeePaid;
  final String? transactionId;
  final DateTime? paidOn;
  final DateTime issuedOn;
  final String? certificatePdfUrl;
  final String verificationQrData;
  final String issuedByOrganizer;

  CertificateModel({
    required this.id,
    required this.certificateNumber,
    required this.eventId,
    required this.eventTitle,
    this.eventCategory = 'Technical',
    required this.eventDate,
    required this.studentId,
    required this.studentName,
    required this.enrollmentNo,
    required this.department,
    this.certificateType = CertificateType.participation,
    this.feeAmount = 50.0,
    this.isFeePaid = false,
    this.transactionId,
    this.paidOn,
    required this.issuedOn,
    this.certificatePdfUrl,
    required this.verificationQrData,
    this.issuedByOrganizer = 'Event Committee',
  });

  bool get isReadyToDownload => isFeePaid;

  CertificateModel copyWith({
    String? id,
    String? certificateNumber,
    String? eventId,
    String? eventTitle,
    String? eventCategory,
    DateTime? eventDate,
    String? studentId,
    String? studentName,
    String? enrollmentNo,
    String? department,
    CertificateType? certificateType,
    double? feeAmount,
    bool? isFeePaid,
    String? transactionId,
    DateTime? paidOn,
    DateTime? issuedOn,
    String? certificatePdfUrl,
    String? verificationQrData,
    String? issuedByOrganizer,
  }) {
    return CertificateModel(
      id: id ?? this.id,
      certificateNumber: certificateNumber ?? this.certificateNumber,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventCategory: eventCategory ?? this.eventCategory,
      eventDate: eventDate ?? this.eventDate,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      department: department ?? this.department,
      certificateType: certificateType ?? this.certificateType,
      feeAmount: feeAmount ?? this.feeAmount,
      isFeePaid: isFeePaid ?? this.isFeePaid,
      transactionId: transactionId ?? this.transactionId,
      paidOn: paidOn ?? this.paidOn,
      issuedOn: issuedOn ?? this.issuedOn,
      certificatePdfUrl: certificatePdfUrl ?? this.certificatePdfUrl,
      verificationQrData: verificationQrData ?? this.verificationQrData,
      issuedByOrganizer: issuedByOrganizer ?? this.issuedByOrganizer,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'certificateNumber': certificateNumber,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventCategory': eventCategory,
      'eventDate': eventDate.toIso8601String(),
      'studentId': studentId,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'department': department,
      'certificateType': certificateType.name,
      'feeAmount': feeAmount,
      'isFeePaid': isFeePaid,
      'transactionId': transactionId,
      'paidOn': paidOn?.toIso8601String(),
      'issuedOn': issuedOn.toIso8601String(),
      'certificatePdfUrl': certificatePdfUrl,
      'verificationQrData': verificationQrData,
      'issuedByOrganizer': issuedByOrganizer,
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    try {
      if (val.runtimeType.toString() == 'Timestamp') {
        return (val as dynamic).toDate() as DateTime;
      }
    } catch (_) {}
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  static DateTime? _parseNullableDate(dynamic val) {
    if (val == null) return null;
    if (val is DateTime) return val;
    try {
      if (val.runtimeType.toString() == 'Timestamp') {
        return (val as dynamic).toDate() as DateTime;
      }
    } catch (_) {}
    return DateTime.tryParse(val.toString());
  }

  factory CertificateModel.fromMap(Map<String, dynamic> map) {
    return CertificateModel(
      id: map['id'] as String? ?? '',
      certificateNumber: map['certificateNumber'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      eventCategory: map['eventCategory'] as String? ?? 'Technical',
      eventDate: _parseDate(map['eventDate']),
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      enrollmentNo: map['enrollmentNo'] as String? ?? '',
      department: map['department'] as String? ?? 'General',
      certificateType: CertificateType.fromString(
          map['certificateType'] as String? ?? 'participation'),
      feeAmount: (map['feeAmount'] as num?)?.toDouble() ?? 50.0,
      isFeePaid: map['isFeePaid'] as bool? ?? false,
      transactionId: map['transactionId'] as String?,
      paidOn: _parseNullableDate(map['paidOn']),
      issuedOn: _parseDate(map['issuedOn']),
      certificatePdfUrl: map['certificatePdfUrl'] as String?,
      verificationQrData: map['verificationQrData'] as String? ?? '',
      issuedByOrganizer: map['issuedByOrganizer'] as String? ?? 'Event Committee',
    );
  }
}
