// lib/models/review_model.dart
class ReviewModel {
  final String id;
  final String serviceId;
  final String? customerId;
  final String? customerName;
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

  ReviewModel({
    required this.id,
    required this.serviceId,
    this.customerId,
    this.customerName,
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
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    DateTime? _parseDate(dynamic dateValue) {
      if (dateValue == null) return null;
      try {
        if (dateValue is String) {
          return DateTime.parse(dateValue);
        } else if (dateValue is Map && dateValue.containsKey('\$date')) {
          return DateTime.parse(dateValue['\$date']);
        }
        return null;
      } catch (e) {
        return null;
      }
    }

    // Extract user/customer info
    String? _extractCustomerName(Map<String, dynamic>? userMap) {
      if (userMap == null) return null;
      return userMap['fullname']?.toString() ??
          userMap['name']?.toString() ??
          userMap['username']?.toString();
    }

    Map<String, dynamic>? userMap;
    if (json['user'] is Map) {
      userMap = Map<String, dynamic>.from(json['user']);
    } else if (json['customer'] is Map) {
      userMap = Map<String, dynamic>.from(json['customer']);
    }

    // Extract provider info if available
    String? providerId;
    String? providerName;
    if (json['provider'] is Map) {
      final providerMap = Map<String, dynamic>.from(json['provider']);
      providerId =
          providerMap['pid']?.toString() ?? providerMap['_id']?.toString();
      providerName = providerMap['fullname']?.toString() ??
          providerMap['name']?.toString();
    }

    return ReviewModel(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      serviceId: json['serviceId']?.toString() ?? '',
      customerId: json['customerId']?.toString() ??
          userMap?['_id']?.toString() ??
          (json['userId'] as String?),
      customerName: _extractCustomerName(userMap) ??
          json['customerName']?.toString() ??
          'Anonymous User',
      rating: (json['rating'] as num?)?.toDouble(),
      comment: json['comment']?.toString()?.isNotEmpty == true
          ? json['comment'].toString()
          : 'No comment provided.',
      response: json['response']?.toString(),
      createdAt: _parseDate(json['createdAt']),
      updatedAt: _parseDate(json['updatedAt']),
      respondedAt: _parseDate(json['respondedAt']),
      helpfulCount: json['helpfulCount'] as int? ?? 0,
      status: json['status']?.toString() ?? 'published',
      providerId: providerId,
      providerName: providerName,
    );
  }

  String getReviewerName() => customerName ?? 'Anonymous User';

  bool get hasProviderResponse => response != null && response!.isNotEmpty;

  bool get isPublished => status?.toLowerCase() == 'published';

  @override
  String toString() {
    return 'ReviewModel{id: $id, rating: $rating, comment: $comment}';
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
