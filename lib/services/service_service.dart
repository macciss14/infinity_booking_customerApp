import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class ServiceService {
  static Future<List<Service>> getServices({
    String? categoryId,
    String? searchQuery,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      print('🔄 ServiceService - Fetching services...');

      // Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (categoryId != null && categoryId.isNotEmpty) {
        queryParams['category'] = categoryId;
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        queryParams['search'] = searchQuery;
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final endpoint = '${Endpoints.services}?$queryString';

      final response = await ApiService.makeRequest(endpoint, 'GET');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> servicesJson =
            data is List ? data : data['services'] ?? data['data'] ?? [];

        final services =
            servicesJson.map((json) => Service.fromJson(json)).toList();
        print('✅ ServiceService - Found ${services.length} services');
        return services;
      } else {
        print(
            '❌ ServiceService - Failed to fetch services: ${response.statusCode}');
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 ServiceService - Error: $e');
      rethrow;
    }
  }

  static Future<Service> getServiceById(String id) async {
    try {
      final endpoint = Endpoints.buildPath(Endpoints.serviceById, {'id': id});
      final response = await ApiService.makeRequest(endpoint, 'GET');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Service.fromJson(data);
      } else {
        throw Exception('Failed to load service: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 ServiceService - Error fetching service $id: $e');
      rethrow;
    }
  }

  static Future<List<Service>> getFeaturedServices() async {
    try {
      final services = await getServices(limit: 6);
      return services.take(6).toList(); // Get first 6 as featured
    } catch (e) {
      print('💥 ServiceService - Error fetching featured services: $e');
      rethrow;
    }
  }
}
