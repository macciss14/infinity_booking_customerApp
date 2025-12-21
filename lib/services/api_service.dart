// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorage _secureStorage = SecureStorage();

  // Helper: Get standard JSON headers with optional auth token
  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ✅ FIXED: GET with proper URL construction
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    final headers = await _getHeaders();
    // ✅ Use AppConstants.buildUrl() for clean URLs
    final url = AppConstants.buildUrl(endpoint);
    final uri = Uri.parse(url).replace(queryParameters: params);

    final response =
        await http.get(uri, headers: headers).timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  // ✅ FIXED: POST with proper URL construction
  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final url = AppConstants.buildUrl(endpoint); // ✅ Use buildUrl
    final uri = Uri.parse(url);

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  // ✅ FIXED: PUT with proper URL construction
  Future<dynamic> put(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final url = AppConstants.buildUrl(endpoint); // ✅ Use buildUrl
    final uri = Uri.parse(url);

    final response = await http
        .put(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  // ✅ FIXED: PATCH with proper URL construction
  Future<dynamic> patch(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final url = AppConstants.buildUrl(endpoint); // ✅ Use buildUrl
    final uri = Uri.parse(url);

    final response = await http
        .patch(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  // ✅ FIXED: DELETE with proper URL construction
  Future<dynamic> delete(String endpoint) async {
    final headers = await _getHeaders();
    final url = AppConstants.buildUrl(endpoint); // ✅ Use buildUrl
    final uri = Uri.parse(url);

    final response = await http
        .delete(uri, headers: headers)
        .timeout(AppConstants.apiTimeout);

    return _handleResponse(response);
  }

  // ✅ FIXED: Multipart Upload with proper URL construction
  Future<dynamic> uploadMultipart({
    required String endpoint,
    required String method,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    // ✅ Use AppConstants.buildUrl() for clean URLs
    final url = AppConstants.buildUrl(endpoint);
    final uri = Uri.parse(url);
    final request = http.MultipartRequest(method, uri);

    if (fields != null) {
      request.fields.addAll(fields);
    }
    if (files != null) {
      request.files.addAll(files);
    }

    final token = await _secureStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send().timeout(AppConstants.apiTimeout);
    final responseStr = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseStr);
    } else {
      dynamic responseJson;
      try {
        responseJson = jsonDecode(responseStr);
      } catch (_) {
        responseJson = {'message': 'Upload failed'};
      }
      final message = responseJson['message'] ?? 'Upload failed';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }

  // Unified response handler for JSON APIs
  dynamic _handleResponse(http.Response response) {
    dynamic responseJson;
    try {
      responseJson = jsonDecode(response.body);
    } catch (e) {
      responseJson = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseJson;
    } else {
      final message = responseJson['message'] ?? 'Something went wrong';
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
}
