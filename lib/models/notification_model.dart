// lib/models/notification_model.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationModel {
  final String id;
  final String? title;
  final String message;
  final String type;
  final String? userId;
  final String? bookingId;
  final String? serviceId;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final Map<String, dynamic>? data;
  final String? priority;
  final String? channel;
  final String? actionUrl;

  NotificationModel({
    required this.id,
    this.title,
    required this.message,
    required this.type,
    this.userId,
    this.bookingId,
    this.serviceId,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.data,
    this.priority,
    this.channel,
    this.actionUrl,
  });

  // ✅ FIXED: Always treat createdAt as UTC from server, convert to local
  DateTime get localCreatedAt {
    // If createdAt is already UTC, convert to local
    if (createdAt.isUtc) {
      return createdAt.toLocal();
    } else {
      // If it's not UTC, assume it's already local or convert
      return createdAt;
    }
  }

  // ✅ FIXED: Better time ago calculation with timezone awareness
  String get timeAgo {
    final now = DateTime.now().toLocal();
    final notificationTime = localCreatedAt;
    
    final difference = now.difference(notificationTime);
    
    // Debug for troubleshooting
    debugPrint('=== Time Calculation Debug ===');
    debugPrint('Server UTC time: ${createdAt.toUtc()}');
    debugPrint('Converted Local time: $notificationTime');
    debugPrint('Current Local time: $now');
    debugPrint('Difference: $difference');
    debugPrint('Difference in minutes: ${difference.inMinutes}');
    debugPrint('Difference in seconds: ${difference.inSeconds}');
    
    if (difference.inSeconds < 0) {
      // Future time - server time might be ahead
      return 'Just now';
    }
    
    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 30) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else if (difference.inDays < 365) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    }
  }

  // ✅ NEW: Smart time display that's more user-friendly
  String get smartTimeAgo {
    final now = DateTime.now().toLocal();
    final notificationTime = localCreatedAt;
    final difference = now.difference(notificationTime);
    
    // Handle timezone/server clock issues
    if (difference.inSeconds < 0) {
      // Notification appears to be from the future (server clock ahead)
      return 'Just now';
    }
    
    // For very recent notifications (last 2 minutes), show "Just now"
    if (difference.inMinutes < 2) {
      return 'Just now';
    }
    
    // For 2-10 minutes, show exact minutes
    if (difference.inMinutes < 10) {
      return '${difference.inMinutes} minutes ago';
    }
    
    // For 10-60 minutes, round to nearest 5 minutes
    if (difference.inMinutes < 60) {
      final roundedMinutes = ((difference.inMinutes / 5).ceil() * 5);
      return '$roundedMinutes minutes ago';
    }
    
    // For 1-2 hours
    if (difference.inHours < 2) {
      return '1 hour ago';
    }
    
    // For 2-24 hours
    if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    }
    
    // For 1-2 days
    if (difference.inDays < 2) {
      return '1 day ago';
    }
    
    // Use the original timeAgo for longer durations
    return timeAgo;
  }

  // ✅ FIXED: Short version for UI
  String get shortTimeAgo {
    final now = DateTime.now().toLocal();
    final notificationTime = localCreatedAt;
    final difference = now.difference(notificationTime);
    
    // Handle server time being ahead
    if (difference.inSeconds < 0 || difference.inMinutes < 1) {
      return 'Just now';
    }
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else {
      return '${(difference.inDays / 365).floor()}y ago';
    }
  }

  // ✅ NEW: Accurate time display for debugging
  String get debugTimeInfo {
    return '''
=== Notification Time Debug ===
ID: $id
Server UTC: ${createdAt.toUtc()}
Local Converted: $localCreatedAt
Current Local: ${DateTime.now().toLocal()}
Difference: ${DateTime.now().toLocal().difference(localCreatedAt)}
Smart Time Ago: $smartTimeAgo
Short Time Ago: $shortTimeAgo
Original Time Ago: $timeAgo
''';
  }

  String get typeDisplayName {
    switch (type.toLowerCase()) {
      case 'booking_created':
        return 'New Booking';
      case 'booking_confirmed':
        return 'Booking Confirmed';
      case 'booking_cancelled':
        return 'Booking Cancelled';
      case 'booking_rescheduled':
        return 'Booking Rescheduled';
      case 'payment_received':
        return 'Payment Received';
      case 'review_received':
        return 'New Review';
      case 'system':
        return 'System Notification';
      case 'promotion':
        return 'Promotion';
      case 'password_changed':
        return 'Password Changed';
      case 'profile_updated':
        return 'Profile Updated';
      default:
        return 'Notification';
    }
  }

  IconData get typeIcon {
    switch (type.toLowerCase()) {
      case 'booking_created':
        return Icons.calendar_today;
      case 'booking_confirmed':
        return Icons.check_circle;
      case 'booking_cancelled':
        return Icons.cancel;
      case 'booking_rescheduled':
        return Icons.schedule;
      case 'payment_received':
        return Icons.payment;
      case 'review_received':
        return Icons.star;
      case 'system':
        return Icons.info;
      case 'promotion':
        return Icons.local_offer;
      case 'password_changed':
        return Icons.lock;
      case 'profile_updated':
        return Icons.person;
      default:
        return Icons.notifications;
    }
  }

  Color get typeColor {
    switch (type.toLowerCase()) {
      case 'booking_created':
        return Colors.blue;
      case 'booking_confirmed':
        return Colors.green;
      case 'booking_cancelled':
        return Colors.red;
      case 'booking_rescheduled':
        return Colors.orange;
      case 'payment_received':
        return Colors.teal;
      case 'review_received':
        return Colors.purple;
      case 'system':
        return Colors.grey;
      case 'promotion':
        return Colors.pink;
      case 'password_changed':
        return Colors.blueGrey;
      case 'profile_updated':
        return Colors.cyan;
      default:
        return Colors.blue;
    }
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    String? userId,
    String? bookingId,
    String? serviceId,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
    Map<String, dynamic>? data,
    String? priority,
    String? channel,
    String? actionUrl,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      userId: userId ?? this.userId,
      bookingId: bookingId ?? this.bookingId,
      serviceId: serviceId ?? this.serviceId,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      data: data ?? this.data,
      priority: priority ?? this.priority,
      channel: channel ?? this.channel,
      actionUrl: actionUrl ?? this.actionUrl,
    );
  }

  // ✅ FIXED: Factory method with better timezone handling
  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) {
        return DateTime.now().toUtc();
      }
      
      try {
        // Handle string dates
        if (dateValue is String) {
          // Check if it's a timestamp string
          final intTimestamp = int.tryParse(dateValue);
          if (intTimestamp != null) {
            // If it's a large number, it's likely milliseconds
            if (intTimestamp > 1000000000000) {
              return DateTime.fromMillisecondsSinceEpoch(intTimestamp, isUtc: true);
            } else {
              // Otherwise, assume seconds
              return DateTime.fromMillisecondsSinceEpoch(intTimestamp * 1000, isUtc: true);
            }
          }
          
          // Try parsing as ISO string
          DateTime? parsed = DateTime.tryParse(dateValue);
          if (parsed != null) {
            // If it doesn't specify timezone, assume UTC
            if (!parsed.isUtc) {
              parsed = DateTime.utc(
                parsed.year,
                parsed.month,
                parsed.day,
                parsed.hour,
                parsed.minute,
                parsed.second,
                parsed.millisecond,
                parsed.microsecond,
              );
            }
            return parsed;
          }
        }
        
        // Handle MongoDB date format
        if (dateValue is Map && dateValue.containsKey('\$date')) {
          final dateStr = dateValue['\$date'].toString();
          final intTimestamp = int.tryParse(dateStr);
          if (intTimestamp != null) {
            return DateTime.fromMillisecondsSinceEpoch(intTimestamp, isUtc: true);
          }
          
          final parsed = DateTime.tryParse(dateStr);
          if (parsed != null) {
            return parsed.isUtc ? parsed : parsed.toUtc();
          }
        }
        
        // Handle numeric timestamps
        if (dateValue is int || dateValue is num) {
          final timestamp = (dateValue is int) ? dateValue : (dateValue as num).toInt();
          if (timestamp > 1000000000000) {
            return DateTime.fromMillisecondsSinceEpoch(timestamp, isUtc: true);
          } else {
            return DateTime.fromMillisecondsSinceEpoch(timestamp * 1000, isUtc: true);
          }
        }
        
        return DateTime.now().toUtc();
      } catch (e) {
        debugPrint('❌ Error parsing date: $e for value: $dateValue');
        return DateTime.now().toUtc();
      }
    }

    final createdAt = parseDate(json['createdAt'] ?? json['created_at'] ?? json['timestamp']);
    
    // Debug the time parsing
    debugPrint('''
📅 Notification Time Parsing:
  Raw value: ${json['createdAt'] ?? json['created_at'] ?? json['timestamp']}
  Parsed UTC: ${createdAt.toUtc()}
  Parsed Local: ${createdAt.toLocal()}
  Is UTC: ${createdAt.isUtc}
  Current UTC: ${DateTime.now().toUtc()}
  Current Local: ${DateTime.now().toLocal()}
''');
    
    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      message: json['message']?.toString() ??
          json['body']?.toString() ??
          'No message',
      type: json['type']?.toString() ?? 'system',
      userId: json['userId']?.toString() ?? json['user']?['_id']?.toString(),
      bookingId: json['bookingId']?.toString() ?? json['booking_id']?.toString(),
      serviceId: json['serviceId']?.toString() ?? json['service_id']?.toString(),
      isRead: json['isRead'] == true || json['read'] == true,
      createdAt: createdAt,
      readAt: json['readAt'] != null ? parseDate(json['readAt']) : null,
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      priority: json['priority']?.toString(),
      channel: json['channel']?.toString(),
      actionUrl: json['actionUrl']?.toString() ?? json['action_url']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
        if (readAt != null) 'readAt': readAt!.toIso8601String(),
        if (data != null) 'data': data,
        if (priority != null) 'priority': priority,
        if (channel != null) 'channel': channel,
        if (actionUrl != null) 'actionUrl': actionUrl,
      };

  @override
  String toString() {
    return 'NotificationModel{id: $id, type: $type, smartTimeAgo: $smartTimeAgo}';
  }
}