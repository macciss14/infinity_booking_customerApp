// lib/models/subcategory_model.dart
class SubcategoryModel {
  final String id;
  final String name;
  final String categoryId;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
  });

  factory SubcategoryModel.fromJson(Map<String, dynamic> json) {
    return SubcategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      categoryId: json['categoryId'] ?? '',
    );
  }
}