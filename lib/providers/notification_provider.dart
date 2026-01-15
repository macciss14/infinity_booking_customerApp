// lib/providers/notification_provider.dart
import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService;
  
  List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications => _notifications;
  
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;
  
  bool _loading = false;
  bool get loading => _loading;
  
  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;
  
  int _currentPage = 1;
  bool _hasMore = true;
  String _filter = 'all'; // 'all' or 'unread'
  String get filter => _filter;
  
  String? _error;
  String? get error => _error;
  
  // Refresh interval for polling (optional)
  DateTime? _lastRefresh;
  
  NotificationProvider(this._notificationService) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      debugPrint('[NotificationProvider] Initializing...');
      await loadUnreadCount();
      await loadNotifications(refresh: true);
    } catch (error) {
      debugPrint('[NotificationProvider] Initialization error: $error');
      _error = 'Failed to load notifications';
      notifyListeners();
    }
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
      debugPrint('[NotificationProvider] Unread count: $count');
      notifyListeners();
    } catch (error) {
      debugPrint('Error loading unread count: $error');
      _unreadCount = 0;
    }
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications.clear();
      _error = null;
      _lastRefresh = DateTime.now();
    }
    
    if (!_hasMore && !refresh) return;
    
    if (_loading) return;
    
    try {
      _loading = true;
      notifyListeners();
      
      debugPrint('[NotificationProvider] Loading notifications, page $_currentPage');
      
      final notifications = await _notificationService.getUserNotifications(
        unreadOnly: _filter == 'unread',
        page: _currentPage,
        limit: 20,
      );
      
      debugPrint('[NotificationProvider] Got ${notifications.length} notifications');
      
      if (refresh) {
        _notifications = notifications;
      } else {
        _notifications.addAll(notifications);
      }
      
      _hasMore = notifications.length >= 20;
      _currentPage++;
      
      // Update unread count
      await loadUnreadCount();
      
      debugPrint('[NotificationProvider] Total notifications: ${_notifications.length}, hasMore: $_hasMore');
      
    } catch (error) {
      debugPrint('Error loading notifications: $error');
      _error = 'Failed to load notifications. Please pull to refresh.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_loadingMore || !_hasMore || _loading) return;
    
    try {
      _loadingMore = true;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 300));
      await loadNotifications(refresh: false);
    } finally {
      _loadingMore = false;
      notifyListeners();
    }
  }

  Future<void> setFilter(String filter) async {
    if (_filter == filter) return;
    
    _filter = filter;
    _currentPage = 1;
    _hasMore = true;
    await loadNotifications(refresh: true);
  }

  Future<bool> markAsRead(String notificationId) async {
    try {
      final success = await _notificationService.markAsRead(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Create a copy with updated read status
          final updatedNotification = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          
          _notifications[index] = updatedNotification;
          
          // If filter is 'unread', remove from list
          if (_filter == 'unread') {
            _notifications.removeAt(index);
          }
          
          // Update unread count
          _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          
          notifyListeners();
          return true;
        }
      }
      return false;
    } catch (error) {
      debugPrint('Error marking as read: $error');
      return false;
    }
  }

  Future<bool> markAllAsRead() async {
    try {
      final success = await _notificationService.markAllAsRead();
      if (success) {
        // Update all notifications locally
        _notifications = _notifications.map((notification) {
          return notification.copyWith(isRead: true, readAt: DateTime.now());
        }).toList();
        
        _unreadCount = 0;
        notifyListeners();
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('Error marking all as read: $error');
      return false;
    }
  }

  Future<bool> deleteNotification(String notificationId) async {
    try {
      final success = await _notificationService.deleteNotification(notificationId);
      if (success) {
        final index = _notifications.indexWhere((n) => n.id == notificationId);
        if (index != -1) {
          // Update unread count if notification was unread
          if (!_notifications[index].isRead) {
            _unreadCount = _unreadCount > 0 ? _unreadCount - 1 : 0;
          }
          
          _notifications.removeAt(index);
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (error) {
      debugPrint('Error deleting notification: $error');
      return false;
    }
  }

  void addNotification(NotificationModel notification) {
    // Add to beginning of list
    _notifications.insert(0, notification);
    
    if (!notification.isRead) {
      _unreadCount++;
    }
    
    notifyListeners();
  }

  Future<void> refresh() async {
    await loadNotifications(refresh: true);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _currentPage = 1;
    _hasMore = true;
    _error = null;
    notifyListeners();
  }

  // Auto-refresh if data is stale (optional)
  bool get shouldRefresh {
    if (_lastRefresh == null) return true;
    final minutesSinceRefresh = DateTime.now().difference(_lastRefresh!).inMinutes;
    return minutesSinceRefresh > 5; // Refresh every 5 minutes
  }
}