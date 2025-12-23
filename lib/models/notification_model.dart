// lib/models/notification_model.dart
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

  // Formatted date
  String get formattedCreatedAt => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  
  // Time ago helper
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

  // Type display name
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

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) return DateTime.now();
      try {
        if (dateValue is String) {
          return DateTime.tryParse(dateValue) ?? DateTime.now();
        } else if (dateValue is Map && dateValue.containsKey('\$date')) {
          return DateTime.tryParse(dateValue['\$date'].toString()) ?? DateTime.now();
        }
        return DateTime.now();
      } catch (e) {
        return DateTime.now();
      }
    }

    return NotificationModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString(),
      message: json['message']?.toString() ?? json['body']?.toString() ?? 'No message',
      type: json['type']?.toString() ?? 'system',
      userId: json['userId']?.toString() ?? json['user']?['_id']?.toString(),
      bookingId: json['bookingId']?.toString(),
      serviceId: json['serviceId']?.toString(),
      isRead: json['isRead'] == true,
      createdAt: parseDate(json['createdAt']),
      readAt: parseDate(json['readAt']),
      data: json['data'] is Map ? Map<String, dynamic>.from(json['data']) : null,
      priority: json['priority']?.toString(),
      channel: json['channel']?.toString(),
      actionUrl: json['actionUrl']?.toString(),
    );
  }

  @override
  String toString() {
    return 'NotificationModel{id: $id, type: $type, isRead: $isRead}';
  }
}