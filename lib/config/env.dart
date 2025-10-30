class EnvConfig {
  EnvConfig._();
  static const String apiBaseUrl = String.fromEnvironment('API_BASE_URL',
      defaultValue: 'http://10.190.80.147:8000/api');
}
