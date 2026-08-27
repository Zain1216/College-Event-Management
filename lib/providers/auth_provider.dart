import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../models/notification_model.dart';
import '../services/firebase_datastore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null && _auth.currentUser != null;
  UserRole get currentRole => _currentUser?.role ?? UserRole.visitor;
  bool get isVisitor => _currentUser?.role == UserRole.visitor;
  bool get isParticipant => _currentUser?.role == UserRole.participant;
  bool get isOrganizer => _currentUser?.role == UserRole.organizer;
  bool get isAdmin => _currentUser?.role == UserRole.admin;

  StreamSubscription<User?>? _authStateSub;
  StreamSubscription? _usersSub;

  AuthProvider() {
    _initAuth();
  }

  Future<void> _initAuth() async {
    _isLoading = true;
    notifyListeners();

    await _dataStore.initialize();

    // Listen to user collection updates in Firestore to keep currentUser in sync
    _usersSub = _dataStore.usersStream.listen((users) {
      if (_currentUser != null) {
        try {
          final updated = users.firstWhere((u) => u.uid == _currentUser!.uid);
          _currentUser = updated;
          notifyListeners();
        } catch (_) {}
      }
    });

    // Listen to real Firebase Authentication state changes
    _authStateSub = _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser == null) {
        _currentUser = null;
        _isLoading = false;
        notifyListeners();
      } else {
        await _loadUserProfile(firebaseUser.uid);
      }
    });
  }

  Future<void> _loadUserProfile(String uid) async {
    try {
      final user = await _dataStore.getUserById(uid);
      if (user != null) {
        _currentUser = user;
      }
    } catch (_) {}
    _isLoading = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _authStateSub?.cancel();
    _usersSub?.cancel();
    super.dispose();
  }

  /// Real Firebase Email & Password Sign In
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final uid = cred.user!.uid;
      final user = await _dataStore.getUserById(uid);

      if (user != null) {
        if (!user.isActive) {
          await _auth.signOut();
          _currentUser = null;
          _errorMessage = 'This account has been deactivated by an administrator.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        if ((user.role == UserRole.organizer || user.role == UserRole.admin) && !user.isApproved) {
          await _auth.signOut();
          _currentUser = null;
          _errorMessage = 'Staff account is pending administrative approval.';
          _isLoading = false;
          notifyListeners();
          return false;
        }

        _currentUser = user;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Real Firebase Account Registration
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
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      final isStaff = role == UserRole.organizer || role == UserRole.admin;
      final newUser = UserModel(
        uid: cred.user!.uid,
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

      await _dataStore.saveUser(newUser);

      if (isStaff) {
        // Send notification to Admin role
        await _dataStore.addNotification(NotificationModel(
          id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
          recipientId: 'role:admin',
          recipientRole: 'admin',
          title: 'New Staff Registration Pending',
          message: '${newUser.fullName} (${newUser.email}) registered as ${newUser.role.displayName}. Awaiting admin approval.',
          type: NotificationType.eventApproval,
          createdAt: DateTime.now(),
        ));

        // Sign out unapproved staff so they must wait for admin verification
        await _auth.signOut();
        _currentUser = null;
      } else {
        _currentUser = newUser;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _parseAuthError(e);
      _isLoading = false;
      notifyListeners();
      return false;
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

  /// Request Real Firebase Password Reset Email
  Future<String> requestPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return 'A secure password reset link has been sent to $email. Please check your inbox.';
    } on FirebaseAuthException catch (e) {
      throw Exception(_parseAuthError(e));
    }
  }

  /// Real Password Update
  Future<void> changePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw Exception(_parseAuthError(e));
    }
  }

  /// Bookmark toggle
  Future<void> toggleBookmark(String eventId) async {
    if (_currentUser == null) return;
    await _dataStore.toggleBookmark(_currentUser!.uid, eventId);
  }

  /// Real Firebase Sign Out
  Future<void> logout() async {
    await _auth.signOut();
    _currentUser = null;
    notifyListeners();
  }

  static String _parseAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with that email address.';
      case 'wrong-password':
        return 'Incorrect password entered.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please wait a moment and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return e.message ?? 'Authentication error occurred.';
    }
  }
}
