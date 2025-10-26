import 'package:dio/dio.dart';

import 'base_service.dart';

class CrudService<T> extends BaseService {
  CrudService({required this.endpoint, super.baseUrl});

  final String endpoint;

  Future<Response<dynamic>> list({Map<String, dynamic>? query}) {
    return client.get(endpoint, queryParameters: query);
  }

  Future<Response<dynamic>> getById(String id) {
    return client.get('$endpoint/$id');
  }

  Future<Response<dynamic>> create(Map<String, dynamic> data) {
    return client.post(endpoint, data: data);
  }

  Future<Response<dynamic>> update(String id, Map<String, dynamic> data) {
    return client.put('$endpoint/$id', data: data);
  }

  Future<Response<dynamic>> delete(String id) {
    return client.delete('$endpoint/$id');
  }
}

