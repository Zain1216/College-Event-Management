enum MediaType {
  image,
  video,
}

class MediaModel {
  final String id;
  final String eventId;
  final String eventTitle;
  final MediaType mediaType;
  final String mediaUrl;
  final String? thumbnailUrl;
  final String caption;
  final String category;
  final String department;
  final String uploadedBy;
  final String uploaderName;
  final bool isApproved;
  final bool isFeatured;
  final int likesCount;
  final List<String> likedByUserIds;
  final DateTime uploadedOn;

  MediaModel({
    required this.id,
    required this.eventId,
    required this.eventTitle,
    this.mediaType = MediaType.image,
    required this.mediaUrl,
    this.thumbnailUrl,
    required this.caption,
    this.category = 'Technical',
    this.department = 'Computer Science',
    required this.uploadedBy,
    required this.uploaderName,
    this.isApproved = true,
    this.isFeatured = false,
    this.likesCount = 0,
    this.likedByUserIds = const [],
    required this.uploadedOn,
  });

  MediaModel copyWith({
    String? id,
    String? eventId,
    String? eventTitle,
    MediaType? mediaType,
    String? mediaUrl,
    String? thumbnailUrl,
    String? caption,
    String? category,
    String? department,
    String? uploadedBy,
    String? uploaderName,
    bool? isApproved,
    bool? isFeatured,
    int? likesCount,
    List<String>? likedByUserIds,
    DateTime? uploadedOn,
  }) {
    return MediaModel(
      id: id ?? this.id,
      eventId: eventId ?? this.eventId,
      eventTitle: eventTitle ?? this.eventTitle,
      mediaType: mediaType ?? this.mediaType,
      mediaUrl: mediaUrl ?? this.mediaUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      caption: caption ?? this.caption,
      category: category ?? this.category,
      department: department ?? this.department,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploaderName: uploaderName ?? this.uploaderName,
      isApproved: isApproved ?? this.isApproved,
      isFeatured: isFeatured ?? this.isFeatured,
      likesCount: likesCount ?? this.likesCount,
      likedByUserIds: likedByUserIds ?? this.likedByUserIds,
      uploadedOn: uploadedOn ?? this.uploadedOn,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'mediaType': mediaType.name,
      'mediaUrl': mediaUrl,
      'thumbnailUrl': thumbnailUrl,
      'caption': caption,
      'category': category,
      'department': department,
      'uploadedBy': uploadedBy,
      'uploaderName': uploaderName,
      'isApproved': isApproved,
      'isFeatured': isFeatured,
      'likesCount': likesCount,
      'likedByUserIds': likedByUserIds,
      'uploadedOn': uploadedOn.toIso8601String(),
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

  factory MediaModel.fromMap(Map<String, dynamic> map) {
    return MediaModel(
      id: map['id'] as String? ?? '',
      eventId: map['eventId'] as String? ?? '',
      eventTitle: map['eventTitle'] as String? ?? '',
      mediaType: (map['mediaType'] == 'video') ? MediaType.video : MediaType.image,
      mediaUrl: map['mediaUrl'] as String? ?? '',
      thumbnailUrl: map['thumbnailUrl'] as String?,
      caption: map['caption'] as String? ?? '',
      category: map['category'] as String? ?? 'Technical',
      department: map['department'] as String? ?? 'Computer Science',
      uploadedBy: map['uploadedBy'] as String? ?? '',
      uploaderName: map['uploaderName'] as String? ?? 'Organizer',
      isApproved: map['isApproved'] as bool? ?? true,
      isFeatured: map['isFeatured'] as bool? ?? false,
      likesCount: (map['likesCount'] as num?)?.toInt() ?? 0,
      likedByUserIds: (map['likedByUserIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      uploadedOn: _parseDate(map['uploadedOn']),
    );
  }
}
