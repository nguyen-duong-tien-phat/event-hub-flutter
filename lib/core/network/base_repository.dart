import 'package:dio/dio.dart';
import 'package:event_hub_mobile/core/network/api_client.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

abstract class BaseRepository {
  final ApiClient apiClient;

  BaseRepository({ApiClient? apiClient}) : apiClient = apiClient ?? ApiClient();

  Future<T> handleRequest<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw ApiException('Something went wrong');
    }
  }

  ApiException _handleDioError(DioException e) {
    final response = e.response;

    if (response == null) {
      return ApiException('Unable to connect to the server');
    }

    final statusCode = response.statusCode;

    final data = response.data;

    String message = 'Something went wrong';

    if (data is Map<String, dynamic>) {
      message =
          data['message']?.toString() ?? data['title']?.toString() ?? message;
    }

    return ApiException(message, statusCode: statusCode);
  }
}
