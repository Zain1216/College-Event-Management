import 'package:flutter_test/flutter_test.dart';
import 'package:fusion_fiesta/models/user_model.dart';
import 'package:fusion_fiesta/models/event_model.dart';
import 'package:fusion_fiesta/models/registration_model.dart';
import 'package:fusion_fiesta/models/certificate_model.dart';
import 'package:fusion_fiesta/models/feedback_model.dart';
import 'package:fusion_fiesta/services/firebase_datastore.dart';
import 'package:fusion_fiesta/services/qr_service.dart';
import 'package:fusion_fiesta/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Pure Firebase FusionFiesta Core Logic Tests', () {
    test('QR Pass Encoding and Decoding', () {
      final reg = RegistrationModel(
        id: 'reg_test_01',
        eventId: 'evt_technova_01',
        eventTitle: 'TechNova 2026',
        eventDate: DateTime(2026, 9, 15),
        eventTime: '10:00 AM',
        studentId: 'usr_student_01',
        studentName: 'Zain Ahmed',
        studentEmail: 'student@fusionfiesta.edu',
        enrollmentNo: 'CS-2023-089',
        department: 'Computer Science',
        registeredOn: DateTime.now(),
        qrPassCode: 'PASS-TECHNOVA-CS2023089-ZAIN',
      );

      final qrData = QrService.generatePassData(reg);
      expect(qrData.startsWith('FF-PASS|'), isTrue);

      final parsed = QrService.parsePassData(qrData);
      expect(parsed, isNotNull);
      expect(parsed!.eventId, equals('evt_technova_01'));
      expect(parsed.studentId, equals('usr_student_01'));
      expect(parsed.enrollmentNo, equals('CS-2023-089'));
      expect(parsed.studentName, equals('Zain Ahmed'));
    });

    test('Feedback 4-Parameter Rating Calculation', () {
      final fb = FeedbackModel(
        id: 'fb_test',
        eventId: 'evt_technova_01',
        eventTitle: 'TechNova 2026',
        studentId: 'usr_student_01',
        studentName: 'Zain Ahmed',
        organizationRating: 5,
        relevanceRating: 4,
        coordinationRating: 5,
        overallRating: 4,
        comments: 'Great event structure and judges.',
        submittedOn: DateTime.now(),
      );

      expect(fb.averageScore, equals(4.5));
      expect(fb.isFlagged, isFalse);
    });

    test('Certificate Fee Clearance Status Check', () {
      final certUnpaid = CertificateModel(
        id: 'cert_01',
        certificateNumber: 'FF-2026-CS-0042',
        eventId: 'evt_flutter_01',
        eventTitle: 'Flutter Workshop',
        eventDate: DateTime(2026, 8, 20),
        studentId: 'usr_student_01',
        studentName: 'Zain Ahmed',
        enrollmentNo: 'CS-2023-089',
        department: 'Computer Science',
        feeAmount: 50.0,
        isFeePaid: false,
        issuedOn: DateTime.now(),
        verificationQrData: 'VERIFY-0042',
      );

      expect(certUnpaid.isReadyToDownload, isFalse);

      final certPaid = certUnpaid.copyWith(
        isFeePaid: true,
        transactionId: 'TXN_TEST_123',
      );

      expect(certPaid.isReadyToDownload, isTrue);
    });

    test('Student Visitor Role Restrictions', () {
      final visitor = UserModel(
        uid: 'usr_visitor',
        email: 'visitor@fusionfiesta.edu',
        fullName: 'Visitor User',
        role: UserRole.visitor,
        createdAt: DateTime.now(),
      );

      expect(visitor.isVerifiedParticipant, isFalse);
      expect(visitor.role, equals(UserRole.visitor));

      final upgraded = visitor.copyWith(
        role: UserRole.participant,
        enrollmentNo: 'CS-2023-999',
        department: 'Computer Science',
      );

      expect(upgraded.isVerifiedParticipant, isTrue);
      expect(upgraded.role, equals(UserRole.participant));
    });
  });

  testWidgets('App Launches and displays FusionFiesta Brand', (WidgetTester tester) async {
    await tester.pumpWidget(const FusionFiestaApp());
    await tester.pumpAndSettle();

    expect(find.textContaining('Fusion'), findsWidgets);
  });
}
