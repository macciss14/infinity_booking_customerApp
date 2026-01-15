import 'dart:convert';
import 'package:flutter/material.dart';
class ReviewModel {
  final String id; // MongoDB _id
  final String serviceId; // This should be svc_xxx
  final String serviceName;
  final String bookingId; // This should be booking reference like BK-xxx
  final double rating;
  final String comment;
  final String reviewerId; // Customer CID
  final String reviewerName;
  final String reviewerEmail;
  final String? reviewerImage;
  final String? providerId; // Provider PID (PROV-xxx)
  final String? providerName;
  final bool isPublished;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Additional fields from your backend
  final bool isVerified;
  final String? status;
  final int? helpfulCount;
  final bool? isHelpful;
  final String? providerResponse;
  final DateTime? respondedAt;

  ReviewModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.bookingId,
    required this.rating,
    required this.comment,
    required this.reviewerId,
    required this.reviewerName,
    required this.reviewerEmail,
    this.reviewerImage,
    this.providerId,
    this.providerName,
    this.isPublished = true,
    this.isFeatured = false,
    required this.createdAt,
    this.updatedAt,
    this.isVerified = false,
    this.status,
    this.helpfulCount,
    this.isHelpful,
    this.providerResponse,
    this.respondedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    print('🔍 Parsing Review JSON: ${json.keys.toList()}');

    // Extract booking ID - CRITICAL: Look for bookingId field
    String extractBookingId() {
      // Your backend returns bookingId directly
      final bookingId = json['bookingId']?.toString().trim();
      if (bookingId != null && bookingId.isNotEmpty) {
        print('✅ Found bookingId: $bookingId');
        return bookingId;
      }
      
      // Also check in nested booking object
      if (json['booking'] is Map) {
        final booking = json['booking'] as Map<String, dynamic>;
        final bookingRef = booking['bookingId']?.toString().trim() ?? 
                          booking['bookingReference']?.toString().trim();
        if (bookingRef != null && bookingRef.isNotEmpty) {
          print('✅ Found bookingId in booking object: $bookingRef');
          return bookingRef;
        }
      }
      
      print('⚠️ No bookingId found in review');
      return '';
    }

    // Extract service ID
    String extractServiceId() {
      // Your backend should return svc_xxx format
      final serviceId = json['serviceId']?.toString() ?? '';
      if (serviceId.isEmpty && json['service'] is Map) {
        return json['service']['serviceId']?.toString() ?? 
               json['service']['id']?.toString() ?? '';
      }
      return serviceId;
    }

    // Parse rating
    double extractRating() {
      try {
        final rating = json['rating'];
        if (rating is int) return rating.toDouble();
        if (rating is double) return rating;
        if (rating is String) return double.tryParse(rating) ?? 0.0;
        return 0.0;
      } catch (e) {
        print('❌ Error parsing rating: $e');
        return 0.0;
      }
    }

    // Parse dates
    DateTime parseDate(dynamic dateValue) {
      try {
        if (dateValue == null) return DateTime.now();
        if (dateValue is DateTime) return dateValue;
        if (dateValue is String) return DateTime.parse(dateValue);
        if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
        return DateTime.now();
      } catch (e) {
        print('❌ Error parsing date: $e');
        return DateTime.now();
      }
    }

    DateTime? parseNullableDate(dynamic dateValue) {
      try {
        if (dateValue == null) return null;
        if (dateValue is DateTime) return dateValue;
        if (dateValue is String) return dateValue.isNotEmpty ? DateTime.parse(dateValue) : null;
        if (dateValue is int) return DateTime.fromMillisecondsSinceEpoch(dateValue);
        return null;
      } catch (e) {
        print('❌ Error parsing nullable date: $e');
        return null;
      }
    }

    // Extract reviewer info
    String extractReviewerId() {
      return json['customerId']?.toString() ?? // Your backend uses customerId
             json['reviewerId']?.toString() ?? 
             json['userId']?.toString() ?? '';
    }

