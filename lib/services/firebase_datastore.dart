import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/registration_model.dart';
import '../models/attendance_model.dart';
import '../models/feedback_model.dart';
import '../models/certificate_model.dart';
import '../models/media_model.dart';
import '../models/notification_model.dart';
import '../models/contact_model.dart';

/// Pure Firebase Cloud Firestore Service Layer for FusionFiesta.
/// Directly synchronizes with live Cloud Firestore collections and provides
/// real-time snapshot streams and robust CRUD operations across the system.
class FirebaseDataStore {
  static final FirebaseDataStore _instance = FirebaseDataStore._internal();
  factory FirebaseDataStore() => _instance;
  FirebaseDataStore._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  // Firestore Collection References
  CollectionReference<Map<String, dynamic>> get _usersCol =>
      _firestore.collection('users');
  CollectionReference<Map<String, dynamic>> get _eventsCol =>
      _firestore.collection('events');
  CollectionReference<Map<String, dynamic>> get _registrationsCol =>
      _firestore.collection('registrations');
  CollectionReference<Map<String, dynamic>> get _attendanceCol =>
      _firestore.collection('attendance');
  CollectionReference<Map<String, dynamic>> get _feedbackCol =>
      _firestore.collection('feedback');
  CollectionReference<Map<String, dynamic>> get _certificatesCol =>
      _firestore.collection('certificates');
  CollectionReference<Map<String, dynamic>> get _mediaCol =>
      _firestore.collection('media_gallery');
  CollectionReference<Map<String, dynamic>> get _notificationsCol =>
      _firestore.collection('notifications');
  CollectionReference<Map<String, dynamic>> get _contactQueriesCol =>
      _firestore.collection('contact_queries');

  // Internal In-Memory State Mirrors (Synchronized in Real-Time from Firestore)
  final List<UserModel> _users = [];
  final List<EventModel> _events = [];
  final List<RegistrationModel> _registrations = [];
  final List<AttendanceModel> _attendance = [];
  final List<FeedbackModel> _feedback = [];
  final List<CertificateModel> _certificates = [];
  final List<MediaModel> _mediaGallery = [];
  final List<NotificationModel> _notifications = [];
  final List<ContactQueryModel> _contactQueries = [];

  // Stream Controllers for Real-Time Snapshot Broadcasting
  final _usersStreamController = StreamController<List<UserModel>>.broadcast();
  final _eventsStreamController = StreamController<List<EventModel>>.broadcast();
  final _registrationsStreamController =
      StreamController<List<RegistrationModel>>.broadcast();
  final _attendanceStreamController =
      StreamController<List<AttendanceModel>>.broadcast();
  final _feedbackStreamController =
      StreamController<List<FeedbackModel>>.broadcast();
  final _certificatesStreamController =
      StreamController<List<CertificateModel>>.broadcast();
  final _mediaStreamController = StreamController<List<MediaModel>>.broadcast();
  final _notificationsStreamController =
      StreamController<List<NotificationModel>>.broadcast();
  final _contactQueriesStreamController =
      StreamController<List<ContactQueryModel>>.broadcast();

  // Public Stream Getters
  Stream<List<UserModel>> get usersStream => _usersStreamController.stream;
  Stream<List<EventModel>> get eventsStream => _eventsStreamController.stream;
  Stream<List<RegistrationModel>> get registrationsStream =>
      _registrationsStreamController.stream;
  Stream<List<AttendanceModel>> get attendanceStream =>
      _attendanceStreamController.stream;
  Stream<List<FeedbackModel>> get feedbackStream =>
      _feedbackStreamController.stream;
  Stream<List<CertificateModel>> get certificatesStream =>
      _certificatesStreamController.stream;
  Stream<List<MediaModel>> get mediaStream => _mediaStreamController.stream;
  Stream<List<NotificationModel>> get notificationsStream =>
      _notificationsStreamController.stream;
  Stream<List<ContactQueryModel>> get contactQueriesStream =>
      _contactQueriesStreamController.stream;

