// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'constants.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // User-related keys
  static const String _userIdKey = 'user_id';
  static const String _customerIdKey = 'customer_id';
  
  // OTP-related keys
  static const String _otpRequestIdKey = 'otp_request_id';
  static const String _otpPhoneKey = 'otp_phone';
  static const String _otpExpiryKey = 'otp_expiry';
  
  // NEW: Password reset keys
  static const String _resetRequestIdKey = 'reset_request_id';
  static const String _resetPhoneKey = 'reset_phone';
  static const String _resetExpiryKey = 'reset_expiry';

  // ─── TOKEN OPERATIONS ───────────────────────────────────
  Future<void> saveToken(String token) async {
    try {
      if (token.isEmpty) {
        throw Exception('Token cannot be empty');
      }
      await _storage.write(key: AppConstants.tokenKey, value: token);
      print('✅ Token saved successfully');
    } catch (e) {
      print('❌ Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      print('🔑 Token retrieved: ${token != null ? "Exists" : "Null"}');
      return token;
    } catch (e) {
      print('❌ Error getting token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      print('🗑️ Token deleted');
    } catch (e) {
      print('❌ Error deleting token: $e');
    }
  }

  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      final hasToken = token != null && token.isNotEmpty;
      print('🔍 Has token check: $hasToken');
      return hasToken;
    } catch (e) {
      print('❌ Error checking token existence: $e');
      return false;
    }
  }

  // ─── USER DATA OPERATIONS ───────────────────────────────
  Future<void> saveUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userDataKey, value: userJson);
      
      // Also save user ID separately for easy access
      if (user.id.isNotEmpty) {
        await saveUserId(user.id);
        print('✅ User data saved successfully for: ${user.email}');
        print('✅ User ID saved: ${user.id}');
        
        // Also save to shared preferences as backup
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(AppConstants.userDataKey, userJson);
          print('✅ User data backed up to shared preferences');
        } catch (e) {
          print('⚠️ Could not backup to shared preferences: $e');
        }
      }
    } catch (e) {
      print('❌ Error saving user data: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userDataKey);

      if (userJson == null || userJson.isEmpty) {
        print('⚠️ No user data found in secure storage');
        
        // Try to get from shared preferences as fallback
        try {
          final prefs = await SharedPreferences.getInstance();
          final backupUserJson = prefs.getString(AppConstants.userDataKey);
          if (backupUserJson != null && backupUserJson.isNotEmpty) {
            print('🔄 Found user data in shared preferences backup');
            final userMap = jsonDecode(backupUserJson);
            if (userMap is Map<String, dynamic>) {
              return UserModel.fromJson(userMap);
            }
          }
        } catch (e) {
          print('⚠️ Error reading from shared preferences: $e');
        }
        
        return null;
      }

      print('✅ User data retrieved from secure storage');
      final userMap = jsonDecode(userJson);

      if (userMap is! Map<String, dynamic>) {
        print('❌ Invalid user data format');
        return null;
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      print('❌ Error getting user data: $e');
      return null;
    }
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: AppConstants.userDataKey);
      
      // Also delete from shared preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.userDataKey);
      } catch (e) {
        print('⚠️ Could not remove from shared preferences: $e');
      }
      
      print('🗑️ User data deleted');
    } catch (e) {
      print('❌ Error deleting user data: $e');
    }
  }

  Future<bool> hasUserData() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userDataKey);
      return userJson != null && userJson.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  // ─── USER ID OPERATIONS ─────────────────────────────────
  Future<void> saveUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      await _storage.write(key: _userIdKey, value: userId);
      print('✅ User ID saved successfully: $userId');
    } catch (e) {
      print('❌ Error saving user ID: $e');
      rethrow;
    }
  }

  Future<String?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      print('👤 User ID retrieved: ${userId != null ? "Exists" : "Null"}');
      
      // If not found, try to get from user data
      if (userId == null || userId.isEmpty) {
        final user = await getUserData();
        if (user != null && user.id.isNotEmpty) {
          print('🔄 Got user ID from user data: ${user.id}');
          await saveUserId(user.id); // Save for next time
          return user.id;
        }
      }
      
      return userId;
    } catch (e) {
      print('❌ Error getting user ID: $e');
      return null;
    }
  }

  // ─── CUSTOMER ID OPERATIONS ─────────────────────────────
  Future<void> saveCustomerId(String customerId) async {
    try {
      if (customerId.isEmpty) {
        throw Exception('Customer ID cannot be empty');
      }
      await _storage.write(key: _customerIdKey, value: customerId);
      print('✅ Customer ID saved successfully: $customerId');
    } catch (e) {
      print('❌ Error saving customer ID: $e');
      rethrow;
    }
  }

  Future<String?> getCustomerId() async {
    try {
      // First try to get from customer_id key
      final customerId = await _storage.read(key: _customerIdKey);
      if (customerId != null && customerId.isNotEmpty) {
        print('👤 Customer ID retrieved from customer_id key: $customerId');
        return customerId;
      }
      
      // If not found, try user_id as fallback
      final userId = await getUserId();
      if (userId != null && userId.isNotEmpty) {
        print('🔄 Using user ID as customer ID: $userId');
        await saveCustomerId(userId); // Save as customer ID for next time
        return userId;
      }
      
      print('⚠️ No customer ID found');
      return null;
    } catch (e) {
      print('❌ Error getting customer ID: $e');
      return null;
    }
  }

  // ─── OTP OPERATIONS ─────────────────────────────────────
  Future<void> saveOtpRequestData(String requestId, String phone) async {
    try {
      await _storage.write(key: _otpRequestIdKey, value: requestId);
      await _storage.write(key: _otpPhoneKey, value: phone);
      await _storage.write(
        key: _otpExpiryKey, 
        value: DateTime.now().add(const Duration(minutes: 10)).toIso8601String()
      );
      print('✅ OTP data saved: requestId=$requestId, phone=$phone');
    } catch (e) {
      print('❌ Error saving OTP data: $e');
      rethrow;
    }
  }

  Future<Map<String, String>?> getOtpRequestData() async {
    try {
      final requestId = await _storage.read(key: _otpRequestIdKey);
      final phone = await _storage.read(key: _otpPhoneKey);
      final expiry = await _storage.read(key: _otpExpiryKey);
      
      if (requestId == null || phone == null || expiry == null) {
        print('⚠️ No OTP data found');
        return null;
      }
      
      // Check if OTP has expired
      try {
        final expiryTime = DateTime.parse(expiry);
        if (DateTime.now().isAfter(expiryTime)) {
          print('⚠️ OTP data has expired');
          await deleteOtpRequestData();
          return null;
        }
      } catch (e) {
        print('⚠️ Error parsing expiry date: $e');
      }
      
      return {
        'requestId': requestId,
        'phone': phone,
        'expiry': expiry,
      };
    } catch (e) {
      print('❌ Error getting OTP data: $e');
      return null;
    }
  }

  Future<void> deleteOtpRequestData() async {
    try {
      await _storage.delete(key: _otpRequestIdKey);
      await _storage.delete(key: _otpPhoneKey);
      await _storage.delete(key: _otpExpiryKey);
      print('✅ OTP data deleted');
    } catch (e) {
      print('❌ Error deleting OTP data: $e');
    }
  }

  // ─── PASSWORD RESET OPERATIONS ──────────────────────────
  Future<void> saveResetPasswordData(String requestId, String phoneNumber) async {
    try {
      await _storage.write(key: _resetRequestIdKey, value: requestId);
      await _storage.write(key: _resetPhoneKey, value: phoneNumber);
      await _storage.write(
        key: _resetExpiryKey, 
        value: DateTime.now().add(const Duration(hours: 1)).toIso8601String()
      );
      print('✅ Password reset data saved: requestId=$requestId, phone=$phoneNumber');
    } catch (e) {
      print('❌ Error saving password reset data: $e');
      rethrow;
    }
  }

  Future<Map<String, String>?> getResetPasswordData() async {
    try {
      final requestId = await _storage.read(key: _resetRequestIdKey);
      final phone = await _storage.read(key: _resetPhoneKey);
      final expiry = await _storage.read(key: _resetExpiryKey);
      
      if (requestId == null || phone == null || expiry == null) {
        print('⚠️ No password reset data found');
        return null;
      }
      
      // Check if reset data has expired (1 hour)
      try {
        final expiryTime = DateTime.parse(expiry);
        if (DateTime.now().isAfter(expiryTime)) {
          print('⚠️ Password reset data has expired');
          await deleteResetPasswordData();
          return null;
        }
      } catch (e) {
        print('⚠️ Error parsing reset expiry date: $e');
      }
      
      return {
        'requestId': requestId,
        'phoneNumber': phone,
        'expiry': expiry,
      };
    } catch (e) {
      print('❌ Error getting password reset data: $e');
      return null;
    }
  }

  Future<void> deleteResetPasswordData() async {
    try {
      await _storage.delete(key: _resetRequestIdKey);
      await _storage.delete(key: _resetPhoneKey);
      await _storage.delete(key: _resetExpiryKey);
      print('✅ Password reset data deleted');
    } catch (e) {
      print('❌ Error deleting password reset data: $e');
    }
  }

  // ─── GENERAL STORAGE OPERATIONS ─────────────────────────
  Future<String?> read({required String key}) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      print('❌ Error reading key $key: $e');
      return null;
    }
  }

  Future<void> write({required String key, required String value}) async {
    try {
      await _storage.write(key: key, value: value);
      print('✅ Saved to $key: $value');
    } catch (e) {
      print('❌ Error writing to $key: $e');
      rethrow;
    }
  }

  Future<void> delete({required String key}) async {
    try {
      await _storage.delete(key: key);
      print('✅ Deleted key: $key');
    } catch (e) {
      print('❌ Error deleting key $key: $e');
    }
  }

  // ─── UTILITY METHODS ────────────────────────────────────
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      
      // Also clear shared preferences
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.clear();
      } catch (e) {
        print('⚠️ Could not clear shared preferences: $e');
      }
      
      print('🗑️ All storage cleared');
    } catch (e) {
      print('❌ Error clearing storage: $e');
    }
  }

  Future<void> updateUserData(Map<String, dynamic> updates) async {
    try {
      final currentUser = await getUserData();
      if (currentUser != null) {
        // Create updated user by copying with updated fields
        final updatedUser = currentUser.copyWith(
          fullname: updates['fullname'] ?? currentUser.fullname,
          phonenumber: updates['phonenumber'] ?? currentUser.phonenumber,
          address: updates['address'] ?? currentUser.address,
          profilephoto: updates['profilephoto'] ?? currentUser.profilephoto,
          updatedAt: DateTime.now(),
        );
        await saveUserData(updatedUser);
        print('✅ User data updated successfully');
      }
    } catch (e) {
      print('❌ Error updating user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllData() async {
    try {
      final allKeys = await _storage.readAll();
      print('📋 All stored keys: ${allKeys.keys}');
      return allKeys;
    } catch (e) {
      print('❌ Error getting all data: $e');
      return {};
    }
  }

  Future<String?> extractUserIdFromUserData() async {
    try {
      final user = await getUserData();
      if (user != null) {
        print('🔍 Extracted user ID from user data: ${user.id}');
        return user.id;
      }
      return null;
    } catch (e) {
      print('❌ Error extracting user ID: $e');
      return null;
    }
  }
}