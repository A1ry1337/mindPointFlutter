class AppConfig {
  static const String apiBaseUrl = 'http://192.168.1.113:8001';
  static const String apiPrefix = '/api';

  static String get apiUrl => '$apiBaseUrl$apiPrefix';
}