  // Direct Synchronous Access to Local Firestore Mirror
  List<UserModel> get users => List.unmodifiable(_users);
  List<EventModel> get events => List.unmodifiable(_events);
  List<RegistrationModel> get registrations => List.unmodifiable(_registrations);
  List<AttendanceModel> get attendance => List.unmodifiable(_attendance);
  List<FeedbackModel> get feedback => List.unmodifiable(_feedback);
  List<CertificateModel> get certificates => List.unmodifiable(_certificates);
  List<MediaModel> get mediaGallery => List.unmodifiable(_mediaGallery);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<ContactQueryModel> get contactQueries =>
      List.unmodifiable(_contactQueries);

  bool _initialized = false;
  bool get isInitialized => _initialized;

  final List<StreamSubscription> _firestoreSubscriptions = [];

  /// Initialize real-time Firestore listeners for all 9 collections
  Future<void> initialize() async {
    if (_initialized) return;

    _cancelSubscriptions();

    // 1. Users Stream
    _firestoreSubscriptions.add(
      _usersCol.snapshots().listen(
        (snapshot) {
          _users.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['uid'] = doc.id;
            _users.add(UserModel.fromMap(data));
          }
          _usersStreamController.add(List.unmodifiable(_users));
        },
        onError: (err) {
          // Stream error handled gracefully (e.g. offline/rules)
        },
      ),
    );

