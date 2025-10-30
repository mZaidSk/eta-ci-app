import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'api_interceptor.dart';

class BaseService {
  BaseService({String? baseUrl})
      : _dio = Dio(BaseOptions(
          baseUrl: baseUrl ??
              const String.fromEnvironment('API_BASE_URL',
                  defaultValue: 'http://10.190.80.147:8000/api'),
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 20),
          sendTimeout: const Duration(seconds: 20),
          headers: {
            'Accept': 'application/json',
            'Content-Type': 'application/json',
          },
        )) {
    _dio.interceptors.add(ApiInterceptor());

    // Add logging interceptor in debug mode
    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) => debugPrint('🌐 API: $obj'),
      ));
    }

    debugPrint(
        '🔧 BaseService initialized with baseUrl: ${_dio.options.baseUrl}');
  }

  final Dio _dio;

  Dio get client => _dio;
}
