// lib/services/auth_service.dart - COMPLETE FIXED VERSION
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import '../models/user_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

// Response wrapper class
class ApiResponse {
  final bool success;
  final dynamic data;
  final String message;
  final int? statusCode;

  ApiResponse({
    required this.success,
    this.data,
    required this.message,
    this.statusCode,
  });
}

class AuthService {
  final SecureStorage _secureStorage = SecureStorage();

  // Helper method to build complete URL
  String _buildUrl(String endpoint) {
    return AppConstants.buildUrl(endpoint);
  }

  // ─── PHONE NUMBER HELPERS ──────────────────────────────
  
  // Clean phone number by removing all non-digit characters
  String _cleanPhoneNumber(String phone) {
    return phone.replaceAll(RegExp(r'[^\d]'), '');
  }
  
  // Validate if phone number is valid (supports all Ethiopian formats)
  bool _isValidEthiopianPhone(String phone) {
    final cleanPhone = _cleanPhoneNumber(phone);
    
    // Must be 9-12 digits
    if (cleanPhone.length < 9 || cleanPhone.length > 12) {
      print('❌ [AuthService] Invalid length: ${cleanPhone.length} digits');
      return false;
    }
    
    final firstDigit = cleanPhone.isNotEmpty ? cleanPhone[0] : '';
    
    // 9-digit format: 9XXXXXXXX or 7XXXXXXXX
    if (cleanPhone.length == 9) {
      if (firstDigit == '9' || firstDigit == '7') {
        print('✅ [AuthService] Valid 9-digit format: $cleanPhone');
        return true;
      }
    }
    
    // 10-digit format: 09XXXXXXXX or 07XXXXXXXX
    if (cleanPhone.length == 10) {
      if (cleanPhone.startsWith('09') || cleanPhone.startsWith('07')) {
        print('✅ [AuthService] Valid 10-digit format: $cleanPhone');
        return true;
      }
    }
    
    // 12-digit format: 2519XXXXXXXX or 2517XXXXXXXX
    if (cleanPhone.length == 12) {
      if (cleanPhone.startsWith('251') && (cleanPhone[3] == '9' || cleanPhone[3] == '7')) {
        print('✅ [AuthService] Valid 12-digit format: $cleanPhone');
        return true;
      }
    }
    
    // For 11-digit (could be something like 0XXXXXXXXXX)
    if (cleanPhone.length == 11) {
      if (cleanPhone.startsWith('09') || cleanPhone.startsWith('07')) {
        final last9 = cleanPhone.substring(2);
        if (last9.length == 9 && (last9[0] == '9' || last9[0] == '7')) {
          print('✅ [AuthService] Valid 11-digit format: $cleanPhone');
          return true;
        }
      }
    }
    
    print('❌ [AuthService] Invalid Ethiopian phone format: $cleanPhone');
    return false;
  }
  