    String extractReviewerName() {
      if (json['customer'] is Map) {
        return json['customer']['fullname']?.toString() ?? 
               json['customer']['name']?.toString() ?? 'Customer';
      }
      return json['reviewerName']?.toString() ?? 
             json['customerName']?.toString() ?? 'Customer';
    }

    // Extract reviewer email
    String extractReviewerEmail() {
      if (json['customer'] is Map) {
        return json['customer']['email']?.toString() ?? '';
      }
      return json['reviewerEmail']?.toString() ?? 
             json['customerEmail']?.toString() ?? '';
    }

    // Extract reviewer image
    String? extractReviewerImage() {
      if (json['customer'] is Map) {
        return json['customer']['image']?.toString() ?? 
               json['customer']['photo']?.toString();
      }
      return json['reviewerImage']?.toString() ?? 
             json['customerImage']?.toString();
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      serviceId: extractServiceId(),
      serviceName: json['serviceName']?.toString() ??
                  json['service']?['name']?.toString() ??
                  json['service']?['title']?.toString() ??
                  'Service',
      bookingId: extractBookingId(), // This is the booking reference like BK-xxx
      rating: extractRating(),
      comment: json['comment']?.toString() ?? '',
      reviewerId: extractReviewerId(),
      reviewerName: extractReviewerName(),
      reviewerEmail: extractReviewerEmail(),
      reviewerImage: extractReviewerImage(),
      providerId: json['providerId']?.toString(),
      providerName: json['providerName']?.toString(),
      isPublished: json['isPublished'] as bool? ?? true,
      isFeatured: json['isFeatured'] as bool? ?? false,
      createdAt: parseDate(json['createdAt']),
      updatedAt: parseNullableDate(json['updatedAt']),
      isVerified: json['isVerified'] as bool? ?? false,
      status: json['status']?.toString(),
      helpfulCount: (json['helpfulCount'] as num?)?.toInt(),
      isHelpful: json['isHelpful'] as bool?,
      providerResponse: json['providerResponse']?.toString(),
      respondedAt: parseNullableDate(json['respondedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'serviceId': serviceId,
      'serviceName': serviceName,
      'bookingId': bookingId, // This is the booking reference
      'rating': rating,
      'comment': comment,
      'customerId': reviewerId, // Your backend expects customerId
      'reviewerName': reviewerName,
      'reviewerEmail': reviewerEmail,
      'reviewerImage': reviewerImage,
      'providerId': providerId,
      'providerName': providerName,
      'isPublished': isPublished,
      'isFeatured': isFeatured,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isVerified': isVerified,
      'status': status,
      'helpfulCount': helpfulCount,
      'isHelpful': isHelpful,
      'providerResponse': providerResponse,
      'respondedAt': respondedAt?.toIso8601String(),
    };
  }

  // ==================== HELPER METHODS ====================

  // Get reviewer initials for avatar
  String get reviewerInitials {
    if (reviewerName.isEmpty) return 'CU';
    final parts = reviewerName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return reviewerName.length >= 2
        ? reviewerName.substring(0, 2).toUpperCase()
        : reviewerName.toUpperCase();
  }

  // Format created at date for display
  String get formattedCreatedAt {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }

  // Format response date for display
  String get formattedResponseDate {
    if (respondedAt == null) return '';
    final now = DateTime.now();
    final difference = now.difference(respondedAt!);
    
    if (difference.inDays > 0) return '${difference.inDays}d ago';
    if (difference.inHours > 0) return '${difference.inHours}h ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes}m ago';
    return 'Just now';
  }

  // Check if review has provider response
  bool get hasProviderResponse => providerResponse != null && providerResponse!.isNotEmpty;
  
  // Get provider response text
  String get providerResponseText => providerResponse ?? '';

  // Get star rating breakdown
  List<int> get starRating {
    final fullStars = rating.floor();
    final hasHalfStar = rating - fullStars >= 0.5;
    return [fullStars, hasHalfStar ? 1 : 0, 5 - fullStars - (hasHalfStar ? 1 : 0)];
  }

  // Check if review is valid
  bool get isValid => serviceId.isNotEmpty && bookingId.isNotEmpty && rating > 0;

  // Get display booking ID (truncated for UI)
  String get displayBookingId {
    if (bookingId.isEmpty) return 'No Booking';
    if (bookingId.length <= 12) return bookingId;
    return '${bookingId.substring(0, 10)}...';
  }

  // Check if booking ID is in BK- format
  bool get isBkFormatBookingId => bookingId.startsWith('BK-');

  // Check if review was created recently (within 7 days)
  bool get isRecent {
    return DateTime.now().difference(createdAt).inDays <= 7;
  }

  // Get rating color based on value
  Color get ratingColor {
    if (rating >= 4.0) return Colors.green;
    if (rating >= 3.0) return Colors.orange;
    return Colors.red;
  }

  // Get rating text based on value
  String get ratingText {
    if (rating >= 4.5) return 'Excellent';
    if (rating >= 4.0) return 'Very Good';
    if (rating >= 3.5) return 'Good';
    if (rating >= 3.0) return 'Average';
    if (rating >= 2.0) return 'Below Average';
    return 'Poor';
  }

  // Check if service ID has svc_ prefix
  bool get hasSvcPrefix => serviceId.startsWith('svc_');

  // Get clean service ID without svc_ prefix
  String get cleanServiceId {
    if (hasSvcPrefix) {
      return serviceId.substring(4);
    }
    return serviceId;
  }

  // Format date for display (e.g., "Jan 15, 2024")
  String get formattedDate {
    final month = _getMonthName(createdAt.month);
    final day = createdAt.day;
    final year = createdAt.year;
    return '$month $day, $year';
  }

  // Helper method to get month name
  String _getMonthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }

