// lib/services/auth_service.dart

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart'; // Import ApiService
import '../models/user_model.dart'; // Import your User model

class AuthService {
  // Key for storing the auth token in shared preferences
  static const String _tokenKey = 'auth_token';
  // Key for storing user data locally (optional, can be fetched from backend after login)
  static const String _userDataKey = 'user_data';

  // Login method - Updated to handle 201 status as well
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await ApiService.loginUser({
        'email': email,
        'password': password,
      });

      // Check for 200 or 201 as successful login status
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token =
            data['token']; // Extract token from response - adjust key if different
        final userJson =
            data['user']; // Extract user data from response - adjust key if different

        if (token != null) {
          // Check if token exists in response
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          if (userJson != null) {
            await prefs.setString(_userDataKey, jsonEncode(userJson));
          }
          // Optionally, return the user object parsed from userJson
          final user = userJson != null ? User.fromJson(userJson) : null;

          return {'success': true, 'token': token, 'user': user};
        } else {
          // Token not found in response
          return {
            'success': false,
            'message': 'Login failed: Invalid response format (token missing).',
          };
        }
      } else {
        // Login failed based on status code
        final errorData = json.decode(response.body);
        // Handle potential List<String> for message (same as register)
        final errorMessage = errorData['message'];
        String displayMessage;
        if (errorMessage is List) {
          // If message is a list, join the elements
          displayMessage = errorMessage.join('. ');
        } else if (errorMessage is String) {
          // If message is a string, use it directly
          displayMessage = errorMessage;
        } else {
          // Fallback
          displayMessage = 'Login failed with status ${response.statusCode}.';
        }
        return {'success': false, 'message': displayMessage};
      }
    } catch (e) {
      // Network error or JSON parsing error
      print('Login Error: $e');
      return {
        'success': false,
        'message': 'An error occurred during login: $e',
      };
    }
  }

  // Register method - Updated to use 'phonenumber' as expected by backend
  static Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String phone,
    String address,
    String password,
    String confirmPassword,
  ) async {
    try {
      // Send data using the key name expected by the backend: 'phonenumber'
      final response = await ApiService.registerUser({
        'phonenumber':
            phone, // Changed from 'phone' or 'phoneNumber' to 'phonenumber'
        'fullname':
            fullName, // Changed from 'fullName' to 'fullname' as expected by backend auth/register
        'email': email,
        'address': address,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      if (response.statusCode == 201) {
        // Assuming 201 for successful creation
        final data = json.decode(response.body);
        final message =
            data['message'] ??
            'Registration successful.'; // Adjust key if different
        return {'success': true, 'message': message};
      } else {
        // Registration failed based on status code
        final errorData = json.decode(response.body);
        // Handle potential List<String> for message
        final errorMessage = errorData['message'];
        String displayMessage;
        if (errorMessage is List) {
          // If message is a list, join the elements
          displayMessage = errorMessage.join('. ');
        } else if (errorMessage is String) {
          // If message is a string, use it directly
          displayMessage = errorMessage;
        } else {
          // Fallback
          displayMessage =
              'Registration failed with status ${response.statusCode}.';
        }
        return {'success': false, 'message': displayMessage};
      }
    } catch (e) {
      // Network error or JSON parsing error
      print('Registration Error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration: $e',
      };
    }
  }

  // NEW: Method to fetch user profile from backend
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      final response = await ApiService.getUserProfile();

      if (response.statusCode == 200) {
        // Assuming 200 for successful profile fetch
        final userData = json.decode(response.body);
        // Update the stored user data in shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_userDataKey, jsonEncode(userData));
        // Return the fetched user object
        final user = User.fromJson(userData);
        return {'success': true, 'user': user};
      } else {
        // Profile fetch failed based on status code
        final errorData = json.decode(response.body);
        // Handle potential List<String> for message (same as login/register)
        final errorMessage = errorData['message'];
        String displayMessage;
        if (errorMessage is List) {
          // If message is a list, join the elements
          displayMessage = errorMessage.join('. ');
        } else if (errorMessage is String) {
          // If message is a string, use it directly
          displayMessage = errorMessage;
        } else {
          // Fallback
          displayMessage =
              'Failed to fetch profile with status ${response.statusCode}.';
        }
        return {'success': false, 'message': displayMessage};
      }
    } catch (e) {
      // Network error or JSON parsing error
      print('Fetch Profile Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while fetching the profile: $e',
      };
    }
  }

  // NEW: Method to update user profile information
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      final response = await ApiService.updateUserProfile(profileData);

      if (response.statusCode == 200) {
        // Assuming 200 for successful profile update
        // Fetch the updated profile data from the backend to ensure consistency
        final result = await fetchUserProfile();
        return result; // Return the result of fetchUserProfile (which includes the updated user data)
      } else {
        // Profile update failed based on status code
        final errorData = json.decode(response.body);
        // Handle potential List<String> for message
        final errorMessage = errorData['message'];
        String displayMessage;
        if (errorMessage is List) {
          // If message is a list, join the elements
          displayMessage = errorMessage.join('. ');
        } else if (errorMessage is String) {
          // If message is a string, use it directly
          displayMessage = errorMessage;
        } else {
          // Fallback
          displayMessage =
              'Failed to update profile with status ${response.statusCode}.';
        }
        return {'success': false, 'message': displayMessage};
      }
    } catch (e) {
      // Network error or JSON parsing error
      print('Update Profile Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while updating the profile: $e',
      };
    }
  }

  // NEW: Method to change user's password
  static Future<Map<String, dynamic>> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      final response = await ApiService.changePassword({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

      if (response.statusCode == 200) {
        // Assuming 200 for successful password change
        // Clear the current token as the password has changed (optional, depending on backend behavior)
        // await logout(); // Uncomment if you want to force re-login after password change
        return {'success': true, 'message': 'Password changed successfully.'};
      } else {
        // Password change failed based on status code
        final errorData = json.decode(response.body);
        // Handle potential List<String> for message
        final errorMessage = errorData['message'];
        String displayMessage;
        if (errorMessage is List) {
          // If message is a list, join the elements
          displayMessage = errorMessage.join('. ');
        } else if (errorMessage is String) {
          // If message is a string, use it directly
          displayMessage = errorMessage;
        } else {
          // Fallback
          displayMessage =
              'Failed to change password with status ${response.statusCode}.';
        }
        return {'success': false, 'message': displayMessage};
      }
    } catch (e) {
      // Network error or JSON parsing error
      print('Change Password Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while changing the password: $e',
      };
    }
  }

  // NEW: Method to upload a new profile photo
  static Future<Map<String, dynamic>> uploadProfilePhoto(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      final response = await ApiService.uploadProfilePhoto(
        imageBytes,
        fileName,
      );

      if (response.statusCode == 200) {
        // Assuming 200 for successful photo upload
        // Fetch the updated profile data from the backend to reflect the new photo URL
        final result = await fetchUserProfile();
        return result; // Return the result of fetchUserProfile (which includes the updated user data)
      } else {
        // Photo upload failed based on status code
        final errorData = json.decode(response.body);
        // Handle potential List<String> for message
        final errorMessage = errorData['message'];
        String displayMessage;
        if (errorMessage is List) {
          // If message is a list, join the elements
          displayMessage = errorMessage.join('. ');
        } else if (errorMessage is String) {
          // If message is a string, use it directly
          displayMessage = errorMessage;
        } else {
          // Fallback
          displayMessage =
              'Failed to upload profile photo with status ${response.statusCode}.';
        }
        return {'success': false, 'message': displayMessage};
      }
    } catch (e) {
      // Network error or JSON parsing error
      print('Upload Profile Photo Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while uploading the profile photo: $e',
      };
    }
  }

  // Check if user is logged in by checking for a stored token
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  // Get the stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // Get the stored user data (if saved locally)
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString != null) {
      try {
        final userData = json.decode(userDataString);
        return User.fromJson(userData);
      } catch (e) {
        print('Error parsing stored user  $e');
        return null;
      }
    }
    return null;
  }

  // Logout: Remove the stored token and user data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
  }
}
