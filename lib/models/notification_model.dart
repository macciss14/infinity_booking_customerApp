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

  String get formattedCreatedAt =>
      DateFormat('dd/MM/yyyy HH:mm').format(createdAt);

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 30) return '${difference.inDays}d ago';
    if (difference.inDays < 365) return '${difference.inDays ~/ 30}mo ago';
    return '${difference.inDays ~/ 365}y ago';
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      try {
        if (dateValue is String) {
          return DateTime.tryParse(dateValue) ?? DateTime.now();
        } else if (dateValue is Map && dateValue.containsKey('\$date')) {
          return DateTime.tryParse(dateValue['\$date'].toString()) ??
              DateTime.now();
        }
        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      message: json['message']?.toString() ??
          json['body']?.toString() ??
          'No message',
      type: json['type']?.toString() ?? 'system',
      userId: json['userId']?.toString() ?? json['user']?['_id']?.toString(),
      bookingId: json['bookingId']?.toString(),
      serviceId: json['serviceId']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: parseDate(json['createdAt']),
      readAt: parseDate(json['readAt']),
      data:
          json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      priority: json['priority']?.toString(),
      channel: json['channel']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'type': type,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };
}
