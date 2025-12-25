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
  String _filter = 'all';
  String get filter => _filter;
  
  NotificationProvider(this._notificationService) {
    loadUnreadCount();
    loadNotifications();
  }

  Future<void> loadUnreadCount() async {
    try {
      final count = await _notificationService.getUnreadCount();
      _unreadCount = count;
      notifyListeners();
    } catch (error) {
      debugPrint('Error loading unread count: $error');
    }
  }

  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _notifications.clear();
    }
    
    if (!_hasMore && !refresh) return;
    
    try {
      _loading = true;
      notifyListeners();
      
      final notifications = await _notificationService.getUserNotifications(
        unreadOnly: _filter == 'unread',
        page: _currentPage,
      );
      
      if (refresh) {
        _notifications = notifications;
      } else {
        _notifications.addAll(notifications);
      }
      
      _hasMore = notifications.length >= 20;
      _currentPage++;
      
      await loadUnreadCount();
    } catch (error) {
      debugPrint('Error loading notifications: $error');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMoreNotifications() async {
    if (_loadingMore || !_hasMore) return;
    
    try {
      _loadingMore = true;
      notifyListeners();
      
      await Future.delayed(const Duration(milliseconds: 500));
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
          _notifications[index] = _notifications[index].copyWith(
            isRead: true,
            readAt: DateTime.now(),
          );
          
          if (_filter == 'unread') {
            _notifications.removeAt(index);
          }
          
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
    _notifications.insert(0, notification);
    if (!notification.isRead) {
      _unreadCount++;
    }
    notifyListeners();
  }

  void refresh() {
    loadNotifications(refresh: true);
  }

  void reset() {
    _notifications.clear();
    _unreadCount = 0;
    _currentPage = 1;
    _hasMore = true;
    notifyListeners();
  }
}