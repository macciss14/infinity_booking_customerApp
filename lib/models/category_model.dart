// lib/models/category_model.dart
class CategoryModel {
  final String id;
  final String name;
  final String? imageUrl;
  final int? serviceCount;

  CategoryModel({
    required this.id,
    required this.name,
    this.imageUrl,
    this.serviceCount,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'],
      serviceCount: json['serviceCount'] is int ? json['serviceCount'] : null,
    );
  }
}