  // Format phone to standard format for API (9XXXXXXXX format for backend)
  String _formatPhoneForApi(String phone) {
    final cleanPhone = _cleanPhoneNumber(phone);
    print('📱 [AuthService] Cleaning phone: $phone -> $cleanPhone');
    
    // If it's 9 digits (9XXXXXXXX or 7XXXXXXXX), keep as is
    if (cleanPhone.length == 9) {
      print('✅ [AuthService] Already 9-digit format: $cleanPhone');
      return cleanPhone;
    }
    
    // If it's 10 digits with leading 0 (09XXXXXXXX or 07XXXXXXXX), remove 0
    if (cleanPhone.length == 10 && (cleanPhone.startsWith('09') || cleanPhone.startsWith('07'))) {
      final formatted = cleanPhone.substring(1);
      print('✅ [AuthService] 10-digit to 9-digit: $cleanPhone -> $formatted');
      return formatted;
    }
    
    // If it's 12 digits with 251 (2519XXXXXXXX or 2517XXXXXXXX), remove 251
    if (cleanPhone.length == 12 && cleanPhone.startsWith('251')) {
      final formatted = cleanPhone.substring(3);
      print('✅ [AuthService] 12-digit to 9-digit: $cleanPhone -> $formatted');
      return formatted;
    }
    
    // For 11 digits (likely 0XXXXXXXXXX)
    if (cleanPhone.length == 11 && (cleanPhone.startsWith('09') || cleanPhone.startsWith('07'))) {
      final formatted = cleanPhone.substring(2);
      if (formatted.length == 9 && (formatted[0] == '9' || formatted[0] == '7')) {
        print('✅ [AuthService] 11-digit to 9-digit: $cleanPhone -> $formatted');
        return formatted;
      }
    }
    
    // For any other valid format, try to extract the 9-digit number
    if (cleanPhone.length >= 9) {
      // Find the last 9 digits
      final formatted = cleanPhone.length > 9 
          ? cleanPhone.substring(cleanPhone.length - 9)
          : cleanPhone;
      
      // Ensure it starts with 9 or 7
      if (formatted.isNotEmpty && (formatted[0] == '9' || formatted[0] == '7')) {
        print('✅ [AuthService] Extracted 9-digit: $cleanPhone -> $formatted');
        return formatted;
      }
    }
    
    print('⚠️ [AuthService] Could not format phone, returning original: $cleanPhone');
    return cleanPhone;
  }

  // Display format for UI (show as 09XXXXXXXX)
  String _formatPhoneForDisplay(String phone) {
    final cleanPhone = _cleanPhoneNumber(phone);
    
    if (cleanPhone.length == 9) {
      return '0$cleanPhone';
    } else if (cleanPhone.length == 10 && (cleanPhone.startsWith('09') || cleanPhone.startsWith('07'))) {
      return cleanPhone;
    } else if (cleanPhone.length == 12 && cleanPhone.startsWith('251')) {
      return '0${cleanPhone.substring(3)}';
    } else if (cleanPhone.length == 11 && (cleanPhone.startsWith('09') || cleanPhone.startsWith('07'))) {
      return cleanPhone;
    }
    
    return phone;
  }

