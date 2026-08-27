class ContactQueryModel {
  final String id;
  final String name;
  final String email;
  final String subject;
  final String category; // 'General' | 'Technical' | 'Event Registration' | 'Sponsorship'
  final String message;
  final bool isResolved;
  final String? adminReply;
  final DateTime submittedOn;

  ContactQueryModel({
    required this.id,
    required this.name,
    required this.email,
    required this.subject,
    this.category = 'General',
    required this.message,
    this.isResolved = false,
    this.adminReply,
    required this.submittedOn,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'subject': subject,
      'category': category,
      'message': message,
      'isResolved': isResolved,
      'adminReply': adminReply,
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

  factory ContactQueryModel.fromMap(Map<String, dynamic> map) {
    return ContactQueryModel(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      subject: map['subject'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      message: map['message'] as String? ?? '',
      isResolved: map['isResolved'] as bool? ?? false,
      adminReply: map['adminReply'] as String?,
      submittedOn: _parseDate(map['submittedOn']),
    );
  }
}

class FaqItem {
  final String question;
  final String answer;
  final String category;

  const FaqItem({
    required this.question,
    required this.answer,
    required this.category,
  });
}
