// lib/models/review_model.dart
import 'dart:convert';
import 'package:flutter/material.dart'; // Add this import
import 'package:intl/intl.dart';

class ReviewModel {
  final String id;
  final String serviceId;
  final String bookingId; // Required for review creation
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
  final List<String>? helpfulUsers;
  final bool? isReported;
  final String? reportReason;
  final String? serviceName;
  final String? providerResponse;
  final String? customerAvatar;
  final String? customerInitials;
  final String? bookingReference;
  final bool? isVerifiedBooking;
  final String? reviewType; // service, provider, booking
  final Map<String, dynamic>? metadata;

  const ReviewModel({
    required this.id,
    required this.serviceId,
    required this.bookingId,
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
    this.helpfulUsers,
    this.isReported,
    this.reportReason,
    this.serviceName,
    this.providerResponse,
    this.customerAvatar,
    this.customerInitials,
    this.bookingReference,
    this.isVerifiedBooking,
    this.reviewType,
    this.metadata,
  });

  // Factory constructor for creating a new review (before sending to API)
  factory ReviewModel.create({
    required String serviceId,
    required String bookingId,
    required double rating,
    required String comment,
    String? customerId,
    String? customerName,
    String? serviceName,
    String? providerId,
    String? providerName,
  }) {
    return ReviewModel(
      id: '', // Will be assigned by server
      serviceId: serviceId,
      bookingId: bookingId,
      customerId: customerId,
      customerName: customerName,
      rating: rating,
      comment: comment,
      status: 'pending',
      createdAt: DateTime.now(),
      serviceName: serviceName,
      providerId: providerId,
      providerName: providerName,
    );
  }

