class ErrorHandler {
  static String handleError(dynamic error) {
    if (error is String) {
      return error;
    } else if (error is ApiException) {
      return error.message;
    } else if (error is FormatException) {
      return 'Data format error. Please try again.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  static String handleNetworkError(dynamic error) {
    if (error is ApiException) {
      switch (error.statusCode) {
        case 400:
          return 'Bad request. Please check your input.';
        case 401:
          return 'Unauthorized. Please login again.';
        case 403:
          return 'Access forbidden.';
        case 404:
          return 'Resource not found.';
        case 500:
          return 'Server error. Please try again later.';
        case 502:
          return 'Server unavailable. Please try again later.';
        case 503:
          return 'Service temporarily unavailable.';
        default:
          return error.message;
      }
    } else {
      return handleError(error);
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int statusCode;

  ApiException({required this.message, required this.statusCode});

  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
