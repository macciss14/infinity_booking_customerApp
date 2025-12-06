// lib/models/service_model.dart - IMPROVED PROVIDER EXTRACTION
class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> subcategoryIds;
  final String? providerName;
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
  final String? providerId;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.subcategoryIds,
    this.providerName,
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
    this.providerId,
  });

  String get formattedPrice {
    final unit = priceUnit?.toUpperCase() ?? 'ETB';
    return '$price $unit';
  }

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> serviceData;

    if (json.containsKey('service') &&
        json['service'] is Map<String, dynamic>) {
      serviceData = Map<String, dynamic>.from(json['service']);
    } else {
      serviceData = json;
    }

    // Extract provider information from various possible locations
    String? providerName;
    String? providerId;

    // Method 1: Check if provider is a Map with name/fullname
    if (serviceData['provider'] is Map<String, dynamic>) {
      final provider = serviceData['provider'];
      providerName = provider['fullname'] ??
          provider['name'] ??
          provider['businessName'] ??
          provider['username'];
      providerId = provider['id']?.toString() ??
          provider['_id']?.toString() ??
          provider['providerId']?.toString();
    }

    // Method 2: Check if providerName is directly in serviceData
    if (providerName == null && serviceData['providerName'] != null) {
      providerName = serviceData['providerName'].toString();
    }

    // Method 3: Check if provider info is at root level
    if (providerName == null && json['provider'] is Map<String, dynamic>) {
      final provider = json['provider'];
      providerName = provider['fullname'] ??
          provider['name'] ??
          provider['businessName'] ??
          provider['username'];
      providerId = provider['id']?.toString() ?? provider['_id']?.toString();
    }

    // Method 4: Fallback to placeholder
    if (providerName == null) {
      providerName = 'Service Provider';
    }

    // Extract subcategory IDs - handle various formats
    List<String> subcategoryIds = [];
    if (serviceData['subcategoryIds'] is List) {
      subcategoryIds = (serviceData['subcategoryIds'] as List)
          .map((id) => id?.toString() ?? '')
          .where((id) => id.isNotEmpty && id != 'undefined')
          .toList();
    } else if (serviceData['subcategoryId'] != null) {
      final subId = serviceData['subcategoryId'].toString();
      if (subId.isNotEmpty && subId != 'undefined') {
        subcategoryIds = [subId];
      }
    }

    return ServiceModel(
      id: serviceData['serviceId']?.toString() ??
          serviceData['id']?.toString() ??
          '',
      name: serviceData['title']?.toString() ??
          serviceData['name']?.toString() ??
          'Service',
      description:
          serviceData['description']?.toString() ?? 'No description available',
      price: _parseDouble(serviceData['totalPrice'] ??
          serviceData['price'] ??
          serviceData['servicePrice']),
      categoryId: serviceData['categoryId']?.toString() ??
          serviceData['category']?.toString() ??
          '',
      subcategoryIds: subcategoryIds,
      providerName: providerName,
      providerId: providerId,
      imageUrl: _parseImageUrl(serviceData),
      paymentMethod: serviceData['paymentMethod']?.toString(),
      priceUnit: serviceData['priceUnit']?.toString() ?? 'ETB',
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

  static String? _parseImageUrl(Map<String, dynamic> data) {
    final banner = data['banner']?.toString()?.trim();
    final imageUrl = data['imageUrl']?.toString()?.trim();
    final image = data['image']?.toString()?.trim();

    return banner ?? imageUrl ?? image;
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
