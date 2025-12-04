// lib/models/service_model.dart - UPDATED
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> subcategoryIds;
  final String providerName;
  final String? imageUrl;
  final String? paymentMethod;
  final String? priceUnit;
  final String? status;
  final int? views;
  final int? totalBookings;
  final String? serviceType;
  final List<dynamic> slots;
  final String? duration;
  final String? locationType;
  final String? serviceArea;
  final bool? isFeatured;
  final String? verificationStatus;
  final double? bookingPrice;
  final String? categoryName;
  final double? rating;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.subcategoryIds,
    required this.providerName,
    this.imageUrl,
    this.paymentMethod,
    this.priceUnit,
    this.status,
    this.views,
    this.totalBookings,
    this.serviceType,
    this.slots = const [],
    this.duration,
    this.locationType,
    this.serviceArea,
    this.isFeatured,
    this.verificationStatus,
    this.bookingPrice,
    this.categoryName,
    this.rating,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    // Handle nested structure: check if there's a 'service' key
    Map<String, dynamic> serviceData;

    if (json.containsKey('service') &&
        json['service'] is Map<String, dynamic>) {
      // Nested structure: {service: {...}, categoryId: '...', subcategoryIds: [...]}
      serviceData = Map<String, dynamic>.from(json['service']);

      // Use categoryId from root if available (overrides inner categoryId)
      if (json['categoryId'] != null) {
        serviceData['categoryId'] = json['categoryId'];
      }

      // Use subcategoryIds from root if available
      if (json['subcategoryIds'] != null && json['subcategoryIds'] is List) {
        serviceData['subcategoryIds'] = json['subcategoryIds'];
      }

      // Also check for singular subcategoryId
      if (json['subcategoryId'] != null &&
          json['subcategoryId'] != 'undefined') {
        serviceData['subcategoryIds'] = [json['subcategoryId']];
      }
    } else {
      // Flat structure
      serviceData = json;
    }

    // Handle provider name from nested object
    String providerName = 'Provider Unknown';
    if (serviceData['provider'] is Map<String, dynamic>) {
      providerName = serviceData['provider']['fullname'] ??
          serviceData['provider']['name'] ??
          'Provider Unknown';
    } else if (json['provider'] is Map<String, dynamic>) {
      // Check root level provider too
      providerName = json['provider']['fullname'] ??
          json['provider']['name'] ??
          'Provider Unknown';
    }

    return ServiceModel(
      id: serviceData['serviceId']?.toString() ??
          serviceData['id']?.toString() ??
          '',
      name: serviceData['title']?.toString() ??
          serviceData['name']?.toString() ??
          '',
      description: serviceData['description']?.toString() ?? '',
      price: _parseDouble(serviceData['totalPrice'] ?? serviceData['price']),
      categoryId: serviceData['categoryId']?.toString() ?? '',
      subcategoryIds: (serviceData['subcategoryIds'] as List<dynamic>?)
              ?.map((id) => id.toString())
              .where((id) => id.isNotEmpty && id != 'undefined')
              .toList() ??
          [],
      providerName: providerName,
      imageUrl: (serviceData['banner'] as String?)?.trim() ??
          (serviceData['imageUrl'] as String?)?.trim(),
      paymentMethod: serviceData['paymentMethod']?.toString(),
      priceUnit: serviceData['priceUnit']?.toString(),
      status: serviceData['status']?.toString(),
      views: _parseInt(serviceData['views']),
      totalBookings: _parseInt(serviceData['totalBookings']),
      serviceType: serviceData['serviceType']?.toString(),
      slots: serviceData['slots'] is List<dynamic> ? serviceData['slots'] : [],
      duration: serviceData['duration']?.toString(),
      locationType: serviceData['locationType']?.toString(),
      serviceArea: serviceData['serviceArea']?.toString(),
      isFeatured: serviceData['isFeatured'] == true,
      verificationStatus: serviceData['verificationStatus']?.toString(),
      bookingPrice: _parseDouble(serviceData['bookingPrice']),
      categoryName: serviceData['categoryName']?.toString(),
      rating: _parseDouble(serviceData['rating']),
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value);
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }
}
