// lib/services/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/service_model.dart';
import '../utils/secure_storage.dart';

class ServiceService {
  final SecureStorage _secureStorage = SecureStorage();

  // ✅ Fetch ALL services
  Future<List<ServiceModel>> getServices() async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.servicesEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load services: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ Alias method for getAllServices (used in HomeScreen)
  Future<List<ServiceModel>> getAllServices() async {
    return await getServices();
  }

  // ✅ Fetch services by CATEGORY ID (uses your new endpoint)
  Future<List<ServiceModel>> getServicesByCategory(String categoryId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = AppConstants.apiBaseUrl +
        AppConstants.replacePathParams(
          AppConstants.servicesByCategoryEndpoint,
          id: categoryId,
        );

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load services: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ Fetch services by SUBCATEGORY ID (uses your new endpoint)
  Future<List<ServiceModel>> getServicesBySubcategory(
      String subcategoryId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = AppConstants.apiBaseUrl +
        AppConstants.replacePathParams(
          AppConstants.servicesBySubcategoryEndpoint,
          subcategoryId: subcategoryId,
        );

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load services: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ Fetch single service by ID
  Future<ServiceModel> getServiceById(String id) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = AppConstants.apiBaseUrl +
        AppConstants.replacePathParams(
          AppConstants.serviceDetailEndpoint,
          id: id,
        );

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to load service: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ Get available slots for a service
  Future<List<dynamic>> getServiceSlots(String serviceId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    // Use replacePathParams for consistency
    final url = AppConstants.apiBaseUrl +
        AppConstants.replacePathParams(
          AppConstants.serviceSlotsEndpoint,
          serviceId: serviceId,
        );

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception(
          'Failed to load slots: ${response.statusCode} ${response.body}');
    }
  }

// Add this method to your existing lib/services/service_service.dart
  Future<List<ServiceModel>> getFilteredServices({
    String? categoryId,
    String? subcategoryId,
    String? searchQuery,
  }) async {
    try {
      if (categoryId != null && categoryId.isNotEmpty) {
        return await getServicesByCategory(categoryId);
      } else if (subcategoryId != null && subcategoryId.isNotEmpty) {
        return await getServicesBySubcategory(subcategoryId);
      } else {
        return await getAllServices();
      }
    } catch (e) {
      throw Exception('Failed to fetch filtered services: $e');
    }
  }

  // ✅ Optional: Simple search (client-side fallback)
  Future<List<ServiceModel>> searchServicesLocally(String query) async {
    final allServices = await getServices();
    final lowerQuery = query.toLowerCase().trim();

    if (lowerQuery.isEmpty) return allServices;

    return allServices.where((service) {
      return service.name.toLowerCase().contains(lowerQuery) ||
          (service.description ?? '').toLowerCase().contains(lowerQuery) ||
          (service.providerName ?? '').toLowerCase().contains(lowerQuery);
    }).toList();
  }
}
