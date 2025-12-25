import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '/../providers/notification_provider.dart';
import '/../models/notification_model.dart';
import '/../utils/constants.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

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
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<NotificationProvider>(context, listen: false);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _provider.loadMoreNotifications();
    }
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    return Dismissible(
      key: Key(notification.id),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Notification'),
            content: const Text('Are you sure you want to delete this notification?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text(
                  'Delete',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        await _provider.deleteNotification(notification.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Notification deleted'),
            backgroundColor: Colors.green,
            action: SnackBarAction(
              label: 'Undo',
              onPressed: () {
                // Note: You would need to implement undo functionality
              },
            ),
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: notification.isRead ? Colors.white : Colors.blue[50],
        elevation: 1,
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: notification.typeColor.withOpacity(
              notification.isRead ? 0.1 : 0.2,
            ),
            child: Icon(
              notification.typeIcon,
              color: notification.typeColor,
            ),
          ),
          title: Text(
            notification.title ?? notification.typeDisplayName,
            style: TextStyle(
              fontWeight: notification.isRead 
                  ? FontWeight.normal 
                  : FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                notification.message,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: notification.isRead 
                      ? Colors.grey[600] 
                      : Colors.grey[800],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 12,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification.timeAgo,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
                  const Spacer(),
                  if (!notification.isRead)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, 
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'NEW',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          trailing: PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'read' && !notification.isRead) {
                await _provider.markAsRead(notification.id);
              } else if (value == 'delete') {
                await _provider.deleteNotification(notification.id);
              }
            },
            itemBuilder: (context) => [
              if (!notification.isRead)
                const PopupMenuItem(
                  value: 'read',
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 20, color: Colors.blue),
                      SizedBox(width: 8),
                      Text('Mark as read'),
                    ],
                  ),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Delete'),
                  ],
                ),
              ),
            ],
          ),
          onTap: () async {
            if (!notification.isRead) {
              await _provider.markAsRead(notification.id);
            }
            // TODO: Handle notification tap (navigate to relevant screen)
            if (notification.bookingId != null) {
              // Navigator.pushNamed(context, '/booking/${notification.bookingId}');
            } else if (notification.serviceId != null) {
              // Navigator.pushNamed(context, '/service/${notification.serviceId}');
            }
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          Text(
            _provider.filter == 'unread'
                ? 'No unread notifications'
                : 'No notifications yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _provider.filter == 'unread'
                ? 'You\'re all caught up!'
                : 'Notifications will appear here',
            style: TextStyle(
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            onPressed: () {
              if (_provider.filter == 'unread') {
                _provider.setFilter('all');
              } else {
                _provider.refresh();
              }
            },
            icon: const Icon(Icons.refresh),
            label: Text(
              _provider.filter == 'unread'
                  ? 'View All Notifications'
                  : 'Refresh',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 20),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListTile(
            leading: const CircleAvatar(
              backgroundColor: Colors.grey,
            ),
            title: Container(
              width: 120,
              height: 16,
              color: Colors.grey[300],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  height: 12,
                  color: Colors.grey[300],
                ),
                const SizedBox(height: 8),
                Container(
                  width: 80,
                  height: 10,
                  color: Colors.grey[300],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    if (_provider.loading && _provider.notifications.isEmpty) {
      return _buildLoadingState();
    }

    if (_provider.notifications.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        if (_provider.filter == 'all' && 
            _provider.notifications.any((n) => !n.isRead))
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.blue[50],
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${_provider.notifications.where((n) => !n.isRead).length} '
                    'unread notifications',
                    style: const TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () async {
                    await _provider.markAllAsRead();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('All notifications marked as read'),
                        backgroundColor: Colors.green,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline, size: 16),
                  label: const Text('Mark all read'),
                ),
              ],
            ),
          ),
        Expanded(
          child: RefreshIndicator(
           onRefresh: () => _provider.refresh() as Future<void>,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: 20),
              itemCount: _provider.notifications.length + 
                        (_provider.loadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index >= _provider.notifications.length) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                return _buildNotificationItem(
                  _provider.notifications[index],
                );
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
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
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
              const PopupMenuItem(
                value: 'unread',
                child: Row(
                  children: [
                    Icon(Icons.mark_unread_chat_alt, 
                      size: 20, 
                      color: Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Text('Unread Only'),
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