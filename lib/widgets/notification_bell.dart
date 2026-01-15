// lib/widgets/notification_bell.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/notification_provider.dart';

class NotificationBell extends StatefulWidget {
  final Color? iconColor;
  final Color? badgeColor;
  final double? iconSize;
  final bool showBadge;
  final VoidCallback? onPressed;
  final bool showLoadingIndicator;
  
  const NotificationBell({
    Key? key,
    this.iconColor,
    this.badgeColor,
    this.iconSize = 24,
    this.showBadge = true,
    this.onPressed,
    this.showLoadingIndicator = true,
  }) : super(key: key);

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
            _provider.unreadCount > 0 
              ? Icons.notifications
              : Icons.notifications_none,
            color: widget.iconColor ?? Theme.of(context).iconTheme.color,
            size: widget.iconSize,
          ),
          onPressed: widget.onPressed ?? () async {
            // ✅ FIXED: Use the correct route name from your constants
            await Navigator.pushNamed(context, '/notifications');
            // Refresh count when returning
            _provider.loadUnreadCount();
          },
          tooltip: 'Notifications',
          splashRadius: widget.iconSize! * 0.7,
        ),
        
        // Unread badge
        if (widget.showBadge && _provider.unreadCount > 0)
          Positioned(
            right: 6,
            top: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                // ✅ FIXED: Use correct color from your AppColors
                color: widget.badgeColor ?? Colors.red, // Changed from AppColors.error
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Text(
                _provider.unreadCount > 99 ? '99+' : _provider.unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  height: 1,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        
        // Loading indicator (small dot)
        if (widget.showLoadingIndicator && _provider.loading)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                // ✅ FIXED: Use correct color
                color: Colors.orange, // Changed from AppColors.warning
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
      ],
    );
  }
}