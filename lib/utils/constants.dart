import 'package:flutter/material.dart';

class Constants {
  static const String apiBaseUrl =
      'https://infinity-booking-backend1.onrender.com/infinity-booking';

  // Colors
  static const Color primaryColor = Color(0xFF1E90FF);
  static const Color secondaryColor = Color(0xFF4169E1);
  static const Color accentColor = Color(0xFF20B2AA);
  static const Color forestGreen = Color(0xFF228B22);
  static const Color successColor = Color(0xFF28A745);
  static const Color warningColor = Color(0xFFFFC107);
  static const Color errorColor = Color(0xFFDC3545);

  // API Timeouts
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // App Constants
  static const String appName = 'Infinity Booking';
  static const String appVersion = '1.0.0';
}

class Endpoints {
  // Auth endpoints
  static const String authLogin = '/auth/login';
  static const String authRegisterCustomer = '/auth/register/customer';

  // Profile endpoints
  static const String userProfile = '/users/profile';
  static const String userChangePassword = '/users/change-password';
  static const String userUploadProfilePhoto = '/users/profile-photo/upload';
  static const String userUploadPhotoWithId = '/users/{id}/upload-photo';
  static const String userUpdateProfile = '/users/{id}';

  // Category endpoints
  static const String categories = '/categories';
  static const String categoryById = '/categories/{id}';
  static const String categorySubcategories = '/categories/{id}/subcategories';

  // Service endpoints
  static const String services = '/services';
  static const String serviceById = '/services/{id}';

  // Booking endpoints
  static const String bookings = '/bookings';
  static const String userBookings = '/bookings/user';
  static const String bookingById = '/bookings/{id}';

  // Helper method to replace path parameters
  static String buildPath(String endpoint, Map<String, String> params) {
    String path = endpoint;
    params.forEach((key, value) {
      path = path.replaceAll('{$key}', value);
    });
    return path;
  }
}

class AppConstants {
  // Validation patterns
  static final RegExp emailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final RegExp phoneRegex = RegExp(r'^[+]?[0-9]{10,15}$');

  // Default values
  static const String defaultCountryCode = '+251'; // Ethiopia
  static const int minPasswordLength = 8;

  // App settings
  static const int itemsPerPage = 10;
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}

// String extension for capitalization
extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }

  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
}

// Date format helpers
class DateFormats {
  static const String displayDate = 'MMM dd, yyyy';
  static const String displayDateTime = 'MMM dd, yyyy • HH:mm';
  static const String apiFormat = 'yyyy-MM-dd';
  static const String apiDateTime = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'";
}
