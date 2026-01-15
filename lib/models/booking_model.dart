import 'dart:convert';
import 'package:intl/intl.dart';

class BookingModel {
  // MongoDB ID
  final String id;
  
  // Booking reference (BK-xxx) - This is what backend uses for review lookup
  final String bookingReference;
  
  // Service info
  final String serviceId;
  final String serviceName;
  final String? serviceImage;
  
  // Provider info
  final String providerId; // This should be PROV-xxx format
  final String providerName;
  
  // Customer info
  final String customerId;
  final String customerName;
  
  // Booking details
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String status; // pending, confirmed, completed, cancelled
  final DateTime createdAt;
  
  // Optional fields
  final String? paymentMethod;
  final String? paymentReference;
  final String? transactionId;
  final String? notes;
  final DateTime? updatedAt;
  final String? cancellationReason;
  final DateTime? cancellationDate;
  final bool isPaid;
  final bool isConfirmed;
  final String currency;
  final String? paymentStatus;
  final DateTime? paymentDate;
  final Map<String, dynamic>? serviceDetails;
  final Map<String, dynamic>? providerDetails;

  BookingModel({
    required this.id,
    required this.bookingReference,
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
    required this.status,
    required this.createdAt,
    this.paymentMethod,
    this.paymentReference,
    this.transactionId,
    this.notes,
    this.updatedAt,
    this.cancellationReason,
    this.cancellationDate,
    this.isPaid = false,
    this.isConfirmed = false,
    this.currency = 'ETB',
    this.paymentStatus,
    this.paymentDate,
    this.serviceDetails,
    this.providerDetails,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing Booking JSON: ${json.keys.toList()}');

    // Extract booking reference - CRITICAL for reviews
    String extractBookingReference() {
      // First priority: bookingReference field
      final bookingRef = json['bookingReference']?.toString().trim();
      if (bookingRef != null && bookingRef.isNotEmpty) {
        print('✅ Found bookingReference: $bookingRef');
        return bookingRef;
      }
      
      // Second priority: bookingId field (might contain BK-xxx)
      final bookingId = json['bookingId']?.toString().trim();
      if (bookingId != null && bookingId.isNotEmpty) {
        print('✅ Using bookingId as reference: $bookingId');
        return bookingId;
      }
      
      // Third priority: reference field
      final reference = json['reference']?.toString().trim();
      if (reference != null && reference.isNotEmpty) {
        print('✅ Using reference as booking reference: $reference');
        return reference;
      }
      
      // Fourth priority: check if it's a BK- format in any field
      final allValues = json.values.whereType<String>();
      for (final value in allValues) {
        if (value.trim().startsWith('BK-') && value.length > 10) {
          print('✅ Found BK- format in value: $value');
          return value.trim();
        }
      }
      
      // Fallback: Generate a reference from MongoDB ID
      final mongoId = json['_id']?.toString() ?? json['id']?.toString() ?? '';
      if (mongoId.isNotEmpty) {
        final ref = 'BK-${DateTime.now().millisecondsSinceEpoch}-${mongoId.substring(0, 6).toUpperCase()}';
        print('⚠️ Generated fallback booking reference: $ref');
        return ref;
      }
      
      print('❌ No booking reference found in booking data');
      return '';
    }

    // Parse date helper
    DateTime parseDate(dynamic dateValue) {
      try {
        if (dateValue == null) return DateTime.now();
        if (dateValue is DateTime) return dateValue;
        if (dateValue is String) {
          // Try ISO format first
          final isoDate = DateTime.tryParse(dateValue);
          if (isoDate != null) return isoDate;
          
          // Try dd/MM/yyyy format
          if (dateValue.contains('/')) {
            final parts = dateValue.split('/');
            if (parts.length == 3) {
              final day = int.tryParse(parts[0]) ?? 1;
              final month = int.tryParse(parts[1]) ?? 1;
              final year = int.tryParse(parts[2]) ?? DateTime.now().year;
              return DateTime(year, month, day);
            }
          }
        }
        if (dateValue is Map && dateValue['\$date'] != null) {
          return DateTime.tryParse(dateValue['\$date'].toString()) ?? DateTime.now();
        }
        return DateTime.now();
      } catch (e) {
        print('❌ Error parsing date: $e');
        return DateTime.now();
      }
    }

    // Extract service ID
    String extractServiceId() {
      final serviceId = json['serviceId']?.toString() ?? '';
      if (serviceId.isEmpty && json['service'] is Map) {
        return json['service']['serviceId']?.toString() ?? 
               json['service']['id']?.toString() ?? '';
      }
      return serviceId;
    }

    // Extract provider ID (should be PROV-xxx)
    String extractProviderId() {
      final providerId = json['providerId']?.toString() ?? '';
      if (providerId.isEmpty && json['provider'] is Map) {
        return json['provider']['pid']?.toString() ?? // Prefer PID
               json['provider']['_id']?.toString() ?? '';
      }
      return providerId;
    }

    // Extract provider name
    String extractProviderName() {
      if (json['provider'] is Map) {
        return json['provider']['fullname']?.toString() ??
               json['provider']['name']?.toString() ??
               'Provider';
      }
      return json['providerName']?.toString() ?? 'Provider';
    }

    // Extract customer name
    String extractCustomerName() {
      if (json['customer'] is Map) {
        return json['customer']['fullname']?.toString() ??
               json['customer']['name']?.toString() ??
               'Customer';
      }
      return json['customerName']?.toString() ?? 'Customer';
    }

    return BookingModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      bookingReference: extractBookingReference(), // This is what backend uses for review lookup
      serviceId: extractServiceId(),
      serviceName: json['serviceName']?.toString() ??
                  json['service']?['title']?.toString() ??
                  json['service']?['name']?.toString() ??
                  'Service',
      serviceImage: json['serviceImage']?.toString() ??
                   json['service']?['imageUrl']?.toString() ??
                   json['service']?['image']?.toString(),
      providerId: extractProviderId(),
      providerName: extractProviderName(),
      customerId: json['customerId']?.toString() ??
                 json['customer']?['_id']?.toString() ??
                 json['user']?['_id']?.toString() ??
                 '',
      customerName: extractCustomerName(),
      bookingDate: parseDate(json['bookingDate'] ?? json['date']),
      startTime: json['startTime']?.toString() ?? '09:00',
      endTime: json['endTime']?.toString() ?? '10:00',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ??
                  (json['amount'] as num?)?.toDouble() ??
                  0.0,
      status: (json['status']?.toString() ?? 'pending').toLowerCase(),
      createdAt: parseDate(json['createdAt']),
      paymentMethod: json['paymentMethod']?.toString(),
      paymentReference: json['paymentReference']?.toString(),
      transactionId: json['transactionId']?.toString(),
      notes: json['notes']?.toString(),
      updatedAt: json['updatedAt'] != null ? parseDate(json['updatedAt']) : null,
      cancellationReason: json['cancellationReason']?.toString(),
      cancellationDate: json['cancellationDate'] != null ? parseDate(json['cancellationDate']) : null,
      isPaid: json['isPaid'] == true || json['paymentStatus'] == 'paid',
      isConfirmed: json['isConfirmed'] == true || (json['status']?.toString().toLowerCase() == 'confirmed'),
      currency: json['currency']?.toString() ?? 'ETB',
      paymentStatus: json['paymentStatus']?.toString(),
      paymentDate: json['paymentDate'] != null ? parseDate(json['paymentDate']) : null,
      serviceDetails: json['service'] is Map ? Map<String, dynamic>.from(json['service']) : null,
      providerDetails: json['provider'] is Map ? Map<String, dynamic>.from(json['provider']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'bookingReference': bookingReference,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'serviceImage': serviceImage,
      'providerId': providerId,
      'providerName': providerName,
      'customerId': customerId,
      'customerName': customerName,
      'bookingDate': formattedBookingDate, // dd/MM/yyyy format
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentReference': paymentReference,
      'transactionId': transactionId,
      'notes': notes,
      'updatedAt': updatedAt?.toIso8601String(),
      'cancellationReason': cancellationReason,
      'cancellationDate': cancellationDate?.toIso8601String(),
      'isPaid': isPaid,
      'isConfirmed': isConfirmed,
      'currency': currency,
      'paymentStatus': paymentStatus,
      'paymentDate': paymentDate?.toIso8601String(),
      'serviceDetails': serviceDetails,
      'providerDetails': providerDetails,
    };
  }

  // =================== DATE FORMATTERS ===================
  
  // For API calls: dd/MM/yyyy format
  String get formattedBookingDate {
    return DateFormat('dd/MM/yyyy').format(bookingDate);
  }
  
  // For display with time
  String get displayBookingDateTime {
    return DateFormat('dd/MM/yyyy HH:mm').format(bookingDate);
  }
  
  // For TimeSlotsUtils: yyyy-MM-dd format
  String get timeSlotsBookingDate {
    return DateFormat('yyyy-MM-dd').format(bookingDate);
  }
  
  String get formattedCreatedAt => DateFormat('dd/MM/yyyy HH:mm').format(createdAt);
  String get formattedTimeRange => '$startTime - $endTime';
  
  // =================== STATUS HELPERS ===================
  
  bool get isPending => status == 'pending';
  bool get isConfirmedStatus => status == 'confirmed';
  bool get isCancelled => status == 'cancelled';
  bool get isCompleted => status == 'completed';
  bool get isPendingPayment => status == 'pending_payment';
  
  // Check if booking can be reviewed
  bool get canBeReviewed {
    return isCompleted && 
           bookingReference.isNotEmpty && 
           bookingReference.startsWith('BK-');
  }
  
  // Status display
  String get statusDisplay {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      case 'pending_payment': return 'Payment Pending';
      default: return status;
    }
  }
  
  // Status color
  String get statusColor {
    switch (status) {
      case 'confirmed': return '#10B981'; // Green
      case 'pending':
      case 'pending_payment': return '#F59E0B'; // Orange
      case 'cancelled': return '#EF4444'; // Red
      case 'completed': return '#3B82F6'; // Blue
      default: return '#6B7280'; // Gray
    }
  }

  @override
  String toString() {
    return 'Booking{id: $id, reference: $bookingReference, service: $serviceId, status: $status, date: $formattedBookingDate}';
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