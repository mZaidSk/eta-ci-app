import 'package:dio/dio.dart';

import 'base_service.dart';

class DashboardService extends BaseService {
  DashboardService({super.baseUrl});

  Future<Response<dynamic>> getStats() {
    return client.get('/dashboard/stats');
  }
}

