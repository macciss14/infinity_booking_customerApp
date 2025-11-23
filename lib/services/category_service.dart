import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/category_model.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class CategoryService {
  static Future<List<Category>> getCategories() async {
    try {
      print('🔄 CategoryService - Fetching categories...');
      final response = await ApiService.makeRequest(
        Endpoints.categories,
        'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> categoriesJson =
            data is List ? data : data['categories'] ?? data['data'] ?? [];

        final categories =
            categoriesJson.map((json) => Category.fromJson(json)).toList();
        print('✅ CategoryService - Found ${categories.length} categories');
        return categories;
      } else {
        print(
            '❌ CategoryService - Failed to fetch categories: ${response.statusCode}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 CategoryService - Error: $e');
      rethrow;
    }
  }

  static Future<Category> getCategoryById(String id) async {
    try {
      final endpoint = Endpoints.buildPath(Endpoints.categoryById, {'id': id});
      final response = await ApiService.makeRequest(endpoint, 'GET');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Category.fromJson(data);
      } else {
        throw Exception('Failed to load category: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 CategoryService - Error fetching category $id: $e');
      rethrow;
    }
  }

  static Future<List<Category>> getSubcategories(String categoryId) async {
    try {
      final endpoint = Endpoints.buildPath(
          Endpoints.categorySubcategories, {'id': categoryId});
      final response = await ApiService.makeRequest(endpoint, 'GET');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> subcategoriesJson =
            data is List ? data : data['subcategories'] ?? [];
        return subcategoriesJson
            .map((json) => Category.fromJson(json))
            .toList();
      } else {
        throw Exception('Failed to load subcategories: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 CategoryService - Error fetching subcategories: $e');
      rethrow;
    }
  }
}