  // ─── OTP REGISTRATION FLOW ──────────────────────────────
  Future<ApiResponse> requestOtp(String phoneNumber) async {
    try {
      print('🔵 [AuthService] Requesting OTP for phone: $phoneNumber');
      
      // Validate phone number
      if (!_isValidEthiopianPhone(phoneNumber)) {
        return ApiResponse(
          success: false,
          message: 'Please enter a valid Ethiopian phone number\n'
                   'Accepted formats:\n'
                   '• 9XXXXXXXX or 7XXXXXXXX (9 digits)\n'
                   '• 09XXXXXXXX or 07XXXXXXXX (10 digits)\n'
                   '• +2519XXXXXXXX or +2517XXXXXXXX (13 characters)',
        );
      }
      
      // Format phone for API
      final formattedPhone = _formatPhoneForApi(phoneNumber);
      print('📱 [AuthService] Formatted phone for OTP: $formattedPhone');
      
      final url = _buildUrl(AppConstants.requestOtpEndpoint);
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phonenumber': formattedPhone,
        }),
      );

      print('🟢 [AuthService] OTP Response: ${response.statusCode}');
      print('🟢 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // Save OTP request data if available
          final otpData = responseData['data'];
          if (otpData != null) {
            final requestId = otpData['requestId'] ?? otpData['_id'];
            if (requestId != null) {
              await _secureStorage.saveOtpRequestData(
                requestId, 
                formattedPhone
              );
              print('✅ [AuthService] OTP data saved');
            }
          }
          
          return ApiResponse(
            success: true,
            data: responseData,
            message: responseData['message'] ?? 'OTP sent successfully',
          );
        } else {
          return ApiResponse(
            success: false,
            data: responseData,
            message: responseData['message'] ?? 'Failed to send OTP',
            statusCode: response.statusCode,
          );
        }
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return ApiResponse(
          success: false,
          data: errorData,
          message: errorData['message'] ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('🔴 [AuthService] OTP request error: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to send OTP. Please check your internet connection.',
      );
    }
  }

  Future<ApiResponse> verifyOtpAndRegister({
    required String otp,
    required String requestId,
    required String phone,
    required String fullname,
    required String email,
    required String address,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      print('🔵 [AuthService] Verifying OTP and registering user');
      
      // Format phone for API
      final formattedPhone = _formatPhoneForApi(phone);
      print('📱 [AuthService] Formatted phone for registration: $formattedPhone');
      print('📧 [AuthService] Email: $email');
      print('📍 [AuthService] Address: $address');
      
      final url = _buildUrl(AppConstants.verifyOtpAndRegisterEndpoint);
      
      // Prepare the request body with all required fields
      Map<String, dynamic> requestBody = {
        'requestId': requestId,
        'phonenumber': formattedPhone,
        'otp': otp.trim(),
        'fullname': fullname.trim(),
        'password': password,
        'confirmPassword': confirmPassword,
      };
      
      // Add email and address (even if empty)
      requestBody['email'] = email.trim();
      requestBody['address'] = address.trim();
      
      print('🔵 [AuthService] Request Body: $requestBody');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );

      print('🟢 [AuthService] Verify OTP Response: ${response.statusCode}');
      print('🟢 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Clean up OTP data
        await _secureStorage.deleteOtpRequestData();
        
        // Extract user data from response
        final userData = responseData['user'] ?? responseData['data'];
        final token = responseData['token'];
        
        if (token != null && userData != null) {
          final user = UserModel.fromJson(userData);
          await _secureStorage.saveToken(token);
          await _secureStorage.saveUserData(user);
          
          if (user.id.isNotEmpty) {
            await _secureStorage.saveUserId(user.id);
          }
          
          print('✅ [AuthService] User registered and logged in');
        }
        
        return ApiResponse(
          success: true,
          data: responseData,
          message: responseData['message'] ?? 'Registration successful',
        );
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        print('🔴 [AuthService] Error details: $errorData');
        return ApiResponse(
          success: false,
          data: errorData,
          message: errorData['message'] ?? 'OTP verification failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('🔴 [AuthService] Registration error: $e');
      return ApiResponse(
        success: false,
        message: 'Registration failed. Please try again.',
      );
    }
  }

  // ─── PASSWORD RESET FLOW ──────────────────────────────
  
  // Request OTP for password reset - FIXED VERSION
  Future<ApiResponse> requestPasswordResetOtp(String phoneNumber) async {
    try {
      print('🔵 [AuthService] Requesting password reset OTP for: $phoneNumber');
      
      // Validate phone number
      if (!_isValidEthiopianPhone(phoneNumber)) {
        return ApiResponse(
          success: false,
          message: 'Please enter a valid Ethiopian phone number\n'
                   'Accepted formats:\n'
                   '• 9XXXXXXXX or 7XXXXXXXX (9 digits)\n'
                   '• 09XXXXXXXX or 07XXXXXXXX (10 digits)\n'
                   '• +2519XXXXXXXX or +2517XXXXXXXX (13 characters)',
        );
      }
      
      // Format phone for API
      final formattedPhone = _formatPhoneForApi(phoneNumber);
      print('📱 [AuthService] Formatted phone for reset: $formattedPhone');
      
      final url = _buildUrl(AppConstants.forgotPasswordEndpoint);
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phonenumber': formattedPhone,
        }),
      );

      print('🟢 [AuthService] Password Reset OTP Response: ${response.statusCode}');
      print('🟢 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        if (responseData['success'] == true) {
          // FIX: Generate a requestId locally since backend doesn't provide one
          // The backend uses phone number to identify the OTP session
          String requestId = 'reset_${DateTime.now().millisecondsSinceEpoch}_$formattedPhone';
          
          // Save reset request data with generated requestId
          await _secureStorage.saveResetPasswordData(requestId, formattedPhone);
          print('✅ [AuthService] Reset password data saved - requestId: $requestId, phone: $formattedPhone');
          
          return ApiResponse(
            success: true,
            data: {
              ...responseData,
              'requestId': requestId, // Add generated requestId
              'phone': formattedPhone,
            },
            message: responseData['message'] ?? 'Password reset OTP sent successfully',
          );
        } else {
          return ApiResponse(
            success: false,
            data: responseData,
            message: responseData['message'] ?? 'Failed to send password reset OTP',
            statusCode: response.statusCode,
          );
        }
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        return ApiResponse(
          success: false,
          data: errorData,
          message: errorData['message'] ?? 'Failed to send password reset OTP',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('🔴 [AuthService] Password reset OTP error: $e');
      return ApiResponse(
        success: false,
        message: 'Failed to send password reset OTP. Please check your internet connection.',
      );
    }
  }

  // Reset password with OTP - FIXED VERSION
  Future<ApiResponse> resetPasswordWithOtp({
    required String otp,
    required String newPassword,
    String? requestId,
    String? phoneNumber,
  }) async {
    try {
      print('🔵 [AuthService] Resetting password with OTP');
      print('🔑 [AuthService] OTP: $otp');
      print('🔑 [AuthService] New password length: ${newPassword.length}');
      
      // Get requestId and phoneNumber from storage if not provided
      String finalRequestId = requestId ?? '';
      String finalPhoneNumber = phoneNumber ?? '';
      
      if (finalRequestId.isEmpty || finalPhoneNumber.isEmpty) {
        final resetData = await _secureStorage.getResetPasswordData();
        finalRequestId = finalRequestId.isEmpty ? (resetData?['requestId'] ?? '') : finalRequestId;
        finalPhoneNumber = finalPhoneNumber.isEmpty ? (resetData?['phoneNumber'] ?? '') : finalPhoneNumber;
      }
      
      print('📝 [AuthService] Using requestId: $finalRequestId');
      print('📱 [AuthService] Using phone: $finalPhoneNumber');
      
      if (finalRequestId.isEmpty || finalPhoneNumber.isEmpty) {
        return ApiResponse(
          success: false,
          message: 'Password reset session expired. Please request a new OTP.',
        );
      }
      
      // Format phone for API
      final formattedPhone = _formatPhoneForApi(finalPhoneNumber);
      print('📱 [AuthService] Formatted phone for reset: $formattedPhone');
      
      final url = _buildUrl(AppConstants.resetPasswordEndpoint);
      
      print('📤 [AuthService] Sending to: $url');
      print('📦 [AuthService] Request body:');
      print('  - requestId: $finalRequestId');
      print('  - phonenumber: $formattedPhone');
      print('  - otp: $otp');
      print('  - newPassword: [${newPassword.length} chars]');
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'requestId': finalRequestId,
          'phonenumber': formattedPhone,
          'otp': otp.trim(),
          'newPassword': newPassword,
        }),
      );

      print('🟢 [AuthService] Reset Password Response: ${response.statusCode}');
      print('🟢 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = jsonDecode(response.body);
        
        // Clean up reset data
        await _secureStorage.deleteResetPasswordData();
        
        return ApiResponse(
          success: true,
          data: responseData,
          message: responseData['message'] ?? 'Password reset successful',
        );
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        print('🔴 [AuthService] Error details: $errorData');
        return ApiResponse(
          success: false,
          data: errorData,
          message: errorData['message'] ?? 'Password reset failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('🔴 [AuthService] Reset password error: $e');
      return ApiResponse(
        success: false,
        message: 'Password reset failed. Please try again.',
      );
    }
  }

  // ─── LOGIN ──────────────────────────────────────────────
  Future<UserModel> login(String phoneNumber, String password) async {
    try {
      print('🔵 [AuthService] Logging in with phone: $phoneNumber');
      
      // Format phone for API
      final formattedPhone = _formatPhoneForApi(phoneNumber);
      print('📱 [AuthService] Formatted phone for login: $formattedPhone');
      
      final url = _buildUrl(AppConstants.loginEndpoint);
      
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phonenumber': formattedPhone,
          'password': password
        }),
      );

      print('🟢 [AuthService] Login Response: ${response.statusCode}');
      print('🟢 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Check for token in response
        if (data.containsKey('token')) {
          final token = data['token'];
          final userData = data['user'] ?? data['data'] ?? data;
          
          if (token == null) {
            throw Exception('No token received from server');
          }
          
          final user = UserModel.fromJson(userData);
          
          // Save auth data
          await _secureStorage.saveToken(token);
          await _secureStorage.saveUserData(user);

          if (user.id.isNotEmpty) {
            await _secureStorage.saveUserId(user.id);
            print('✅ User ID saved: ${user.id}');
          }

          print('✅ [AuthService] Login successful!');
          return user;
        } 
        // Check for success structure
        else if (data['success'] == true && data['data'] != null) {
          final userData = data['data'];
          
          if (userData['token'] != null) {
            final token = userData['token'];
            final user = UserModel.fromJson(userData);
            
            await _secureStorage.saveToken(token);
            await _secureStorage.saveUserData(user);

            if (user.id.isNotEmpty) {
              await _secureStorage.saveUserId(user.id);
              print('✅ User ID saved: ${user.id}');
            }

            print('✅ [AuthService] Login successful!');
            return user;
          } else {
            throw Exception('Invalid response format from server');
          }
        }
        else {
          final errorMsg = data['message'] ?? data['error'] ?? 'Invalid response format';
          print('🔴 [AuthService] Login failed: $errorMsg');
          throw Exception(errorMsg);
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid phone number or password');
      } else if (response.statusCode == 400) {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final errorMsg = errorData['message'] ?? 'Bad request. Please check your input.';
        throw Exception(errorMsg);
      } else {
        final errorData = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        final errorMsg = errorData['message'] ?? 'Login failed. Please try again.';
        throw Exception(errorMsg);
      }
    } catch (e) {
      print('🔴 [AuthService] Login Error: $e');
      rethrow;
    }
  }

  // Alias for backward compatibility
  Future<UserModel> loginWithPhone(String phoneNumber, String password) async {
    return login(phoneNumber, password);
  }

  // ─── LOGOUT ─────────────────────────────────────────────
  Future<void> logout() async {
    try {
      final token = await _secureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        try {
          final url = _buildUrl(AppConstants.logoutEndpoint);
          await http.post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );
          print('✅ [AuthService] Logout API successful');
        } catch (e) {
          print('🟡 [AuthService] Logout API call failed: $e');
        }
      }
    } catch (e) {
      print('🔴 [AuthService] Logout error: $e');
    } finally {
      await _secureStorage.clearAll();
      print('✅ [AuthService] All storage cleared');
    }
  }

  // ─── UTILITIES ─────────────────────────────────────────
  Future<bool> isLoggedIn() async => await _secureStorage.hasToken();

  Future<UserModel?> getCurrentUser() async => await _secureStorage.getUserData();

  Future<String?> getToken() async => await _secureStorage.getToken();

  // Validate phone number for UI
  bool validatePhoneNumber(String phone) {
    return _isValidEthiopianPhone(phone);
  }

  // ─── GET OTP REQUEST DATA ──────────────────────────────
  Future<Map<String, String>?> getOtpRequestData() async {
    try {
      return await _secureStorage.getOtpRequestData();
    } catch (e) {
      print('🔴 [AuthService] Error getting OTP data: $e');
      return null;
    }
  }

  // ─── GET RESET PASSWORD DATA ───────────────────────────
  Future<Map<String, String>?> getResetPasswordData() async {
    try {
      return await _secureStorage.getResetPasswordData();
    } catch (e) {
      print('🔴 [AuthService] Error getting reset password data: $e');
      return null;
    }
  }

  // ─── FETCH PROFILE ─────────────────────────────────────
  Future<UserModel> fetchUserProfile() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated');
    }

    try {
      print('🔵 [AuthService] Fetching user profile');
      
      final url = _buildUrl(AppConstants.profileEndpoint);
      
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🟢 [AuthService] Profile Response: ${response.statusCode}');
      print('🟢 [AuthService] Profile Body: ${response.body}');

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
      print('🔴 [AuthService] Fetch Profile Error: $e');
      rethrow;
    }
  }

  // ─── UPDATE PROFILE ────────────────────────────────────
  Future<UserModel> updateProfile({
    String? fullname,
    String? phonenumber,
    String? email,
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
      payload['phonenumber'] = _formatPhoneForApi(phonenumber);
    }
    if (email != null) {
      payload['email'] = email.trim();
    }
    if (address != null) {
      payload['address'] = address.trim();
    }

    if (payload.isEmpty) {
      return currentUser;
    }

    try {
      final endpoint = 'infinity-booking/users/${currentUser.id}';
      final url = _buildUrl(endpoint);
      
      print('🔵 [AuthService] Updating profile with payload: $payload');
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      );

      print('🟢 [AuthService] Update Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = UserModel.fromJson(data);
        await _secureStorage.saveUserData(updatedUser);
        print('✅ [AuthService] Profile updated');
        return updatedUser;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      print('🔴 [AuthService] Update Profile Error: $e');
      throw Exception('Failed to update profile: $e');
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
      print('🔵 [AuthService] Changing password');
      
      final url = _buildUrl(AppConstants.changePasswordEndpoint);
      
      final response = await http.patch(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      print('🟢 [AuthService] Change Password Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        print('✅ [AuthService] Password changed');
        return;
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Password change failed');
      }
    } catch (e) {
      print('🔴 [AuthService] Change Password Error: $e');
      rethrow;
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
      // CORRECT ENDPOINT based on your error log - should be lowercase 'profilephoto'
      final endpoint = 'infinity-booking/users/${currentUser.id}/upload-photo';
      final url = '${AppConstants.baseUrl}/$endpoint';
      
      print('📤 [AuthService] Uploading profile photo for user: ${currentUser.id}');
      print('🌐 [AuthService] Upload URL: $url');
      print('🔑 [AuthService] Token exists: ${token.isNotEmpty}');

      final request = http.MultipartRequest('PATCH', Uri.parse(url));
      request.headers['Authorization'] = 'Bearer $token';
      // Don't set Content-Type for multipart requests - let the library handle it

      if (kIsWeb) {
        // WEB VERSION
        Uint8List bytes;
        String fileName;
        String mimeType;

        if (imageSource is Uint8List) {
          bytes = imageSource;
          fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          mimeType = 'image/jpeg';
          print('📷 [AuthService] Web: Using Uint8List (${bytes.length} bytes)');
        } else if (imageSource is String) {
          final base64Data = imageSource.split(',').last;
          bytes = base64Decode(base64Data);
          fileName = 'profile_${DateTime.now().millisecondsSinceEpoch}.jpg';
          mimeType = 'image/jpeg';
          print('📷 [AuthService] Web: Using base64 string (${bytes.length} bytes)');
        } else {
          throw Exception('Unsupported image source for web');
        }

        // Validate image size (5MB limit)
        if (bytes.length > 5 * 1024 * 1024) {
          throw Exception('Image size must be less than 5MB');
        }

        // FIXED: Use lowercase 'profilephoto' as field name
        final multipartFile = http.MultipartFile.fromBytes(
          'profilephoto', // FIXED: lowercase field name
          bytes,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
        print('✅ [AuthService] Added file to request: $fileName (${bytes.length} bytes)');
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
        final mimeType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';
        final fileSize = await file.length();
        
        print('📷 [AuthService] Mobile: File path: ${file.path}');
        print('📷 [AuthService] Mobile: File size: ${fileSize} bytes');
        print('📷 [AuthService] Mobile: MIME type: $mimeType');

        // Validate image size (5MB limit)
        if (fileSize > 5 * 1024 * 1024) {
          throw Exception('Image size must be less than 5MB');
        }

        // FIXED: Use lowercase 'profilephoto' as field name
        final multipartFile = await http.MultipartFile.fromPath(
          'profilephoto', // FIXED: lowercase field name
          file.path,
          contentType: MediaType.parse(mimeType),
        );

        request.files.add(multipartFile);
        print('✅ [AuthService] Added file to request: ${file.path} (${fileSize} bytes)');
      }

      print('🔄 [AuthService] Sending request...');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('🟢 [AuthService] Upload Response: ${response.statusCode}');
      print('📄 [AuthService] Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final updatedUser = UserModel.fromJson(data);
        await _secureStorage.saveUserData(updatedUser);
        print('✅ [AuthService] Profile photo uploaded successfully');
        return updatedUser;
      } else {
        // Try with different field name combinations
        print('⚠️ [AuthService] Upload failed with status: ${response.statusCode}');
        throw Exception('Upload failed: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('🔴 [AuthService] Upload Profile Photo Error: $e');
      throw Exception('Upload failed: ${e.toString()}');
    }
  }

  // Helper method to parse user data properly
  UserModel _parseUserFromResponse(Map<String, dynamic> data) {
    try {
      // Check both possible field names (profilePhoto vs profilephoto)
      final profilePhoto = data['profilePhoto'] ?? data['profilephoto'] ?? '';
      
      // Extract customer profile data
      final customerProfile = data['customerProfile'] as Map<String, dynamic>? ?? {};
      
      // Merge data from both sources
      final userData = {...data};
      if (customerProfile.isNotEmpty) {
        userData.addAll(customerProfile);
      }
      
      // Create UserModel using the UserModel.fromJson factory
      return UserModel.fromJson(userData);
      
    } catch (e) {
      print('❌ [AuthService] Error parsing user: $e');
      // Fallback: create basic user from available data
      return UserModel(
        id: data['_id']?.toString() ?? '',
        fullname: data['fullname']?.toString() ?? '',
        email: data['email']?.toString() ?? '',
        phonenumber: data['phonenumber']?.toString() ?? '',
        profilephoto: data['profilePhoto']?.toString() ?? data['profilephoto']?.toString(),
        address: data['address']?.toString(),
        createdAt: data['createdAt'] != null 
            ? DateTime.parse(data['createdAt'].toString())
            : DateTime.now(),
        updatedAt: data['updatedAt'] != null 
            ? DateTime.tryParse(data['updatedAt'].toString())
            : null,
        customerProfileId: null,
        pid: null,
        role: data['role']?.toString() ?? 'customer',
        isActive: true,
        isVerified: data['isVerified'] as bool? ?? false,
        authToken: null,
        cid: data['cid']?.toString(),
      );
    }
  }

  // Test upload endpoint
  Future<void> testUploadEndpoint() async {
    try {
      print('🧪 [AuthService] Testing upload endpoint...');
      
      final token = await getToken();
      final user = await getCurrentUser();
      
      if (token == null || user == null) {
        print('❌ No token or user found');
        return;
      }
      
      print('✅ Token exists (${token.substring(0, 20)}...)');
      print('✅ User ID: ${user.id}');
      
      // Test different endpoints
      final endpoints = [
        'infinity-booking/users/${user.id}/upload-photo',
        'infinity-booking/users/upload-photo',
        'infinity-booking/users/profile-photo',
      ];
      
      for (final endpoint in endpoints) {
        final url = '${AppConstants.baseUrl}/$endpoint';
        print('\n🔍 Testing: $url');
        
        try {
          final testResponse = await http.get(
            Uri.parse(url),
            headers: {'Authorization': 'Bearer $token'},
          );
          print('🟡 Response: ${testResponse.statusCode}');
        } catch (e) {
          print('🟡 GET failed: $e');
        }
      }
      
    } catch (e) {
      print('🔴 Test error: $e');
    }
  }

  // Save user data
  Future<void> saveUserData(UserModel user) async {
    await _secureStorage.saveUserData(user);
  }

  // Clear all data
  Future<void> clearAllData() async {
    await _secureStorage.clearAll();
  }
}