  // Format time for display (e.g., "2:30 PM")
  String get formattedTime {
    final hour = createdAt.hour % 12;
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final period = createdAt.hour < 12 ? 'AM' : 'PM';
    final displayHour = hour == 0 ? 12 : hour;
    return '$displayHour:$minute $period';
  }

  // Get full date and time
  String get formattedDateTime {
    return '$formattedDate at $formattedTime';
  }

  // Copy with method for immutability
  ReviewModel copyWith({
    String? id,
    String? serviceId,
    String? serviceName,
    String? bookingId,
    double? rating,
    String? comment,
    String? reviewerId,
    String? reviewerName,
    String? reviewerEmail,
    String? reviewerImage,
    String? providerId,
    String? providerName,
    bool? isPublished,
    bool? isFeatured,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    String? status,
    int? helpfulCount,
    bool? isHelpful,
    String? providerResponse,
    DateTime? respondedAt,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      serviceId: serviceId ?? this.serviceId,
      serviceName: serviceName ?? this.serviceName,
      bookingId: bookingId ?? this.bookingId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      reviewerId: reviewerId ?? this.reviewerId,
      reviewerName: reviewerName ?? this.reviewerName,
      reviewerEmail: reviewerEmail ?? this.reviewerEmail,
      reviewerImage: reviewerImage ?? this.reviewerImage,
      providerId: providerId ?? this.providerId,
      providerName: providerName ?? this.providerName,
      isPublished: isPublished ?? this.isPublished,
      isFeatured: isFeatured ?? this.isFeatured,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      status: status ?? this.status,
      helpfulCount: helpfulCount ?? this.helpfulCount,
      isHelpful: isHelpful ?? this.isHelpful,
      providerResponse: providerResponse ?? this.providerResponse,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }

  @override
  String toString() {
    return 'ReviewModel{id: $id, service: $serviceId, booking: $bookingId, rating: $rating, reviewer: $reviewerName}';
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