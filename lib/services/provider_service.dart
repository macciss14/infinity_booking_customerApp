// lib/services/provider_service.dart
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/secure_storage.dart';
import '../models/provider_model.dart';

class ProviderService {
  final SecureStorage _secureStorage = SecureStorage();

  Future<ProviderModel> getProviderByPid(String providerPid) async {
    if (providerPid.trim().isEmpty) throw Exception('Provider PID cannot be empty');
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final endpoint = AppConstants.replacePathParams(AppConstants.providerByPidEndpoint, pid: providerPid.trim());
    final url = AppConstants.buildUrl(endpoint);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      Map<String, dynamic> providerData;
      if (data is Map) {
        if (data.containsKey('data')) {
          providerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : {};
        } else if (data.containsKey('provider')) {
          providerData = data['provider'] is Map ? Map<String, dynamic>.from(data['provider']) : {};
        } else if (data.containsKey('user')) {
          providerData = data['user'] is Map ? Map<String, dynamic>.from(data['user']) : {};
        } else {
          providerData = Map<String, dynamic>.from(data);
        }
        if (providerData.isEmpty) throw Exception('Provider data is empty');
        return ProviderModel.fromJson(providerData);
      }
      throw Exception('Invalid response format: Expected Map');
    } else if (response.statusCode == 404) {
      throw Exception('Provider not found with PID: $providerPid');
    } else {
      String errorMsg = 'Failed to fetch provider (${response.statusCode})';
      try {
        final errorJson = json.decode(response.body);
        errorMsg = errorJson['message'] ?? errorJson['error'] ?? errorMsg;
      } catch (_) {}
      throw Exception(errorMsg);
    }
  }

  Future<ProviderModel> getProviderById(String providerId) async {
    if (providerId.trim().isEmpty) throw Exception('Provider ID cannot be empty');
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final endpoint = AppConstants.replacePathParams(AppConstants.providerEndpoint, id: providerId.trim());
    final url = AppConstants.buildUrl(endpoint);
    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 15));

    if (response.statusCode == 200) {
      final dynamic data = json.decode(response.body);
      Map<String, dynamic> providerData;
      if (data is Map) {
        if (data.containsKey('data')) {
          providerData = data['data'] is Map ? Map<String, dynamic>.from(data['data']) : {};
        } else if (data.containsKey('provider')) {
          providerData = data['provider'] is Map ? Map<String, dynamic>.from(data['provider']) : {};
        } else {
          providerData = Map<String, dynamic>.from(data);
        }
        if (providerData.isEmpty) throw Exception('Provider data is empty');
        return ProviderModel.fromJson(providerData);
      }
      throw Exception('Invalid response format');
    } else if (response.statusCode == 404) {
      throw Exception('Provider not found with ID: $providerId');
    }

    String errorMsg = 'Failed to fetch provider by ID (${response.statusCode})';
    try {
      final errorJson = json.decode(response.body);
      errorMsg = errorJson['message'] ?? errorJson['error'] ?? errorMsg;
    } catch (_) {}
    throw Exception(errorMsg);
  }

  Future<ProviderModel?> getProviderSmart(String identifier) async {
    if (identifier.trim().isEmpty) return null;
    try {
      final result = await getProviderByPid(identifier);
      if (result.pid.isNotEmpty) return result;
    } catch (pidError) {
      if (pidError.toString().contains('404') || pidError.toString().contains('not found')) {
        try {
          final result = await getProviderById(identifier);
          if (result.id.isNotEmpty) return result;
        } catch (_) {}
      }
    }
    return null;
  }

  Future<ProviderModel?> getProviderByEmail(String email) async {
    if (email.trim().isEmpty) return null;
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return null;
      final searchUrl = '${AppConstants.apiBaseUrl}infinity-booking/providers/search?email=${Uri.encodeQueryComponent(email)}';
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          return ProviderModel.fromJson(Map<String, dynamic>.from(data[0]));
        } else if (data is Map<String, dynamic>) {
          return ProviderModel.fromJson(data);
        } else if (data is Map && data.containsKey('data')) {
          final providers = data['data'];
          if (providers is List && providers.isNotEmpty) {
            return ProviderModel.fromJson(Map<String, dynamic>.from(providers[0]));
          }
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<List<ProviderModel>> getProvidersByIds(List<String> providerIds) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');
      final results = <ProviderModel>[];
      const batchSize = 5;
      for (var i = 0; i < providerIds.length; i += batchSize) {
        final batch = providerIds.sublist(
          i,
          i + batchSize > providerIds.length ? providerIds.length : i + batchSize,
        );
        final batchFutures = batch.map((id) => getProviderById(id).catchError((_) => null));
        final batchResults = await Future.wait(batchFutures);
        results.addAll(batchResults.whereType<ProviderModel>());
        if (i + batchSize < providerIds.length) await Future.delayed(const Duration(milliseconds: 500));
      }
      return results;
    } catch (_) {
      return [];
    }
  }

  Future<List<ProviderModel>> searchProviders(String query) async {
    if (query.trim().isEmpty) return [];
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return [];
      final searchUrl = '${AppConstants.apiBaseUrl}infinity-booking/providers/search?q=${Uri.encodeQueryComponent(query)}&limit=20';
      final response = await http.get(
        Uri.parse(searchUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<ProviderModel> providers = [];
        if (data is List) {
          providers.addAll(data.map((item) => ProviderModel.fromJson(Map<String, dynamic>.from(item))).toList());
        } else if (data is Map<String, dynamic>) {
          if (data.containsKey('data')) {
            final items = data['data'];
            if (items is List) {
              providers.addAll(items.map((item) => ProviderModel.fromJson(Map<String, dynamic>.from(item))).toList());
            }
          } else {
            providers.add(ProviderModel.fromJson(data));
          }
        }
        return providers;
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> validateProviderExists(String identifier) async {
    try {
      return await getProviderSmart(identifier) != null;
    } catch (_) {
      return false;
    }
  }

  Future<Map<String, dynamic>> getProviderStatistics(String providerId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');
      final statsUrl = '${AppConstants.apiBaseUrl}infinity-booking/providers/$providerId/statistics';
      final response = await http.get(
        Uri.parse(statsUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Map<String, dynamic>.from(data);
      }
      return {};
    } catch (_) {
      return {};
    }
  }
}