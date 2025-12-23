// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;
  bool _loading = false;

  int get unreadCount => _unreadCount;
  bool get loading => _loading;

  NotificationProvider() {
    // Load unread count when provider is created
    loadUnreadCount();
  }

  Future<void> loadUnreadCount() async {
    try {
      _loading = true;
      notifyListeners();
      
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
    } catch (error) {
      print('❌ Error loading unread count: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void incrementUnreadCount() {
    _unreadCount++;
    notifyListeners();
  }

  void decrementUnreadCount() {
    if (_unreadCount > 0) {
      _unreadCount--;
      notifyListeners();
    }
  }

  void resetUnreadCount() {
    _unreadCount = 0;
    notifyListeners();
  }
}