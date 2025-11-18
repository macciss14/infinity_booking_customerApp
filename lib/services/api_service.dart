// lib/services/api_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart'; // Import your constants.dart
import 'auth_service.dart'; // Import AuthService

class ApiService {
  // Base URL is defined in constants.dart
  static const String baseUrl = Constants
      .apiBaseUrl; // e.g., 'https://infinity-booking-backend1.onrender.com/infinity-booking'

  // Generic method to make API calls
  static Future<http.Response> makeRequest(
    String endpoint,
    String method, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    final url = Uri.parse('$baseUrl$endpoint'); // Combine base URL and endpoint
    print('Making API call to: $url'); // Debug print

    // Prepare headers
    final requestHeaders = <String, String>{
      'Content-Type': 'application/json',
      ...?headers, // Add any specific headers passed
    };

    http.Response response;

    switch (method) {
      case 'GET':
        response = await http.get(url, headers: requestHeaders);
        break;
      case 'POST':
        response = await http.post(
          url,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
        break;
      case 'PUT':
        response = await http.put(
          url,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
        break;
      case 'PATCH':
        response = await http.patch(
          url,
          headers: requestHeaders,
          body: jsonEncode(body),
        );
        break;
      case 'DELETE':
        response = await http.delete(url, headers: requestHeaders);
        break;
      default:
        throw Exception('HTTP method $method not supported');
    }

    print('API Call: $method $url');
    print('Response Status: ${response.statusCode}');
    print('Response Body: ${response.body}');

    return response;
  }

  // Specific method for user registration - Updated endpoint for customer
  static Future<http.Response> registerUser(
    Map<String, dynamic> userData,
  ) async {
    // Endpoint: POST /infinity-booking/auth/register/customer
    return makeRequest('/auth/register/customer', 'POST', body: userData);
  }

  // Specific method for user login
  static Future<http.Response> loginUser(
    Map<String, dynamic> credentials,
  ) async {
    // Endpoint: POST /infinity-booking/auth/login
    return makeRequest('/auth/login', 'POST', body: credentials);
  }

  // Specific method to get user profile - NEW
  static Future<http.Response> getUserProfile() async {
    // Endpoint: GET /infinity-booking/users/profile
    // This call requires an Authorization header with the Bearer token
    final token = await AuthService.getToken(); // Get the stored token
    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }
    final headers = {
      'Authorization': 'Bearer $token', // Include the token in the header
    };
    return makeRequest('/users/profile', 'GET', headers: headers);
  }

  // Specific method to update user profile - NEW
  static Future<http.Response> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    // Endpoint: PATCH /infinity-booking/users/{id}
    // Assuming the endpoint is /infinity-booking/users/{id} for self-update
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }
    final headers = {'Authorization': 'Bearer $token'};

    // Extract the user's ID from the profileData map
    final userId = profileData['id']; // Adjust key based on your data structure
    if (userId == null) {
      throw Exception('User ID not found in profile data sent to API.');
    }

    // Remove the 'id' field from the data payload as it's part of the URL
    final updatePayload = Map<String, dynamic>.from(profileData);
    updatePayload.remove('id');

    // Construct the endpoint URL using the extracted ID
    final endpoint = '/users/$userId';
    print(
      'ApiService.updateUserProfile: Constructed endpoint: $endpoint',
    ); // Debug print
    print(
      'ApiService.updateUserProfile: Sending payload: $updatePayload',
    ); // Debug print

    return makeRequest(
      endpoint,
      'PATCH',
      headers: headers,
      body: updatePayload,
    );
  }

  // Specific method to change password - NEW
  static Future<http.Response> changePassword(
    Map<String, dynamic> passwordData,
  ) async {
    // Endpoint: PATCH /infinity-booking/users/change-password
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }
    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest(
      '/users/change-password',
      'PATCH',
      headers: headers,
      body: passwordData,
    );
  }

  // Specific method to upload profile photo - NEW (Web-friendly, Multipart)
  static Future<http.Response> uploadProfilePhoto(
    List<int> imageBytes,
    String fileName,
  ) async {
    // Endpoint: PATCH /infinity-booking/users/profile-photo/upload
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No token found. User might not be logged in.');
    }

    // Create a multipart request for file upload
    final uri = Uri.parse('$baseUrl/users/profile-photo/upload');
    final request = http.MultipartRequest('PATCH', uri); // Use PATCH method

    // Add the authorization header
    request.headers['Authorization'] = 'Bearer $token';

    // Add the file to the request using MultipartFile.fromBytes
    // The field name 'photo' must match exactly what the backend expects (as per upload.single("photo"))
    final multipartFile = http.MultipartFile.fromBytes(
      'photo', // <-- CRITICAL: Field name must match backend expectation 'photo'
      imageBytes,
      filename: fileName,
    );

    request.files.add(multipartFile);

    print(
      'ApiService.uploadProfilePhoto: Sending multipart request to: $uri',
    ); // Debug print
    print(
      'ApiService.uploadProfilePhoto: Field name: photo, Filename: $fileName',
    ); // Debug print

    // Send the multipart request
    final response = await request.send();

    // Convert the streamed response to a standard http.Response
    final resp = await http.Response.fromStream(response);

    print('Upload Profile Photo Response Status: ${resp.statusCode}');
    print('Upload Profile Photo Response Body: ${resp.body}');

    return resp;
  }

  // Add other API methods here as needed (e.g., getServices, createBooking, etc.)
}
