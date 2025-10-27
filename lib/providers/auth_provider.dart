import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

import '../services/auth_service.dart';
import '../services/api_interceptor.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider() : _service = AuthService();

  final AuthService _service;
  final ApiInterceptor _apiInterceptor = ApiInterceptor();
  String? _accessToken;
  String? _refreshToken;
  Map<String, dynamic>? _user;
  String? _error;
  bool _loading = false;

  String? get accessToken => _accessToken;
  String? get refreshToken => _refreshToken;
  Map<String, dynamic>? get user => _user;
  String? get error => _error;
  bool get isLoading => _loading;
  bool get isAuthenticated => _accessToken != null && _accessToken!.isNotEmpty;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      debugPrint('🔐 Attempting login for: $email');
      final response = await _service.login(email, password);
      debugPrint('📡 Login response status: ${response.statusCode}');
      debugPrint('📦 Login response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        // Extract tokens and user data from response
        _accessToken = response.data['access'];
        _refreshToken = response.data['refresh'];
        _user = response.data['user'];

        debugPrint('✅ Login successful! Token: ${_accessToken?.substring(0, 20)}...');
        debugPrint('👤 User: ${_user?['name']} (${_user?['email']})');

        // Inject access token into API interceptor for all future requests
        _apiInterceptor.setToken(_accessToken);
        return true;
      } else {
        _error = 'Login failed - unexpected status code';
        debugPrint('❌ Login failed: $_error');
        return false;
      }
    } on DioException catch (e) {
      debugPrint('❌ DioException during login:');
      debugPrint('   Status: ${e.response?.statusCode}');
      debugPrint('   Data: ${e.response?.data}');
      debugPrint('   Message: ${e.message}');

      // Try to extract error message from different possible formats
      if (e.response?.data is Map) {
        final data = e.response?.data as Map<String, dynamic>;
        _error = data['message'] ??
                 data['error'] ??
                 data['detail'] ??
                 'Network error occurred';
      } else if (e.response?.data is String) {
        _error = e.response?.data;
      } else {
        _error = e.message ?? 'Network error occurred';
      }
      return false;
    } catch (e) {
      debugPrint('❌ Unexpected error during login: $e');
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final response = await _service.register(email, password, name);
      if (response.statusCode == 200 || response.statusCode == 201) {
        // Registration successful - store user data
        // Note: Your API doesn't return tokens on registration, so we need to login afterward
        _user = response.data;

        // Auto-login after successful registration
        final loginSuccess = await login(email, password);
        return loginSuccess;
      } else {
        _error = 'Registration failed';
        return false;
      }
    } on DioException catch (e) {
      _error = e.response?.data?['message'] ?? e.response?.data?['error'] ?? 'Network error occurred';
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    // Clear token from API interceptor
    _apiInterceptor.clearToken();
    notifyListeners();
  }
}

