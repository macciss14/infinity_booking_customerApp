// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // App Information
  static const String appName = 'Infinity Booking';
  static const String appVersion = '1.0.0';

  // API Configuration
  static const String baseUrl =
      'https://infinity-booking-backend1.onrender.com'; // ✅ No trailing spaces

  // ✅ apiBaseUrl is just the base URL (endpoints include /infinity-booking)
  static const String apiBaseUrl = '$baseUrl';

  // Endpoints (all include /infinity-booking prefix for clarity)
  static const String registerEndpoint =
      '/infinity-booking/auth/register/customer';
  static const String loginEndpoint = '/infinity-booking/auth/login';
  static const String profileEndpoint = '/infinity-booking/users/profile';
  static const String updateProfileEndpoint = '/infinity-booking/users/';
  static const String uploadPhotoEndpoint =
      '/infinity-booking/users/profile-photo/upload';
  static const String logoutEndpoint = '/infinity-booking/auth/logout';
  static const String changePasswordEndpoint =
      '/infinity-booking/users/change-password';
  static const String categoriesEndpoint = '/infinity-booking/categories';
  static const String subcategoriesEndpoint =
      '/infinity-booking/categories/{id}/subcategories';
  static const String servicesEndpoint = '/infinity-booking/services';
  static const String serviceDetailEndpoint = '/infinity-booking/services/{id}';
  static const String createBookingEndpoint = '/infinity-booking/bookings';
  static const String userBookingsEndpoint = '/infinity-booking/bookings/user';
  static const String bookingDetailEndpoint = '/infinity-booking/bookings/{id}';
  static const String serviceSlotsEndpoint =
      '/infinity-booking/services/{serviceId}/slots';

  // Storage Keys
  static const String tokenKey = 'auth_token';
  static const String userDataKey = 'user_data';
  static const String firstLaunchKey = 'first_launch';

  // Validation
  static const int minPasswordLength = 8;

  // Design
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
}

class AppStrings {
  // Common
  static const String appName = 'Infinity Booking';
  static const String welcome = 'Welcome';
  static const String loading = 'Loading...';
  static const String error = 'Error';
  static const String success = 'Success';
  static const String tryAgain = 'Try Again';
  static const String noData = 'No data available';

  // Auth
  static const String login = 'Login';
  static const String register = 'Register';
  static const String email = 'Email';
  static const String password = 'Password';
  static const String confirmPassword = 'Confirm Password';
  static const String fullName = 'Full Name';
  static const String phone = 'Phone Number';
  static const String forgotPassword = 'Forgot Password?';
  static const String dontHaveAccount = "Don't have an account?";
  static const String alreadyHaveAccount = "Already have an account?";

  // Validation Messages
  static const String emailRequired = 'Email is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordRequired = 'Password is required';
  static const String passwordTooShort =
      'Password must be at least 8 characters';
  static const String nameRequired = 'Full name is required';
  static const String phoneRequired = 'Phone number is required';
  static const String invalidPhone = 'Please enter a valid phone number';
  static const String passwordsDontMatch = 'Passwords do not match';
}

// ✨ Color Constants (based on your preferences)
class AppColors {
  // Primary Brand Colors
  static const Color primary = Color(0xFF4169E1); // Royal Blue
  static const Color primaryLight = Color(0xFF1E90FF); // Dodger Blue
  static const Color secondary = Color(0xFF20B2AA); // LightSeaGreen

  // Backgrounds
  static const Color scaffoldBackground = Color(0xFFF8F9FA);
  static const Color cardBackground = Colors.white;
  static const Color searchBackground = Color(0xFFF5F5F5);
  static const Color chipBackground = Colors.white;

  // Text Colors
  static const Color textPrimary = Color(0xFF212529);
  static const Color textSecondary = Color(0xFF6C757D);

  // Borders & Dividers
  static const Color borderColor = Color(0xFFCED4DA);
}

// ✨ Reusable App Theme
ThemeData appTheme() {
  return ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.scaffoldBackground,
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: AppColors.cardBackground,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.searchBackground,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(25),
        borderSide: const BorderSide(color: AppColors.primaryLight, width: 2),
      ),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.chipBackground,
      disabledColor: Colors.grey.shade100,
      selectedColor: AppColors.primaryLight,
      labelStyle: const TextStyle(color: AppColors.textPrimary),
      secondarySelectedColor: AppColors.primaryLight,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: AppColors.borderColor),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      ),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary),
      titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: AppColors.textPrimary),
      labelMedium: TextStyle(fontSize: 12, color: AppColors.textSecondary),
    ),
  );
}