  // Factory constructor from JSON
  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    // Helper function to parse dates
    DateTime? parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          return DateTime.tryParse(dateValue);
        } else if (dateValue is Map && dateValue.containsKey('\$date')) {
          return DateTime.tryParse(dateValue['\$date'].toString());
        } else if (dateValue is int) {
          return DateTime.fromMillisecondsSinceEpoch(dateValue);
        }
        return null;
      } catch (e) {
        print('Error parsing date: $e');
        return null;
      }
    }

    // Extract user/customer info
    Map<String, dynamic>? userMap;
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user']);
    } else if (json['customer'] is Map) {
      userMap = Map<String, dynamic>.from(json['customer']);
    } else if (json['reviewer'] is Map) {
      userMap = Map<String, dynamic>.from(json['reviewer']);
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

    // Extract booking info
    Map<String, dynamic>? bookingMap;
    if (json['booking'] is Map) {
      bookingMap = Map<String, dynamic>.from(json['booking']);
    }

    // Helper function to extract customer name
    String? extractCustomerName(Map<String, dynamic>? userMap) {
      if (userMap == null) return null;
      return userMap['fullname']?.toString() ??
          userMap['name']?.toString() ??
          userMap['username']?.toString() ??
          userMap['email']?.toString();
    }

    // Generate customer initials
    String? generateCustomerInitials(String? name) {
      if (name == null || name.isEmpty) return null;
      final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
    }

    // Parse rating
    double? parseRating(dynamic ratingValue) {
      if (ratingValue == null) return null;
      if (ratingValue is double) return ratingValue;
      if (ratingValue is int) return ratingValue.toDouble();
      if (ratingValue is String) return double.tryParse(ratingValue);
      return null;
    }

    final customerName = extractCustomerName(userMap);
    final initials = generateCustomerInitials(customerName);

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? 
                serviceMap?['_id']?.toString() ??
                serviceMap?['id']?.toString() ??
                '',
      bookingId: json['bookingId']?.toString() ?? 
                bookingMap?['_id']?.toString() ??
                bookingMap?['id']?.toString() ??
                json['booking']?.toString() ?? // Sometimes booking is just an ID string
                '',
      customerId: json['customerId']?.toString() ??
                 userMap?['_id']?.toString() ??
                 userMap?['id']?.toString() ??
                 json['userId']?.toString() ??
                 json['reviewerId']?.toString(),
      customerName: customerName ??
                   json['customerName']?.toString() ??
                   json['reviewerName']?.toString() ??
                   'Anonymous User',
      customerEmail: userMap?['email']?.toString() ??
                    json['customerEmail']?.toString() ??
                    json['reviewerEmail']?.toString(),
      rating: parseRating(json['rating']) ?? 0.0,
      comment: json['comment']?.toString() ??
               json['review']?.toString() ??
               json['message']?.toString() ??
               'No comment provided.',
      response: json['response']?.toString(),
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseDate(json['updatedAt']),
      respondedAt: parseDate(json['respondedAt']) ??
                  parseDate(json['responseDate']),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt() ?? 0,
      status: (json['status']?.toString() ?? 'published').toLowerCase(),
      providerId: providerMap?['pid']?.toString() ??
                 providerMap?['_id']?.toString() ??
                 json['providerId']?.toString(),
      providerName: providerMap?['fullname']?.toString() ??
                   providerMap?['name']?.toString() ??
                   json['providerName']?.toString(),
      helpfulUsers: json['helpfulUsers'] is List
          ? List<String>.from(json['helpfulUsers'].map((x) => x.toString()))
          : null,
      isReported: json['isReported'] == true || json['reported'] == true,
      reportReason: json['reportReason']?.toString() ?? json['reportMessage']?.toString(),
      serviceName: serviceMap?['name']?.toString() ??
                  serviceMap?['title']?.toString() ??
                  json['serviceName']?.toString(),
      providerResponse: json['providerResponse']?.toString(),
      customerAvatar: userMap?['avatar']?.toString() ??
                     userMap?['profilePhoto']?.toString() ??
                     userMap?['imageUrl']?.toString() ??
                     json['customerAvatar']?.toString(),
      customerInitials: initials,
      bookingReference: bookingMap?['reference']?.toString() ??
                       bookingMap?['bookingNumber']?.toString() ??
                       json['bookingReference']?.toString(),
      isVerifiedBooking: bookingMap?['isVerified'] ?? json['isVerifiedBooking'] ?? false,
      reviewType: json['reviewType']?.toString() ?? 'service',
      metadata: json['metadata'] is Map ? Map<String, dynamic>.from(json['metadata']) : null,
    );
  }

  // Convert to JSON for API requests
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'bookingId': bookingId,
      'customerId': customerId,
      'customerName': customerName,
      'customerEmail': customerEmail,
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
      'helpfulUsers': helpfulUsers,
      'isReported': isReported,
      'reportReason': reportReason,
      'serviceName': serviceName,
      'providerResponse': providerResponse,
      'customerAvatar': customerAvatar,
      'customerInitials': customerInitials,
      'bookingReference': bookingReference,
      'isVerifiedBooking': isVerifiedBooking,
      'reviewType': reviewType,
      'metadata': metadata,
    };
  }

  // Convert to JSON string
  String toJsonString() => json.encode(toJson());

  // For creating API request body (only essential fields)
  Map<String, dynamic> toApiJson() {
    return {
      'serviceId': serviceId,
      'bookingId': bookingId,
      'rating': rating,
      'comment': comment,
      if (customerId != null) 'customerId': customerId,
    };
  }

  // ========== GETTERS ==========

  String get formattedCreatedAt {
    if (createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    
    if (difference.inDays > 7) {
      return DateFormat('dd/MM/yyyy').format(createdAt!);
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  String get formattedDetailedDate {
    if (createdAt == null) return 'Unknown date';
    return DateFormat('dd MMM yyyy, HH:mm').format(createdAt!);
  }

  String get formattedResponseDate {
    if (respondedAt == null) return '';
    return DateFormat('dd MMM yyyy, HH:mm').format(respondedAt!);
  }

  String get reviewerName => customerName ?? 'Anonymous User';
  
  String get reviewerInitials {
    if (customerInitials != null && customerInitials!.isNotEmpty) {
      return customerInitials!;
    }
    final name = reviewerName;
    if (name.isEmpty) return '?';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.length >= 2
        ? name.substring(0, 2).toUpperCase()
        : name.toUpperCase();
  }

  bool get hasProviderResponse => 
      (response?.isNotEmpty == true) || 
      (providerResponse?.isNotEmpty == true);
  
  String get providerResponseText => response ?? providerResponse ?? '';
  
  bool get isPublished => status?.toLowerCase() == 'published';
  
  bool get isPending => status?.toLowerCase() == 'pending';
  
  bool get isHidden => status?.toLowerCase() == 'hidden';
  
  bool get isDraft => status?.toLowerCase() == 'draft';
  
  bool get isHelpful => (helpfulCount ?? 0) > 0;
  
  bool get isReportedStatus => isReported == true;
  
  bool get isVerified => isVerifiedBooking == true;
  
  int get starRating => rating?.round() ?? 0;

  // Fixed: Use Color objects instead of strings
  Color get statusColor {
    switch (status?.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'hidden':
      case 'archived':
        return Colors.grey;
      case 'reported':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String get statusText {
    switch (status?.toLowerCase()) {
      case 'published':
        return 'Published';
      case 'pending':
        return 'Pending Review';
      case 'hidden':
        return 'Hidden';
      case 'archived':
        return 'Archived';
      case 'reported':
        return 'Reported';
      default:
        return status ?? 'Unknown';
    }
  }

  String get ratingCategory {
    final r = rating ?? 0.0;
    if (r >= 4.5) return 'Excellent';
    if (r >= 4.0) return 'Very Good';
    if (r >= 3.0) return 'Good';
    if (r >= 2.0) return 'Fair';
    return 'Poor';
  }

  // Fixed: Return Color object
  Color get ratingColor {
    final r = rating ?? 0.0;
    if (r >= 4.0) return Colors.green;
    if (r >= 3.0) return Colors.orange;
    return Colors.red;
  }

  // ========== HELPER METHODS ==========

  // Copy with method
  ReviewModel copyWith({
    String? id,
    String? serviceId,
    String? bookingId,
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
    List<String>? helpfulUsers,
    bool? isReported,
    String? reportReason,
    String? serviceName,
    String? providerResponse,
    String? customerAvatar,
    String? customerInitials,
    String? bookingReference,
    bool? isVerifiedBooking,
    String? reviewType,
    Map<String, dynamic>? metadata,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      bookingId: bookingId ?? this.bookingId,
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
      helpfulUsers: helpfulUsers ?? this.helpfulUsers,
      isReported: isReported ?? this.isReported,
      reportReason: reportReason ?? this.reportReason,
      serviceName: serviceName ?? this.serviceName,
      providerResponse: providerResponse ?? this.providerResponse,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      customerInitials: customerInitials ?? this.customerInitials,
      bookingReference: bookingReference ?? this.bookingReference,
      isVerifiedBooking: isVerifiedBooking ?? this.isVerifiedBooking,
      reviewType: reviewType ?? this.reviewType,
      metadata: metadata ?? this.metadata,
    );
  }

  // For creating an empty review (placeholder)
  factory ReviewModel.empty() {
    return ReviewModel(
      id: '',
      serviceId: '',
      bookingId: '',
      rating: 0.0,
      comment: '',
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  // Check if review is empty
  bool get isEmpty => id.isEmpty || serviceId.isEmpty || bookingId.isEmpty;

  // Check if review is valid for submission
  bool get isValidForSubmission {
    return serviceId.isNotEmpty && 
           bookingId.isNotEmpty && 
           (rating ?? 0) > 0 && 
           (comment?.isNotEmpty == true);
  }

  // Star widgets for UI (now returns Widgets properly)
  List<Widget> getStarWidgets({double size = 16}) {
    final fullStars = starRating;
    final emptyStars = 5 - fullStars;
    final stars = <Widget>[];
    
    for (int i = 0; i < fullStars; i++) {
      stars.add(Icon(Icons.star, size: size, color: Colors.amber));
    }
    for (int i = 0; i < emptyStars; i++) {
      stars.add(Icon(Icons.star_border, size: size, color: Colors.grey));
    }
    
    return stars;
  }

  // Rating progress (0-1)
  double get ratingProgress => (rating ?? 0.0) / 5.0;

  // Check if review can be edited (within 24 hours of creation)
  bool get canBeEdited {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inHours <= 24 && isPublished;
  }

  // Check if review can be deleted (within 1 hour of creation)
  bool get canBeDeleted {
    if (createdAt == null) return false;
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    return difference.inHours <= 1;
  }

  // Get excerpt of comment (first 100 chars)
  String get commentExcerpt {
    if (comment == null || comment!.isEmpty) return '';
    return comment!.length <= 100 ? comment! : '${comment!.substring(0, 100)}...';
  }

  @override
  String toString() {
    return 'ReviewModel{id: $id, serviceId: $serviceId, rating: $rating, status: $status}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          serviceId == other.serviceId &&
          bookingId == other.bookingId;

  @override
  int get hashCode => Object.hash(id, serviceId, bookingId);
}