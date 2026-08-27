class FeedbackModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final String studentId;
  final String studentName;
  final int organizationRating; // 1 - 5
  final int relevanceRating;    // 1 - 5
  final int coordinationRating; // 1 - 5
  final int overallRating;      // 1 - 5
  final String comments;
  final bool isFlagged;
  final DateTime submittedOn;

  FeedbackModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    required this.studentId,
    required this.studentName,
    required this.organizationRating,
    required this.relevanceRating,
    required this.coordinationRating,
    required this.overallRating,
    this.comments = '',
    this.isFlagged = false,
    required this.submittedOn,
  });

  double get averageScore =>
      (organizationRating + relevanceRating + coordinationRating + overallRating) / 4.0;

  FeedbackModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    String? studentId,
    String? studentName,
    int? organizationRating,
    int? relevanceRating,
    int? coordinationRating,
    int? overallRating,
    String? comments,
    bool? isFlagged,
    DateTime? submittedOn,
  }) {
    return FeedbackModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      organizationRating: organizationRating ?? this.organizationRating,
      relevanceRating: relevanceRating ?? this.relevanceRating,
      coordinationRating: coordinationRating ?? this.coordinationRating,
      overallRating: overallRating ?? this.overallRating,
      comments: comments ?? this.comments,
      isFlagged: isFlagged ?? this.isFlagged,
      submittedOn: submittedOn ?? this.submittedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'studentId': studentId,
      'studentName': studentName,
      'organizationRating': organizationRating,
      'relevanceRating': relevanceRating,
      'coordinationRating': coordinationRating,
      'overallRating': overallRating,
      'averageScore': averageScore,
      'comments': comments,
      'isFlagged': isFlagged,
      'submittedOn': submittedOn.toIso8601String(),
    };
  }

  static DateTime _parseDate(dynamic val) {
    if (val == null) return DateTime.now();
    if (val is DateTime) return val;
    try {
      if (val.runtimeType.toString() == 'Timestamp') {
        return (val as dynamic).toDate() as DateTime;
      }
    } catch (_) {}
    return DateTime.tryParse(val.toString()) ?? DateTime.now();
  }

  factory FeedbackModel.fromMap(Map<String, dynamic> map) {
    return FeedbackModel(
      id: map['id'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      studentId: map['studentId'] as String? ?? '',
      studentName: map['studentName'] as String? ?? '',
      organizationRating: (map['organizationRating'] as num?)?.toInt() ?? 5,
      relevanceRating: (map['relevanceRating'] as num?)?.toInt() ?? 5,
      coordinationRating: (map['coordinationRating'] as num?)?.toInt() ?? 5,
      overallRating: (map['overallRating'] as num?)?.toInt() ?? 5,
      comments: map['comments'] as String? ?? '',
      isFlagged: map['isFlagged'] as bool? ?? false,
      submittedOn: _parseDate(map['submittedOn']),
    );
  }
}
