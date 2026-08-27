import 'dart:async';
import 'package:flutter/foundation.dart';
import '../models/feedback_model.dart';
import '../services/firebase_datastore.dart';

class FeedbackProvider extends ChangeNotifier {
  final FirebaseDataStore _dataStore = FirebaseDataStore();

  List<FeedbackModel> _feedbacks = [];
  bool _isLoading = false;
  String? _errorMessage;

  StreamSubscription? _fbSub;

  FeedbackProvider() {
    _init();
  }

  void _init() {
    _feedbacks = _dataStore.feedback;
    _fbSub = _dataStore.feedbackStream.listen((fbs) {
      _feedbacks = fbs;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _fbSub?.cancel();
    super.dispose();
  }

  List<FeedbackModel> get allFeedbacks => _feedbacks;
  List<FeedbackModel> get flaggedFeedbacks => _feedbacks.where((f) => f.isFlagged).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<FeedbackModel> getFeedbacksForEvent(String eventId) {
    return _feedbacks.where((f) => f.eventId == eventId).toList();
  }

  List<FeedbackModel> getFeedbacksByStudent(String studentId) {
    return _feedbacks.where((f) => f.studentId == studentId).toList();
  }

  bool hasStudentSubmittedFeedback(String eventId, String studentId) {
    return _feedbacks.any((f) => f.eventId == eventId && f.studentId == studentId);
  }

  /// Submit Multi-Criteria Feedback
  Future<bool> submitFeedback({
    required String eventId,
    required String eventTitle,
    required String studentId,
    required String studentName,
    required int organizationRating,
    required int relevanceRating,
    required int coordinationRating,
    required int overallRating,
    required String comments,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final item = FeedbackModel(
        id: 'fb_${DateTime.now().millisecondsSinceEpoch}',
        eventId: eventId,
        eventTitle: eventTitle,
        studentId: studentId,
        studentName: studentName,
        organizationRating: organizationRating,
        relevanceRating: relevanceRating,
        coordinationRating: coordinationRating,
        overallRating: overallRating,
        comments: comments.trim(),
        submittedOn: DateTime.now(),
      );

      await _dataStore.submitFeedback(item);
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

  /// Toggle Flag
  Future<void> toggleFeedbackFlag(String feedbackId, bool isFlagged) async {
    await _dataStore.toggleFeedbackFlag(feedbackId, isFlagged);
  }
}
