// lib/utils/constants.dart

import 'package:flutter/material.dart';

class Constants {
  static const String apiBaseUrl = 'https://infinity-booking-backend1.onrender.com/infinity-booking';

  // Colors
  static const Color primaryColor = Color(0xFF1E90FF); // DodgerBlue
  static const Color secondaryColor = Color(0xFF4169E1); // RoyalBlue
  static const Color accentColor = Color(0xFF20B2AA); // LightSeaGreen
  static const Color forestGreen = Color(0xFF228B22);
}

// Optional: Define common API endpoints here for consistency
class Endpoints {
  static const String authLogin = '/auth/login';
  static const String authRegisterCustomer = '/auth/register/customer';
  static const String userProfile = '/users/profile';
  static const String userChangePassword = '/users/change-password';
  static const String userUploadProfilePhoto = '/users/profile-photo/upload'; // Updated to match backend expectation 'photo'
  // Add other endpoints as needed
}