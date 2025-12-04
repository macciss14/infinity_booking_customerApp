import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../utils/secure_storage.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final SecureStorage _secureStorage = SecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    final token = await _secureStorage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<dynamic> get(String endpoint, {Map<String, dynamic>? params}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint')
        .replace(queryParameters: params);

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<dynamic> post(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final response = await http
        .post(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  Future<dynamic> patch(String endpoint,
      {required Map<String, dynamic> body}) async {
    final headers = await _getHeaders();
    final uri = Uri.parse('${AppConstants.apiBaseUrl}$endpoint');

    final response = await http
        .patch(
          uri,
          headers: headers,
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 30));

    return _handleResponse(response);
  }

  // Add this method for multipart uploads (photo upload)
  Future<dynamic> patchMultipart(
      String endpoint, http.MultipartRequest request) async {
    final token = await _secureStorage.getToken();
    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseStr = await response.stream.bytesToString();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(responseStr);
    } else {
      final responseJson = jsonDecode(responseStr);
      final errorMessage = responseJson['message'] ?? 'Something went wrong';
      throw Exception('$errorMessage (Status: ${response.statusCode})');
    }
  }

  dynamic _handleResponse(http.Response response) {
    final responseJson = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return responseJson;
    } else {
      final errorMessage = responseJson['message'] ?? 'Something went wrong';
      throw Exception('$errorMessage (Status: ${response.statusCode})');
    }
  }
}
