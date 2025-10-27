import 'package:dio/dio.dart';

import 'base_service.dart';

class AuthService extends BaseService {
  AuthService({super.baseUrl});

  Future<Response<dynamic>> login(String email, String password) {
    return client.post('/users/login/', data: {
      'email': email,
      'password': password,
    });
  }

  Future<Response<dynamic>> register(String email, String password, String name) {
    return client.post('/users/register/', data: {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  Future<Response<dynamic>> me() {
    return client.get('/auth/me');
  }
}
