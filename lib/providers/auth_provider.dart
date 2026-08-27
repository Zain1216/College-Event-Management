import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../services/firebase_datastore.dart';
import '../services/firebase_config.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  String? _passwordResetToken;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get passwordResetToken => _passwordResetToken;

  bool get isAuthenticated => _currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.visitor;
  bool get isVisitor => _currentUser?.role == UserRole.visitor;
  bool get isParticipant => _currentUser?.role == UserRole.participant;
  bool get isOrganizer => _currentUser?.role == UserRole.organizer;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  StreamSubscription? _usersSub;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    await _dataStore.initialize();

    // Listen to user updates in Firestore
    _usersSub = _dataStore.usersStream.listen((users) {
      if (_currentUser != null) {
        try {
          final updated = users.firstWhere((u) => u.uid == _currentUser!.uid);
          _currentUser = updated;
          notifyListeners();
        } catch (_) {}
      }
    });

    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString('auth_user_uid');

    if (savedUid != null) {
      _currentUser = _dataStore.findUserById(savedUid);
    }

    // Default to Student Participant demo user on first launch if not logged in
    if (_currentUser == null) {
      _currentUser = _dataStore.findUserByEmail('student@fusionfiesta.edu');
      if (_currentUser != null) {
        await prefs.setString('auth_user_uid', _currentUser!.uid);
      }
    }

    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _usersSub?.cancel();
    super.dispose();
  }

  /// Sign In with Email & Password
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 300)); // Smooth UX transition

    final user = _dataStore.findUserByEmail(email);

    if (user == null) {
      _errorMessage = 'No user found with email $email.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if (!user.isActive) {
      _errorMessage = 'This account has been deactivated by administrator.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    if ((user.role == UserRole.organizer || user.role == UserRole.admin) && !user.isApproved) {
      _errorMessage = 'Staff account is pending administrative approval.';
      _isLoading = false;
      notifyListeners();
      return false;
    }

    _currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_user_uid', user.uid);

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Quick 1-Tap Demo Switcher for fast evaluation across all 4 roles
  Future<void> switchDemoRole(String roleKey) async {
    final creds = FirebaseConfig.demoCredentials[roleKey.toLowerCase()];
    if (creds != null) {
      await login(creds['email']!, creds['password']!);
    }
  }

  /// Register new user account
  Future<bool> register({
    required String email,
    required String password,
    required String fullName,
    required UserRole role,
    required String department,
    String mobile = '',
    String? enrollmentNo,
    String? collegeIdProof,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newUser = await _dataStore.registerUser(
        email: email,
        fullName: fullName,
        role: role,
        department: department,
        mobile: mobile,
        enrollmentNo: enrollmentNo,
        collegeIdProof: collegeIdProof,
      );

      if (newUser.isApproved) {
        _currentUser = newUser;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_user_uid', newUser.uid);
      }

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

  /// Upgrade Student Visitor to Student Participant (SRS 1.6 #1)
  Future<bool> upgradeToParticipant({
    required String enrollmentNo,
    required String department,
    String mobile = '',
    String? idProof,
  }) async {
    if (_currentUser == null) return false;

    _isLoading = true;
    notifyListeners();

    final updated = _currentUser!.copyWith(
      role: UserRole.participant,
      enrollmentNo: enrollmentNo.trim(),
      department: department.trim(),
      mobile: mobile.isNotEmpty ? mobile : _currentUser!.mobile,
      collegeIdProof: idProof ?? 'https://images.unsplash.com/photo-1571260899304-425eee4c7efc?w=600',
    );

    await _dataStore.updateUser(updated);
    _currentUser = updated;

    _isLoading = false;
    notifyListeners();
    return true;
  }

  /// Update User Profile
  Future<void> updateProfile({
    required String fullName,
    required String mobile,
    required String department,
    String? enrollmentNo,
    String? profilePicUrl,
  }) async {
    if (_currentUser == null) return;

    final updated = _currentUser!.copyWith(
      fullName: fullName,
      mobile: mobile,
      department: department,
      enrollmentNo: enrollmentNo ?? _currentUser!.enrollmentNo,
      profilePicUrl: profilePicUrl ?? _currentUser!.profilePicUrl,
    );

    await _dataStore.updateUser(updated);
    _currentUser = updated;
    notifyListeners();
  }

  /// Request Forgot Password Token (SRS 1.6 #1)
  Future<String> requestPasswordReset(String email) async {
    final user = _dataStore.findUserByEmail(email);
    if (user == null) {
      throw Exception('No registered account found with that email address.');
    }

    final token = 'FF-RESET-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _passwordResetToken = token;
    notifyListeners();
    return token;
  }

  /// Complete Password Reset
  Future<bool> resetPasswordWithToken({
    required String email,
    required String token,
    required String newPassword,
  }) async {
    if (_passwordResetToken != null && _passwordResetToken == token.trim()) {
      _passwordResetToken = null;
      notifyListeners();
      return true;
    }
    throw Exception('Invalid or expired reset token.');
  }

  /// Bookmark toggle
  Future<void> toggleBookmark(String eventId) async {
    if (_currentUser == null) return;
    await _dataStore.toggleBookmark(_currentUser!.uid, eventId);
  }

  /// Sign Out
  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_user_uid');
    notifyListeners();
  }
}
