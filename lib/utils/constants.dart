// lib/utils/constants.dart

import 'package:flutter/material.dart'; // Import Material library for Color

class Constants {
  // API Base URL
  static const String apiBaseUrl =
      'https://infinity-booking-backend1.onrender.com/infinity-booking';

  // Colors
  static const Color primaryColor = Color(0xFF1E90FF); // DodgerBlue
  static const Color secondaryColor = Color(0xFF4169E1); // RoyalBlue
  static const Color accentColor = Color(0xFF20B2AA); // LightSeaGreen
  static const Color forestGreen = Color(0xFF228B22);
}

// Optional: Define common API endpoints here for consistency
class Endpoints {
  static const String authLogin = '/auth/login';
  static const String authRegister = '/auth/register';
  static const String userProfile = '/users/profile';
  // Add other endpoints as needed
}
