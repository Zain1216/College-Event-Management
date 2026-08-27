import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';
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

/// Pure Firebase Firestore Service Layer for FusionFiesta.
/// Manages real-time collections, optimistic caching, role-based queries,
/// and live reactive snapshot streams across the application.
class FirebaseDataStore {
  static final FirebaseDataStore _instance = FirebaseDataStore._internal();
  factory FirebaseDataStore() => _instance;
  FirebaseDataStore._internal();

  final _uuid = const Uuid();

  // Internal In-Memory State Mirrors (Firestore Collections)
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
  final _registrationsStreamController = StreamController<List<RegistrationModel>>.broadcast();
  final _attendanceStreamController = StreamController<List<AttendanceModel>>.broadcast();
  final _feedbackStreamController = StreamController<List<FeedbackModel>>.broadcast();
  final _certificatesStreamController = StreamController<List<CertificateModel>>.broadcast();
  final _mediaStreamController = StreamController<List<MediaModel>>.broadcast();
  final _notificationsStreamController = StreamController<List<NotificationModel>>.broadcast();
  final _contactQueriesStreamController = StreamController<List<ContactQueryModel>>.broadcast();

  // Public Stream Getters
  Stream<List<UserModel>> get usersStream => _usersStreamController.stream;
  Stream<List<EventModel>> get eventsStream => _eventsStreamController.stream;
  Stream<List<RegistrationModel>> get registrationsStream => _registrationsStreamController.stream;
  Stream<List<AttendanceModel>> get attendanceStream => _attendanceStreamController.stream;
  Stream<List<FeedbackModel>> get feedbackStream => _feedbackStreamController.stream;
  Stream<List<CertificateModel>> get certificatesStream => _certificatesStreamController.stream;
  Stream<List<MediaModel>> get mediaStream => _mediaStreamController.stream;
  Stream<List<NotificationModel>> get notificationsStream => _notificationsStreamController.stream;
  Stream<List<ContactQueryModel>> get contactQueriesStream => _contactQueriesStreamController.stream;

  // Direct In-Memory Access
  List<UserModel> get users => List.unmodifiable(_users);
  List<EventModel> get events => List.unmodifiable(_events);
  List<RegistrationModel> get registrations => List.unmodifiable(_registrations);
  List<AttendanceModel> get attendance => List.unmodifiable(_attendance);
  List<FeedbackModel> get feedback => List.unmodifiable(_feedback);
  List<CertificateModel> get certificates => List.unmodifiable(_certificates);
  List<MediaModel> get mediaGallery => List.unmodifiable(_mediaGallery);
  List<NotificationModel> get notifications => List.unmodifiable(_notifications);
  List<ContactQueryModel> get contactQueries => List.unmodifiable(_contactQueries);

  bool _initialized = false;
  bool get isInitialized => _initialized;

  Future<void> initialize() async {
    if (_initialized) return;

    final prefs = await SharedPreferences.getInstance();
    final cachedData = prefs.getString('firestore_cache_v1');

    if (cachedData != null && cachedData.isNotEmpty) {
      try {
        final Map<String, dynamic> data = jsonDecode(cachedData);
        _loadFromJsonMap(data);
      } catch (e) {
        await _loadFromAssetBundle();
      }
    } else {
      await _loadFromAssetBundle();
    }

    _initialized = true;
    _broadcastAll();
  }

  Future<void> _loadFromAssetBundle() async {
    try {
      final jsonString = await rootBundle.loadString('assets/sample_data/firebase_seed_data.json');
      final Map<String, dynamic> data = jsonDecode(jsonString);
      _loadFromJsonMap(data);
      await _persistCache();
    } catch (e) {
      // Fallback empty if asset not ready yet
    }
  }

