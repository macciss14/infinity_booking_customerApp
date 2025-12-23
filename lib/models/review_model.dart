// lib/models/review_model.dart
import 'package:intl/intl.dart';

class ReviewModel {
  final String id;
  final String serviceId;
  final String? customerId;
  final String? customerName;
  final String? customerEmail;
  final double? rating;
  final String? comment;
  final String? response;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? respondedAt;
  final int? helpfulCount;
  final String? status;
  final String? providerId;
  final String? providerName;
  final String? bookingId;
  final List<String>? helpfulUsers;
  final bool? isReported;
  final String? reportReason;
  final String? serviceName;
  final String? providerResponse;

  ReviewModel({
    required this.id,
    required this.serviceId,
    this.customerId,
    this.customerName,
    this.customerEmail,
    this.rating,
    this.comment,
    this.response,
    this.createdAt,
    this.updatedAt,
    this.respondedAt,
    this.helpfulCount,
    this.status,
    this.providerId,
    this.providerName,
    this.bookingId,
    this.helpfulUsers,
    this.isReported,
    this.reportReason,
    this.serviceName,
    this.providerResponse,
  });

  // Formatted date getters
  String get formattedCreatedAt => createdAt != null 
      ? DateFormat('dd/MM/yyyy HH:mm').format(createdAt!)
      : 'Unknown';
  
  String get formattedRespondedAt => respondedAt != null
      ? DateFormat('dd/MM/yyyy HH:mm').format(respondedAt!)
      : '';

  // Helper getters
  String getReviewerName() => customerName ?? 'Anonymous User';
  
  String get reviewerInitials {
    final name = getReviewerName();
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  bool get hasProviderResponse => (response?.isNotEmpty == true) || 
                                  (providerResponse?.isNotEmpty == true);
  
  String get providerResponseText => response ?? providerResponse ?? '';
  
  bool get isPublished => status?.toLowerCase() == 'published';
  
  bool get isPending => status?.toLowerCase() == 'pending';
  
  bool get isHidden => status?.toLowerCase() == 'hidden';
  
  bool get isHelpful => (helpfulCount ?? 0) > 0;

  // Star rating helper
  int get starRating => rating?.round() ?? 0;

  // Status color
  String get statusColor {
    switch (status?.toLowerCase()) {
      case 'published':
        return '#10B981'; // green
      case 'pending':
        return '#F59E0B'; // amber
      case 'hidden':
        return '#6B7280'; // gray
      default:
        return '#6B7280';
    }
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          return DateTime.tryParse(dateValue);
        } else if (dateValue is Map && dateValue.containsKey('\$date')) {
          return DateTime.tryParse(dateValue['\$date'].toString());
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    // Extract user/customer info
    Map<String, dynamic>? userMap;
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user']);
    } else if (json['customer'] is Map) {
      userMap = Map<String, dynamic>.from(json['customer']);
    }

    String? extractCustomerName(Map<String, dynamic>? userMap) {
      if (userMap == null) return null;
      return userMap['fullname']?.toString() ??
          userMap['name']?.toString() ??
          userMap['username']?.toString() ??
          userMap['email']?.toString();
    }

    // Extract provider info
    Map<String, dynamic>? providerMap;
    if (json['provider'] is Map) {
      providerMap = Map<String, dynamic>.from(json['provider']);
    }

    // Extract service info
    Map<String, dynamic>? serviceMap;
    if (json['service'] is Map) {
      serviceMap = Map<String, dynamic>.from(json['service']);
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? 
                serviceMap?['_id']?.toString() ??
                serviceMap?['id']?.toString() ??
                '',
      customerId: json['customerId']?.toString() ??
                 userMap?['_id']?.toString() ??
                 userMap?['id']?.toString() ??
                 json['userId']?.toString(),
      customerName: extractCustomerName(userMap) ??
                   json['customerName']?.toString() ??
                   'Anonymous User',
      customerEmail: userMap?['email']?.toString() ??
                    json['customerEmail']?.toString(),
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      comment: json['comment']?.toString() ??
               json['review']?.toString() ??
               'No comment provided.',
      response: json['response']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      respondedAt: parseDate(json['respondedAt']) ??
                  parseDate(json['responseDate']),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      status: json['status']?.toString()?.toLowerCase() ?? 'published',
      providerId: providerMap?['pid']?.toString() ??
                 providerMap?['_id']?.toString() ??
                 json['providerId']?.toString(),
      providerName: providerMap?['fullname']?.toString() ??
                   providerMap?['name']?.toString() ??
                   json['providerName']?.toString(),
      bookingId: json['bookingId']?.toString(),
      helpfulUsers: json['helpfulUsers'] is List
          ? List<String>.from(json['helpfulUsers'].map((x) => x.toString()))
          : null,
      isReported: json['isReported'] == true,
      reportReason: json['reportReason']?.toString(),
      serviceName: serviceMap?['name']?.toString() ??
                  serviceMap?['title']?.toString() ??
                  json['serviceName']?.toString(),
      providerResponse: json['providerResponse']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'customerId': customerId,
      'customerName': customerName,
      'rating': rating,
      'comment': comment,
      'response': response,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'respondedAt': respondedAt?.toIso8601String(),
      'helpfulCount': helpfulCount,
      'status': status,
      'providerId': providerId,
      'providerName': providerName,
      'bookingId': bookingId,
      'helpfulUsers': helpfulUsers,
      'isReported': isReported,
      'reportReason': reportReason,
      'serviceName': serviceName,
      'providerResponse': providerResponse,
    };
  }

  ReviewModel copyWith({
    String? id,
    String? serviceId,
    String? customerId,
    String? customerName,
    String? customerEmail,
    double? rating,
    String? comment,
    String? response,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? respondedAt,
    int? helpfulCount,
    String? status,
    String? providerId,
    String? providerName,
    String? bookingId,
    List<String>? helpfulUsers,
    bool? isReported,
    String? reportReason,
    String? serviceName,
    String? providerResponse,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      customerEmail: customerEmail ?? this.customerEmail,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      response: response ?? this.response,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      respondedAt: respondedAt ?? this.respondedAt,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      status: status ?? this.status,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      bookingId: bookingId ?? this.bookingId,
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      serviceName: serviceName ?? this.serviceName,
      providerResponse: providerResponse ?? this.providerResponse,
    );
  }

  @override
  String toString() {
    return 'ReviewModel{id: $id, rating: $rating, serviceId: $serviceId}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}