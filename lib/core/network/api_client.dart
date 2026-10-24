import 'dart:io';

import 'package:dio/dio.dart';
import 'package:event_hub_mobile/core/network/api_exception.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  ApiClient(this._dio); // Dio is given to us, we don't create it

  final Dio _dio;

  Future<T> _send<T>(
    Future<Response> Function() request,
    T Function(dynamic json)? parser,
  ) async {
    try {
      final response = await request();
      if (parser != null) return parser(response.data);
      return response.data as T;
    } on DioException catch (e) {
      throw _mapDioException(e);
    } catch (e) {
      debugPrint(e.toString());
      throw const UnknownException(
        message: 'Unexpected response from the server.',
      );
    }
  }

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic json) parser,
  }) async {
    return _send(
      () => _dio.get(path, queryParameters: queryParameters),
      parser,
    );
  }

  Future<T> post<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    Map<String, dynamic>? headers,
    T Function(dynamic json)? parser,
  }) async {
    return _send(
      () => _dio.post(
        path,
        queryParameters: queryParameters,
        data: data,
        options: headers == null ? null : Options(headers: headers),
      ),
      parser,
    );
  }

  Future<T> put<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    return _send(
      () => _dio.put(path, queryParameters: queryParameters, data: data),
      parser,
    );
  }

  Future<T> patch<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    return _send(
      () => _dio.patch(path, queryParameters: queryParameters, data: data),
      parser,
    );
  }

  Future<T> delete<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    T Function(dynamic json)? parser,
  }) async {
    return _send(
      () => _dio.delete(path, queryParameters: queryParameters, data: data),
      parser,
    );
  }
}

ApiException _mapDioException(DioException e) {
  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.transformTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return const NetworkException(
        message: 'The server took too long to respond.',
      );
    case DioExceptionType.connectionError:
      return const NetworkException();
    case DioExceptionType.cancel:
      return const CancelledException();
    case DioExceptionType.badResponse:
      return _fromResponse(e.response);
    case DioExceptionType.badCertificate:
    case DioExceptionType.unknown:
      // Your HandshakeException landed here as [unknown]
      if (e.error is SocketException || e.error is HandshakeException) {
        return const NetworkException();
      }
      return const UnknownException();
  }
}

ApiException _fromResponse(Response? response) {
  final status = response?.statusCode;
  final data = response?.data;

  return switch (status) {
    400 || 422 => ValidationException(
      message: _readMessage(data) ?? 'Some information is invalid.',
      statusCode: status,
      fieldErrors: _readFieldErrors(data),
    ),
    401 =>
      _readMessage(data) == null
          ? const UnauthorizedException()
          : UnauthorizedException(message: _readMessage(data)!),
    403 => const ForbiddenException(),
    404 => const NotFoundException(),
    409 =>
      _readMessage(data) == null
          ? const ConflictException()
          : ConflictException(message: _readMessage(data)!),
    429 =>
      _readMessage(data) == null
          ? const TooManyRequestException()
          : TooManyRequestException(message: _readMessage(data)!),
    final code? when code >= 500 => ServerException(statusCode: code),
    _ => UnknownException(statusCode: status),
  };
}

String? _readMessage(dynamic data) {
  if (data is! Map) return null;
  final message = data['message'] ?? data['detail'] ?? data['title'];
  return message is String ? message : null;
}

Map<String, List<String>> _readFieldErrors(dynamic data) {
  if (data is! Map || data['errors'] is! Map) return {};

  final errors = data['errors'] as Map;

  Map<String, List<String>> result = {};
  for (final entry in errors.entries) {
    if (entry.value is List) {
      result[entry.key.toString()] = (entry.value as List)
          .map((e) => e.toString())
          .toList();
    } else if (entry.value is String) {
      result[entry.key.toString()] = [entry.value.toString()];
    }
  }

  return result;
}
