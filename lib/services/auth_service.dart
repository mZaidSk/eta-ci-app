import 'package:dio/dio.dart';

import 'base_service.dart';

class AuthService extends BaseService {
  AuthService({super.baseUrl});

  Future<Response<dynamic>> login(String email, String password) {
    return client.post('/auth/login', data: {'email': email, 'password': password});
  }

  Future<Response<dynamic>> me() {
    return client.get('/auth/me');
  }
}

