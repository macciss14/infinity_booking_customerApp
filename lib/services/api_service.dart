// lib/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
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
    final headers = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
    print('📤 [ApiService] Headers: $headers');
    return headers;
  }

  // Helper to build complete URL with proper formatting
  String _buildCompleteUrl(String endpoint) {
    final url = AppConstants.buildUrl(endpoint);
    print('🔗 [ApiService] Built URL: $url');
    return url;
  }

  // GET with logging
  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    try {
      final headers = await _getHeaders();
      final url = _buildCompleteUrl(endpoint);
      final uri = Uri.parse(url).replace(queryParameters: params);

      print('📤 [ApiService] GET Request:');
      print('📤 URL: $uri');
      print('📤 Params: $params');

      final response = await http.get(uri, headers: headers).timeout(AppConstants.apiTimeout);

      print('📥 [ApiService] GET Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] GET Error for $endpoint: $e');
      rethrow;
    }
  }

  // POST with logging
  Future<dynamic> post(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final headers = await _getHeaders();
      final url = _buildCompleteUrl(endpoint);
      final uri = Uri.parse(url);

      print('📤 [ApiService] POST Request:');
      print('📤 URL: $uri');
      print('📤 Body: ${jsonEncode(body)}');

      final response = await http.post(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(AppConstants.apiTimeout);

      print('📥 [ApiService] POST Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] POST Error for $endpoint: $e');
      rethrow;
    }
  }

  // PUT with logging
  Future<dynamic> put(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final headers = await _getHeaders();
      final url = _buildCompleteUrl(endpoint);
      final uri = Uri.parse(url);

      print('📤 [ApiService] PUT Request:');
      print('📤 URL: $uri');
      print('📤 Body: ${jsonEncode(body)}');

      final response = await http.put(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(AppConstants.apiTimeout);

      print('📥 [ApiService] PUT Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] PUT Error for $endpoint: $e');
      rethrow;
    }
  }

  // PATCH with logging
  Future<dynamic> patch(String endpoint, {required Map<String, dynamic> body}) async {
    try {
      final headers = await _getHeaders();
      final url = _buildCompleteUrl(endpoint);
      final uri = Uri.parse(url);

      print('📤 [ApiService] PATCH Request:');
      print('📤 URL: $uri');
      print('📤 Body: ${jsonEncode(body)}');

      final response = await http.patch(
        uri,
        headers: headers,
        body: jsonEncode(body),
      ).timeout(AppConstants.apiTimeout);

      print('📥 [ApiService] PATCH Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] PATCH Error for $endpoint: $e');
      rethrow;
    }
  }

  // DELETE with logging
  Future<dynamic> delete(String endpoint) async {
    try {
      final headers = await _getHeaders();
      final url = _buildCompleteUrl(endpoint);
      final uri = Uri.parse(url);

      print('📤 [ApiService] DELETE Request:');
      print('📤 URL: $uri');

      final response = await http.delete(uri, headers: headers).timeout(AppConstants.apiTimeout);

      print('📥 [ApiService] DELETE Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      return _handleResponse(response);
    } catch (e) {
      print('❌ [ApiService] DELETE Error for $endpoint: $e');
      rethrow;
    }
  }

  // Multipart Upload with logging
  Future<dynamic> uploadMultipart({
    required String endpoint,
    required String method,
    Map<String, String>? fields,
    List<http.MultipartFile>? files,
  }) async {
    try {
      final url = _buildCompleteUrl(endpoint);
      final uri = Uri.parse(url);
      final request = http.MultipartRequest(method, uri);

      print('📤 [ApiService] Multipart Request:');
      print('📤 URL: $uri');
      print('📤 Method: $method');
      print('📤 Fields: $fields');
      print('📤 Files: ${files?.length ?? 0}');

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

      print('📤 [ApiService] Request Headers: ${request.headers}');

      final response = await request.send().timeout(AppConstants.apiTimeout);
      final responseStr = await response.stream.bytesToString();

      print('📥 [ApiService] Multipart Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: $responseStr');

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
    } catch (e) {
      print('❌ [ApiService] Multipart Upload Error for $endpoint: $e');
      rethrow;
    }
  }

  // Simplified multipart for file uploads
  Future<dynamic> uploadFile({
    required String endpoint,
    required String filePath,
    required String fieldName,
    Map<String, String>? additionalFields,
  }) async {
    try {
      print('📤 [ApiService] Uploading file: $filePath');
      
      final url = _buildCompleteUrl(endpoint);
      final request = http.MultipartRequest('POST', Uri.parse(url));

      final token = await _secureStorage.getToken();
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      // Add file
      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      // Add additional fields
      if (additionalFields != null) {
        request.fields.addAll(additionalFields);
      }

      final response = await request.send();
      final responseStr = await response.stream.bytesToString();

      print('📥 [ApiService] File Upload Response:');
      print('📥 Status: ${response.statusCode}');
      print('📥 Body: $responseStr');

      return jsonDecode(responseStr);
    } catch (e) {
      print('❌ [ApiService] File Upload Error: $e');
      rethrow;
    }
  }

  // Unified response handler for JSON APIs
  dynamic _handleResponse(http.Response response) {
    dynamic responseJson;
    try {
      responseJson = jsonDecode(response.body);
    } catch (e) {
      print('🟡 [ApiService] Failed to parse JSON, using raw body');
      responseJson = {'message': response.body};
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      print('✅ [ApiService] Request successful');
      return responseJson;
    } else {
      final message = responseJson['message'] ?? 'Something went wrong';
      print('🔴 [ApiService] Request failed: $message (${response.statusCode})');
      throw Exception('$message (Status: ${response.statusCode})');
    }
  }
}