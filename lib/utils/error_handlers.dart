import 'package:flutter/material.dart';

class ErrorHandlers {
  static String getFriendlyErrorMessage(dynamic error) {
    if (error == null) return 'An unknown error occurred';

    final errorString = error.toString().toLowerCase();

    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('connection')) {
      return 'Network error: Please check your internet connection';
    } else if (errorString.contains('timeout')) {
      return 'Request timeout: Please try again';
    } else if (errorString.contains('401') ||
        errorString.contains('unauthorized')) {
      return 'Session expired: Please login again';
    } else if (errorString.contains('404')) {
      return 'Resource not found';
    } else if (errorString.contains('500')) {
      return 'Server error: Please try again later';
    } else if (errorString.contains('validation') ||
        errorString.contains('invalid')) {
      return 'Invalid data provided';
    } else {
      return 'An error occurred: $error';
    }
  }

  static void showErrorSnackBar(BuildContext context, dynamic error) {
    final message = getFriendlyErrorMessage(error);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  static void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  static Widget buildErrorWidget(String error, VoidCallback onRetry) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
          ),
        ],
      ),
    );
  }
}
