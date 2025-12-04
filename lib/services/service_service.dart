// lib/services/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/service_model.dart';
import '../utils/secure_storage.dart';

class ServiceService {
  final SecureStorage _secureStorage = SecureStorage();

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
      throw Exception('Failed to load services: ${response.statusCode}');
    }
  }

  Future<List<ServiceModel>> searchServices({
    String? query,
    String? categoryId,
    String? subcategoryId,
    String? sort,
  }) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final queryParams = <String, String>{};
    if (query != null && query.trim().isNotEmpty) {
      queryParams['search'] = query.trim();
    }
    if (categoryId != null && categoryId.isNotEmpty) {
      queryParams['categoryId'] = categoryId;
    }
    if (subcategoryId != null && subcategoryId.isNotEmpty) {
      queryParams['subcategoryId'] = subcategoryId;
    }
    if (sort != null) {
      queryParams['sort'] = sort;
    }

    final uri =
        Uri.parse('${AppConstants.apiBaseUrl}${AppConstants.servicesEndpoint}')
            .replace(queryParameters: queryParams);

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => ServiceModel.fromJson(json)).toList();
    } else {
      throw Exception('Search failed: ${response.statusCode}');
    }
  }

  Future<ServiceModel> getServiceById(String id) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.serviceDetailEndpoint.replaceAll('{id}', id)}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return ServiceModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load service: ${response.statusCode}');
    }
  }

  Future<List<dynamic>> getServiceSlots(String serviceId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
          '${AppConstants.apiBaseUrl}/infinity-booking/services/$serviceId/slots'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load slots: ${response.statusCode}');
    }
  }
}
