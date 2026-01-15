// lib/models/service_model.dart 
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
  final String? type;
  final List<ServiceSlot> slots;
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
  final Map<String, dynamic>? provider;
  final Map<String, dynamic>? categoryData;
  final List<dynamic>? reviews;
  final String? serviceId;
  final String? banner;
  final String? subcategoryName;
  final Map<String, dynamic>? subcategory;
  final List<Map<String, dynamic>>? subcategories;
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
    this.type,
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
    this.provider,
    this.categoryData,
    this.reviews,
    this.serviceId,
    this.banner,
    this.subcategoryName,
    this.subcategory,
    this.subcategories,
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

  // =================== PROPERTIES ===================

  Map<String, dynamic>? get providerData => provider;

  String get displayProviderName {
    if (providerName != null && providerName!.isNotEmpty) return providerName!;
    if (provider != null && provider!.isNotEmpty) {
      final fullname = provider!['fullname']?.toString();
      if (fullname != null && fullname.isNotEmpty) return fullname;
      final name = provider!['name']?.toString();
      if (name != null && name.isNotEmpty) return name;
      final businessName = provider!['businessName']?.toString();
      if (businessName != null && businessName.isNotEmpty) return businessName;
      final firstName = provider!['firstName']?.toString();
      final lastName = provider!['lastName']?.toString();
      if (firstName != null && lastName != null) return '$firstName $lastName';
      final username = provider!['username']?.toString();
      if (username != null && username.isNotEmpty) return username;
    }
    if (providerPid != null && providerPid!.isNotEmpty) return 'Provider $providerPid';
    if (providerId != null && providerId!.isNotEmpty) return 'Provider $providerId';
    return 'Service Provider';
  }

  String get providerInitials {
    final name = displayProviderName;
    if (name == 'Service Provider') return 'SP';
    final parts = name.split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'SP';
  }

  bool get hasProviderContactInfo {
    return (providerEmail?.isNotEmpty == true) ||
        (providerPhone?.isNotEmpty == true);
  }

  String? get providerContactInfo {
    final contacts = <String>[];
    if (providerEmail?.isNotEmpty == true) contacts.add(providerEmail!);
    if (providerPhone?.isNotEmpty == true) contacts.add(providerPhone!);
    return contacts.isNotEmpty ? contacts.join(' • ') : null;
  }

  double? get providerRating {
    if (provider != null) {
      final rating = provider!['rating'];
      if (rating is num) return rating.toDouble();
      if (rating is String) {
        try {
          return double.parse(rating);
        } catch (_) {
          return null;
        }
      }
    }
    return null;
  }

  bool get isProviderVerified {
    if (provider != null) {
      final verified = provider!['isVerified'];
      if (verified is bool) return verified;
      if (verified is String) return verified.toLowerCase() == 'true';
    }
    return false;
  }

  String get formattedPrice {
    final unit = priceUnit?.toUpperCase() ?? 'ETB';
    return '${price.toStringAsFixed(2)} $unit';
  }

  double get totalPrice => price + (bookingPrice ?? 0);

  String get formattedTotalPrice {
    final unit = priceUnit?.toUpperCase() ?? 'ETB';
    return '${totalPrice.toStringAsFixed(2)} $unit';
  }

  String get availabilityStatus {
    final available = getAvailableSlotsCount();
    if (available == 0) return 'No Slots';
    if (available < 3) return 'Limited';
    if (available < 10) return 'Available';
    return 'Plenty Available';
  }

  String get availabilityClass {
    final available = getAvailableSlotsCount();
    if (available == 0) return 'unavailable';
    if (available < 3) return 'limited';
    return 'available';
  }

  String get availabilityColor {
    final available = getAvailableSlotsCount();
    if (available == 0) return '#ef4444';
    if (available < 3) return '#f59e0b';
    return '#10b981';
  }

  int getAvailableSlotsCount() {
    if (slots.isEmpty) return 0;
    int count = 0;
    for (final slot in slots) {
      if (slot.schedule != null) { // Changed from weeklySchedule to schedule
        for (final day in slot.schedule!) {
          if (day.isWorkingDay && day.timeSlots != null) {
            for (final ts in day.timeSlots!) {
              if (ts.isAvailable == true && ts.isBooked != true) count++;
            }
          }
        }
      }
    }
    return count;
  }

  int get workingDaysCount {
    if (slots.isEmpty) return 0;
    int count = 0;
    for (final slot in slots) {
      if (slot.schedule != null) { // Changed from weeklySchedule to schedule
        for (final day in slot.schedule!) {
          if (day.isWorkingDay) count++;
        }
      }
    }
    return count;
  }

  int get totalTimeSlots {
    if (slots.isEmpty) return 0;
    int count = 0;
    for (final slot in slots) {
      if (slot.schedule != null) { // Changed from weeklySchedule to schedule
        for (final day in slot.schedule!) {
          if (day.isWorkingDay && day.timeSlots != null) {
            count += day.timeSlots!.length;
          }
        }
      }
    }
    return count;
  }

  DateTime? get nextAvailableDate {
    if (slots.isEmpty) return null;
    try {
      final now = DateTime.now();
      for (final slot in slots) {
        if (slot.schedule != null) { // Changed from weeklySchedule to schedule
          for (final day in slot.schedule!) {
            if (day.isWorkingDay && day.timeSlots != null && day.timeSlots!.isNotEmpty) {
              return now.add(const Duration(days: 1));
            }
          }
        }
      }
    } catch (e) {
      print('Error getting next available date: $e');
    }
    return null;
  }

  String get formattedServiceType {
    final typeToFormat = type ?? serviceType;
    if (typeToFormat == null || typeToFormat.isEmpty) return 'Standard';
    return typeToFormat[0].toUpperCase() + typeToFormat.substring(1);
  }

  List<String> get subcategoryNames {
    final names = <String>{};
    if (subcategories != null) {
      for (final sub in subcategories!) {
        final name = sub['name'] ?? sub['title'];
        if (name != null && name.toString().isNotEmpty) {
          names.add(name.toString());
        }
      }
    }
    if (subcategory != null) {
      final name = subcategory!['name'] ?? subcategory!['title'];
      if (name != null && name.toString().isNotEmpty) {
        names.add(name.toString());
      }
    }
    if (subcategoryName != null && subcategoryName!.isNotEmpty) {
      names.add(subcategoryName!);
    }
    return names.toList();
  }

  String get displayCategoryName {
    if (categoryName != null && categoryName!.isNotEmpty) return categoryName!;
    if (categoryData != null) {
      final name = categoryData!['name'] ?? categoryData!['title'];
      if (name != null && name.toString().isNotEmpty) return name.toString();
    }
    return 'Uncategorized';
  }

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

  String get statusColor {
    final statusLower = status?.toLowerCase() ?? 'published';
    switch (statusLower) {
      case 'published':
      case 'active':
        return '#10b981';
      case 'draft':
        return '#f59e0b';
      case 'archived':
      case 'suspended':
      case 'inactive':
        return '#ef4444';
      default:
        return '#6b7280';
    }
  }

  String get formattedCreatedAt {
    if (createdAt == null) return 'Unknown';
    final now = DateTime.now();
    final difference = now.difference(createdAt!);
    if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else {
      return 'Just now';
    }
  }

  // =================== FACTORY METHOD ===================

  factory ServiceModel.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic> serviceData =
        json.containsKey('service') && json['service'] is Map<String, dynamic>
            ? Map<String, dynamic>.from(json['service'])
            : json;

    Map<String, dynamic>? providerMap;
    if (serviceData['provider'] is Map<String, dynamic>) {
      providerMap = Map<String, dynamic>.from(serviceData['provider']);
    } else if (json['provider'] is Map<String, dynamic>) {
      providerMap = Map<String, dynamic>.from(json['provider']);
    }

    String? providerName;
    String? providerId;
    String? providerEmail;
    String? providerPhone;
    String? providerPid;

    if (providerMap != null) {
      providerName = providerMap['fullname'] ??
          providerMap['name'] ??
          providerMap['businessName'] ??
          providerMap['username'] ??
          (providerMap['firstName'] != null && providerMap['lastName'] != null
              ? '${providerMap['firstName']} ${providerMap['lastName']}'
              : null);
      providerEmail = providerMap['email']?.toString();
      providerPhone = providerMap['phonenumber']?.toString();
      providerId = providerMap['id']?.toString() ??
          providerMap['_id']?.toString() ??
          providerMap['providerId']?.toString();
      providerPid = providerMap['pid']?.toString().trim();
    } else {
      providerName = serviceData['providerName']?.toString();
      providerEmail = serviceData['providerEmail']?.toString();
      providerPhone = serviceData['providerPhone']?.toString();
      providerId = serviceData['providerId']?.toString();
      providerPid = serviceData['providerPid']?.toString();
    }

    Map<String, dynamic>? subcategoryMap;
    if (serviceData['subcategory'] is Map<String, dynamic>) {
      subcategoryMap = Map<String, dynamic>.from(serviceData['subcategory']);
    }

    List<Map<String, dynamic>>? subcategoriesList;
    if (serviceData['subcategories'] is List) {
      subcategoriesList = (serviceData['subcategories'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }

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

    List<ServiceSlot> slots = [];
    if (serviceData['slots'] is List) {
      slots = _parseSlots(serviceData['slots'] as List);
    }

    DateTime? createdAt = _parseMongoDBDate(serviceData['createdAt']);
    DateTime? updatedAt = _parseMongoDBDate(serviceData['updatedAt']);

    Map<String, dynamic>? metadata;
    if (serviceData['metadata'] is Map) {
      metadata = Map<String, dynamic>.from(serviceData['metadata']);
    }

    Map<String, dynamic>? statistics;
    if (serviceData['statistics'] is Map) {
      statistics = Map<String, dynamic>.from(serviceData['statistics']);
    }

    Map<String, dynamic>? categoryDataMap;
    if (serviceData['category'] is Map) {
      categoryDataMap = Map<String, dynamic>.from(serviceData['category']);
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
      provider: providerMap,
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
      type: serviceData['type']?.toString(),
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
      categoryData: categoryDataMap,
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
      subcategory: subcategoryMap,
      subcategories: subcategoriesList,
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

  // =================== PRIVATE HELPER METHODS ===================

  static DateTime? _parseMongoDBDate(dynamic dateValue) {
    if (dateValue == null) return null;
    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is Map) {
        final dateMap = dateValue as Map<String, dynamic>;
        if (dateMap['\$date'] != null) {
          final dateStr = dateMap['\$date'].toString();
          return DateTime.parse(dateStr);
        }
      }
    } catch (e) {
      print('Error parsing date: $e');
    }
    return null;
  }

  static List<ServiceSlot> _parseSlots(List<dynamic> slotsData) {
    final parsedSlots = <ServiceSlot>[];
    for (var slot in slotsData) {
      if (slot is Map<String, dynamic>) {
        try {
          parsedSlots.add(ServiceSlot.fromJson(slot));
        } catch (e) {
          print('Error parsing slot: $e');
        }
      }
    }
    return parsedSlots;
  }

  static String? _parseImageUrl(Map<String, dynamic> data) {
    final banner = data['banner']?.toString().trim();
    final imageUrl = data['imageUrl']?.toString().trim();
    final image = data['image']?.toString().trim();
    final thumbnail = data['thumbnail']?.toString().trim();
    final coverImage = data['coverImage']?.toString().trim();
    return banner ?? imageUrl ?? image ?? thumbnail ?? coverImage;
  }

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

  // =================== SERIALIZATION ===================

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
      'imageUrl': imageUrl,
      'paymentMethod': paymentMethod,
      'priceUnit': priceUnit,
      'status': status,
      'views': views,
      'totalBookings': totalBookings,
      'reviewCount': reviewCount,
      'serviceType': serviceType,
      'type': type,
      'slots': slots.map((slot) => slot.toJson()).toList(),
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
      'providerEmail': providerEmail,
      'providerPhone': providerPhone,
      'providerPid': providerPid,
      'weeklySchedule': weeklySchedule,
      'totalSlots': totalSlots,
      'availableSlots': availableSlots,
      'provider': provider,
      'categoryData': categoryData,
      'reviews': reviews,
      'banner': banner,
      'subcategoryName': subcategoryName,
      'subcategory': subcategory,
      'subcategories': subcategories,
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
    String? type,
    List<ServiceSlot>? slots,
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
    Map<String, dynamic>? provider,
    Map<String, dynamic>? categoryData,
    List<dynamic>? reviews,
    String? serviceId,
    String? banner,
    String? subcategoryName,
    Map<String, dynamic>? subcategory,
    List<Map<String, dynamic>>? subcategories,
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
      type: type ?? this.type,
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
      provider: provider ?? this.provider,
      categoryData: categoryData ?? this.categoryData,
      reviews: reviews ?? this.reviews,
      serviceId: serviceId ?? this.serviceId,
      banner: banner ?? this.banner,
      subcategoryName: subcategoryName ?? this.subcategoryName,
      subcategory: subcategory ?? this.subcategory,
      subcategories: subcategories ?? this.subcategories,
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

  @override
  String toString() {
    return 'ServiceModel{id: $id, name: $name, providerName: $providerName}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ServiceModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

// =================== SERVICE-ONLY TIME SLOT MODELS ===================

class ServiceSlot {
  final List<DaySchedule>? schedule; // Changed from weeklySchedule to schedule
  final List<DateSlot>? specificDates;

  const ServiceSlot({
    this.schedule, // Changed from weeklySchedule to schedule
    this.specificDates,
  });

  factory ServiceSlot.fromJson(Map<String, dynamic> json) {
    return ServiceSlot(
      schedule: json['schedule'] != null // Changed from weeklySchedule to schedule
          ? (json['schedule'] as List)
              .map((x) => DaySchedule.fromJson(x))
              .toList()
          : json['weeklySchedule'] != null // Fallback to old name if exists
              ? (json['weeklySchedule'] as List)
                  .map((x) => DaySchedule.fromJson(x))
                  .toList()
              : null,
      specificDates: json['specificDates'] != null
          ? (json['specificDates'] as List)
              .map((x) => DateSlot.fromJson(x))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (schedule != null)
        'schedule': schedule!.map((x) => x.toJson()).toList(), // Changed from weeklySchedule to schedule
      if (specificDates != null)
        'specificDates': specificDates!.map((x) => x.toJson()).toList(),
    };
  }
}

class DaySchedule {
  final String day;
  final bool isWorkingDay;
  final List<TimeSlot>? timeSlots;
  final String? date;
  final List<String>? dates;
  final List<DateRange>? dateRanges;

  const DaySchedule({
    required this.day,
    required this.isWorkingDay,
    this.timeSlots,
    this.date,
    this.dates,
    this.dateRanges,
  });

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: json['day']?.toString() ?? '',
      isWorkingDay: json['isWorkingDay'] as bool? ?? false,
      timeSlots: json['timeSlots'] != null
          ? (json['timeSlots'] as List)
              .map((x) => TimeSlot.fromJson(x))
              .toList()
          : null,
      date: json['date']?.toString(),
      dates: json['dates'] != null
          ? List<String>.from(json['dates'] as List)
          : null,
      dateRanges: json['dateRanges'] != null
          ? (json['dateRanges'] as List)
              .map((x) => DateRange.fromJson(x))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isWorkingDay': isWorkingDay,
      if (timeSlots != null)
        'timeSlots': timeSlots!.map((x) => x.toJson()).toList(),
      if (date != null) 'date': date,
      if (dates != null) 'dates': dates,
      if (dateRanges != null)
        'dateRanges': dateRanges!.map((x) => x.toJson()).toList(),
    };
  }
}

