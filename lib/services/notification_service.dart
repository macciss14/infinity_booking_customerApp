import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class NotificationService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();
  
  Future<List<NotificationModel>> getUserNotifications({
    bool? unreadOnly,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return [];
      }

      const String endpoint = 'infinity-booking/notifications/my-notifications';
      String url = AppConstants.buildUrl(endpoint);

      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (unreadOnly == true) 'unreadOnly': 'true',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);

      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is! Map<String, dynamic>) {
          return [];
        }

        List<dynamic> notificationsData = [];
        
        if (data.containsKey('data') && data['data'] is List) {
          notificationsData = data['data'];
        } else if (data.containsKey('notifications') && data['notifications'] is List) {
          notificationsData = data['notifications'];
        } else if (data.containsKey('items') && data['items'] is List) {
          notificationsData = data['items'];
        }

        return notificationsData
            .map<NotificationModel>((json) => NotificationModel.fromJson(json))
            .toList();
      } else {
        debugPrint('API Error: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (error) {
      debugPrint('Error in NotificationService.getUserNotifications: $error');
      return [];
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return 0;
      }

      const String endpoint = 'infinity-booking/notifications/unread-count';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data is Map) {
          return (data['count'] as num?)?.toInt() ?? 
                 (data['unreadCount'] as num?)?.toInt() ?? 
                 (data['totalUnread'] as num?)?.toInt() ?? 0;
        } else if (data is num) {
          return data.toInt();
        }
      }
      debugPrint('Failed to get unread count: ${response.statusCode}');
      return 0;
    } catch (error) {
      debugPrint('Error fetching unread count: $error');
      return 0;
    }
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return false;
      }

      final endpoint = 'infinity-booking/notifications/$notificationId/read';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (error) {
      debugPrint('Error marking as read: $error');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return false;
      }

      const String endpoint = 'infinity-booking/notifications/all/read';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (error) {
      debugPrint('Error marking all as read: $error');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('No authentication token found');
        return false;
      }

      final endpoint = 'infinity-booking/notifications/$notificationId';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (error) {
      debugPrint('Error deleting notification: $error');
      return false;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}