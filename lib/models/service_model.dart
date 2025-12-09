// lib/models/service_model.dart - UPDATED WITH ALL FIELDS
import 'dart:convert';

class ServiceModel {
  final String id;
  final String name;
  final String description;
  final double price;
  final String categoryId;
  final List<String> subcategoryIds;
  final String? providerName;
  final String? providerId;
  final String? imageUrl;
  final String? paymentMethod;
  final String? priceUnit;
  final String? status;
  final int? views;
  final int? totalBookings;
  final int? reviewCount;
  final String? serviceType;
  final List<dynamic> slots;
  final String? duration;
  final String? locationType;
  final String? serviceArea;
  final bool? isFeatured;
  final bool? isVerified;
  final String? verificationStatus;
  final double? bookingPrice;
  final String? categoryName;
  final double? rating;
  final String? pricingNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? providerEmail;
  final String? providerPhone;
  final String? providerPid;
  final List<dynamic>? weeklySchedule;
  final int? totalSlots;
  final int? availableSlots;
  final String? createdAtRaw;
  final String? updatedAtRaw;
  final Map<String, dynamic>? providerData;
  final Map<String, dynamic>? categoryData;
  final List<dynamic>? reviews;
  final String? serviceId;
  final String? banner;
  final String? subcategoryName;
  final bool? isActive;
  final bool? isAvailable;
  final String? locationAddress;
  final double? latitude;
  final double? longitude;
  final int? maxBookingsPerSlot;
  final int? minBookingNoticeHours;
  final int? cancellationNoticeHours;
  final String? cancellationPolicy;
  final String? refundPolicy;
  final List<dynamic>? serviceTags;
  final List<dynamic>? serviceImages;
  final String? serviceLanguage;
  final String? serviceCurrency;
  final bool? requiresApproval;
  final bool? instantBooking;
  final int? advancePaymentPercentage;
  final List<dynamic>? availablePaymentMethods;
  final Map<String, dynamic>? metadata;
  final Map<String, dynamic>? statistics;

  ServiceModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.categoryId,
    required this.subcategoryIds,
    this.providerName,
    this.providerId,
    this.imageUrl,
    this.paymentMethod,
    this.priceUnit,
    this.status,
    this.views,
    this.totalBookings,
    this.reviewCount,
    this.serviceType,
    this.slots = const [],
    this.duration,
    this.locationType,
    this.serviceArea,
    this.isFeatured,
    this.isVerified,
    this.verificationStatus,
    this.bookingPrice,
    this.categoryName,
    this.rating,
    this.pricingNotes,
    this.createdAt,
    this.updatedAt,
    this.providerEmail,
    this.providerPhone,
    this.providerPid,
    this.weeklySchedule,
    this.totalSlots,
    this.availableSlots,
    this.createdAtRaw,
    this.updatedAtRaw,
    this.providerData,
    this.categoryData,
    this.reviews,
    this.serviceId,
    this.banner,
    this.subcategoryName,
    this.isActive,
    this.isAvailable,
    this.locationAddress,
    this.latitude,
    this.longitude,
    this.maxBookingsPerSlot,
    this.minBookingNoticeHours,
    this.cancellationNoticeHours,
    this.cancellationPolicy,
    this.refundPolicy,
    this.serviceTags,
    this.serviceImages,
    this.serviceLanguage,
    this.serviceCurrency,
    this.requiresApproval,
    this.instantBooking,
    this.advancePaymentPercentage,
    this.availablePaymentMethods,
    this.metadata,
    this.statistics,
  });

  // ✅ NEW: Safe provider name getter (critical for UI)
  String get displayProviderName {
    if (providerName == null || providerName!.trim().isEmpty) {
      return 'Service Provider';
    }
    return providerName!;
  }

  // Getter for formatted price
  String get formattedPrice {
    final unit = priceUnit?.toUpperCase() ?? 'ETB';
    return '$price $unit';
  }

  // Getter for total price (service + booking)
  double get totalPrice {
    return price + (bookingPrice ?? 0);
  }

  // Getter for formatted total price
  String get formattedTotalPrice {
    final unit = priceUnit?.toUpperCase() ?? 'ETB';
    return '${totalPrice.toStringAsFixed(2)} $unit';
  }

  // Getter for availability status based on slots
  String get availabilityStatus {
    final available = availableSlots ?? getAvailableSlotsCount();
    if (available == 0) return 'No Slots';
    if (available < 3) return 'Limited';
    if (available < 10) return 'Available';
    return 'Plenty Available';
  }

  // Helper method to count available slots
  int getAvailableSlotsCount() {
    if (slots.isEmpty) return 0;

    int count = 0;
    for (var slot in slots) {
      if (slot is Map<String, dynamic>) {
        final weeklySchedule = slot['weeklySchedule'] as List?;
        if (weeklySchedule != null) {
          for (var day in weeklySchedule) {
            if (day is Map && (day['isWorkingDay'] == true)) {
              final timeSlots = day['timeSlots'] as List?;
              if (timeSlots != null) {
                count += timeSlots
                    .where((ts) =>
                        ts is Map &&
                        (ts['isAvailable'] == true) &&
                        (ts['isBooked'] != true))
                    .length;
              }
            }
          }
        }
      }
    }
    return count;
  }

  // Getter for working days count
  int get workingDaysCount {
    if (slots.isEmpty) return 0;

    int count = 0;
    for (var slot in slots) {
      if (slot is Map<String, dynamic>) {
        final weeklySchedule = slot['weeklySchedule'] as List?;
        if (weeklySchedule != null) {
          count += weeklySchedule
              .where((day) => day is Map && (day['isWorkingDay'] == true))
              .length;
        }
      }
    }
    return count;
  }

  // Getter for total time slots
  int get totalTimeSlots {
    if (slots.isEmpty) return 0;

    int count = 0;
    for (var slot in slots) {
      if (slot is Map<String, dynamic>) {
        final weeklySchedule = slot['weeklySchedule'] as List?;
        if (weeklySchedule != null) {
          for (var day in weeklySchedule) {
            if (day is Map && (day['isWorkingDay'] == true)) {
              final timeSlots = day['timeSlots'] as List?;
              if (timeSlots != null) count += timeSlots.length;
            }
          }
        }
      }
    }
    return count;
  }

  // Getter for service type formatted
  String get formattedServiceType {
    if (serviceType == null || serviceType!.isEmpty) return 'Standard';
    return serviceType![0].toUpperCase() + serviceType!.substring(1);
  }

  // Factory method to parse JSON
  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> serviceData;

    // Check if service data is nested under 'service' key
    if (json.containsKey('service') &&
        json['service'] is Map<String, dynamic>) {
      serviceData = Map<String, dynamic>.from(json['service']);
    } else {
      serviceData = json;
    }

    // Extract provider information from various possible locations
    String? providerName;
    String? providerId;
    String? providerEmail;
    String? providerPhone;
    String? providerPid;
    Map<String, dynamic>? providerData;

    // Method 1: Check if provider is a Map with details
    if (serviceData['provider'] is Map<String, dynamic>) {
      final provider = serviceData['provider'];
      providerName = provider['fullname'] ??
          provider['name'] ??
          provider['businessName'] ??
          provider['username'] ??
          (provider['firstName'] != null && provider['lastName'] != null
              ? '${provider['firstName']} ${provider['lastName']}'
              : null);
      providerId = provider['id']?.toString() ??
          provider['_id']?.toString() ??
          provider['providerId']?.toString();
      providerEmail = provider['email']?.toString();
      providerPhone = provider['phone']?.toString();
      providerPid = provider['pid']?.toString();
      providerData = provider;
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
          provider['username'] ??
          (provider['firstName'] != null && provider['lastName'] != null
              ? '${provider['firstName']} ${provider['lastName']}'
              : null);
      providerId = provider['id']?.toString() ?? provider['_id']?.toString();
      providerEmail = provider['email']?.toString();
      providerPhone = provider['phone']?.toString();
      providerPid = provider['pid']?.toString();
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

    // Parse slots data
    List<dynamic> slots = [];
    if (serviceData['slots'] is List) {
      slots = serviceData['slots'];
    }

    // Parse date fields
    DateTime? createdAt;
    DateTime? updatedAt;

    try {
      if (serviceData['createdAt'] != null) {
        if (serviceData['createdAt'] is String) {
          createdAt = DateTime.parse(serviceData['createdAt']);
        } else if (serviceData['createdAt'] is Map) {
          final dateMap = serviceData['createdAt'] as Map;
          if (dateMap['\$date'] != null) {
            createdAt = DateTime.parse(dateMap['\$date'].toString());
          }
        }
      }

      if (serviceData['updatedAt'] != null) {
        if (serviceData['updatedAt'] is String) {
          updatedAt = DateTime.parse(serviceData['updatedAt']);
        } else if (serviceData['updatedAt'] is Map) {
          final dateMap = serviceData['updatedAt'] as Map;
          if (dateMap['\$date'] != null) {
            updatedAt = DateTime.parse(dateMap['\$date'].toString());
          }
        }
      }
    } catch (e) {
      print('Error parsing dates: $e');
    }

    // Parse metadata if available
    Map<String, dynamic>? metadata;
    if (serviceData['metadata'] is Map) {
      metadata = Map<String, dynamic>.from(serviceData['metadata']);
    }

    // Parse statistics if available
    Map<String, dynamic>? statistics;
    if (serviceData['statistics'] is Map) {
      statistics = Map<String, dynamic>.from(serviceData['statistics']);
    }

    return ServiceModel(
      id: serviceData['serviceId']?.toString() ??
          serviceData['id']?.toString() ??
          serviceData['_id']?.toString() ??
          '',
      serviceId: serviceData['serviceId']?.toString(),
      name: serviceData['title']?.toString() ??
          serviceData['name']?.toString() ??
          'Service',
      description:
          serviceData['description']?.toString() ?? 'No description available',
      price: _parseDouble(serviceData['totalPrice'] ??
          serviceData['price'] ??
          serviceData['servicePrice'] ??
          0),
      categoryId: serviceData['categoryId']?.toString() ??
          serviceData['category']?['_id']?.toString() ??
          serviceData['category']?.toString() ??
          '',
      subcategoryIds: subcategoryIds,
      providerName: providerName,
      providerId: providerId,
      providerEmail: providerEmail,
      providerPhone: providerPhone,
      providerPid: providerPid,
      providerData: providerData,
      imageUrl: _parseImageUrl(serviceData),
      paymentMethod: serviceData['paymentMethod']?.toString(),
      priceUnit: serviceData['priceUnit']?.toString() ?? 'ETB',
      status: serviceData['status']?.toString() ?? 'published',
      views: _parseInt(serviceData['views'] ?? serviceData['viewCount']),
      totalBookings: _parseInt(
          serviceData['totalBookings'] ?? serviceData['bookingsCount']),
      reviewCount:
          _parseInt(serviceData['reviewCount'] ?? serviceData['totalReviews']),
      serviceType: serviceData['serviceType']?.toString(),
      slots: slots,
      duration: serviceData['duration']?.toString(),
      locationType: serviceData['locationType']?.toString(),
      serviceArea: serviceData['serviceArea']?.toString(),
      isFeatured: serviceData['isFeatured'] == true,
      isVerified: serviceData['isVerified'] == true,
      verificationStatus: serviceData['verificationStatus']?.toString(),
      bookingPrice: _parseDouble(serviceData['bookingPrice']),
      categoryName: serviceData['categoryName']?.toString() ??
          serviceData['category']?['name']?.toString() ??
          serviceData['category']?['title']?.toString(),
      categoryData: serviceData['category'] is Map
          ? Map<String, dynamic>.from(serviceData['category'])
          : null,
      rating:
          _parseDouble(serviceData['rating'] ?? serviceData['averageRating']),
      pricingNotes: serviceData['pricingNotes']?.toString(),
      createdAt: createdAt,
      updatedAt: updatedAt,
      createdAtRaw: serviceData['createdAt']?.toString(),
      updatedAtRaw: serviceData['updatedAt']?.toString(),
      weeklySchedule: serviceData['weeklySchedule'] is List
          ? serviceData['weeklySchedule']
          : null,
      totalSlots: _parseInt(serviceData['totalSlots']),
      availableSlots: _parseInt(serviceData['availableSlots']),
      reviews: serviceData['reviews'] is List ? serviceData['reviews'] : null,
      banner: serviceData['banner']?.toString(),
      subcategoryName: serviceData['subcategoryName']?.toString() ??
          serviceData['subcategory']?['name']?.toString() ??
          serviceData['subcategory']?['title']?.toString(),
      isActive: serviceData['isActive'] == true,
      isAvailable: serviceData['isAvailable'] == true,
      locationAddress: serviceData['locationAddress']?.toString(),
      latitude: _parseDouble(serviceData['latitude']),
      longitude: _parseDouble(serviceData['longitude']),
      maxBookingsPerSlot: _parseInt(serviceData['maxBookingsPerSlot']),
      minBookingNoticeHours: _parseInt(serviceData['minBookingNoticeHours']),
      cancellationNoticeHours:
          _parseInt(serviceData['cancellationNoticeHours']),
      cancellationPolicy: serviceData['cancellationPolicy']?.toString(),
      refundPolicy: serviceData['refundPolicy']?.toString(),
      serviceTags: serviceData['serviceTags'] is List
          ? serviceData['serviceTags']
          : null,
      serviceImages: serviceData['serviceImages'] is List
          ? serviceData['serviceImages']
          : null,
      serviceLanguage: serviceData['serviceLanguage']?.toString(),
      serviceCurrency: serviceData['serviceCurrency']?.toString() ?? 'ETB',
      requiresApproval: serviceData['requiresApproval'] == true,
      instantBooking: serviceData['instantBooking'] == true,
      advancePaymentPercentage:
          _parseInt(serviceData['advancePaymentPercentage']),
      availablePaymentMethods: serviceData['availablePaymentMethods'] is List
          ? serviceData['availablePaymentMethods']
          : null,
      metadata: metadata,
      statistics: statistics,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serviceId': serviceId,
      'name': name,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'subcategoryIds': subcategoryIds,
      'providerName': providerName,
      'providerId': providerId,
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'providerPid': providerPid,
      'imageUrl': imageUrl,
      'paymentMethod': paymentMethod,
      'priceUnit': priceUnit,
      'status': status,
      'views': views,
      'totalBookings': totalBookings,
      'reviewCount': reviewCount,
      'serviceType': serviceType,
      'slots': slots,
      'duration': duration,
      'locationType': locationType,
      'serviceArea': serviceArea,
      'isFeatured': isFeatured,
      'isVerified': isVerified,
      'verificationStatus': verificationStatus,
      'bookingPrice': bookingPrice,
      'categoryName': categoryName,
      'rating': rating,
      'pricingNotes': pricingNotes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'providerData': providerData,
      'categoryData': categoryData,
      'weeklySchedule': weeklySchedule,
      'totalSlots': totalSlots,
      'availableSlots': availableSlots,
      'banner': banner,
      'subcategoryName': subcategoryName,
      'isActive': isActive,
      'isAvailable': isAvailable,
      'locationAddress': locationAddress,
      'latitude': latitude,
      'longitude': longitude,
      'maxBookingsPerSlot': maxBookingsPerSlot,
      'minBookingNoticeHours': minBookingNoticeHours,
      'cancellationNoticeHours': cancellationNoticeHours,
      'cancellationPolicy': cancellationPolicy,
      'refundPolicy': refundPolicy,
      'serviceTags': serviceTags,
      'serviceImages': serviceImages,
      'serviceLanguage': serviceLanguage,
      'serviceCurrency': serviceCurrency,
      'requiresApproval': requiresApproval,
      'instantBooking': instantBooking,
      'advancePaymentPercentage': advancePaymentPercentage,
      'availablePaymentMethods': availablePaymentMethods,
      'metadata': metadata,
      'statistics': statistics,
    };
  }

  // Helper method to parse image URL
  static String? _parseImageUrl(Map<String, dynamic> data) {
    final banner = data['banner']?.toString()?.trim();
    final imageUrl = data['imageUrl']?.toString()?.trim();
    final image = data['image']?.toString()?.trim();
    final thumbnail = data['thumbnail']?.toString()?.trim();
    final coverImage = data['coverImage']?.toString()?.trim();

    return banner ?? imageUrl ?? image ?? thumbnail ?? coverImage;
  }

  // Helper method to parse double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value.replaceAll(',', ''));
      } catch (_) {
        return 0.0;
      }
    }
    return 0.0;
  }

  // Helper method to parse integer
  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value.replaceAll(',', ''));
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  // Create a copy with updated fields
  ServiceModel copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    String? categoryId,
    List<String>? subcategoryIds,
    String? providerName,
    String? providerId,
    String? imageUrl,
    String? paymentMethod,
    String? priceUnit,
    String? status,
    int? views,
    int? totalBookings,
    int? reviewCount,
    String? serviceType,
    List<dynamic>? slots,
    String? duration,
    String? locationType,
    String? serviceArea,
    bool? isFeatured,
    bool? isVerified,
    String? verificationStatus,
    double? bookingPrice,
    String? categoryName,
    double? rating,
    String? pricingNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? providerEmail,
    String? providerPhone,
    String? providerPid,
    List<dynamic>? weeklySchedule,
    int? totalSlots,
    int? availableSlots,
    String? createdAtRaw,
    String? updatedAtRaw,
    Map<String, dynamic>? providerData,
    Map<String, dynamic>? categoryData,
    List<dynamic>? reviews,
    String? serviceId,
    String? banner,
    String? subcategoryName,
    bool? isActive,
    bool? isAvailable,
    String? locationAddress,
    double? latitude,
    double? longitude,
    int? maxBookingsPerSlot,
    int? minBookingNoticeHours,
    int? cancellationNoticeHours,
    String? cancellationPolicy,
    String? refundPolicy,
    List<dynamic>? serviceTags,
    List<dynamic>? serviceImages,
    String? serviceLanguage,
    String? serviceCurrency,
    bool? requiresApproval,
    bool? instantBooking,
    int? advancePaymentPercentage,
    List<dynamic>? availablePaymentMethods,
    Map<String, dynamic>? metadata,
    Map<String, dynamic>? statistics,
  }) {
    return ServiceModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      categoryId: categoryId ?? this.categoryId,
      subcategoryIds: subcategoryIds ?? this.subcategoryIds,
      providerName: providerName ?? this.providerName,
      providerId: providerId ?? this.providerId,
      imageUrl: imageUrl ?? this.imageUrl,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      priceUnit: priceUnit ?? this.priceUnit,
      status: status ?? this.status,
      views: views ?? this.views,
      totalBookings: totalBookings ?? this.totalBookings,
      reviewCount: reviewCount ?? this.reviewCount,
      serviceType: serviceType ?? this.serviceType,
      slots: slots ?? this.slots,
      duration: duration ?? this.duration,
      locationType: locationType ?? this.locationType,
      serviceArea: serviceArea ?? this.serviceArea,
      isFeatured: isFeatured ?? this.isFeatured,
      isVerified: isVerified ?? this.isVerified,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      bookingPrice: bookingPrice ?? this.bookingPrice,
      categoryName: categoryName ?? this.categoryName,
      rating: rating ?? this.rating,
      pricingNotes: pricingNotes ?? this.pricingNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      providerEmail: providerEmail ?? this.providerEmail,
      providerPhone: providerPhone ?? this.providerPhone,
      providerPid: providerPid ?? this.providerPid,
      weeklySchedule: weeklySchedule ?? this.weeklySchedule,
      totalSlots: totalSlots ?? this.totalSlots,
      availableSlots: availableSlots ?? this.availableSlots,
      createdAtRaw: createdAtRaw ?? this.createdAtRaw,
      updatedAtRaw: updatedAtRaw ?? this.updatedAtRaw,
      providerData: providerData ?? this.providerData,
      categoryData: categoryData ?? this.categoryData,
      reviews: reviews ?? this.reviews,
      serviceId: serviceId ?? this.serviceId,
      banner: banner ?? this.banner,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      isActive: isActive ?? this.isActive,
      isAvailable: isAvailable ?? this.isAvailable,
      locationAddress: locationAddress ?? this.locationAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      maxBookingsPerSlot: maxBookingsPerSlot ?? this.maxBookingsPerSlot,
      minBookingNoticeHours:
          minBookingNoticeHours ?? this.minBookingNoticeHours,
      cancellationNoticeHours:
          cancellationNoticeHours ?? this.cancellationNoticeHours,
      cancellationPolicy: cancellationPolicy ?? this.cancellationPolicy,
      refundPolicy: refundPolicy ?? this.refundPolicy,
      serviceTags: serviceTags ?? this.serviceTags,
      serviceImages: serviceImages ?? this.serviceImages,
      serviceLanguage: serviceLanguage ?? this.serviceLanguage,
      serviceCurrency: serviceCurrency ?? this.serviceCurrency,
      requiresApproval: requiresApproval ?? this.requiresApproval,
      instantBooking: instantBooking ?? this.instantBooking,
      advancePaymentPercentage:
          advancePaymentPercentage ?? this.advancePaymentPercentage,
      availablePaymentMethods:
          availablePaymentMethods ?? this.availablePaymentMethods,
      metadata: metadata ?? this.metadata,
      statistics: statistics ?? this.statistics,
    );
  }

  // Method to check if service is available for booking
  bool isAvailableForBooking() {
    if (status?.toLowerCase() != 'published' &&
        status?.toLowerCase() != 'active') {
      return false;
    }

    if (isActive == false || isAvailable == false) {
      return false;
    }

    return getAvailableSlotsCount() > 0;
  }

  // Method to get service duration in minutes
  int? getDurationInMinutes() {
    if (duration == null) return null;

    final durationStr = duration!.toLowerCase();
    if (durationStr.contains('hour')) {
      final match = RegExp(r'(\d+)').firstMatch(durationStr);
      if (match != null) {
        return int.parse(match.group(1)!) * 60;
      }
    } else if (durationStr.contains('min')) {
      final match = RegExp(r'(\d+)').firstMatch(durationStr);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    }

    return null;
  }

  // Method to get all service images
  List<String> getAllImages() {
    final images = <String>[];

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      images.add(imageUrl!);
    }

    if (banner != null && banner!.isNotEmpty && !images.contains(banner)) {
      images.add(banner!);
    }

    if (serviceImages != null) {
      for (var img in serviceImages!) {
        if (img is String && img.isNotEmpty && !images.contains(img)) {
          images.add(img);
        } else if (img is Map && img['url'] is String) {
          final url = img['url'] as String;
          if (url.isNotEmpty && !images.contains(url)) {
            images.add(url);
          }
        }
      }
    }

    return images;
  }

  // Method to get service tags as list of strings
  List<String> getServiceTags() {
    if (serviceTags == null) return [];

    return serviceTags!
        .map((tag) {
          if (tag is String) return tag;
          if (tag is Map && tag['name'] is String) return tag['name'] as String;
          return tag.toString();
        })
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  @override
  String toString() {
    return 'ServiceModel{id: $id, name: $name, price: $price, provider: $providerName, availableSlots: ${getAvailableSlotsCount()}}';
  }
}
