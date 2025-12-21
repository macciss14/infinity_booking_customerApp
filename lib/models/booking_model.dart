// lib/models/booking_model.dart
import 'dart:convert';
import 'package:intl/intl.dart';

class BookingModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String? serviceImage;
  final String providerId;    // 🔥 Must be PROV-xxx (not MongoDB _id)
  final String providerName;
  final String customerId;
  final String customerName;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String? paymentMethod;
  final String? paymentReference;
  final String? transactionId;
  final String? bookingReference;
  final String? notes;
  final String status; // pending, confirmed, cancelled, completed, pending_payment
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final String? cancellationPolicy;
  final String? refundAmount;
  final bool isPaid;
  final bool isConfirmed;
  final String currency;
  final double? advancePayment;
  final double? remainingAmount;
  final String? invoiceNumber;
  final String? paymentStatus; // pending, paid, failed, refunded
  final DateTime? paymentDate;
  final Map<String, dynamic>? serviceDetails;
  final Map<String, dynamic>? providerDetails;
  final List<dynamic>? bookingItems;
  final bool isAdminBooking;
  final String? adminNotes;
  final bool requiresConfirmation;
  final String? bookingType; // normal, recurring, emergency

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    this.serviceImage,
    required this.providerId,
    required this.providerName,
    required this.customerId,
    required this.customerName,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.paymentMethod,
    this.paymentReference,
    this.transactionId,
    this.bookingReference,
    this.notes,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.cancellationReason,
    this.cancellationDate,
    this.cancellationPolicy,
    this.refundAmount,
    required this.isPaid,
    required this.isConfirmed,
    this.currency = 'ETB',
    this.advancePayment,
    this.remainingAmount,
    this.invoiceNumber,
    this.paymentStatus,
    this.paymentDate,
    this.serviceDetails,
    this.providerDetails,
    this.bookingItems,
    this.isAdminBooking = false,
    this.adminNotes,
    this.requiresConfirmation = false,
    this.bookingType = 'normal',
  });

  // Formatted date getters
  String get formattedBookingDate => DateFormat('dd/MM/yyyy').format(bookingDate);
  String get formattedCreatedAt => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  String get formattedTimeRange => '$startTime - $endTime';
  
  // Status getters
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isConfirmedStatus => status.toLowerCase() == 'confirmed';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isCompleted => status.toLowerCase() == 'completed';
  bool get isPendingPayment => status.toLowerCase() == 'pending_payment';
  
  // Color based on status
  String get statusColor {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return '#10B981';
      case 'pending':
      case 'pending_payment':
        return '#F59E0B';
      case 'cancelled':
        return '#EF4444';
      case 'completed':
        return '#3B82F6';
      default:
        return '#6B7280';
    }
  }

  String get statusIcon {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return '✓';
      case 'pending':
        return '⏳';
      case 'pending_payment':
        return '💰';
      case 'cancelled':
        return '✗';
      default:
        return '?';
    }
  }

  // 🔥 EXTRACT PROVIDER PID FROM providerDetails IF AVAILABLE
  String get resolvedProviderPid {
    if (providerDetails != null && providerDetails!['pid'] != null) {
      return providerDetails!['pid'].toString();
    }
    // Fallback: if providerId looks like a PID
    if (providerId.startsWith('PROV-')) {
      return providerId;
    }
    return providerId;
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    DateTime _parseBookingDate(dynamic dateData) {
      if (dateData == null) return DateTime.now();
      if (dateData is String) {
        if (dateData.contains('/')) {
          // Handle DD/MM/YYYY from backend (rare, but safe)
          final parts = dateData.split('/');
          if (parts.length == 3) {
            final d = int.tryParse(parts[0]) ?? 1;
            final m = int.tryParse(parts[1]) ?? 1;
            final y = int.tryParse(parts[2]) ?? DateTime.now().year;
            return DateTime(y, m, d);
          }
        }
        return DateTime.tryParse(dateData) ?? DateTime.now();
      } else if (dateData is Map && dateData['\$date'] != null) {
        return DateTime.tryParse(dateData['\$date'].toString()) ?? DateTime.now();
      }
      return DateTime.now();
    }

    DateTime? _parseDate(dynamic dateData) {
      if (dateData == null) return null;
      if (dateData is String) return DateTime.tryParse(dateData);
      if (dateData is Map && dateData['\$date'] != null) {
        return DateTime.tryParse(dateData['\$date'].toString());
      }
      return null;
    }

    Map<String, dynamic>? serviceDetails;
    if (json['service'] is Map) {
      serviceDetails = Map<String, dynamic>.from(json['service']);
    } else if (json['serviceDetails'] is Map) {
      serviceDetails = Map<String, dynamic>.from(json['serviceDetails']);
    }

    Map<String, dynamic>? providerDetails;
    if (json['provider'] is Map) {
      providerDetails = Map<String, dynamic>.from(json['provider']);
    } else if (json['providerDetails'] is Map) {
      providerDetails = Map<String, dynamic>.from(json['providerDetails']);
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      serviceName: json['serviceName']?.toString() ??
          serviceDetails?['title']?.toString() ??
          serviceDetails?['name']?.toString() ??
          'Service',
      serviceImage: json['serviceImage']?.toString() ??
          serviceDetails?['imageUrl']?.toString() ??
          serviceDetails?['image']?.toString(),
      providerId: json['providerId']?.toString() ??
          providerDetails?['pid']?.toString() ??  // ✅ Prefer PID
          providerDetails?['_id']?.toString() ??
          '',
      providerName: json['providerName']?.toString() ??
          providerDetails?['fullname']?.toString() ??
          providerDetails?['name']?.toString() ??
          'Provider',
      customerId: json['customerId']?.toString() ??
          json['customer']?['_id']?.toString() ??
          json['user']?['_id']?.toString() ??
          '',
      customerName: json['customerName']?.toString() ??
          json['customer']?['fullname']?.toString() ??
          json['user']?['fullname']?.toString() ??
          'Customer',
      bookingDate: _parseBookingDate(json['bookingDate'] ?? json['date']),
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '10:00',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
          (json['amount'] as num?)?.toDouble() ??
          0.0,
      paymentMethod: json['paymentMethod']?.toString(),
      paymentReference: json['paymentReference']?.toString(),
      transactionId: json['transactionId']?.toString(),
      bookingReference: json['bookingReference']?.toString() ??
          json['reference']?.toString(),
      notes: json['notes']?.toString(),
      status: json['status']?.toString()?.toLowerCase() ?? 'pending',
      createdAt: _parseDate(json['createdAt']) ?? DateTime.now(),
      updatedAt: _parseDate(json['updatedAt']),
      cancellationReason: json['cancellationReason']?.toString(),
      cancellationDate: _parseDate(json['cancellationDate']),
      cancellationPolicy: json['cancellationPolicy']?.toString(),
      refundAmount: json['refundAmount']?.toString(),
      isPaid: json['isPaid'] == true || json['paymentStatus'] == 'paid',
      isConfirmed: json['isConfirmed'] == true,
      currency: json['currency']?.toString() ?? 'ETB',
      advancePayment: (json['advancePayment'] as num?)?.toDouble(),
      remainingAmount: (json['remainingAmount'] as num?)?.toDouble(),
      invoiceNumber: json['invoiceNumber']?.toString(),
      paymentStatus: json['paymentStatus']?.toString(),
      paymentDate: _parseDate(json['paymentDate']),
      serviceDetails: serviceDetails,
      providerDetails: providerDetails,
      bookingItems: json['bookingItems'] is List ? List.from(json['bookingItems']) : null,
      isAdminBooking: json['isAdminBooking'] == true,
      adminNotes: json['adminNotes']?.toString(),
      requiresConfirmation: json['requiresConfirmation'] == true,
      bookingType: json['bookingType']?.toString() ?? 'normal',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceImage': serviceImage,
      'providerId': providerId,
      'providerName': providerName,
      'customerId': customerId,
      'customerName': customerName,
      'bookingDate': bookingDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'transactionId': transactionId,
      'bookingReference': bookingReference,
      'notes': notes,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'cancellationDate': cancellationDate?.toIso8601String(),
      'cancellationPolicy': cancellationPolicy,
      'refundAmount': refundAmount,
      'isPaid': isPaid,
      'isConfirmed': isConfirmed,
      'currency': currency,
      'advancePayment': advancePayment,
      'remainingAmount': remainingAmount,
      'invoiceNumber': invoiceNumber,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate?.toIso8601String(),
      'serviceDetails': serviceDetails,
      'providerDetails': providerDetails,
      'bookingItems': bookingItems,
      'isAdminBooking': isAdminBooking,
      'adminNotes': adminNotes,
      'requiresConfirmation': requiresConfirmation,
      'bookingType': bookingType,
    };
  }

  BookingModel copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? serviceImage,
    String? providerId,
    String? providerName,
    String? customerId,
    String? customerName,
    DateTime? bookingDate,
    String? startTime,
    String? endTime,
    double? totalAmount,
    String? paymentMethod,
    String? paymentReference,
    String? transactionId,
    String? bookingReference,
    String? notes,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? cancellationReason,
    DateTime? cancellationDate,
    String? cancellationPolicy,
    String? refundAmount,
    bool? isPaid,
    bool? isConfirmed,
    String? currency,
    double? advancePayment,
    double? remainingAmount,
    String? invoiceNumber,
    String? paymentStatus,
    DateTime? paymentDate,
    Map<String, dynamic>? serviceDetails,
    Map<String, dynamic>? providerDetails,
    List<dynamic>? bookingItems,
    bool? isAdminBooking,
    String? adminNotes,
    bool? requiresConfirmation,
    String? bookingType,
  }) {
    return BookingModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      serviceImage: serviceImage ?? this.serviceImage,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      bookingDate: bookingDate ?? this.bookingDate,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentReference: paymentReference ?? this.paymentReference,
      transactionId: transactionId ?? this.transactionId,
      bookingReference: bookingReference ?? this.bookingReference,
      notes: notes ?? this.notes,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      cancellationDate: cancellationDate ?? this.cancellationDate,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      refundAmount: refundAmount ?? this.refundAmount,
      isPaid: isPaid ?? this.isPaid,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      currency: currency ?? this.currency,
      advancePayment: advancePayment ?? this.advancePayment,
      remainingAmount: remainingAmount ?? this.remainingAmount,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentDate: paymentDate ?? this.paymentDate,
      serviceDetails: serviceDetails ?? this.serviceDetails,
      providerDetails: providerDetails ?? this.providerDetails,
      bookingItems: bookingItems ?? this.bookingItems,
      isAdminBooking: isAdminBooking ?? this.isAdminBooking,
      adminNotes: adminNotes ?? this.adminNotes,
      requiresConfirmation: requiresConfirmation ?? this.requiresConfirmation,
      bookingType: bookingType ?? this.bookingType,
    );
  }

  @override
  String toString() {
    return 'BookingModel{id: $id, providerId: $providerId, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookingModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}