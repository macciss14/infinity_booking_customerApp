// lib/services/notification_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/notification_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class NotificationService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();
  
  // Main method to get user notifications
  Future<List<NotificationModel>> getUserNotifications({
    bool? unreadOnly,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      debugPrint('📱 [NotificationService] Fetching notifications...');
      
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('❌ [NotificationService] No auth token found');
        return [];
      }

      // Use the correct endpoint
      const String endpoint = AppConstants.userNotificationsEndpoint;
      debugPrint('📱 Endpoint: $endpoint');
      
      String url = AppConstants.buildUrl(endpoint);
      debugPrint('📱 Full URL: $url');
      
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (unreadOnly == true) 'unreadOnly': 'true',
      };

      final uri = Uri.parse(url).replace(queryParameters: params);
      debugPrint('📱 Final URI with params: $uri');

      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      debugPrint('📱 Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseBody = response.body;
        
        if (responseBody.isEmpty) {
          debugPrint('📱 Response body is empty');
          return [];
        }
        
        debugPrint('📱 Response body length: ${responseBody.length} chars');
        
        try {
          final data = jsonDecode(responseBody);
          
          // Handle different response structures
          List<dynamic> notificationsData = [];
          
          if (data is Map<String, dynamic>) {
            debugPrint('📱 Response is a Map, keys: ${data.keys.toList()}');
            
            // Check for common response formats
            if (data.containsKey('success') && data['success'] == true) {
              // Format: {"success": true, "data": [...]}
              if (data['data'] is List) {
                notificationsData = data['data'];
              }
            } 
            else if (data.containsKey('data') && data['data'] is List) {
              notificationsData = data['data'];
            }
            else if (data.containsKey('notifications') && data['notifications'] is List) {
              notificationsData = data['notifications'];
            }
            else if (data.containsKey('items') && data['items'] is List) {
              notificationsData = data['items'];
            }
            else if (data.containsKey('results') && data['results'] is List) {
              notificationsData = data['results'];
            }
            else {
              // Try to find any list in the response
              for (var key in data.keys) {
                if (data[key] is List) {
                  notificationsData = data[key];
                  debugPrint('📱 Found list in key "$key"');
                  break;
                }
              }
            }
          } 
          else if (data is List) {
            debugPrint('📱 Response is directly a List');
            notificationsData = data;
          }

          debugPrint('📱 Found ${notificationsData.length} notification items');
          
          final notifications = notificationsData
              .where((item) => item != null && item is Map)
              .map<NotificationModel>((json) {
                try {
                  return NotificationModel.fromJson(json);
                } catch (e) {
                  debugPrint('❌ Error parsing notification: $e\nJSON: $json');
                  return NotificationModel(
                    id: 'error-${DateTime.now().millisecondsSinceEpoch}',
                    title: 'Error',
                    message: 'Failed to parse notification',
                    type: 'system',
                    isRead: false,
                    createdAt: DateTime.now(),
                  );
                }
              })
              .where((notification) => notification.id.isNotEmpty)
              .toList();
          
          debugPrint('✅ Successfully parsed ${notifications.length} notifications');
          
          // Sort by creation date (newest first)
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          
          return notifications;
        } catch (parseError) {
          debugPrint('❌ JSON Parse Error: $parseError');
          debugPrint('❌ Response body: ${responseBody.substring(0, 200)}...');
          return [];
        }
      } 
      else if (response.statusCode == 401) {
        debugPrint('❌ Unauthorized (401) - Token may be expired');
        await _secureStorage.deleteToken();
        return [];
      } 
      else if (response.statusCode == 404) {
        debugPrint('❌ Endpoint not found (404)');
        debugPrint('❌ Response: ${response.body}');
        return [];
      } 
      else if (response.statusCode == 403) {
        debugPrint('❌ Forbidden (403)');
        return [];
      }
      else {
        debugPrint('❌ API Error ${response.statusCode}: ${response.body}');
        return [];
      }
    } catch (error) {
      debugPrint('❌ Exception in getUserNotifications: $error');
      if (error is http.ClientException) {
        debugPrint('❌ Network error: ${error.message}');
      }
      return [];
    }
  }

  // Get unread count
  Future<int> getUnreadCount() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('📱 No auth token for unread count');
        return 0;
      }

      const String endpoint = AppConstants.unreadNotificationsCountEndpoint;
      final url = AppConstants.buildUrl(endpoint);
      
      debugPrint('📱 Fetching unread count from: $url');

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('📱 Unread count response: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('📱 Unread count data: $data');
        
        if (data is Map<String, dynamic>) {
          // Try different possible keys
          if (data.containsKey('count')) {
            return (data['count'] as num).toInt();
          } else if (data.containsKey('unreadCount')) {
            return (data['unreadCount'] as num).toInt();
          } else if (data.containsKey('totalUnread')) {
            return (data['totalUnread'] as num).toInt();
          } else if (data.containsKey('unread_count')) {
            return (data['unread_count'] as num).toInt();
          } else if (data.containsKey('total')) {
            return (data['total'] as num).toInt();
          }
        } else if (data is num) {
          return data.toInt();
        } else if (data is int) {
          return data;
        } else if (data is String) {
          return int.tryParse(data) ?? 0;
        }
      }
      
      debugPrint('📱 Failed to get unread count: ${response.body}');
      return 0;
    } catch (error) {
      debugPrint('❌ Error fetching unread count: $error');
      return 0;
    }
  }

  // Mark notification as read
  Future<bool> markAsRead(String notificationId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('❌ No auth token for markAsRead');
        return false;
      }

      final endpoint = AppConstants.markNotificationReadEndpoint.replaceAll('{id}', notificationId);
      final url = AppConstants.buildUrl(endpoint);
      debugPrint('📱 Mark as read URL: $url');

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: jsonEncode({'isRead': true}),
      ).timeout(const Duration(seconds: 15));

      debugPrint('📱 Mark as read response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (error) {
      debugPrint('❌ Error marking as read: $error');
      return false;
    }
  }

  // Mark all notifications as read
  Future<bool> markAllAsRead() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('❌ No auth token for markAllAsRead');
        return false;
      }

      const String endpoint = AppConstants.markAllNotificationsReadEndpoint;
      final url = AppConstants.buildUrl(endpoint);
      debugPrint('📱 Mark all read URL: $url');

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('📱 Mark all read response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (error) {
      debugPrint('❌ Error marking all as read: $error');
      return false;
    }
  }

  // Delete notification
  Future<bool> deleteNotification(String notificationId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) {
        debugPrint('❌ No auth token for deleteNotification');
        return false;
      }

      final endpoint = AppConstants.deleteNotificationEndpoint.replaceAll('{id}', notificationId);
      final url = AppConstants.buildUrl(endpoint);
      debugPrint('📱 Delete notification URL: $url');

      final response = await _httpClient.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 15));

      debugPrint('📱 Delete response: ${response.statusCode}');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (error) {
      debugPrint('❌ Error deleting notification: $error');
      return false;
    }
  }

  // Initialize and load notifications on app start
  Future<void> initialize() async {
    try {
      debugPrint('📱 Initializing NotificationService...');
      await getUnreadCount(); // Preload unread count
    } catch (error) {
      debugPrint('❌ Error initializing NotificationService: $error');
    }
  }

  void dispose() {
    _httpClient.close();
  }
}