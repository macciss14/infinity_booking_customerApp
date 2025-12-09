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
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['_id'] ?? json['id'] ?? '',
      serviceId: json['serviceId'] ?? '',
      customerId: json['customerId'] ?? json['userId'] ?? json['user']?['_id'],
      customerName: json['customerName'] ?? 
                   json['user']?['fullname'] ?? 
                   json['user']?['name'] ?? 
                   json['customer']?['fullname'] ?? 
                   json['customer']?['name'],
      rating: (json['rating'] as num?)?.toDouble(),
      comment: json['comment'],
      response: json['response'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
      respondedAt: json['respondedAt'] != null 
          ? DateTime.parse(json['respondedAt']) 
          : null,
      helpfulCount: json['helpfulCount'] as int?,
      status: json['status'],
    );
  }
}