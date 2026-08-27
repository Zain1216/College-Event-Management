import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/certificate_model.dart';
import '../models/event_model.dart';
import '../services/firebase_datastore.dart';
import '../services/certificate_pdf_service.dart';

class CertificateProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<CertificateModel> _certificates = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _certSub;

  CertificateProvider() {
    _init();
  }

  void _init() {
    _certificates = _dataStore.certificates;
    _certSub = _dataStore.certificatesStream.listen((certs) {
      _certificates = certs;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _certSub?.cancel();
    super.dispose();
  }

  List<CertificateModel> get allCertificates => _certificates;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<CertificateModel> getCertificatesForStudent(String studentId) {
    return _certificates.where((c) => c.studentId == studentId).toList();
  }

  List<CertificateModel> getCertificatesForEvent(String eventId) {
    return _certificates.where((c) => c.eventId == eventId).toList();
  }

  /// Issue Certificate (Organizer / Admin)
  Future<CertificateModel> issueCertificate({
    required EventModel event,
    required String studentId,
    required String studentName,
    required String enrollmentNo,
    required String department,
    CertificateType type = CertificateType.participation,
    String issuedBy = 'Event Committee',
  }) async {
    return await _dataStore.issueCertificate(
      event: event,
      studentId: studentId,
      studentName: studentName,
      enrollmentNo: enrollmentNo,
      department: department,
      type: type,
      issuedBy: issuedBy,
    );
  }

  /// Process Simulated Certificate Fee Payment (SRS 1.4 & 1.6 #6)
  Future<bool> payCertificateFee({
    required String certificateId,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 600)); // Payment gateway simulation
      await _dataStore.processCertificateFeePayment(
        certificateId: certificateId,
        paymentMethod: paymentMethod,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Download or Print PDF
  Future<void> downloadCertificate(CertificateModel cert) async {
    await CertificatePdfService.downloadOrPrintCertificate(cert);
  }
}
