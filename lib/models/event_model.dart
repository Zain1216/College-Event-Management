enum EventCategory {
  technical,
  cultural,
  sports,
  seminar,
  workshop,
}

extension EventCategoryExtension on EventCategory {
  String get displayName {
    switch (this) {
      case EventCategory.technical:
        return 'Technical';
      case EventCategory.cultural:
        return 'Cultural';
      case EventCategory.sports:
        return 'Sports';
      case EventCategory.seminar:
        return 'Seminar';
      case EventCategory.workshop:
        return 'Workshop';
    }
  }

  static EventCategory fromString(String cat) {
    switch (cat.toLowerCase()) {
      case 'cultural':
        return EventCategory.cultural;
      case 'sports':
        return EventCategory.sports;
      case 'seminar':
        return EventCategory.seminar;
      case 'workshop':
        return EventCategory.workshop;
      case 'technical':
      default:
        return EventCategory.technical;
    }
  }
}

enum EventStatus {
  pending,
  approved,
  live,
  completed,
  cancelled,
}

extension EventStatusExtension on EventStatus {
  String get displayName {
    switch (this) {
      case EventStatus.pending:
        return 'Pending Approval';
      case EventStatus.approved:
        return 'Upcoming';
      case EventStatus.live:
        return 'Live Now';
      case EventStatus.completed:
        return 'Completed';
      case EventStatus.cancelled:
        return 'Cancelled';
    }
  }

  static EventStatus fromString(String st) {
    switch (st.toLowerCase()) {
      case 'pending':
        return EventStatus.pending;
      case 'approved':
      case 'upcoming':
        return EventStatus.approved;
      case 'live':
        return EventStatus.live;
      case 'completed':
        return EventStatus.completed;
      case 'cancelled':
        return EventStatus.cancelled;
      default:
        return EventStatus.pending;
    }
  }
}

class EventWinner {
  final int rank; // 1, 2, 3
  final String studentId;
  final String studentName;
  final String prizeTitle;

  EventWinner({
    required this.rank,
    required this.studentId,
    required this.studentName,
    required this.prizeTitle,
  });

  Map<String, dynamic> toMap() => {
        'rank': rank,
        'studentId': studentId,
        'studentName': studentName,
        'prizeTitle': prizeTitle,
      };

  factory EventWinner.fromMap(Map<String, dynamic> map) => EventWinner(
        rank: map['rank'] as int? ?? 1,
        studentId: map['studentId'] as String? ?? '',
        studentName: map['studentName'] as String? ?? '',
        prizeTitle: map['prizeTitle'] as String? ?? '',
      );
}