class TimeSlot {
  final String startTime;
  final String endTime;
  final bool? isAvailable;
  final bool? isBooked;
  final String? bookingId;
  final String? slotIdentifier;
  final String? status;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    this.isAvailable = true,
    this.isBooked = false,
    this.bookingId,
    this.slotIdentifier,
    this.status,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['startTime']?.toString() ?? '',
      endTime: json['endTime']?.toString() ?? '',
      isAvailable: json['isAvailable'] as bool? ?? true,
      isBooked: json['isBooked'] as bool? ?? false,
      bookingId: json['bookingId']?.toString(),
      slotIdentifier: json['slotIdentifier']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isAvailable': isAvailable,
      'isBooked': isBooked,
      if (bookingId != null) 'bookingId': bookingId,
      if (slotIdentifier != null) 'slotIdentifier': slotIdentifier,
      if (status != null) 'status': status,
    };
  }

  TimeSlot copyWith({
    String? startTime,
    String? endTime,
    bool? isAvailable,
    bool? isBooked,
    String? bookingId,
    String? slotIdentifier,
    String? status,
  }) {
    return TimeSlot(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isAvailable: isAvailable ?? this.isAvailable,
      isBooked: isBooked ?? this.isBooked,
      bookingId: bookingId ?? this.bookingId,
      slotIdentifier: slotIdentifier ?? this.slotIdentifier,
      status: status ?? this.status,
    );
  }
}

