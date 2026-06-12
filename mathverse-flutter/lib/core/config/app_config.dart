class AppConfig {
  static const String appName = 'MathApp';
  static const String apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:8080',
  );
  static const String mathEngineUrl = String.fromEnvironment(
    'MATH_ENGINE_URL',
    defaultValue: 'http://localhost:8000',
  );
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
}
