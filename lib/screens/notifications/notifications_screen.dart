// lib/screens/notifications/notifications_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';
import '../../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _scrollController = ScrollController();
  late NotificationProvider _provider;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    
    // Test time calculation on init
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _testTimeCalculation();
    });
  }

  void _testTimeCalculation() {
    debugPrint('=== Time Calculation Test ===');
    debugPrint('Current Device Time: ${DateTime.now().toLocal()}');
    debugPrint('Current UTC Time: ${DateTime.now().toUtc()}');
    
    // Test with a notification from 3 minutes ago
    final testTime = DateTime.now().toLocal().subtract(const Duration(minutes: 3));
    debugPrint('Test Time (3 min ago): $testTime');
    debugPrint('Difference: ${DateTime.now().toLocal().difference(testTime)}');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<NotificationProvider>(context, listen: false);

    // Auto-refresh if needed
    if (_provider.shouldRefresh) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _provider.refresh();
      });
    }
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _provider.loadMoreNotifications();
    }
  }

  Widget _buildNotificationItem(NotificationModel notification, int index) {
    // Debug the notification time
    debugPrint(notification.debugTimeInfo);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
      ),
      elevation: notification.isRead ? 0.5 : 1.5,
      color: notification.isRead
          ? AppColors.cardBackground
          : AppColors.notificationUnread,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: notification.typeColor.withOpacity(0.1),
          radius: 20,
          child: Icon(
            notification.typeIcon,
            color: notification.typeColor,
            size: 20,
          ),
        ),
        title: Text(
          notification.title ?? notification.typeDisplayName,
          style: TextStyle(
            fontWeight:
                notification.isRead ? FontWeight.normal : FontWeight.w600,
            fontSize: 15,
            color: AppColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              notification.message,
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.3,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 4),
                // ✅ FIXED: Use smartTimeAgo for better display
                Text(
                  notification.smartTimeAgo,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                  ),
                ),
                const Spacer(),
                if (!notification.isRead)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: AppColors.primary.withOpacity(0.3),
                          width: 0.5),
                    ),
                    child: Text(
                      'NEW',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(Icons.more_vert, size: 20, color: AppColors.textTertiary),
          onSelected: (value) async {
            if (value == 'read' && !notification.isRead) {
              await _provider.markAsRead(notification.id);
              _showSnackBar('Marked as read');
            } else if (value == 'delete') {
              final shouldDelete = await _showDeleteConfirmation(notification);
              if (shouldDelete) {
                await _provider.deleteNotification(notification.id);
                _showSnackBar('Notification deleted');
              }
            }
          },
          itemBuilder: (context) => [
            if (!notification.isRead)
              PopupMenuItem(
                value: 'read',
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Mark as read'),
                  ],
                ),
              ),
            PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                  const SizedBox(width: 8),
                  const Text('Delete'),
                ],
              ),
            ),
          ],
        ),
        onTap: () async {
          // Mark as read on tap if unread
          if (!notification.isRead) {
            await _provider.markAsRead(notification.id);
          }

          // Navigate based on notification type
          _handleNotificationTap(notification);
        },
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Handle navigation based on notification type
    if (notification.bookingId != null) {
      // Navigate to booking details
      Navigator.pushNamed(
        context,
        AppConstants.routeBookingDetail
            .replaceAll(':id', notification.bookingId!),
      );
    } else if (notification.serviceId != null) {
      // Navigate to service details
      Navigator.pushNamed(
        context,
        AppConstants.routeServiceDetail
            .replaceAll(':id', notification.serviceId!),
      );
    } else if (notification.actionUrl != null) {
      // Handle custom action URL
      // You can use url_launcher package for web URLs
    }
    // Otherwise, just mark as read (already done above)
  }

  Future<bool> _showDeleteConfirmation(NotificationModel notification) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text(
                'Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: AppColors.grey300,
            ),
            const SizedBox(height: 24),
            Text(
              _provider.filter == 'unread'
                  ? 'No unread notifications'
                  : 'No notifications yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              _provider.filter == 'unread'
                  ? 'You\'re all caught up!'
                  : 'Your notifications will appear here',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            if (_provider.filter == 'unread')
              ElevatedButton.icon(
                onPressed: () => _provider.setFilter('all'),
                icon: const Icon(Icons.list),
                label: const Text('View All Notifications'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Refresh'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
            ),
            title: Container(
              width: 120,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 20),
            Text(
              'Failed to load notifications',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _provider.error ?? 'Please check your internet connection',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: _provider.refresh,
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_provider.error != null && _provider.notifications.isEmpty) {
      return _buildErrorState();
    }

    if (_provider.loading && _provider.notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (_provider.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        // Mark all read banner
        if (_provider.filter == 'all' && _provider.unreadCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: AppColors.primaryLight,
            child: Row(
              children: [
                Icon(
                  Icons.notifications_active,
                  size: 18,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${_provider.unreadCount} unread notification${_provider.unreadCount > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await _provider.markAllAsRead();
                    _showSnackBar('All notifications marked as read');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    'Mark all read',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Notifications list
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => _provider.refresh(),
            color: AppColors.primary,
            backgroundColor: AppColors.cardBackground,
            child: ListView.separated(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: _provider.notifications.length +
                  (_provider.loadingMore ? 1 : 0),
              separatorBuilder: (context, index) => const SizedBox(height: 4),
              itemBuilder: (context, index) {
                if (index >= _provider.notifications.length) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  );
                }
                return _buildNotificationItem(
                    _provider.notifications[index], index);
              },
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppColors.appBarBackground,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 1,
        actions: [
          // Filter dropdown
          PopupMenuButton<String>(
            onSelected: (value) => _provider.setFilter(value),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Row(
                  children: [
                    Icon(Icons.list, size: 20),
                    SizedBox(width: 8),
                    Text('All Notifications'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_unread_chat_alt,
                        size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Text('Unread Only'),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.filter_list),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _provider.refresh,
            tooltip: 'Refresh',
          ),
          // Debug button
          IconButton(
            icon: const Icon(Icons.bug_report),
            onPressed: () {
              // Debug all notifications
              for (var notification in _provider.notifications) {
                debugPrint(notification.debugTimeInfo);
              }
            },
            tooltip: 'Debug Times',
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, child) {
          return _buildContent();
        },
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}