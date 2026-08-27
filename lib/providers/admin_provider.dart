import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../models/event_model.dart';
import '../models/contact_model.dart';
import '../services/firebase_datastore.dart';
import '../services/report_export_service.dart';

class AdminProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<UserModel> _users = [];
  List<ContactQueryModel> _contactQueries = [];
  int _simulatedFailedLogins = 3; // For security alert monitor in SRS

  StreamSubscription? _userSub;
  StreamSubscription? _querySub;

  AdminProvider() {
    _init();
  }

  void _init() {
    _users = _dataStore.users;
    _contactQueries = _dataStore.contactQueries;

    _userSub = _dataStore.usersStream.listen((list) {
      _users = list;
      notifyListeners();
    });

    _querySub = _dataStore.contactQueriesStream.listen((list) {
      _contactQueries = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _userSub?.cancel();
    _querySub?.cancel();
    super.dispose();
  }

  List<UserModel> get allUsers => _users;
  List<ContactQueryModel> get allQueries => _contactQueries;
  int get simulatedFailedLogins => _simulatedFailedLogins;

  List<UserModel> get pendingStaffApprovals =>
      _users.where((u) => (u.role == UserRole.organizer || u.role == UserRole.admin) && !u.isApproved).toList();

  int get totalActiveUsers => _users.where((u) => u.isActive).length;

  // Department-wise stats computation
  Map<String, int> get departmentEventCounts {
    final Map<String, int> counts = {};
    for (var e in _dataStore.events) {
      counts[e.department] = (counts[e.department] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> get departmentParticipantCounts {
    final Map<String, int> counts = {};
    for (var r in _dataStore.registrations) {
      counts[r.department] = (counts[r.department] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> toggleUserApproval(String uid, bool isApproved) async {
    await _dataStore.toggleUserApproval(uid, isApproved);
  }

  Future<void> toggleUserActive(String uid, bool isActive) async {
    await _dataStore.toggleUserActive(uid, isActive);
  }

  Future<void> changeUserRole(String uid, UserRole newRole) async {
    await _dataStore.updateUserRole(uid, newRole);
  }

  Future<void> replyToQuery(String queryId, String reply) async {
    await _dataStore.replyToContactQuery(queryId, reply);
  }

  Future<void> submitContactQuery({
    required String name,
    required String email,
    required String subject,
    required String category,
    required String message,
  }) async {
    final query = ContactQueryModel(
      id: 'query_${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim(),
      subject: subject.trim(),
      category: category,
      message: message.trim(),
      submittedOn: DateTime.now(),
    );
    await _dataStore.submitContactQuery(query);
  }

  /// Export PDF Report
  Future<void> exportPdfReport({String department = 'All'}) async {
    await ReportExportService.exportPdfReport(
      events: _dataStore.events,
      registrations: _dataStore.registrations,
      certificates: _dataStore.certificates,
      feedbacks: _dataStore.feedback,
      filterDepartment: department,
    );
  }

  /// Export Excel Report bytes
  Uint8List exportExcelReport() {
    return ReportExportService.generateExcelReport(
      events: _dataStore.events,
      registrations: _dataStore.registrations,
      certificates: _dataStore.certificates,
      feedbacks: _dataStore.feedback,
    );
  }

  /// Reset Database to Factory Seed Data
  Future<void> resetDatabase() async {
    await _dataStore.resetToSeedData();
    notifyListeners();
  }
}
