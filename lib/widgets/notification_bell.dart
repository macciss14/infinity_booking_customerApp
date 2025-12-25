import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationBell extends StatefulWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double? iconSize;
  final bool showBadge;
  
  const NotificationBell({
    super.key,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24,
    this.showBadge = true,
  });

  @override
  State<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends State<NotificationBell> {
  late NotificationProvider _provider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _provider = Provider.of<NotificationProvider>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            color: widget.iconColor ?? Theme.of(context).iconTheme.color,
            size: widget.iconSize,
          ),
          onPressed: () async {
            // Navigate to notifications screen
            await Navigator.pushNamed(context, '/notifications');
            // Refresh count when returning
            _provider.loadUnreadCount();
          },
          tooltip: 'Notifications',
        ),
        if (widget.showBadge && _provider.unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: widget.badgeColor ?? Colors.red,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
              ),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              child: Text(
                _provider.unreadCount > 9 ? '9+' : _provider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        // Optional: Show loading indicator
        if (_provider.loading)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
      ],
    );
  }
}