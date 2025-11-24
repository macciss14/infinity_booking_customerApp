class Service {
  final String id;
  final String title;
  final String description;
  final double price;
  final String categoryId;
  final String subcategoryId;
  final String providerId;
  final String providerName;
  final List<String> images;
  final double rating;
  final int reviewCount;
  final String duration;
  final bool isAvailable;
  final String location;
  final List<String> tags;
  final List<String> availableTimeSlots;
  final DateTime createdAt;

  Service({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.categoryId,
    this.subcategoryId = '',
    required this.providerId,
    required this.providerName,
    this.images = const [],
    this.rating = 0.0,
    this.reviewCount = 0,
    this.duration = '1 hour',
    this.isAvailable = true,
    this.location = '',
    this.tags = const [],
    this.availableTimeSlots = const [],
    required this.createdAt,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      price: (json['price'] ?? json['price'] ?? 0.0).toDouble(),
      categoryId:
          json['categoryId']?.toString() ?? json['category']?.toString() ?? '',
      subcategoryId: json['subcategoryId']?.toString() ??
          json['subcategory']?.toString() ??
          '',
      providerId:
          json['providerId']?.toString() ?? json['provider']?.toString() ?? '',
      providerName: json['providerName']?.toString() ?? 'Unknown Provider',
      images:
          (json['images'] as List?)?.map((e) => e.toString()).toList() ?? [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      reviewCount: json['reviewCount'] ?? 0,
      duration: json['duration']?.toString() ?? '1 hour',
      isAvailable: json['isAvailable'] ?? true,
      location: json['location']?.toString() ?? '',
      tags: (json['tags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      availableTimeSlots: (json['availableTimeSlots'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['timeSlots'] as List?)?.map((e) => e.toString()).toList() ??
          (json['availableSlots'] as List?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['slots'] as List?)?.map((e) => e.toString()).toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'price': price,
      'categoryId': categoryId,
      'subcategoryId': subcategoryId,
      'providerId': providerId,
      'providerName': providerName,
      'images': images,
      'rating': rating,
      'reviewCount': reviewCount,
      'duration': duration,
      'isAvailable': isAvailable,
      'location': location,
      'tags': tags,
      'availableTimeSlots': availableTimeSlots,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get formattedPrice => 'ETB ${price.toStringAsFixed(2)}';
  String get ratingText => rating.toStringAsFixed(1);

  bool get hasAvailableTimeSlots => availableTimeSlots.isNotEmpty;

  List<String> get formattedTimeSlots {
    return availableTimeSlots.map((slot) {
      return slot;
    }).toList();
  }

  bool isTimeSlotAvailable(String timeSlot) {
    return availableTimeSlots.contains(timeSlot);
  }
}
