import 'package:dio/dio.dart';

import 'api_interceptor.dart';

class BaseService {
  BaseService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? const String.fromEnvironment('API_BASE_URL', defaultValue: 'https://api.example.com'),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )) {
    _dio.interceptors.add(ApiInterceptor());
  }

  final Dio _dio;

  Dio get client => _dio;
}