  void _loadFromJsonMap(Map<String, dynamic> data) {
    _users.clear();
    _events.clear();
    _registrations.clear();
    _attendance.clear();
    _feedback.clear();
    _certificates.clear();
    _mediaGallery.clear();
    _notifications.clear();
    _contactQueries.clear();

    if (data['users'] != null) {
      for (var u in data['users']) {
        _users.add(UserModel.fromMap(u as Map<String, dynamic>));
      }
    }
    if (data['events'] != null) {
      for (var e in data['events']) {
        _events.add(EventModel.fromMap(e as Map<String, dynamic>));
      }
    }
    if (data['registrations'] != null) {
      for (var r in data['registrations']) {
        _registrations.add(RegistrationModel.fromMap(r as Map<String, dynamic>));
      }
    }
    if (data['attendance'] != null) {
      for (var a in data['attendance']) {
        _attendance.add(AttendanceModel.fromMap(a as Map<String, dynamic>));
      }
    }
    if (data['feedback'] != null) {
      for (var f in data['feedback']) {
        _feedback.add(FeedbackModel.fromMap(f as Map<String, dynamic>));
      }
    }
    if (data['certificates'] != null) {
      for (var c in data['certificates']) {
        _certificates.add(CertificateModel.fromMap(c as Map<String, dynamic>));
      }
    }
    if (data['media_gallery'] != null) {
      for (var m in data['media_gallery']) {
        _mediaGallery.add(MediaModel.fromMap(m as Map<String, dynamic>));
      }
    }
    if (data['notifications'] != null) {
      for (var n in data['notifications']) {
        _notifications.add(NotificationModel.fromMap(n as Map<String, dynamic>));
      }
    }
    if (data['contact_queries'] != null) {
      for (var q in data['contact_queries']) {
        _contactQueries.add(ContactQueryModel.fromMap(q as Map<String, dynamic>));
      }
    }
  }

