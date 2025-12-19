class AppConfig {
  static const String apiBaseUrl = 'http://localhost:8001';
  static const String apiPrefix = '/api';

  static String get apiUrl => '$apiBaseUrl$apiPrefix';
}