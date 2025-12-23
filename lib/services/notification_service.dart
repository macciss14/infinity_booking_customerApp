// lib/services/notification_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class NotificationService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();

  // Get user notifications
  Future<List<NotificationModel>> getUserNotifications({
    bool? unreadOnly,
    int page = 1,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return [];

      const String endpoint = 'infinity-booking/notifications/my-notifications';
      String url = AppConstants.buildUrl(endpoint);

      final params = {
        'page': page.toString(),
        'limit': '20',
        if (unreadOnly == true) 'unreadOnly': 'true',
      };

      final queryString = Uri(queryParameters: params).query;
      if (queryString.isNotEmpty) {
        url = '$url?$queryString';
      }

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> notificationsData = [];

        if (data is Map) {
          notificationsData = data['notifications'] ?? data['data'] ?? [];
        } else if (data is List) {
          notificationsData = data;
        }

        return notificationsData
            .map((json) => NotificationModel.fromJson(json))
            .toList();
      }
      return [];
    } catch (error) {
      print('❌ Error fetching notifications: $error');
      return [];
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return 0;

      const String endpoint = 'infinity-booking/notifications/unread-count';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['count'] as num?)?.toInt() ?? 0;
      }
      return 0;
    } catch (error) {
      print('❌ Error fetching unread count: $error');
      return 0;
    }
  }

  // Mark as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return false;

      final endpoint = 'infinity-booking/notifications/$notificationId/read';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (error) {
      print('❌ Error marking as read: $error');
      return false;
    }
  }

  // Mark all as read
  Future<bool> markAllAsRead() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return false;

      const String endpoint = 'infinity-booking/notifications/all/read';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (error) {
      print('❌ Error marking all as read: $error');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return false;

      final endpoint = 'infinity-booking/notifications/$notificationId';
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      return response.statusCode == 200;
    } catch (error) {
      print('❌ Error deleting notification: $error');
      return false;
    }
  }

  void dispose() {
    _httpClient.close();
  }
}