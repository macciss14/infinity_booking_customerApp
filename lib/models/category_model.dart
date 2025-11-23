class Category {
  final String id;
  final String name;
  final String description;
  final String? icon;
  final String? image;
  final int serviceCount;
  final bool isActive;
  final List<Category>? subcategories;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    required this.description,
    this.icon,
    this.image,
    this.serviceCount = 0,
    this.isActive = true,
    this.subcategories,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    // Handle different JSON structures
    final id = json['_id']?.toString() ?? json['id']?.toString() ?? '';
    final name = json['name']?.toString() ?? '';
    final description = json['description']?.toString() ?? '';

    // Handle service count - could be from different fields
    int serviceCount = 0;
    if (json['serviceCount'] != null) {
      serviceCount = json['serviceCount'] is int
          ? json['serviceCount']
          : int.tryParse(json['serviceCount'].toString()) ?? 0;
    } else if (json['servicesCount'] != null) {
      serviceCount = json['servicesCount'] is int
          ? json['servicesCount']
          : int.tryParse(json['servicesCount'].toString()) ?? 0;
    }

    // Handle subcategories
    List<Category>? subcategories;
    if (json['subcategories'] is List) {
      subcategories = (json['subcategories'] as List)
          .map((e) => Category.fromJson(e))
          .toList();
    }

    return Category(
      id: id,
      name: name,
      description: description,
      icon: json['icon']?.toString(),
      image: json['image']?.toString(),
      serviceCount: serviceCount,
      isActive: json['isActive'] ?? true,
      subcategories: subcategories,
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'icon': icon,
      'image': image,
      'serviceCount': serviceCount,
      'isActive': isActive,
      'subcategories': subcategories?.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
