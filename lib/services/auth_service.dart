// services/auth_service.dart
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class AuthService {
  final SecureStorage _secureStorage = SecureStorage();

  // ─── REGISTER ───────────────────────────────────────────
  Future<void> register({
    required String fullname,
    required String email,
    required String phonenumber,
    required String address,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'fullname': fullname.trim(),
          'email': email.trim(),
          'phonenumber': phonenumber.trim(),
          'address': address.trim(),
          'password': password,
          'confirmPassword': confirmPassword,
        }),
      );

      print('Register Status: ${response.statusCode}');
      print('Register Response: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('Register Error: $e');
      rethrow;
    }
  }

  // ─── LOGIN ───────────────────────────────────────────────
  Future<UserModel> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email.trim(), 'password': password}),
      );

      print('Login Status: ${response.statusCode}');
      print('Login Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['token'];

        final user = UserModel.fromJson(data);
        await _secureStorage.saveToken(token);
        await _secureStorage.saveUserData(user);
        return user;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('Login Error: $e');
      rethrow;
    }
  }

  // lib/services/auth_service.dart

// ─── LOGOUT ─────────────────────────────────────────────
  Future<void> logout() async {
    // ✅ Remove BuildContext parameter
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          await http.post(
            Uri.parse(
                '${AppConstants.apiBaseUrl}${AppConstants.logoutEndpoint}'),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
        } catch (e) {
          print('Logout API call failed (safe to ignore): $e');
        }
      }
    } catch (e) {
      print('Logout error: $e');
    } finally {
      await _secureStorage.clearAll();
      // ✅ DO NOT NAVIGATE HERE — return control to UI
    }
  }

  // ─── UTILITIES ─────────────────────────────────────────
  Future<bool> isLoggedIn() async => await _secureStorage.hasToken();

  Future<UserModel?> getCurrentUser() async =>
      await _secureStorage.getUserData();

  // ─── FETCH PROFILE ─────────────────────────────────────
  Future<UserModel> fetchUserProfile() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.profileEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Fetch Profile Status: ${response.statusCode}');
      print('Fetch Profile Response: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = UserModel.fromJson(data);
        await _secureStorage.saveUserData(user);
        return user;
      } else if (response.statusCode == 401) {
        await _secureStorage.clearAll();
        throw Exception('Session expired. Please login again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch profile');
      }
    } catch (e) {
      print('Fetch Profile Error: $e');
      rethrow;
    }
  }

  // ─── UPDATE PROFILE DETAILS ─────────────────────────────
  Future<UserModel> updateProfile({
    String? fullname,
    String? phonenumber,
    String? address,
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not found');
    }

    final payload = <String, dynamic>{};
    if (fullname != null && fullname.trim().isNotEmpty) {
      payload['fullname'] = fullname.trim();
    }
    if (phonenumber != null && phonenumber.trim().isNotEmpty) {
      payload['phonenumber'] = phonenumber.trim();
    }
    if (address != null && address.trim().isNotEmpty) {
      payload['address'] = address.trim();
    }

    if (payload.isEmpty) {
      return currentUser;
    }

    print('Update Profile - User ID: ${currentUser.id}');
    print('Update Profile - Payload: $payload');

    try {
      // Try multiple endpoints
      List<String> endpoints = [
        '${AppConstants.apiBaseUrl}/users/${currentUser.id}',
        '${AppConstants.apiBaseUrl}/users/profile',
        '${AppConstants.apiBaseUrl}/customer-profiles/${currentUser.id}',
        '${AppConstants.apiBaseUrl}/customer-profiles/${currentUser.customerProfileId}',
      ];

      for (var endpoint in endpoints) {
        if (endpoint.contains('null')) continue; // Skip if ID is null

        try {
          final response = await http.patch(
            Uri.parse(endpoint),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(payload),
          );

          print('Trying endpoint: $endpoint');
          print('Update Profile Status: ${response.statusCode}');
          print('Update Profile Response: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final updatedUser = UserModel.fromJson(data);
            await _secureStorage.saveUserData(updatedUser);
            return updatedUser;
          }
        } catch (e) {
          print('Error with endpoint $endpoint: $e');
          continue;
        }
      }

      throw Exception('Failed to update profile. All endpoints failed.');
    } catch (e) {
      print('Update Profile Error: $e');
      throw Exception('Failed to update profile: $e');
    }
  }

  // ─── UPLOAD PROFILE IMAGE ──────────────────────────────
  Future<UserModel> uploadProfileImage(dynamic imageSource) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw Exception('User not found');
    }

    try {
      print('Uploading profile photo for USER ID: ${currentUser.id}');
      print('Customer Profile ID: ${currentUser.customerProfileId}');

      // Try different field names and endpoints
      List<Map<String, String>> configurations = [
        {
          'endpoint':
              '${AppConstants.apiBaseUrl}/users/${currentUser.id}/upload-photo',
          'field': 'profilePhoto'
        },
        {
          'endpoint':
              '${AppConstants.apiBaseUrl}/users/${currentUser.id}/upload-photo',
          'field': 'profilephoto'
        },
        {
          'endpoint':
              '${AppConstants.apiBaseUrl}/users/${currentUser.id}/upload-photo',
          'field': 'photo'
        },
        {
          'endpoint':
              '${AppConstants.apiBaseUrl}/users/${currentUser.id}/upload-photo',
          'field': 'image'
        },
        {
          'endpoint':
              '${AppConstants.apiBaseUrl}/customer-profiles/${currentUser.customerProfileId}/upload-photo',
          'field': 'profilePhoto'
        },
      ];

      for (var config in configurations) {
        if (config['endpoint']!.contains('null')) continue;

        try {
          print('Trying: ${config['endpoint']} with field: ${config['field']}');

          final request = http.MultipartRequest(
            'PATCH',
            Uri.parse(config['endpoint']!),
          );

          request.headers['Authorization'] = 'Bearer $token';

          if (kIsWeb) {
            // WEB VERSION
            Uint8List bytes;
            String fileName;
            String mimeType;

            if (imageSource is Uint8List) {
              bytes = imageSource;
              fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
              mimeType = 'image/jpeg';
            } else if (imageSource is String) {
              final base64Data = imageSource.split(',').last;
              bytes = base64Decode(base64Data);
              fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
              mimeType = 'image/jpeg';
            } else {
              throw Exception('Unsupported image source for web');
            }

            final multipartFile = http.MultipartFile.fromBytes(
              config['field']!,
              bytes,
              filename: fileName,
              contentType: MediaType.parse(mimeType),
            );

            request.files.add(multipartFile);
          } else {
            // MOBILE VERSION
            if (imageSource is! File) {
              throw Exception('Expected File for mobile platform');
            }

            final file = imageSource;
            if (!await file.exists()) {
              throw Exception('Image file does not exist');
            }

            final fileExtension = file.path.split('.').last.toLowerCase();
            final mimeType =
                fileExtension == 'png' ? 'image/png' : 'image/jpeg';

            final multipartFile = await http.MultipartFile.fromPath(
              config['field']!,
              file.path,
              contentType: MediaType.parse(mimeType),
            );

            request.files.add(multipartFile);
          }

          final streamedResponse = await request.send();
          final response = await http.Response.fromStream(streamedResponse);

          print('Upload Status: ${response.statusCode}');
          print('Upload Response: ${response.body}');

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            final updatedUser = UserModel.fromJson(data);
            await _secureStorage.saveUserData(updatedUser);
            return updatedUser;
          } else if (response.statusCode == 400) {
            print('400 error with field ${config['field']}, trying next...');
            continue;
          }
        } catch (e) {
          print('Error with config $config: $e');
          continue;
        }
      }

      throw Exception('Upload failed. Tried all field names and endpoints.');
    } catch (e) {
      print('Upload Profile Photo Error: $e');
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  // ─── CHANGE PASSWORD ───────────────────────────────────
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    try {
      final response = await http.patch(
        Uri.parse(
            '${AppConstants.apiBaseUrl}${AppConstants.changePasswordEndpoint}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      print('Change Password Status: ${response.statusCode}');
      print('Change Password Response: ${response.body}');

      if (response.statusCode == 200) {
        return;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Password change failed');
      }
    } catch (e) {
      print('Change Password Error: $e');
      rethrow;
    }
  }
}
