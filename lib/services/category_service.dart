// lib/services/category_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../utils/secure_storage.dart';

class CategoryService {
  final SecureStorage _secureStorage = SecureStorage();

  Future<List<CategoryModel>> getCategories() async {
    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => CategoryModel.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load categories: ${response.statusCode}');
    }
  }

  Future<List<SubcategoryModel>> getSubcategoriesByCategory(
      String categoryId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    // ✅ DEBUG: Print the exact URL being called
    final url =
        '${AppConstants.apiBaseUrl}${AppConstants.subcategoriesEndpoint.replaceAll('{id}', categoryId)}';
    print('Fetching subcategories from: $url'); // ✅ ADD THIS LINE

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => SubcategoryModel.fromJson(json)).toList();
    } else {
      // ✅ FALLBACK: Try alternative endpoint format
      try {
        // Alternative 1: Try without /infinity-booking prefix
        final altUrl =
            '${AppConstants.baseUrl}/categories/$categoryId/subcategories';
        print('Trying alternative URL: $altUrl');

        final altResponse = await http.get(
          Uri.parse(altUrl),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (altResponse.statusCode == 200) {
          final List<dynamic> data = json.decode(altResponse.body);
          return data.map((json) => SubcategoryModel.fromJson(json)).toList();
        }
      } catch (e) {
        // Alternative 2: Try with different path
        try {
          final altUrl2 =
              '${AppConstants.apiBaseUrl}/categories/$categoryId/subcategories';
          print('Trying alternative URL 2: $altUrl2');

          final altResponse2 = await http.get(
            Uri.parse(altUrl2),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
          );

          if (altResponse2.statusCode == 200) {
            final List<dynamic> data = json.decode(altResponse2.body);
            return data.map((json) => SubcategoryModel.fromJson(json)).toList();
          }
        } catch (e2) {
          throw Exception(
              'Failed to load subcategories: ${response.statusCode} - ${response.body}');
        }
      }

      throw Exception('Failed to load subcategories: ${response.statusCode}');
    }
  }
}
