class ApiConstants {
  /// Backend base URL. Override at build time for deployment:
  ///   flutter build web --dart-define=API_BASE_URL=https://your-api.onrender.com/api
  /// Defaults to the local dev server (use http://10.0.2.2:5000/api on Android emulator).
  static const String _baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:5000/api',
  );

  static String get baseUrl => _baseUrl;

  // Auth endpoints
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String refresh = '/auth/refresh';
  static const String me = '/auth/me';
  static const String profile = '/auth/profile';
  static const String logout = '/auth/logout';

  // Roadmap endpoints
  static const String roadmaps = '/roadmaps';
  static const String userRoadmap = '/users/me/roadmap';
  static const String updateRoadmapProgress = '/users/me/roadmap/progress';

  // DSA endpoints
  static const String catalogProblems = '/problems';
  static const String userProblems = '/users/me/problems';
  static const String revisions = '/users/me/revisions';

  // Project endpoints
  static const String projects = '/projects';
  static const String userProjects = '/users/me/projects';

  // Dashboard & Analytics
  static const String dashboard = '/users/me/dashboard';
  static const String analytics = '/users/me/analytics';
  static const String activity = '/users/me/activity';

  // Interview endpoints
  static const String interviewQuestions = '/interview-questions';
  static const String interviewProgress = '/users/me/interview-progress';
}
