// lib/utils/secure_storage.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import 'constants.dart';

class SecureStorage {
  static const FlutterSecureStorage _storage = FlutterSecureStorage();
  
  // ✅ ADD userId Key constant INSIDE the class
  static const String _userIdKey = 'user_id';

  Future<void> saveToken(String token) async {
    try {
      if (token.isEmpty) {
        throw Exception('Token cannot be empty');
      }
      await _storage.write(key: AppConstants.tokenKey, value: token);
      print('Token saved successfully');
    } catch (e) {
      print('Error saving token: $e');
      rethrow;
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: AppConstants.tokenKey);
      print('Token retrieved: ${token != null ? "Exists" : "Null"}');
      return token;
    } catch (e) {
      print('Error getting token: $e');
      return null;
    }
  }

  Future<void> deleteToken() async {
    try {
      await _storage.delete(key: AppConstants.tokenKey);
      print('Token deleted');
    } catch (e) {
      print('Error deleting token: $e');
    }
  }

  Future<void> saveUserData(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await _storage.write(key: AppConstants.userDataKey, value: userJson);
      print('User data saved successfully for: ${user.email}');
    } catch (e) {
      print('Error saving user data: $e');
      rethrow;
    }
  }

  Future<UserModel?> getUserData() async {
    try {
      final userJson = await _storage.read(key: AppConstants.userDataKey);

      if (userJson == null || userJson.isEmpty) {
        print('No user data found in storage');
        return null;
      }

      print('User data retrieved from storage');
      final userMap = jsonDecode(userJson);

      if (userMap is! Map<String, dynamic>) {
        print('Invalid user data format');
        return null;
      }

      return UserModel.fromJson(userMap);
    } catch (e) {
      print('Error getting user data: $e');
      return null;
    }
  }

  Future<void> deleteUserData() async {
    try {
      await _storage.delete(key: AppConstants.userDataKey);
      print('User data deleted');
    } catch (e) {
      print('Error deleting user data: $e');
    }
  }

  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      print('All storage cleared');
    } catch (e) {
      print('Error clearing storage: $e');
    }
  }

  Future<bool> hasToken() async {
    try {
      final token = await getToken();
      final hasToken = token != null && token.isNotEmpty;
      print('Has token check: $hasToken');
      return hasToken;
    } catch (e) {
      print('Error checking token existence: $e');
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
        print('User data updated successfully');
      }
    } catch (e) {
      print('Error updating user data: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getAllData() async {
    try {
      final allKeys = await _storage.readAll();
      print('All stored keys: ${allKeys.keys}');
      return allKeys;
    } catch (e) {
      print('Error getting all data: $e');
      return {};
    }
  }

  // ✅ ADD getUserId and saveUserId INSIDE the class
  Future<String?> getUserId() async {
    try {
      final userId = await _storage.read(key: _userIdKey);
      print('User ID retrieved: ${userId != null ? "Exists" : "Null"}');
      return userId;
    } catch (e) {
      print('Error getting user ID: $e');
      return null;
    }
  }

  Future<void> saveUserId(String userId) async {
    try {
      if (userId.isEmpty) {
        throw Exception('User ID cannot be empty');
      }
      await _storage.write(key: _userIdKey, value: userId);
      print('User ID saved successfully');
    } catch (e) {
      print('Error saving user ID: $e');
      rethrow;
    }
  }
}