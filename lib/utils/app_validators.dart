class AppValidators {
  // RFC 5322 compliant regex ensuring proper username, @ symbol, domain, and valid TLD (.com, .edu, .org, etc.)
  static final RegExp _emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  static final RegExp _phoneRegex = RegExp(
    r'^\+?[0-9\s\-()]{7,15}$',
  );

  /// Validates email address with thorough format checks
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = value.trim();
    if (!trimmed.contains('@')) {
      return 'Email must contain an "@" symbol';
    }
    if (!trimmed.contains('.')) {
      return 'Email must contain a valid domain (e.g. .com, .edu)';
    }
    if (!_emailRegex.hasMatch(trimmed)) {
      return 'Enter a valid email address (e.g. name@domain.com)';
    }
    return null;
  }

  /// Validates password with configurable minimum length
  static String? password(String? value, {int minLength = 6}) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    return null;
  }

  /// Validates required text fields
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates enrollment/student ID number
  static String? enrollmentNo(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Enrollment / Student ID number is required';
    }
    if (value.trim().length < 3) {
      return 'Please enter a valid student ID';
    }
    return null;
  }

  /// Validates optional phone number
  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null; // Phone is optional
    }
    if (!_phoneRegex.hasMatch(value.trim())) {
      return 'Enter a valid phone number (7-15 digits)';
    }
    return null;
  }

  /// Validates positive numeric fields (e.g. capacity, fee)
  static String? positiveInteger(String? value, String fieldName, {int min = 1}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    final parsed = int.tryParse(value.trim());
    if (parsed == null || parsed < min) {
      return '$fieldName must be at least $min';
    }
    return null;
  }
}