class DateRange {
  final String startDate;
  final String endDate;

  const DateRange({
    required this.startDate,
    required this.endDate,
  });

  factory DateRange.fromJson(Map<String, dynamic> json) {
    return DateRange(
      startDate: json['startDate']?.toString() ?? '',
      endDate: json['endDate']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate,
      'endDate': endDate,
    };
  }
}

class DateSlot {
  final String? date;
  final List<TimeSlot>? timeSlots;

  const DateSlot({
    this.date,
    this.timeSlots,
  });

  factory DateSlot.fromJson(Map<String, dynamic> json) {
    return DateSlot(
      date: json['date']?.toString(),
      timeSlots: json['timeSlots'] != null
          ? (json['timeSlots'] as List)
              .map((x) => TimeSlot.fromJson(x))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date,
      if (timeSlots != null)
        'timeSlots': timeSlots!.map((x) => x.toJson()).toList(),
    };
  }
}

class SelectedSlot {
  final String? date;
  final TimeSlot? timeSlot;
  final String? serviceId;

  const SelectedSlot({
    this.date,
    this.timeSlot,
    this.serviceId,
  });

  Map<String, dynamic> toJson() {
    return {
      if (date != null) 'date': date,
      if (timeSlot != null) 'timeSlot': timeSlot!.toJson(),
      if (serviceId != null) 'serviceId': serviceId,
    };
  }

  factory SelectedSlot.fromJson(Map<String, dynamic> json) {
    return SelectedSlot(
      date: json['date']?.toString(),
      timeSlot: json['timeSlot'] != null 
          ? TimeSlot.fromJson(json['timeSlot'] as Map<String, dynamic>)
          : null,
      serviceId: json['serviceId']?.toString(),
    );
  }
}