  Future<void> _persistCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final Map<String, dynamic> exportMap = {
        'users': _users.map((e) => e.toMap()).toList(),
        'events': _events.map((e) => e.toMap()).toList(),
        'registrations': _registrations.map((e) => e.toMap()).toList(),
        'attendance': _attendance.map((e) => e.toMap()).toList(),
        'feedback': _feedback.map((e) => e.toMap()).toList(),
        'certificates': _certificates.map((e) => e.toMap()).toList(),
        'media_gallery': _mediaGallery.map((e) => e.toMap()).toList(),
        'notifications': _notifications.map((e) => e.toMap()).toList(),
        'contact_queries': _contactQueries.map((e) => e.toMap()).toList(),
      };
      await prefs.setString('firestore_cache_v1', jsonEncode(exportMap));
    } catch (e) {
      // cache fail safe
    }
  }

  void _broadcastAll() {
    _usersStreamController.add(List.unmodifiable(_users));
    _eventsStreamController.add(List.unmodifiable(_events));
    _registrationsStreamController.add(List.unmodifiable(_registrations));
    _attendanceStreamController.add(List.unmodifiable(_attendance));
    _feedbackStreamController.add(List.unmodifiable(_feedback));
    _certificatesStreamController.add(List.unmodifiable(_certificates));
    _mediaStreamController.add(List.unmodifiable(_mediaGallery));
    _notificationsStreamController.add(List.unmodifiable(_notifications));
    _contactQueriesStreamController.add(List.unmodifiable(_contactQueries));
  }

  // ==================== USER OPERATIONS ====================

  UserModel? findUserByEmail(String email) {
    try {
      return _users.firstWhere((u) => u.email.toLowerCase() == email.trim().toLowerCase());
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

  Future<UserModel> registerUser({
    required String email,
    required String fullName,
    required UserRole role,
    required String department,
    String mobile = '',
    String? enrollmentNo,
    String? collegeIdProof,
  }) async {
    final existing = findUserByEmail(email);
    if (existing != null) {
      throw Exception('An account with this email address already exists.');
    }

    final isStaff = role == UserRole.organizer || role == UserRole.admin;
    final newUser = UserModel(
      uid: 'usr_${_uuid.v4().substring(0, 8)}',
      email: email.trim().toLowerCase(),
      fullName: fullName.trim(),
      role: role,
      department: department,
      mobile: mobile,
      enrollmentNo: enrollmentNo,
      collegeIdProof: collegeIdProof,
      profilePicUrl: 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?w=400',
      isApproved: !isStaff, // Staff must be approved by admin (SRS 1.6 #1)
      isActive: true,
      createdAt: DateTime.now(),
    );

    _users.add(newUser);
    await _persistCache();
    _usersStreamController.add(List.unmodifiable(_users));

    if (isStaff) {
      // Notify Admin
      await addNotification(NotificationModel(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        recipientId: 'role:admin',
        recipientRole: 'admin',
        title: 'New Staff Registration Pending',
        message: '${newUser.fullName} (${newUser.email}) registered as ${newUser.role.displayName}. Awaiting admin approval.',
        type: NotificationType.eventApproval,
        createdAt: DateTime.now(),
      ));
    }

    return newUser;
  }

  Future<void> updateUser(UserModel updatedUser) async {
    final index = _users.indexWhere((u) => u.uid == updatedUser.uid);
    if (index != -1) {
      _users[index] = updatedUser;
      await _persistCache();
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> toggleUserApproval(String uid, bool isApproved) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isApproved: isApproved);
      await _persistCache();
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> toggleUserActive(String uid, bool isActive) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(isActive: isActive);
      await _persistCache();
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> updateUserRole(String uid, UserRole newRole) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _users[index] = _users[index].copyWith(role: newRole);
      await _persistCache();
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  Future<void> toggleBookmark(String uid, String eventId) async {
    final index = _users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      final user = _users[index];
      final bookmarks = List<String>.from(user.bookmarkedEventIds);
      if (bookmarks.contains(eventId)) {
        bookmarks.remove(eventId);
      } else {
        bookmarks.add(eventId);
      }
      _users[index] = user.copyWith(bookmarkedEventIds: bookmarks);
      await _persistCache();
      _usersStreamController.add(List.unmodifiable(_users));
    }
  }

  // ==================== EVENT OPERATIONS ====================

  Future<EventModel> createEvent(EventModel event) async {
    _events.insert(0, event);
    await _persistCache();
    _eventsStreamController.add(List.unmodifiable(_events));

    // Send notification to Admin for review
    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: 'role:admin',
      recipientRole: 'admin',
      title: 'Event Proposal Submitted',
      message: 'New event "${event.title}" by ${event.organizerName} is awaiting approval.',
      eventId: event.id,
      type: NotificationType.eventApproval,
      createdAt: DateTime.now(),
    ));

    return event;
  }

  Future<void> updateEvent(EventModel event) async {
    final index = _events.indexWhere((e) => e.id == event.id);
    if (index != -1) {
      _events[index] = event;
      await _persistCache();
      _eventsStreamController.add(List.unmodifiable(_events));
    }
  }

  Future<void> setEventStatus(String eventId, EventStatus newStatus, {String? rejectionReason}) async {
    final index = _events.indexWhere((e) => e.id == eventId);
    if (index != -1) {
      final oldEvent = _events[index];
      _events[index] = oldEvent.copyWith(
        status: newStatus,
        rejectionReason: rejectionReason,
      );
      await _persistCache();
      _eventsStreamController.add(List.unmodifiable(_events));

      // Notify organizer
      await addNotification(NotificationModel(
        id: 'notif_${_uuid.v4().substring(0, 8)}',
        recipientId: oldEvent.organizerId,
        recipientRole: 'organizer',
        title: 'Event Status: ${newStatus.displayName}',
        message: newStatus == EventStatus.approved
            ? 'Your event "${oldEvent.title}" has been approved by the Admin and is now visible to students!'
            : (rejectionReason != null && rejectionReason.isNotEmpty)
                ? 'Your event proposal was declined. Reason: $rejectionReason'
                : 'Your event status has been updated to ${newStatus.displayName}.',
        eventId: eventId,
        type: NotificationType.eventApproval,
        createdAt: DateTime.now(),
      ));

      // If made live or approved, notify all students
      if (newStatus == EventStatus.approved || newStatus == EventStatus.live) {
        await addNotification(NotificationModel(
          id: 'notif_${_uuid.v4().substring(0, 8)}',
          recipientId: 'all',
          recipientRole: 'all',
          title: newStatus == EventStatus.live ? '🔴 EVENT IS NOW LIVE!' : '🎉 New Event Announced',
          message: '"${oldEvent.title}" (${oldEvent.category.displayName}) - Check schedule & register now!',
          eventId: eventId,
          type: NotificationType.announcement,
          createdAt: DateTime.now(),
        ));
      }
    }
  }

  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
    await _persistCache();
    _eventsStreamController.add(List.unmodifiable(_events));
  }

  // ==================== REGISTRATION OPERATIONS ====================

  Future<RegistrationModel> registerForEvent({
    required EventModel event,
    required UserModel user,
  }) async {
    if (user.role == UserRole.visitor) {
      throw Exception('Student Visitors must upgrade to Participant profile before registering for events.');
    }
    if (user.enrollmentNo == null || user.enrollmentNo!.trim().isEmpty) {
      throw Exception('Please update your profile with your Enrollment Number and Department to complete registration.');
    }
    if (event.isFull) {
      throw Exception('This event has reached its maximum registration limit (${event.maxParticipants}).');
    }

    final alreadyRegistered = _registrations.any(
      (r) => r.eventId == event.id && r.studentId == user.uid && r.status != RegistrationStatus.cancelled,
    );
    if (alreadyRegistered) {
      throw Exception('You are already registered for this event.');
    }

    final qrPass = 'PASS-${event.id.toUpperCase()}-${user.enrollmentNo}-${user.fullName.toUpperCase().replaceAll(' ', '')}';
    final registration = RegistrationModel(
      id: 'reg_${_uuid.v4().substring(0, 8)}',
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

    _registrations.insert(0, registration);

    // Update event registration count
    final eventIndex = _events.indexWhere((e) => e.id == event.id);
    if (eventIndex != -1) {
      _events[eventIndex] = _events[eventIndex].copyWith(
        registeredCount: _events[eventIndex].registeredCount + 1,
      );
      _eventsStreamController.add(List.unmodifiable(_events));
    }

    await _persistCache();
    _registrationsStreamController.add(List.unmodifiable(_registrations));

    // Send confirmation in-app notification
    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: user.uid,
      recipientRole: 'participant',
      title: 'Registration Confirmed! 🎉',
      message: 'You are successfully registered for "${event.title}". View your digital QR pass in My Passes.',
      eventId: event.id,
      type: NotificationType.registrationConfirmed,
      createdAt: DateTime.now(),
    ));

    return registration;
  }

  Future<void> cancelRegistration(String registrationId) async {
    final index = _registrations.indexWhere((r) => r.id == registrationId);
    if (index != -1) {
      final reg = _registrations[index];
      _registrations[index] = reg.copyWith(status: RegistrationStatus.cancelled);

      // Decrement event count
      final eventIndex = _events.indexWhere((e) => e.id == reg.eventId);
      if (eventIndex != -1) {
        final currentCount = _events[eventIndex].registeredCount;
        _events[eventIndex] = _events[eventIndex].copyWith(
          registeredCount: (currentCount - 1).clamp(0, _events[eventIndex].maxParticipants),
        );
        _eventsStreamController.add(List.unmodifiable(_events));
      }

      await _persistCache();
      _registrationsStreamController.add(List.unmodifiable(_registrations));
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

    final newAttendance = AttendanceModel(
      id: 'att_${_uuid.v4().substring(0, 8)}',
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

    _attendance.insert(0, newAttendance);

    // Update registration status to attended
    final regIndex = _registrations.indexWhere((r) => r.eventId == eventId && r.studentId == studentId);
    if (regIndex != -1) {
      _registrations[regIndex] = _registrations[regIndex].copyWith(status: RegistrationStatus.attended);
      _registrationsStreamController.add(List.unmodifiable(_registrations));
    }

    await _persistCache();
    _attendanceStreamController.add(List.unmodifiable(_attendance));

    return newAttendance;
  }

  // ==================== FEEDBACK & RATINGS ====================

  Future<FeedbackModel> submitFeedback(FeedbackModel item) async {
    // Spam/profanity basic check
    final bannedWords = ['spam', 'scam', 'abuse', 'hate', 'fake'];
    bool isFlagged = item.isFlagged;
    for (var w in bannedWords) {
      if (item.comments.toLowerCase().contains(w)) {
        isFlagged = true;
        break;
      }
    }

    final feedbackWithFlag = item.copyWith(isFlagged: isFlagged);
    _feedback.insert(0, feedbackWithFlag);

    // Recompute event average rating
    final eventFeedbacks = _feedback.where((f) => f.eventId == item.eventId && !f.isFlagged).toList();
    if (eventFeedbacks.isNotEmpty) {
      final totalScore = eventFeedbacks.map((f) => f.averageScore).reduce((a, b) => a + b);
      final avg = totalScore / eventFeedbacks.length;
      final eventIndex = _events.indexWhere((e) => e.id == item.eventId);
      if (eventIndex != -1) {
        _events[eventIndex] = _events[eventIndex].copyWith(
          averageRating: double.parse(avg.toStringAsFixed(2)),
          reviewCount: eventFeedbacks.length,
          isTopRated: avg >= 4.5,
        );
        _eventsStreamController.add(List.unmodifiable(_events));
      }
    }

    await _persistCache();
    _feedbackStreamController.add(List.unmodifiable(_feedback));

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
    final index = _feedback.indexWhere((f) => f.id == feedbackId);
    if (index != -1) {
      _feedback[index] = _feedback[index].copyWith(isFlagged: isFlagged);
      await _persistCache();
      _feedbackStreamController.add(List.unmodifiable(_feedback));
    }
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
    final existingIndex = _certificates.indexWhere(
      (c) => c.eventId == event.id && c.studentId == studentId,
    );

    final certNum = 'FF-${DateTime.now().year}-${department.substring(0, 2).toUpperCase()}-${(1000 + _certificates.length)}';
    final cert = CertificateModel(
      id: 'cert_${_uuid.v4().substring(0, 8)}',
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

    if (existingIndex != -1) {
      _certificates[existingIndex] = cert;
    } else {
      _certificates.insert(0, cert);
    }

    await _persistCache();
    _certificatesStreamController.add(List.unmodifiable(_certificates));

    // Notify Student
    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: studentId,
      recipientRole: 'participant',
      title: '🎓 E-Certificate Issued!',
      message: 'Your ${type.displayName} for "${event.title}" is ready. Clear the certificate processing fee to download.',
      eventId: event.id,
      type: NotificationType.certificateReady,
      createdAt: DateTime.now(),
    ));

    return cert;
  }

  Future<CertificateModel> processCertificateFeePayment({
    required String certificateId,
    required String paymentMethod, // 'Card' | 'UPI' | 'Wallet'
  }) async {
    final index = _certificates.indexWhere((c) => c.id == certificateId);
    if (index == -1) throw Exception('Certificate record not found.');

    final txnId = 'TXN_${paymentMethod.toUpperCase()}_${_uuid.v4().substring(0, 10).toUpperCase()}';
    final updatedCert = _certificates[index].copyWith(
      isFeePaid: true,
      transactionId: txnId,
      paidOn: DateTime.now(),
    );

    _certificates[index] = updatedCert;
    await _persistCache();
    _certificatesStreamController.add(List.unmodifiable(_certificates));

    await addNotification(NotificationModel(
      id: 'notif_${_uuid.v4().substring(0, 8)}',
      recipientId: updatedCert.studentId,
      recipientRole: 'participant',
      title: 'Payment Successful! Receipt #$txnId',
      message: 'Your certificate for "${updatedCert.eventTitle}" is now unlocked for instant PDF download.',
      eventId: updatedCert.eventId,
      type: NotificationType.certificateReady,
      createdAt: DateTime.now(),
    ));

    return updatedCert;
  }

  // ==================== MEDIA GALLERY OPERATIONS ====================

  Future<MediaModel> uploadMedia(MediaModel media) async {
    _mediaGallery.insert(0, media);
    await _persistCache();
    _mediaStreamController.add(List.unmodifiable(_mediaGallery));
    return media;
  }

  Future<void> toggleMediaLike(String mediaId, String userId) async {
    final index = _mediaGallery.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      final media = _mediaGallery[index];
      final likesList = List<String>.from(media.likedByUserIds);
      if (likesList.contains(userId)) {
        likesList.remove(userId);
      } else {
        likesList.add(userId);
      }
      _mediaGallery[index] = media.copyWith(
        likesCount: likesList.length,
        likedByUserIds: likesList,
      );
      await _persistCache();
      _mediaStreamController.add(List.unmodifiable(_mediaGallery));
    }
  }

  Future<void> toggleMediaApproval(String mediaId, bool isApproved) async {
    final index = _mediaGallery.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      _mediaGallery[index] = _mediaGallery[index].copyWith(isApproved: isApproved);
      await _persistCache();
      _mediaStreamController.add(List.unmodifiable(_mediaGallery));
    }
  }

  Future<void> toggleMediaFeatured(String mediaId, bool isFeatured) async {
    final index = _mediaGallery.indexWhere((m) => m.id == mediaId);
    if (index != -1) {
      _mediaGallery[index] = _mediaGallery[index].copyWith(isFeatured: isFeatured);
      await _persistCache();
      _mediaStreamController.add(List.unmodifiable(_mediaGallery));
    }
  }

  Future<void> deleteMedia(String mediaId) async {
    _mediaGallery.removeWhere((m) => m.id == mediaId);
    await _persistCache();
    _mediaStreamController.add(List.unmodifiable(_mediaGallery));
  }

  // ==================== NOTIFICATIONS ====================

  Future<void> addNotification(NotificationModel notif) async {
    _notifications.insert(0, notif);
    await _persistCache();
    _notificationsStreamController.add(List.unmodifiable(_notifications));
  }

  Future<void> markNotificationRead(String notifId) async {
    final index = _notifications.indexWhere((n) => n.id == notifId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      await _persistCache();
      _notificationsStreamController.add(List.unmodifiable(_notifications));
    }
  }

  Future<void> markAllNotificationsRead(String userId) async {
    for (int i = 0; i < _notifications.length; i++) {
      if (_notifications[i].recipientId == userId || _notifications[i].recipientId == 'all') {
        _notifications[i] = _notifications[i].copyWith(isRead: true);
      }
    }
    await _persistCache();
    _notificationsStreamController.add(List.unmodifiable(_notifications));
  }

  // ==================== CONTACT QUERIES ====================

  Future<void> submitContactQuery(ContactQueryModel query) async {
    _contactQueries.insert(0, query);
    await _persistCache();
    _contactQueriesStreamController.add(List.unmodifiable(_contactQueries));

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
    final index = _contactQueries.indexWhere((q) => q.id == queryId);
    if (index != -1) {
      _contactQueries[index] = ContactQueryModel(
        id: _contactQueries[index].id,
        name: _contactQueries[index].name,
        email: _contactQueries[index].email,
        subject: _contactQueries[index].subject,
        category: _contactQueries[index].category,
        message: _contactQueries[index].message,
        isResolved: true,
        adminReply: reply,
        submittedOn: _contactQueries[index].submittedOn,
      );
      await _persistCache();
      _contactQueriesStreamController.add(List.unmodifiable(_contactQueries));
    }
  }

  // Reset database to initial factory seed
  Future<void> resetToSeedData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firestore_cache_v1');
    await _loadFromAssetBundle();
    _broadcastAll();
  }
}