class EventModel {
  final String id;
  final String title;
  final String description;
  final EventCategory category;
  final String department;
  final DateTime date;
  final String time;
  final String venue;
  final double latitude;
  final double longitude;
  final EventStatus status;
  final String organizerId;
  final String organizerName;
  final String organizerEmail;
  final String organizerPhone;
  final int maxParticipants;
  final int registeredCount;
  final String bannerUrl;
  final String? guidelinesPdfUrl;
  final List<String> coOrganizers;
  final List<String> volunteers;
  final List<String> tags;
  final double averageRating;
  final int reviewCount;
  final bool isTopRated;
  final String? rejectionReason;
  final List<EventWinner> winners;
  final double certificateFee;
  final DateTime createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.department,
    required this.date,
    required this.time,
    required this.venue,
    this.latitude = 12.9716,
    this.longitude = 77.5946,
    required this.status,
    required this.organizerId,
    required this.organizerName,
    this.organizerEmail = '',
    this.organizerPhone = '',
    required this.maxParticipants,
    this.registeredCount = 0,
    required this.bannerUrl,
    this.guidelinesPdfUrl,
    this.coOrganizers = const [],
    this.volunteers = const [],
    this.tags = const [],
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.isTopRated = false,
    this.rejectionReason,
    this.winners = const [],
    this.certificateFee = 50.0,
    required this.createdAt,
  });

  int get availableSlots => (maxParticipants - registeredCount).clamp(0, maxParticipants);
  bool get isFull => registeredCount >= maxParticipants;

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    EventCategory? category,
    String? department,
    DateTime? date,
    String? time,
    String? venue,
    double? latitude,
    double? longitude,
    EventStatus? status,
    String? organizerId,
    String? organizerName,
    String? organizerEmail,
    String? organizerPhone,
    int? maxParticipants,
    int? registeredCount,
    String? bannerUrl,
    String? guidelinesPdfUrl,
    List<String>? coOrganizers,
    List<String>? volunteers,
    List<String>? tags,
    double? averageRating,
    int? reviewCount,
    bool? isTopRated,
    String? rejectionReason,
    List<EventWinner>? winners,
    double? certificateFee,
    DateTime? createdAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      department: department ?? this.department,
      date: date ?? this.date,
      time: time ?? this.time,
      venue: venue ?? this.venue,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      organizerId: organizerId ?? this.organizerId,
      organizerName: organizerName ?? this.organizerName,
      organizerEmail: organizerEmail ?? this.organizerEmail,
      organizerPhone: organizerPhone ?? this.organizerPhone,
      maxParticipants: maxParticipants ?? this.maxParticipants,
      registeredCount: registeredCount ?? this.registeredCount,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      guidelinesPdfUrl: guidelinesPdfUrl ?? this.guidelinesPdfUrl,
      coOrganizers: coOrganizers ?? this.coOrganizers,
      volunteers: volunteers ?? this.volunteers,
      tags: tags ?? this.tags,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      isTopRated: isTopRated ?? this.isTopRated,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      winners: winners ?? this.winners,
      certificateFee: certificateFee ?? this.certificateFee,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.displayName,
      'department': department,
      'date': date.toIso8601String(),
      'time': time,
      'venue': venue,
      'latitude': latitude,
      'longitude': longitude,
      'status': status.name,
      'organizerId': organizerId,
      'organizerName': organizerName,
      'organizerEmail': organizerEmail,
      'organizerPhone': organizerPhone,
      'maxParticipants': maxParticipants,
      'registeredCount': registeredCount,
      'bannerUrl': bannerUrl,
      'guidelinesPdfUrl': guidelinesPdfUrl,
      'coOrganizers': coOrganizers,
      'volunteers': volunteers,
      'tags': tags,
      'averageRating': averageRating,
      'reviewCount': reviewCount,
      'isTopRated': isTopRated,
      'rejectionReason': rejectionReason,
      'winners': winners.map((w) => w.toMap()).toList(),
      'certificateFee': certificateFee,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory EventModel.fromMap(Map<String, dynamic> map) {
    return EventModel(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      category: EventCategoryExtension.fromString(map['category'] as String? ?? 'Technical'),
      department: map['department'] as String? ?? 'Computer Science',
      date: map['date'] != null
          ? DateTime.tryParse(map['date'].toString()) ?? DateTime.now().add(const Duration(days: 3))
          : DateTime.now().add(const Duration(days: 3)),
      time: map['time'] as String? ?? '10:00 AM',
      venue: map['venue'] as String? ?? 'Main Auditorium',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 12.9716,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 77.5946,
      status: EventStatusExtension.fromString(map['status'] as String? ?? 'approved'),
      organizerId: map['organizerId'] as String? ?? '',
      organizerName: map['organizerName'] as String? ?? '',
      organizerEmail: map['organizerEmail'] as String? ?? '',
      organizerPhone: map['organizerPhone'] as String? ?? '',
      maxParticipants: (map['maxParticipants'] as num?)?.toInt() ?? 100,
      registeredCount: (map['registeredCount'] as num?)?.toInt() ?? 0,
      bannerUrl: map['bannerUrl'] as String? ?? '',
      guidelinesPdfUrl: map['guidelinesPdfUrl'] as String?,
      coOrganizers: (map['coOrganizers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      volunteers: (map['volunteers'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      tags: (map['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: (map['reviewCount'] as num?)?.toInt() ?? 0,
      isTopRated: map['isTopRated'] as bool? ?? false,
      rejectionReason: map['rejectionReason'] as String?,
      winners: (map['winners'] as List<dynamic>?)
              ?.map((e) => EventWinner.fromMap(e as Map<String, dynamic>))
              .toList() ??
          [],
      certificateFee: (map['certificateFee'] as num?)?.toDouble() ?? 50.0,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
