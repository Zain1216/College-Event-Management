enum UserRole {
  visitor,
  participant,
  organizer,
  admin,
}

extension UserRoleExtension on UserRole {
  String get displayName {
    switch (this) {
      case UserRole.visitor:
        return 'Student Visitor';
      case UserRole.participant:
        return 'Student Participant';
      case UserRole.organizer:
        return 'Event Organizer';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  String get key {
    switch (this) {
      case UserRole.visitor:
        return 'visitor';
      case UserRole.participant:
        return 'participant';
      case UserRole.organizer:
        return 'organizer';
      case UserRole.admin:
        return 'admin';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toLowerCase()) {
      case 'participant':
        return UserRole.participant;
      case 'organizer':
        return UserRole.organizer;
      case 'admin':
        return UserRole.admin;
      case 'visitor':
      default:
        return UserRole.visitor;
    }
  }
}

class UserModel {
  final String uid;
  final String email;
  final String fullName;
  final UserRole role;
  final String department;
  final String mobile;
  final String? enrollmentNo;
  final String? collegeIdProof; // URL or document ref
  final String? profilePicUrl;
  final bool isApproved; // For Staff / Organizers
  final bool isActive;
  final DateTime createdAt;
  final List<String> bookmarkedEventIds;

  UserModel({
    required this.uid,
    required this.email,
    required this.fullName,
    required this.role,
    this.department = 'General',
    this.mobile = '',
    this.enrollmentNo,
    this.collegeIdProof,
    this.profilePicUrl,
    this.isApproved = true,
    this.isActive = true,
    required this.createdAt,
    this.bookmarkedEventIds = const [],
  });

  bool get isStudent => role == UserRole.visitor || role == UserRole.participant;
  bool get isVerifiedParticipant => role == UserRole.participant && (enrollmentNo != null && enrollmentNo!.isNotEmpty);
  bool get isStaff => role == UserRole.organizer || role == UserRole.admin;

  UserModel copyWith({
    String? uid,
    String? email,
    String? fullName,
    UserRole? role,
    String? department,
    String? mobile,
    String? enrollmentNo,
    String? collegeIdProof,
    String? profilePicUrl,
    bool? isApproved,
    bool? isActive,
    DateTime? createdAt,
    List<String>? bookmarkedEventIds,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      department: department ?? this.department,
      mobile: mobile ?? this.mobile,
      enrollmentNo: enrollmentNo ?? this.enrollmentNo,
      collegeIdProof: collegeIdProof ?? this.collegeIdProof,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      isApproved: isApproved ?? this.isApproved,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      bookmarkedEventIds: bookmarkedEventIds ?? this.bookmarkedEventIds,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'role': role.key,
      'department': department,
      'mobile': mobile,
      'enrollmentNo': enrollmentNo,
      'collegeIdProof': collegeIdProof,
      'profilePicUrl': profilePicUrl,
      'isApproved': isApproved,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'bookmarkedEventIds': bookmarkedEventIds,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] as String? ?? '',
      email: map['email'] as String? ?? '',
      fullName: map['fullName'] as String? ?? '',
      role: UserRoleExtension.fromString(map['role'] as String? ?? 'visitor'),
      department: map['department'] as String? ?? 'General',
      mobile: map['mobile'] as String? ?? '',
      enrollmentNo: map['enrollmentNo'] as String?,
      collegeIdProof: map['collegeIdProof'] as String?,
      profilePicUrl: map['profilePicUrl'] as String?,
      isApproved: map['isApproved'] as bool? ?? true,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'].toString()) ?? DateTime.now()
          : DateTime.now(),
      bookmarkedEventIds: (map['bookmarkedEventIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
