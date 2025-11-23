import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  // Simple in-memory cache
  static User? _currentUser;
  static String? _authToken;

  // Clear all data
  static Future<void> _clearAllData() async {
    _currentUser = null;
    _authToken = null;
    print('🧹 AuthService - Cleared all in-memory data');
  }

  // Handle error responses
  static Map<String, dynamic> _handleErrorResponse(http.Response response) {
    try {
      final errorData = json.decode(response.body);
      final errorMessage = errorData['message'];

      String displayMessage;
      if (errorMessage is List) {
        displayMessage = errorMessage.join('. ');
      } else if (errorMessage is String) {
        displayMessage = errorMessage;
      } else {
        displayMessage = 'Request failed with status ${response.statusCode}';
      }

      return {'success': false, 'message': displayMessage};
    } catch (e) {
      return {
        'success': false,
        'message': 'Request failed with status ${response.statusCode}',
      };
    }
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return _authToken != null && _authToken!.isNotEmpty;
  }

  // Get token method
  static Future<String?> getToken() async {
    return _authToken;
  }

  // Login method
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      print('🔐 AuthService.login - Attempting login for: $email');

      final response = await ApiService.loginUser({
        'email': email,
        'password': password,
      });

      print('🔐 AuthService.login - Response status: ${response.statusCode}');
      print('🔐 AuthService.login - Response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userJson = data['user'] ?? data;

        if (token != null && token is String) {
          _authToken = token;

          if (userJson != null) {
            _currentUser = User.fromJson(userJson);
            print(
              '✅ AuthService.login - User data stored: ${_currentUser!.fullName}',
            );
          }

          return {'success': true, 'token': token, 'user': _currentUser};
        } else {
          return {
            'success': false,
            'message': 'Invalid response: Token missing or invalid',
          };
        }
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('💥 AuthService.login - Error: $e');
      return {
        'success': false,
        'message': 'Network error: Please check your connection and try again',
      };
    }
  }

  // Fetch user profile from API
  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      print('🔄 AuthService.fetchUserProfile - Fetching from API...');

      if (_authToken == null || _authToken!.isEmpty) {
        print('❌ AuthService.fetchUserProfile - No authentication token found');
        return {
          'success': false,
          'message': 'Not authenticated. Please login again.',
        };
      }

      final response = await ApiService.getUserProfile();

      print(
          '🔄 AuthService.fetchUserProfile - Response status: ${response.statusCode}');
      print(
          '🔄 AuthService.fetchUserProfile - Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ AuthService.fetchUserProfile - API response received');

        _currentUser = User.fromJson(userData);
        print(
          '✅ AuthService.fetchUserProfile - Profile fetched: ${_currentUser!.fullName}',
        );
        return {'success': true, 'user': _currentUser};
      } else if (response.statusCode == 401) {
        print('❌ AuthService.fetchUserProfile - Token expired or invalid');
        await logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('💥 AuthService.fetchUserProfile - Error: $e');

      if (e.toString().contains('No authentication token') ||
          e.toString().contains('401')) {
        await logout();
        return {
          'success': false,
          'message': 'Session expired. Please login again.',
        };
      }

      return {'success': false, 'message': 'Failed to fetch profile: $e'};
    }
  }

  // Get current user from memory
  static Future<User?> getCurrentUser() async {
    return _currentUser;
  }

  // Comprehensive profile loading
  static Future<Map<String, dynamic>> getProfileWithFallback() async {
    try {
      print('🔄 AuthService.getProfileWithFallback - Starting...');

      final isLoggedIn = await AuthService.isLoggedIn();
      if (!isLoggedIn) {
        print('❌ AuthService.getProfileWithFallback - User not logged in');
        return {
          'success': false,
          'message': 'Please login to access your profile',
        };
      }

      // Always try to fetch fresh data from API first
      print(
          '🔄 AuthService.getProfileWithFallback - Fetching fresh data from API...');
      final apiResult = await fetchUserProfile();

      if (apiResult['success']) {
        print('✅ AuthService.getProfileWithFallback - API fetch successful');
        return apiResult;
      } else {
        print(
            '❌ AuthService.getProfileWithFallback - API fetch failed, using cache if available');
        // If API fails but we have cached user, return cached user
        if (_currentUser != null) {
          print(
              '✅ AuthService.getProfileWithFallback - Using cached user data');
          return {'success': true, 'user': _currentUser};
        } else {
          return apiResult;
        }
      }
    } catch (e) {
      print('💥 AuthService.getProfileWithFallback - Error: $e');
      // If we have cached user, return it even on error
      if (_currentUser != null) {
        print(
            '✅ AuthService.getProfileWithFallback - Using cached user despite error');
        return {'success': true, 'user': _currentUser};
      }
      return {'success': false, 'message': 'Failed to load profile: $e'};
    }
  }

  // Update profile
  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('🔄 AuthService.updateProfile - Starting update...');
      print('📤 Update data: $profileData');

      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user data available. Please login again.',
        };
      }

      final updateData = Map<String, dynamic>.from(profileData);
      updateData['id'] = _currentUser!.id;

      print('🔑 Using User ID: ${_currentUser!.id}');
      print('📤 Update payload: ${updateData.keys.toList()}');

      final response = await ApiService.updateUserProfile(updateData);

      print('📥 Update response status: ${response.statusCode}');
      print('📥 Update response body: ${response.body}');

      if (response.statusCode == 200) {
        print('✅ AuthService.updateProfile - Update successful');

        // Update the cached user object with the new data
        final updatedUserData = Map<String, dynamic>.from(
          _currentUser!.toJson(),
        );
        updatedUserData.addAll(updateData); // Merge updated fields
        _currentUser = User.fromJson(updatedUserData);

        // Fetch fresh data to ensure consistency
        final refreshResult = await fetchUserProfile();
        if (refreshResult['success']) {
          print('✅ User data refreshed after update');
          return refreshResult;
        } else {
          return {
            'success': true,
            'message': 'Profile updated successfully (refresh failed)',
            'user': _currentUser,
          };
        }
      } else {
        print(
            '❌ AuthService.updateProfile - Update failed with status: ${response.statusCode}');
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('💥 AuthService.updateProfile - Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while updating the profile: $e',
      };
    }
  }

  // Upload profile photo - COMPLETELY REWRITTEN with multiple fallbacks
  static Future<Map<String, dynamic>> uploadProfilePhoto(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      print('📸 AuthService.uploadProfilePhoto - Starting upload...');

      if (_currentUser == null) {
        return {
          'success': false,
          'message': 'No user data available. Please login again.',
        };
      }

      print('📸 Uploading photo for user: ${_currentUser!.id}');
      print('📸 File: $fileName, Size: ${imageBytes.length} bytes');

      // Try multiple upload methods in sequence
      final uploadMethods = [
        _uploadWithPrimaryMethod,
        _uploadWithAlternativeMethod,
        _uploadWithPostMethod,
      ];

      for (var uploadMethod in uploadMethods) {
        try {
          print('🔄 Trying upload method: ${uploadMethod.toString()}');
          final result = await uploadMethod(imageBytes, fileName);

          if (result['success']) {
            print(
                '✅ Upload successful with method: ${uploadMethod.toString()}');
            return result;
          }
        } catch (e) {
          print('❌ Upload method failed: $e');
          // Continue to next method
        }
      }

      // If all methods fail
      return {
        'success': false,
        'message': 'All upload methods failed. Please try again later.',
      };
    } catch (e) {
      print('💥 AuthService.uploadProfilePhoto - Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while uploading the profile photo: $e',
      };
    }
  }

  // Primary upload method
  static Future<Map<String, dynamic>> _uploadWithPrimaryMethod(
    List<int> imageBytes,
    String fileName,
  ) async {
    final response = await ApiService.uploadProfilePhoto(imageBytes, fileName);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return await _handleSuccessfulUpload(response);
    } else {
      throw Exception('Primary upload failed: ${response.statusCode}');
    }
  }

  // Alternative upload method
  static Future<Map<String, dynamic>> _uploadWithAlternativeMethod(
    List<int> imageBytes,
    String fileName,
  ) async {
    final response = await ApiService.uploadProfilePhotoWithId(
      _currentUser!.id,
      imageBytes,
      fileName,
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return await _handleSuccessfulUpload(response);
    } else {
      throw Exception('Alternative upload failed: ${response.statusCode}');
    }
  }

  // POST method upload
  static Future<Map<String, dynamic>> _uploadWithPostMethod(
    List<int> imageBytes,
    String fileName,
  ) async {
    final response =
        await ApiService.uploadProfilePhotoPost(imageBytes, fileName);

    if (response.statusCode == 200 || response.statusCode == 201) {
      return await _handleSuccessfulUpload(response);
    } else {
      throw Exception('POST upload failed: ${response.statusCode}');
    }
  }

  // Handle successful upload response
  static Future<Map<String, dynamic>> _handleSuccessfulUpload(
      http.Response response) async {
    print('✅ Upload successful, processing response...');

    try {
      final responseData = json.decode(response.body);
      print('📸 Full upload response: $responseData');

      // Try to extract photo URL from various possible locations
      String? photoUrl = _extractPhotoUrl(responseData);

      if (photoUrl != null && photoUrl.isNotEmpty) {
        print('📸 Extracted photo URL: $photoUrl');

        // Update cached user
        _currentUser = _currentUser!.copyWith(profilePhoto: photoUrl);

        return {
          'success': true,
          'message': 'Profile photo updated successfully',
          'user': _currentUser,
        };
      } else {
        print('🔄 No photo URL found in response, fetching fresh profile...');
        // Fetch fresh profile data
        final refreshResult = await fetchUserProfile();
        return refreshResult;
      }
    } catch (e) {
      print('❌ Error processing upload response: $e');
      // Even if parsing fails, try to refresh profile
      final refreshResult = await fetchUserProfile();
      return refreshResult;
    }
  }

  // Extract photo URL from response data
  static String? _extractPhotoUrl(dynamic responseData) {
    if (responseData is! Map) return null;

    // Try different field names for the photo URL
    final possibleFields = [
      'profilePhoto',
      'profilePicture',
      'photoUrl',
      'imageUrl',
      'avatar',
      'url',
      'photo',
      'image',
      'fileUrl',
      'picture'
    ];

    for (var field in possibleFields) {
      if (responseData[field] != null &&
          responseData[field].toString().isNotEmpty) {
        return responseData[field].toString();
      }
    }

    // Check nested user object
    if (responseData['user'] is Map) {
      final userData = responseData['user'];
      for (var field in possibleFields) {
        if (userData[field] != null && userData[field].toString().isNotEmpty) {
          return userData[field].toString();
        }
      }
    }

    return null;
  }

  // Registration method
  static Future<Map<String, dynamic>> register(
    String fullName,
    String email,
    String phone,
    String address,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await ApiService.registerUser({
        'phonenumber': phone,
        'fullname': fullName,
        'email': email,
        'address': address,
        'password': password,
        'confirmPassword': confirmPassword,
      });

      print('📝 Registration response status: ${response.statusCode}');
      print('📝 Registration response body: ${response.body}');

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final message = data['message'] ??
            'Registration successful. Please login to continue.';
        return {'success': true, 'message': message};
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('💥 Registration Error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration: $e',
      };
    }
  }

  // Change password
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
        return {'success': true, 'message': 'Password changed successfully.'};
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('💥 Change Password Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while changing the password: $e',
      };
    }
  }

  // Logout method
  static Future<void> logout() async {
    try {
      await _clearAllData();
      print('✅ AuthService.logout - User logged out successfully');
    } catch (e) {
      print('❌ AuthService.logout - Error: $e');
    }
  }

  // Clear all auth data
  static Future<void> clearAllData() async {
    try {
      await _clearAllData();
      print('✅ AuthService.clearAllData - All auth data cleared');
    } catch (e) {
      print('❌ AuthService.clearAllData - Error: $e');
    }
  }

  // Refresh current user data from API
  static Future<void> refreshCurrentUser() async {
    if (await isLoggedIn()) {
      await fetchUserProfile();
    }
  }
}
