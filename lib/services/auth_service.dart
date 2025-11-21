import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';

  static Future<void> _clearCorruptedUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userDataKey);
    print('🧹 AuthService - Cleared corrupted user data');
  }

  static Future<void> _saveUserToPrefs(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = jsonEncode(user.toJson());
      await prefs.setString(_userDataKey, userJson);
      print(
        '💾 AuthService - User saved to SharedPreferences: ${user.fullName}',
      );
    } catch (e) {
      print('❌ AuthService._saveUserToPrefs - Error: $e');
    }
  }

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

  static Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(_tokenKey);
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('❌ AuthService.isLoggedIn - Error: $e');
      return false;
    }
  }

  static Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      print('❌ AuthService.getToken - Error: $e');
      return null;
    }
  }

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

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        final token = data['token'];
        final userJson = data['user'] ?? data;

        if (token != null && token is String) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_tokenKey, token);
          print('✅ AuthService.login - Token saved successfully');

          if (userJson != null) {
            await _clearCorruptedUserData();
            final user = User.fromJson(userJson);
            await _saveUserToPrefs(user);
            print('✅ AuthService.login - User data saved: ${user.fullName}');

            return {'success': true, 'token': token, 'user': user};
          } else {
            return {'success': true, 'token': token, 'user': null};
          }
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
      return {'success': false, 'message': 'Login failed: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    try {
      print('🔄 AuthService.fetchUserProfile - Fetching from API...');
      final response = await ApiService.getUserProfile();

      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        print('✅ AuthService.fetchUserProfile - API response received');

        final user = User.fromJson(userData);
        await _saveUserToPrefs(user);

        print(
          '✅ AuthService.fetchUserProfile - Profile fetched and saved: ${user.fullName}',
        );
        return {'success': true, 'user': user};
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('💥 AuthService.fetchUserProfile - Error: $e');
      return {'success': false, 'message': 'Failed to fetch profile: $e'};
    }
  }

  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(_userDataKey);

      if (userDataString != null && userDataString.isNotEmpty) {
        final userData = json.decode(userDataString);
        final user = User.fromJson(userData);
        print('✅ AuthService.getCurrentUser - User loaded: ${user.fullName}');
        return user;
      } else {
        print('ℹ️ AuthService.getCurrentUser - No user data found');
        return null;
      }
    } catch (e) {
      print('💥 AuthService.getCurrentUser - Error parsing user data: $e');
      await _clearCorruptedUserData();
      return null;
    }
  }

  static Future<Map<String, dynamic>> getProfileWithFallback() async {
    try {
      print('🔄 AuthService.getProfileWithFallback - Starting...');

      final User? user = await getCurrentUser();

      if (user != null && user.id.isNotEmpty) {
        print('✅ AuthService.getProfileWithFallback - Using cached user data');
        return {'success': true, 'user': user};
      }

      print(
        '🔄 AuthService.getProfileWithFallback - No valid cached data, fetching from API...',
      );

      final apiResult = await fetchUserProfile();

      if (apiResult['success']) {
        print('✅ AuthService.getProfileWithFallback - API fetch successful');
        return apiResult;
      } else {
        print(
          '❌ AuthService.getProfileWithFallback - API fetch failed: ${apiResult['message']}',
        );
        return apiResult;
      }
    } catch (e) {
      print('💥 AuthService.getProfileWithFallback - Error: $e');
      return {'success': false, 'message': 'Failed to load profile: $e'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile(
    Map<String, dynamic> profileData,
  ) async {
    try {
      print('🔄 AuthService.updateProfile - Starting update...');

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'No user data available. Please login again.',
        };
      }

      final updateData = Map<String, dynamic>.from(profileData);
      updateData['id'] = currentUser.id;

      print('🔑 Using User ID: ${currentUser.id}');
      print('📤 Update payload: ${updateData.keys.toList()}');

      final response = await ApiService.updateUserProfile(updateData);

      print('📥 Update response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ AuthService.updateProfile - Update successful');

        final refreshResult = await fetchUserProfile();

        if (refreshResult['success']) {
          print('✅ User data refreshed after update');
          return refreshResult;
        } else {
          return {
            'success': true,
            'message': 'Profile updated successfully (refresh failed)',
            'user': currentUser,
          };
        }
      } else {
        print(
          '❌ AuthService.updateProfile - Update failed with status: ${response.statusCode}',
        );
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

  static Future<Map<String, dynamic>> uploadProfilePhoto(
    List<int> imageBytes,
    String fileName,
  ) async {
    try {
      print('📸 AuthService.uploadProfilePhoto - Starting upload...');

      final currentUser = await getCurrentUser();
      if (currentUser == null) {
        return {
          'success': false,
          'message': 'No user data available. Please login again.',
        };
      }

      print('📸 Uploading photo for user: ${currentUser.id}');

      final response = await ApiService.uploadProfilePhoto(
        imageBytes,
        fileName,
      );

      if (response.statusCode == 200) {
        print('✅ Profile photo uploaded successfully');
        final result = await fetchUserProfile();
        return result;
      } else {
        print('🔄 Main upload failed, trying alternative endpoint...');

        final altResponse = await ApiService.uploadProfilePhotoWithId(
          currentUser.id,
          imageBytes,
          fileName,
        );

        if (altResponse.statusCode == 200) {
          print('✅ Profile photo uploaded via alternative endpoint');
          final result = await fetchUserProfile();
          return result;
        } else {
          return _handleErrorResponse(altResponse);
        }
      }
    } catch (e) {
      print('💥 AuthService.uploadProfilePhoto - Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while uploading the profile photo: $e',
      };
    }
  }

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

      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        final message = data['message'] ?? 'Registration successful.';
        return {'success': true, 'message': message};
      } else {
        return _handleErrorResponse(response);
      }
    } catch (e) {
      print('Registration Error: $e');
      return {
        'success': false,
        'message': 'An error occurred during registration: $e',
      };
    }
  }

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
      print('Change Password Error: $e');
      return {
        'success': false,
        'message': 'An error occurred while changing the password: $e',
      };
    }
  }

  static Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(_userDataKey);
      print('✅ AuthService.logout - User logged out successfully');
    } catch (e) {
      print('❌ AuthService.logout - Error: $e');
    }
  }
}
