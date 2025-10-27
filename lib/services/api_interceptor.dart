import 'package:dio/dio.dart';

class ApiInterceptor extends Interceptor {
  ApiInterceptor._();

  static final ApiInterceptor _instance = ApiInterceptor._();

  factory ApiInterceptor() => _instance;

  String? _token;

  void setToken(String? token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (_token != null && _token!.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $_token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Centralized error handling hook
    super.onError(err, handler);
  }
}