    // 2. Events Stream
    _firestoreSubscriptions.add(
      _eventsCol.snapshots().listen(
        (snapshot) {
          _events.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _events.add(EventModel.fromMap(data));
          }
          _events.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _eventsStreamController.add(List.unmodifiable(_events));
        },
        onError: (err) {},
      ),
    );

    // 3. Registrations Stream
    _firestoreSubscriptions.add(
      _registrationsCol.snapshots().listen(
        (snapshot) {
          _registrations.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _registrations.add(RegistrationModel.fromMap(data));
          }
          _registrations.sort((a, b) => b.registeredOn.compareTo(a.registeredOn));
          _registrationsStreamController.add(List.unmodifiable(_registrations));
        },
        onError: (err) {},
      ),
    );

    // 4. Attendance Stream
    _firestoreSubscriptions.add(
      _attendanceCol.snapshots().listen(
        (snapshot) {
          _attendance.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _attendance.add(AttendanceModel.fromMap(data));
          }
          _attendance.sort((a, b) => b.markedOn.compareTo(a.markedOn));
          _attendanceStreamController.add(List.unmodifiable(_attendance));
        },
        onError: (err) {},
      ),
    );

    // 5. Feedback Stream
    _firestoreSubscriptions.add(
      _feedbackCol.snapshots().listen(
        (snapshot) {
          _feedback.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _feedback.add(FeedbackModel.fromMap(data));
          }
          _feedback.sort((a, b) => b.submittedOn.compareTo(a.submittedOn));
          _feedbackStreamController.add(List.unmodifiable(_feedback));
        },
        onError: (err) {},
      ),
    );

    // 6. Certificates Stream
    _firestoreSubscriptions.add(
      _certificatesCol.snapshots().listen(
        (snapshot) {
          _certificates.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _certificates.add(CertificateModel.fromMap(data));
          }
          _certificates.sort((a, b) => b.issuedOn.compareTo(a.issuedOn));
          _certificatesStreamController.add(List.unmodifiable(_certificates));
        },
        onError: (err) {},
      ),
    );

    // 7. Media Gallery Stream
    _firestoreSubscriptions.add(
      _mediaCol.snapshots().listen(
        (snapshot) {
          _mediaGallery.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _mediaGallery.add(MediaModel.fromMap(data));
          }
          _mediaGallery.sort((a, b) => b.uploadedOn.compareTo(a.uploadedOn));
          _mediaStreamController.add(List.unmodifiable(_mediaGallery));
        },
        onError: (err) {},
      ),
    );

    // 8. Notifications Stream
    _firestoreSubscriptions.add(
      _notificationsCol.snapshots().listen(
        (snapshot) {
          _notifications.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _notifications.add(NotificationModel.fromMap(data));
          }
          _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          _notificationsStreamController.add(List.unmodifiable(_notifications));
        },
        onError: (err) {},
      ),
    );

    // 9. Contact Queries Stream
    _firestoreSubscriptions.add(
      _contactQueriesCol.snapshots().listen(
        (snapshot) {
          _contactQueries.clear();
          for (var doc in snapshot.docs) {
            final data = doc.data();
            data['id'] = doc.id;
            _contactQueries.add(ContactQueryModel.fromMap(data));
          }
          _contactQueries.sort((a, b) => b.submittedOn.compareTo(a.submittedOn));
          _contactQueriesStreamController.add(List.unmodifiable(_contactQueries));
        },
        onError: (err) {},
      ),
    );

    _initialized = true;
  }

  void _cancelSubscriptions() {
    for (var sub in _firestoreSubscriptions) {
      sub.cancel();
    }
    _firestoreSubscriptions.clear();
  }

  // ==================== USER OPERATIONS ====================

  UserModel? findUserByEmail(String email) {
    try {
      return _users.firstWhere(
        (u) => u.email.toLowerCase() == email.trim().toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  UserModel? findUserById(String uid) {
    try {
      return _users.firstWhere((u) => u.uid == uid);
    } catch (_) {
      return null;
    }
  }

  Future<UserModel?> getUserById(String uid) async {
    final cached = findUserById(uid);
    if (cached != null) return cached;

    try {
      final doc = await _usersCol.doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        data['uid'] = doc.id;
        final user = UserModel.fromMap(data);
        final index = _users.indexWhere((u) => u.uid == uid);
        if (index != -1) {
          _users[index] = user;
        } else {
          _users.add(user);
        }
        _usersStreamController.add(List.unmodifiable(_users));
        return user;
      }
    } catch (_) {}
    return null;
  }

  Future<void> saveUser(UserModel user) async {
    await _usersCol.doc(user.uid).set(user.toMap(), SetOptions(merge: true));
    final index = _users.indexWhere((u) => u.uid == user.uid);
    if (index != -1) {
      _users[index] = user;
    } else {
      _users.add(user);
    }
    _usersStreamController.add(List.unmodifiable(_users));
  }

  Future<void> updateUser(UserModel updatedUser) async {
    await _usersCol.doc(updatedUser.uid).set(updatedUser.toMap(), SetOptions(merge: true));
    final index = _users.indexWhere((u) => u.uid == updatedUser.uid);
    if (index != -1) {
      _users[index] = updatedUser;
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> toggleUserApproval(String uid, bool isApproved) async {
    await _usersCol.doc(uid).update({'isApproved': isApproved});
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isApproved: isApproved);
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> toggleUserActive(String uid, bool isActive) async {
    await _usersCol.doc(uid).update({'isActive': isActive});
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: isActive);
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> updateUserRole(String uid, UserRole newRole) async {
    await _usersCol.doc(uid).update({'role': newRole.key});
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(role: newRole);
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> toggleBookmark(String uid, String eventId) async {
    final user = findUserById(uid);
    if (user != null) {
      final bookmarks = List<String>.from(user.bookmarkedEventIds);
      if (bookmarks.contains(eventId)) {
        bookmarks.remove(eventId);
      } else {
        bookmarks.add(eventId);
      }
      await _usersCol.doc(uid).update({'bookmarkedEventIds': bookmarks});
      final index = _users.indexWhere((u) => u.uid == uid);
      if (index != -1) {
        _users[index] = user.copyWith(bookmarkedEventIds: bookmarks);
        _usersStreamController.add(List.unmodifiable(_users));
      }
    }
  }

  // ==================== EVENT OPERATIONS ====================

  Future<EventModel> createEvent(EventModel event) async {
    final eventId = event.id.isNotEmpty ? event.id : 'evt_${_uuid.v4().substring(0, 8)}';
    final toSave = event.copyWith(id: eventId);

    await _eventsCol.doc(eventId).set(toSave.toMap());

    // Notify Admin about new proposal
    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: 'role:admin',
      recipientRole: 'admin',
      title: 'Event Proposal Submitted',
      message: 'New event "${toSave.title}" by ${toSave.organizerName} is awaiting approval.',
      eventId: toSave.id,
      type: NotificationType.eventApproval,
      createdAt: DateTime.now(),
    ));

    return toSave;
  }

  Future<void> updateEvent(EventModel event) async {
    await _eventsCol.doc(event.id).set(event.toMap(), SetOptions(merge: true));
  }

  Future<void> setEventStatus(
    String eventId,
    EventStatus newStatus, {
    String? rejectionReason,
  }) async {
    final updateData = <String, dynamic>{
      'status': newStatus.name,
    };
    if (rejectionReason != null) {
      updateData['rejectionReason'] = rejectionReason;
    }

    await _eventsCol.doc(eventId).update(updateData);

    final event = _events.firstWhere((e) => e.id == eventId, orElse: () => EventModel(
      id: eventId,
      title: 'Event',
      description: '',
      category: EventCategory.technical,
      department: 'General',
      date: DateTime.now(),
      time: '',
      venue: '',
      status: newStatus,
      organizerId: '',
      organizerName: '',
      maxParticipants: 100,
      bannerUrl: '',
      createdAt: DateTime.now(),
    ));

    // Notify organizer
    if (event.organizerId.isNotEmpty) {
      await addNotification(NotificationModel(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        recipientId: event.organizerId,
        recipientRole: 'organizer',
        title: 'Event Status: ${newStatus.displayName}',
        message: newStatus == EventStatus.approved
            ? 'Your event "${event.title}" has been approved by the Admin and is now visible to students!'
            : (rejectionReason != null && rejectionReason.isNotEmpty)
                ? 'Your event proposal was declined. Reason: $rejectionReason'
                : 'Your event status has been updated to ${newStatus.displayName}.',
        eventId: eventId,
        type: NotificationType.eventApproval,
        createdAt: DateTime.now(),
      ));
    }

    // If made live or approved, notify all students
    if (newStatus == EventStatus.approved || newStatus == EventStatus.live) {
      await addNotification(NotificationModel(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        recipientId: 'all',
        recipientRole: 'all',
        title: newStatus == EventStatus.live
            ? '🔴 EVENT IS NOW LIVE!'
            : '🎉 New Event Announced',
        message: '"${event.title}" (${event.category.displayName}) - Check schedule & register now!',
        eventId: eventId,
        type: NotificationType.announcement,
        createdAt: DateTime.now(),
      ));
    }
  }

  Future<void> deleteEvent(String eventId) async {
    await _eventsCol.doc(eventId).delete();
  }

  // ==================== REGISTRATION OPERATIONS ====================

  Future<RegistrationModel> registerForEvent({
    required EventModel event,
    required UserModel user,
  }) async {
    if (user.role == UserRole.visitor) {
      throw Exception(
        'Student Visitors must upgrade to Participant profile before registering for events.',
      );
    }
    if (user.enrollmentNo == null || user.enrollmentNo!.trim().isEmpty) {
      throw Exception(
        'Please update your profile with your Enrollment Number and Department to complete registration.',
      );
    }
    if (event.isFull) {
      throw Exception(
        'This event has reached its maximum registration limit (${event.maxParticipants}).',
      );
    }

    final alreadyRegistered = _registrations.any(
      (r) =>
          r.eventId == event.id &&
          r.studentId == user.uid &&
          r.status != RegistrationStatus.cancelled,
    );
    if (alreadyRegistered) {
      throw Exception('You are already registered for this event.');
    }

    final regId = 'reg_${_uuid.v4().substring(0, 8)}';
    final qrPass =
        'PASS-${event.id.toUpperCase()}-${user.enrollmentNo}-${user.fullName.toUpperCase().replaceAll(' ', '')}';
    final registration = RegistrationModel(
      id: regId,
      eventId: event.id,
      eventTitle: event.title,
      eventCategory: event.category.displayName,
      eventVenue: event.venue,
      eventDate: event.date,
      eventTime: event.time,
      studentId: user.uid,
      studentName: user.fullName,
      studentEmail: user.email,
      enrollmentNo: user.enrollmentNo ?? 'N/A',
      department: user.department,
      registeredOn: DateTime.now(),
      status: RegistrationStatus.registered,
      qrPassCode: qrPass,
    );

    // Save registration and increment event count in Firestore
    await _registrationsCol.doc(regId).set(registration.toMap());
    await _eventsCol.doc(event.id).update({
      'registeredCount': FieldValue.increment(1),
    });

    // Send confirmation in-app notification
    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: user.uid,
      recipientRole: 'participant',
      title: 'Registration Confirmed! 🎉',
      message:
          'You are successfully registered for "${event.title}". View your digital QR pass in My Passes.',
      eventId: event.id,
      type: NotificationType.registrationConfirmed,
      createdAt: DateTime.now(),
    ));

    return registration;
  }

  Future<void> cancelRegistration(String registrationId) async {
    final reg = _registrations.firstWhere(
      (r) => r.id == registrationId,
      orElse: () => RegistrationModel(
        id: registrationId,
        eventId: '',
        eventTitle: '',
        eventDate: DateTime.now(),
        eventTime: '',
        studentId: '',
        studentName: '',
        studentEmail: '',
        enrollmentNo: '',
        department: '',
        registeredOn: DateTime.now(),
        qrPassCode: '',
      ),
    );

    await _registrationsCol.doc(registrationId).update({
      'status': RegistrationStatus.cancelled.name,
    });

    if (reg.eventId.isNotEmpty) {
      await _eventsCol.doc(reg.eventId).update({
        'registeredCount': FieldValue.increment(-1),
      });
    }
  }

  // ==================== ATTENDANCE & QR CHECK-IN ====================

  Future<AttendanceModel> checkInParticipant({
    required String eventId,
    required String studentId,
    required String studentName,
    String enrollmentNo = '',
    String department = '',
    required String verifiedByOrganizerId,
    String method = 'qr_scanner',
  }) async {
    final existing = _attendance.firstWhere(
      (a) => a.eventId == eventId && a.studentId == studentId,
      orElse: () => AttendanceModel(
        id: '',
        eventId: '',
        studentId: '',
        studentName: '',
        markedOn: DateTime.now(),
      ),
    );

    if (existing.id.isNotEmpty) {
      return existing; // already checked in
    }

    final attId = 'att_${_uuid.v4().substring(0, 8)}';
    final newAttendance = AttendanceModel(
      id: attId,
      eventId: eventId,
      studentId: studentId,
      studentName: studentName,
      enrollmentNo: enrollmentNo,
      department: department,
      attended: true,
      markedOn: DateTime.now(),
      checkInMethod: method,
      verifiedBy: verifiedByOrganizerId,
    );

    await _attendanceCol.doc(attId).set(newAttendance.toMap());

    // Update matching registration status to attended in Firestore
    final matchingRegs = await _registrationsCol
        .where('eventId', isEqualTo: eventId)
        .where('studentId', isEqualTo: studentId)
        .get();
    for (var doc in matchingRegs.docs) {
      await doc.reference.update({
        'status': RegistrationStatus.attended.name,
      });
    }

    return newAttendance;
  }

  // ==================== FEEDBACK & RATINGS ====================

  Future<FeedbackModel> submitFeedback(FeedbackModel item) async {
    final bannedWords = ['spam', 'scam', 'abuse', 'hate', 'fake'];
    bool isFlagged = item.isFlagged;
    for (var w in bannedWords) {
      if (item.comments.toLowerCase().contains(w)) {
        isFlagged = true;
        break;
      }
    }

    final feedbackId = item.id.isNotEmpty ? item.id : 'fb_${_uuid.v4().substring(0, 8)}';
    final feedbackWithFlag = item.copyWith(id: feedbackId, isFlagged: isFlagged);

    await _feedbackCol.doc(feedbackId).set(feedbackWithFlag.toMap());

    // Recompute event average rating from Firestore feedback
    final allFeedbacksForEvent = _feedback.where((f) => f.eventId == item.eventId && !f.isFlagged).toList();
    allFeedbacksForEvent.add(feedbackWithFlag);

    if (allFeedbacksForEvent.isNotEmpty) {
      final totalScore = allFeedbacksForEvent.map((f) => f.averageScore).reduce((a, b) => a + b);
      final avg = totalScore / allFeedbacksForEvent.length;
      final parsedAvg = double.parse(avg.toStringAsFixed(2));

      await _eventsCol.doc(item.eventId).update({
        'averageRating': parsedAvg,
        'reviewCount': allFeedbacksForEvent.length,
        'isTopRated': parsedAvg >= 4.5,
      });
    }

    if (isFlagged) {
      await addNotification(NotificationModel(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        recipientId: 'role:admin',
        recipientRole: 'admin',
        title: '⚠️ Flagged Feedback Alert',
        message: 'Feedback submitted on "${item.eventTitle}" was automatically flagged for review.',
        eventId: item.eventId,
        type: NotificationType.securityAlert,
        createdAt: DateTime.now(),
      ));
    }

    return feedbackWithFlag;
  }

  Future<void> toggleFeedbackFlag(String feedbackId, bool isFlagged) async {
    await _feedbackCol.doc(feedbackId).update({'isFlagged': isFlagged});
  }

  // ==================== CERTIFICATE & FEE PAYMENT ====================

  Future<CertificateModel> issueCertificate({
    required EventModel event,
    required String studentId,
    required String studentName,
    required String enrollmentNo,
    required String department,
    CertificateType type = CertificateType.participation,
    String issuedBy = 'Event Committee',
  }) async {
    final certNum =
        'FF-${DateTime.now().year}-${department.isNotEmpty ? department.substring(0, 2).toUpperCase() : 'GN'}-${(1000 + _certificates.length)}';
    final certId = 'cert_${_uuid.v4().substring(0, 8)}';
    final cert = CertificateModel(
      id: certId,
      certificateNumber: certNum,
      eventId: event.id,
      eventTitle: event.title,
      eventCategory: event.category.displayName,
      eventDate: event.date,
      studentId: studentId,
      studentName: studentName,
      enrollmentNo: enrollmentNo,
      department: department,
      certificateType: type,
      feeAmount: event.certificateFee,
      isFeePaid: false,
      issuedOn: DateTime.now(),
      verificationQrData: 'VERIFY-$certNum-$studentName-${type.name}',
      issuedByOrganizer: issuedBy,
    );

    await _certificatesCol.doc(certId).set(cert.toMap());

    // Notify Student
    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: studentId,
      recipientRole: 'participant',
      title: '🎓 E-Certificate Issued!',
      message:
          'Your ${type.displayName} for "${event.title}" is ready. Clear the certificate processing fee to download.',
      eventId: event.id,
      type: NotificationType.certificateReady,
      createdAt: DateTime.now(),
    ));

    return cert;
  }

  Future<CertificateModel> processCertificateFeePayment({
    required String certificateId,
    required String paymentMethod,
  }) async {
    final cert = _certificates.firstWhere(
      (c) => c.id == certificateId,
      orElse: () => throw Exception('Certificate record not found.'),
    );

    final txnId =
        'TXN_${paymentMethod.toUpperCase()}_${_uuid.v4().substring(0, 10).toUpperCase()}';
    final paidDate = DateTime.now();

    await _certificatesCol.doc(certificateId).update({
      'isFeePaid': true,
      'transactionId': txnId,
      'paidOn': paidDate.toIso8601String(),
    });

    final updatedCert = cert.copyWith(
      isFeePaid: true,
      transactionId: txnId,
      paidOn: paidDate,
    );

    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: updatedCert.studentId,
      recipientRole: 'participant',
      title: 'Payment Successful! Receipt #$txnId',
      message:
          'Your certificate for "${updatedCert.eventTitle}" is now unlocked for instant PDF download.',
      eventId: updatedCert.eventId,
      type: NotificationType.certificateReady,
      createdAt: DateTime.now(),
    ));

    return updatedCert;
  }

  // ==================== MEDIA GALLERY OPERATIONS ====================

  Future<MediaModel> uploadMedia(MediaModel media) async {
    final mediaId = media.id.isNotEmpty ? media.id : 'med_${_uuid.v4().substring(0, 8)}';
    final toSave = media.copyWith(id: mediaId);
    await _mediaCol.doc(mediaId).set(toSave.toMap());
    return toSave;
  }

  Future<void> toggleMediaLike(String mediaId, String userId) async {
    final media = _mediaGallery.firstWhere((m) => m.id == mediaId, orElse: () => MediaModel(
      id: mediaId,
      eventId: '',
      eventTitle: '',
      mediaUrl: '',
      caption: '',
      uploadedBy: '',
      uploaderName: '',
      uploadedOn: DateTime.now(),
    ));

    final likesList = List<String>.from(media.likedByUserIds);
    if (likesList.contains(userId)) {
      likesList.remove(userId);
    } else {
      likesList.add(userId);
    }

    await _mediaCol.doc(mediaId).update({
      'likesCount': likesList.length,
      'likedByUserIds': likesList,
    });
  }

  Future<void> toggleMediaApproval(String mediaId, bool isApproved) async {
    await _mediaCol.doc(mediaId).update({'isApproved': isApproved});
  }

  Future<void> toggleMediaFeatured(String mediaId, bool isFeatured) async {
    await _mediaCol.doc(mediaId).update({'isFeatured': isFeatured});
  }

  Future<void> deleteMedia(String mediaId) async {
    await _mediaCol.doc(mediaId).delete();
  }

  // ==================== NOTIFICATIONS ====================

  Future<void> addNotification(NotificationModel notif) async {
    final notifId = notif.id.isNotEmpty ? notif.id : 'notif_${_uuid.v4().substring(0, 8)}';
    final toSave = notif.copyWith(id: notifId);
    await _notificationsCol.doc(notifId).set(toSave.toMap());
  }

  Future<void> markNotificationRead(String notifId) async {
    await _notificationsCol.doc(notifId).update({'isRead': true});
  }

  Future<void> markAllNotificationsRead(String userId) async {
    final unread = await _notificationsCol
        .where('isRead', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (var doc in unread.docs) {
      final recipient = doc.data()['recipientId'];
      if (recipient == userId || recipient == 'all') {
        batch.update(doc.reference, {'isRead': true});
      }
    }
    await batch.commit();
  }

  // ==================== CONTACT QUERIES ====================

  Future<void> submitContactQuery(ContactQueryModel query) async {
    final queryId = query.id.isNotEmpty ? query.id : 'query_${_uuid.v4().substring(0, 8)}';
    final toSave = ContactQueryModel(
      id: queryId,
      name: query.name,
      email: query.email,
      subject: query.subject,
      category: query.category,
      message: query.message,
      isResolved: query.isResolved,
      adminReply: query.adminReply,
      submittedOn: query.submittedOn,
    );

    await _contactQueriesCol.doc(queryId).set(toSave.toMap());

    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: 'role:admin',
      recipientRole: 'admin',
      title: 'New Support Query: ${query.subject}',
      message: 'From ${query.name} (${query.email}) regarding ${query.category}.',
      type: NotificationType.general,
      createdAt: DateTime.now(),
    ));
  }

  Future<void> replyToContactQuery(String queryId, String reply) async {
    await _contactQueriesCol.doc(queryId).update({
      'isResolved': true,
      'adminReply': reply,
    });
  }
}
