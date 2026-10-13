sealed class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException({required this.message, this.statusCode});

  @override
  String toString() => '$runtimeType($statusCode): $message';
}

class NetworkException extends ApiException {
  const NetworkException({
    super.message = "Can't reach the server. Check your connection",
  });
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException({super.message = 'Please sign in again.'})
    : super(statusCode: 401);
}

class ForbiddenException extends ApiException {
  const ForbiddenException({
    super.message = "You don't have permission to do this.",
  }) : super(statusCode: 403);
}

class NotFoundException extends ApiException {
  const NotFoundException({super.message = 'Not found.'})
    : super(statusCode: 404);
}

class ValidationException extends ApiException {
  const ValidationException({
    super.message = 'Some information is invalid.',
    super.statusCode,
    this.fieldErrors = const {},
  });

  /// e.g. {'email': ['Email is required']}
  final Map<String, List<String>> fieldErrors;
}

class ServerException extends ApiException {
  const ServerException({
    super.message = 'Something went wrong on our side. Please try again.',
    super.statusCode,
  });
}

class CancelledException extends ApiException {
  const CancelledException({super.message = 'Request was cancelled.'});
}

class UnknownException extends ApiException {
  const UnknownException({
    super.message = 'Something went wrong.',
    super.statusCode,
  });
}
