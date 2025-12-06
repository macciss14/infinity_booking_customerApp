// lib/services/category_service.dart - IMPROVED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/category_model.dart';
import '../models/subcategory_model.dart';
import '../utils/secure_storage.dart';

class CategoryService {
  final SecureStorage _secureStorage = SecureStorage();
  final Map<String, List<SubcategoryModel>> _subcategoriesCache = {};

  Future<List<CategoryModel>> getCategories() async {
    try {
      print(
          'Fetching categories from: ${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}');

      final response = await http.get(
        Uri.parse(
            '${AppConstants.apiBaseUrl}${AppConstants.categoriesEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Categories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        List<dynamic> data;

        if (responseBody is Map && responseBody.containsKey('data')) {
          data = responseBody['data'] as List<dynamic>;
        } else if (responseBody is List) {
          data = responseBody;
        } else {
          data = [];
        }

        final categories = data.map((json) {
          return CategoryModel(
            id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
            name: json['name']?.toString() ?? 'Unnamed Category',
            imageUrl: json['imageUrl']?.toString() ?? json['image']?.toString(),
            serviceCount:
                json['serviceCount'] is int ? json['serviceCount'] : 0,
          );
        }).toList();

        print('Fetched ${categories.length} categories');
        return categories;
      } else {
        print('Categories response body: ${response.body}');
        throw Exception('Failed to load categories: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching categories: $e');
      throw Exception(
          'Failed to load categories. Please check your internet connection.');
    }
  }

  Future<List<SubcategoryModel>> getSubcategoriesByCategory(
      String categoryId) async {
    print('Fetching subcategories for category: $categoryId');

    // Return cached data if available
    if (_subcategoriesCache.containsKey(categoryId)) {
      print('Returning cached subcategories for $categoryId');
      return _subcategoriesCache[categoryId]!;
    }

    final token = await _secureStorage.getToken();
    if (token == null) {
      print('No token available for subcategories request');
      return [];
    }

    try {
      // First, try the main endpoint
      final mainEndpoint =
          '${AppConstants.apiBaseUrl}/infinity-booking/categories/$categoryId/subcategories';
      print('Trying main endpoint: $mainEndpoint');

      final response = await http.get(
        Uri.parse(mainEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      print('Subcategories response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);

        List<dynamic> data;
        if (responseBody is Map && responseBody.containsKey('data')) {
          data = responseBody['data'] as List<dynamic>;
        } else if (responseBody is List) {
          data = responseBody;
        } else if (responseBody is Map &&
            responseBody.containsKey('subcategories')) {
          data = responseBody['subcategories'] as List<dynamic>;
        } else {
          data = [];
        }

        final subcategories = data.map((json) {
          return SubcategoryModel(
            id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
            name: json['name']?.toString() ?? 'Unnamed Subcategory',
            categoryId: json['categoryId']?.toString() ??
                json['category']?.toString() ??
                categoryId,
          );
        }).toList();

        // Cache the result
        _subcategoriesCache[categoryId] = subcategories;

        print(
            'Successfully fetched ${subcategories.length} subcategories for category $categoryId');
        return subcategories;
      } else if (response.statusCode == 404) {
        print('Main endpoint not found, trying alternatives...');
        return await _tryAlternativeEndpoints(categoryId, token);
      } else {
        print('Unexpected response: ${response.body}');
        return await _tryAlternativeEndpoints(categoryId, token);
      }
    } catch (e) {
      print('Error fetching subcategories from main endpoint: $e');
      return await _tryAlternativeEndpoints(categoryId, token);
    }
  }

  Future<List<SubcategoryModel>> _tryAlternativeEndpoints(
      String categoryId, String token) async {
    final alternativeEndpoints = [
      '${AppConstants.apiBaseUrl}/categories/$categoryId/subcategories',
      '${AppConstants.baseUrl}/infinity-booking/categories/$categoryId/subcategories',
      '${AppConstants.baseUrl}/categories/$categoryId/subcategories',
    ];

    for (var endpoint in alternativeEndpoints) {
      try {
        print('Trying alternative endpoint: $endpoint');

        final response = await http.get(
          Uri.parse(endpoint),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body) as List<dynamic>;
          final subcategories = data.map((json) {
            return SubcategoryModel(
              id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
              name: json['name']?.toString() ?? 'Unnamed Subcategory',
              categoryId: json['categoryId']?.toString() ??
                  json['category']?.toString() ??
                  categoryId,
            );
          }).toList();

          _subcategoriesCache[categoryId] = subcategories;
          print(
              'Successfully fetched ${subcategories.length} subcategories from alternative endpoint');
          return subcategories;
        }
      } catch (e) {
        print('Error with endpoint $endpoint: $e');
        continue;
      }
    }

    // If no endpoints worked, check if categories include subcategories
    try {
      print('Checking if categories include subcategories...');
      final categories = await getCategories();
      final category = categories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => CategoryModel(id: '', name: ''),
      );

      // Some APIs return subcategories within the category object
      // We'll return empty for now since we can't parse that structure
      print('No subcategories found for category $categoryId');
      _subcategoriesCache[categoryId] = [];
      return [];
    } catch (e) {
      print('Error checking category for subcategories: $e');
      _subcategoriesCache[categoryId] = [];
      return [];
    }
  }

  // Clear cache
  void clearCache() {
    _subcategoriesCache.clear();
  }
}
