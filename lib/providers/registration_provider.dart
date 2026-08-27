import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/registration_model.dart';
import '../models/attendance_model.dart';
import '../models/event_model.dart';
import '../models/user_model.dart';
import '../services/firebase_datastore.dart';
import '../services/qr_service.dart';

class RegistrationProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<RegistrationModel> _registrations = [];
  List<AttendanceModel> _attendance = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _regSub;
  StreamSubscription? _attSub;

  RegistrationProvider() {
    _init();
  }

  void _init() {
    _registrations = _dataStore.registrations;
    _attendance = _dataStore.attendance;

    _regSub = _dataStore.registrationsStream.listen((regs) {
      _registrations = regs;
      notifyListeners();
    });

    _attSub = _dataStore.attendanceStream.listen((atts) {
      _attendance = atts;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _regSub?.cancel();
    _attSub?.cancel();
    super.dispose();
  }

  List<RegistrationModel> get allRegistrations => _registrations;
  List<AttendanceModel> get allAttendance => _attendance;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<RegistrationModel> getRegistrationsForStudent(String studentId) {
    return _registrations.where((r) => r.studentId == studentId).toList();
  }

  List<RegistrationModel> getActiveRegistrationsForStudent(String studentId) {
    return _registrations
        .where((r) => r.studentId == studentId && r.status != RegistrationStatus.cancelled)
        .toList();
  }

  List<RegistrationModel> getRegistrationsForEvent(String eventId) {
    return _registrations.where((r) => r.eventId == eventId).toList();
  }

  List<AttendanceModel> getAttendanceForEvent(String eventId) {
    return _attendance.where((a) => a.eventId == eventId).toList();
  }

  bool isUserRegistered(String eventId, String studentId) {
    return _registrations.any(
      (r) => r.eventId == eventId && r.studentId == studentId && r.status != RegistrationStatus.cancelled,
    );
  }

  bool hasUserAttended(String eventId, String studentId) {
    return _attendance.any((a) => a.eventId == eventId && a.studentId == studentId && a.attended);
  }

  /// Single-Click Event Registration (SRS 1.6 #4)
  Future<RegistrationModel?> registerStudent({
    required EventModel event,
    required UserModel user,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reg = await _dataStore.registerForEvent(event: event, user: user);
      _isLoading = false;
      notifyListeners();
      return reg;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return null;
    }
  }

  /// Cancel Registration
  Future<void> cancelRegistration(String registrationId) async {
    await _dataStore.cancelRegistration(registrationId);
  }

  /// QR Code Check-in Verification (SRS 1.6 #5)
  Future<String> checkInViaQr({
    required String rawQrString,
    required String currentEventId,
    required String organizerId,
  }) async {
    final payload = QrService.parsePassData(rawQrString);
    if (payload == null) {
      return 'Invalid QR pass format.';
    }

    if (payload.eventId.isNotEmpty && payload.eventId.toLowerCase() != currentEventId.toLowerCase()) {
      return 'Ticket belongs to a different event.';
    }

    // Match student from registrations
    final reg = _registrations.firstWhere(
      (r) =>
          r.eventId == currentEventId &&
          (r.studentId == payload.studentId ||
              r.qrPassCode == payload.passCode ||
              (payload.studentName.isNotEmpty && r.studentName.toLowerCase().contains(payload.studentName.toLowerCase()))),
      orElse: () => RegistrationModel(
        id: '',
        eventId: '',
        eventTitle: '',
        eventDate: DateTime.now(),
        eventTime: '',
        studentId: '',
        studentName: payload.studentName.isNotEmpty ? payload.studentName : 'Student',
        studentEmail: '',
        enrollmentNo: payload.enrollmentNo,
        department: '',
        registeredOn: DateTime.now(),
        qrPassCode: '',
      ),
    );

    final sId = reg.studentId.isNotEmpty ? reg.studentId : (payload.studentId.isNotEmpty ? payload.studentId : 'usr_walkin');
    final sName = reg.studentName.isNotEmpty ? reg.studentName : payload.studentName;

    await _dataStore.checkInParticipant(
      eventId: currentEventId,
      studentId: sId,
      studentName: sName,
      enrollmentNo: reg.enrollmentNo,
      department: reg.department,
      verifiedByOrganizerId: organizerId,
      method: 'qr_scanner',
    );

    return 'SUCCESS: Checked in ${sName} (${reg.enrollmentNo})';
  }

  /// Manual Check-in toggle
  Future<void> checkInManual({
    required String eventId,
    required String studentId,
    required String studentName,
    required String enrollmentNo,
    required String department,
    required String organizerId,
  }) async {
    await _dataStore.checkInParticipant(
      eventId: eventId,
      studentId: studentId,
      studentName: studentName,
      enrollmentNo: enrollmentNo,
      department: department,
      verifiedByOrganizerId: organizerId,
      method: 'manual',
    );
  }
}
