class EnvConfig {
  EnvConfig._();
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://192.168.0.101:8000/api');
}
