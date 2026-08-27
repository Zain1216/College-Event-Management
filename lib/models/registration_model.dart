enum RegistrationStatus {
  registered,
  attended,
  cancelled,
}

extension RegistrationStatusExtension on RegistrationStatus {
  String get displayName {
    switch (this) {
      case RegistrationStatus.registered:
        return 'Confirmed';
      case RegistrationStatus.attended:
        return 'Attended';
      case RegistrationStatus.cancelled:
        return 'Cancelled';
    }
  }

  static RegistrationStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'attended':
        return RegistrationStatus.attended;
      case 'cancelled':
        return RegistrationStatus.cancelled;
      case 'registered':
      default:
        return RegistrationStatus.registered;
    }
  }
}

class RegistrationModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String eventCategory;
  final String eventVenue;
  final DateTime eventDate;
  final String eventTime;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String enrollmentNo;
  final String department;
  final DateTime registeredOn;
  final RegistrationStatus status;
  final String qrPassCode; // Unique verification string for QR scanner

  RegistrationModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    this.eventCategory = 'Technical',
    this.eventVenue = 'Campus Auditorium',
    required this.eventDate,
    required this.eventTime,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.enrollmentNo,
    required this.department,
    required this.registeredOn,
    this.status = RegistrationStatus.registered,
    required this.qrPassCode,
  });

  bool get isAttended => status == RegistrationStatus.attended;
  bool get isCancelled => status == RegistrationStatus.cancelled;
  bool get isActive => status == RegistrationStatus.registered;

  RegistrationModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? eventCategory,
    String? eventVenue,
    DateTime? eventDate,
    String? eventTime,
    String? studentId,
    String? studentName,
    String? studentEmail,
    String? enrollmentNo,
    String? department,
    DateTime? registeredOn,
    RegistrationStatus? status,
    String? qrPassCode,
  }) {
    return RegistrationModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      eventCategory: eventCategory ?? this.eventCategory,
      eventVenue: eventVenue ?? this.eventVenue,
      eventDate: eventDate ?? this.eventDate,
      eventTime: eventTime ?? this.eventTime,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      studentEmail: studentEmail ?? this.studentEmail,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      department: department ?? this.department,
      registeredOn: registeredOn ?? this.registeredOn,
      status: status ?? this.status,
      qrPassCode: qrPassCode ?? this.qrPassCode,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventCategory': eventCategory,
      'eventVenue': eventVenue,
      'eventDate': eventDate.toIso8601String(),
      'eventTime': eventTime,
      'studentId': studentId,
      'studentName': studentName,
      'studentEmail': studentEmail,
      'enrollmentNo': enrollmentNo,
      'department': department,
      'registeredOn': registeredOn.toIso8601String(),
      'status': status.name,
      'qrPassCode': qrPassCode,
    };
  }

  factory RegistrationModel.fromMap(Map<String, dynamic> map) {
    return RegistrationModel(
      id: map['id'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      eventCategory: map['eventCategory'] as String? ?? 'Technical',
      eventVenue: map['eventVenue'] as String? ?? 'Campus Auditorium',
      eventDate: map['eventDate'] != null
          ? DateTime.tryParse(map['eventDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      eventTime: map['eventTime'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      studentEmail: map['studentEmail'] as String? ?? '',
      enrollmentNo: map['enrollmentNo'] as String? ?? '',
      department: map['department'] as String? ?? 'General',
      registeredOn: map['registeredOn'] != null
          ? DateTime.tryParse(map['registeredOn'].toString()) ?? DateTime.now()
          : DateTime.now(),
      status: RegistrationStatusExtension.fromString(map['status'] as String? ?? 'registered'),
      qrPassCode: map['qrPassCode'] as String? ?? '',
    );
  }
}
