import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = Constants.apiBaseUrl;

  static Future<http.Response> makeRequest(
    String endpoint,
    String method, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 Making API call to: $url');

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        ...?headers,
      };

      http.Response response;

      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(url, headers: requestHeaders);
          break;
        case 'POST':
          response = await http.post(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PUT':
          response = await http.put(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'PATCH':
          response = await http.patch(
            url,
            headers: requestHeaders,
            body: body != null ? jsonEncode(body) : null,
          );
          break;
        case 'DELETE':
          response = await http.delete(url, headers: requestHeaders);
          break;
        default:
          throw Exception('HTTP method $method not supported');
      }

      print('📡 API Call: $method $url');
      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode >= 400) {
        print('❌ Error Response Body: ${response.body}');
      }

      return response;
    } catch (e) {
      print('❌ API Request Error: $e');
      rethrow;
    }
  }

  // Registration method
  static Future<http.Response> registerUser(
    Map<String, dynamic> userData,
  ) async {
    final userDataToSend = Map<String, dynamic>.from(userData);

    userDataToSend['phonenumber'] =
        userDataToSend['phonenumber'] ??
        userDataToSend['phone'] ??
        userDataToSend['phoneNumber'] ??
        '';

    userDataToSend.removeWhere(
      (key, value) => key == 'phone' || key == 'phoneNumber',
    );

    return makeRequest('/auth/register/customer', 'POST', body: userDataToSend);
  }

  // Login method
  static Future<http.Response> loginUser(
    Map<String, dynamic> credentials,
  ) async {
    return makeRequest('/auth/login', 'POST', body: credentials);
  }

  // GET USER PROFILE
  static Future<http.Response> getUserProfile() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest('/users/profile', 'GET', headers: headers);
  }

  // UPDATE USER PROFILE - CORRECT ENDPOINT: PATCH /users/{id}
  static Future<http.Response> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};

    // Extract user ID for the endpoint
    final userId = profileData['id'];
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is required for profile update');
    }

    // Remove ID from payload - it goes in URL
    final updatePayload = Map<String, dynamic>.from(profileData);
    updatePayload.remove('id');

    print('📝 Updating user profile for ID: $userId');
    print('📝 Using endpoint: PATCH /users/$userId');

    return makeRequest(
      '/users/$userId',
      'PATCH',
      headers: headers,
      body: updatePayload,
    );
  }

  // UPLOAD PROFILE PHOTO - CORRECT ENDPOINT: PATCH /users/profile-photo/upload
  static Future<http.Response> uploadProfilePhoto(
    List<int> imageBytes,
    String fileName,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl/users/profile-photo/upload');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    final multipartFile = http.MultipartFile.fromBytes(
      'photo',
      imageBytes,
      filename: fileName,
    );

    request.files.add(multipartFile);

    print('📸 Uploading profile photo to: PATCH /users/profile-photo/upload');
    print('📸 File: $fileName, Size: ${imageBytes.length} bytes');

    try {
      final response = await request.send();
      final resp = await http.Response.fromStream(response);

      print('📸 Upload Response Status: ${resp.statusCode}');

      if (resp.statusCode >= 400) {
        print('❌ Upload Error: ${resp.body}');
      }

      return resp;
    } catch (e) {
      print('❌ Upload Request Failed: $e');
      rethrow;
    }
  }

  // ALTERNATIVE UPLOAD PROFILE PHOTO - PATCH /users/{id}/upload-photo
  static Future<http.Response> uploadProfilePhotoWithId(
    String userId,
    List<int> imageBytes,
    String fileName,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl/users/$userId/upload-photo');
    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    final multipartFile = http.MultipartFile.fromBytes(
      'photo',
      imageBytes,
      filename: fileName,
    );

    request.files.add(multipartFile);

    print('📸 Uploading profile photo to: PATCH /users/$userId/upload-photo');

    try {
      final response = await request.send();
      return await http.Response.fromStream(response);
    } catch (e) {
      print('❌ Upload with ID Failed: $e');
      rethrow;
    }
  }

  // Change password
  static Future<http.Response> changePassword(
    Map<String, dynamic> passwordData,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest(
      '/users/change-password',
      'PATCH',
      headers: headers,
      body: passwordData,
    );
  }

  // Add other API methods as needed
  static Future<http.Response> getServices() async {
    return makeRequest('/services', 'GET');
  }

  static Future<http.Response> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest(
      '/bookings',
      'POST',
      headers: headers,
      body: bookingData,
    );
  }

  static Future<http.Response> getUserBookings() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest('/bookings/user', 'GET', headers: headers);
  }
}
