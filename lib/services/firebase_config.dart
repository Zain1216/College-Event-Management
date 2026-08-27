class FirebaseConfig {
  static const String appName = 'FusionFiesta';
  static const String projectId = 'fusionfiesta-college-events';
  static const String storageBucket = 'fusionfiesta-college-events.appspot.com';
  static const String apiKey = 'AIzaSyDemoFusionFiestaApiKey2026';
  static const String messagingSenderId = '849201948201';
  static const String appId = '1:849201948201:web:9c8d7e6f5a4b3c2d1e0f';

  // Demo user credentials for quick testing (Admin, Organizer, Participant, Visitor)
  static const Map<String, Map<String, String>> demoCredentials = {
    'admin': {
      'email': 'admin@fusionfiesta.edu',
      'password': 'Admin@123',
      'name': 'Dr. Arthur Vance (Admin)',
      'role': 'Administrator',
    },
    'organizer': {
      'email': 'organizer@fusionfiesta.edu',
      'password': 'Org@123',
      'name': 'Prof. Elena Rostova (Organizer)',
      'role': 'Event Organizer',
    },
    'participant': {
      'email': 'student@fusionfiesta.edu',
      'password': 'Student@123',
      'name': 'Zain Ahmed (Student Participant)',
      'role': 'Student Participant',
    },
    'visitor': {
      'email': 'visitor@fusionfiesta.edu',
      'password': 'Visitor@123',
      'name': 'Rohan Verma (Student Visitor)',
      'role': 'Student Visitor',
    },
  };
}
