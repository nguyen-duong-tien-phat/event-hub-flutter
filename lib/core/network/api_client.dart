import 'package:dio/dio.dart';

class ApiClient {
  ApiClient(this._dio); // Dio is given to us, we don't create it

  final Dio _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    final response = await _dio.get(path, queryParameters: queryParameters);
    // response.data is already decoded: a Map or a List
    return parser(response.data);
  }
}
