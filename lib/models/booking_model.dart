import 'package:flutter/material.dart';

class Booking {
  final String id;
  final String customerId;
  final String serviceId;
  final String serviceTitle;
  final String providerId;
  final String providerName;
  final DateTime bookingDate;
  final String timeSlot;
  final double totalAmount;
  final String status; // pending, confirmed, completed, cancelled
  final String? customerNotes;
  final String? providerNotes;
  final String? cancellationReason;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Booking({
    required this.id,
    required this.customerId,
    required this.serviceId,
    required this.serviceTitle,
    required this.providerId,
    required this.providerName,
    required this.bookingDate,
    required this.timeSlot,
    required this.totalAmount,
    this.status = 'pending',
    this.customerNotes,
    this.providerNotes,
    this.cancellationReason,
    required this.createdAt,
    this.updatedAt,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      customerId: json['customerId']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceTitle: json['serviceTitle']?.toString() ?? '',
      providerId: json['providerId']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? '',
      bookingDate:
          DateTime.parse(json['bookingDate'] ?? DateTime.now().toString()),
      timeSlot: json['timeSlot']?.toString() ?? '',
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      status: json['status']?.toString() ?? 'pending',
      customerNotes: json['customerNotes']?.toString(),
      providerNotes: json['providerNotes']?.toString(),
      cancellationReason: json['cancellationReason']?.toString(),
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
      updatedAt:
          json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customerId': customerId,
      'serviceId': serviceId,
      'serviceTitle': serviceTitle,
      'providerId': providerId,
      'providerName': providerName,
      'bookingDate': bookingDate.toIso8601String(),
      'timeSlot': timeSlot,
      'totalAmount': totalAmount,
      'status': status,
      'customerNotes': customerNotes,
      'providerNotes': providerNotes,
      'cancellationReason': cancellationReason,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  String get formattedAmount => 'ETB ${totalAmount.toStringAsFixed(2)}';
  String get formattedDate =>
      '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  Color get statusColor {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'confirmed':
        return 'Confirmed';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Unknown';
    }
  }
}
