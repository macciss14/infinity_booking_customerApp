// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'constants.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // ✅ ADD userId Key constant INSIDE the class
  static const String _userIdKey = 'user_id';
  
  // 🔥 NEW: Add constant for customer ID (this might be different from user ID)
  static const String _customerIdKey = 'customer_id';

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

  Future<void> saveUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userDataKey, value: userJson);
      
      // 🔥 NEW: Also save user ID separately for easy access
      if (user.id.isNotEmpty) {
        await saveUserId(user.id);
        print('✅ User data saved successfully for: ${user.email}');
        print('✅ User ID saved: ${user.id}');
        
        // 🔥 ALSO save to shared preferences as backup
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
        
        // 🔥 NEW: Try to get from shared preferences as fallback
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
      
      // 🔥 NEW: Also delete from shared preferences
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

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      
      // 🔥 NEW: Also clear shared preferences
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

  // Additional utility methods

  Future<bool> hasUserData() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userDataKey);
      return userJson != null && userJson.isNotEmpty;
    } catch (e) {
      return false;
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

  // ✅ ADD getUserId and saveUserId INSIDE the class
  Future<String?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      print('👤 User ID retrieved: ${userId != null ? "Exists" : "Null"}');
      
      // 🔥 NEW: If not found, try to get from user data
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

  // 🔥 NEW: Customer ID methods (customer ID might be different from user ID)
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

  // 🔥 NEW: Extract user ID from user data
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