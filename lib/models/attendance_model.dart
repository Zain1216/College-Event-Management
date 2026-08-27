class AttendanceModel {
  final String id;
  final String eventId;
  final String studentId;
  final String studentName;
  final String enrollmentNo;
  final String department;
  final bool attended;
  final DateTime markedOn;
  final String checkInMethod; // 'qr_scanner' | 'manual'
  final String verifiedBy; // Organizer UID

  AttendanceModel({
    required this.id,
    required this.eventId,
    required this.studentId,
    required this.studentName,
    this.enrollmentNo = '',
    this.department = '',
    this.attended = true,
    required this.markedOn,
    this.checkInMethod = 'qr_scanner',
    this.verifiedBy = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'studentId': studentId,
      'studentName': studentName,
      'enrollmentNo': enrollmentNo,
      'department': department,
      'attended': attended,
      'markedOn': markedOn.toIso8601String(),
      'checkInMethod': checkInMethod,
      'verifiedBy': verifiedBy,
    };
  }

  factory AttendanceModel.fromMap(Map<String, dynamic> map) {
    return AttendanceModel(
      id: map['id'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      enrollmentNo: map['enrollmentNo'] as String? ?? '',
      department: map['department'] as String? ?? '',
      attended: map['attended'] as bool? ?? true,
      markedOn: map['markedOn'] != null
          ? DateTime.tryParse(map['markedOn'].toString()) ?? DateTime.now()
          : DateTime.now(),
      checkInMethod: map['checkInMethod'] as String? ?? 'qr_scanner',
      verifiedBy: map['verifiedBy'] as String? ?? '',
    );
  }
}
