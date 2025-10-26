import 'package:flutter/foundation.dart';

// import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider();

  // final AuthService _service;
  String? _token;
  String? _error;
  bool _loading = false;

  String? get token => _token;
  String? get error => _error;
  bool get isLoading => _loading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<bool> login(String email, String password) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // Mock login success without API
      await Future<void>.delayed(const Duration(milliseconds: 400));
      _token = 'demo-token';
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null;
    notifyListeners();
  }
}

