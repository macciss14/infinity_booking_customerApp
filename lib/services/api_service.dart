import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = Constants.apiBaseUrl;

  // Generic method to make API calls
  static Future<http.Response> makeRequest(
    String endpoint,
    String method, {
    Map<String, String>? headers,
    dynamic body,
  }) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      print('🌐 Making API call to: $url');

      // Get token for authenticated requests
      String? token;
      if (!endpoint.contains('/auth/')) {
        token = await AuthService.getToken();
        if (token == null) {
          throw Exception('No authentication token found');
        }
      }

      final requestHeaders = <String, String>{
        'Content-Type': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
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

      print('📡 API Call: $method $endpoint');
      print('📊 Response Status: ${response.statusCode}');

      if (response.statusCode == 401) {
        print('❌ API Request - Unauthorized (401)');
        await AuthService.logout();
        throw Exception('Authentication failed. Please login again.');
      }

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

    userDataToSend['phonenumber'] = userDataToSend['phonenumber'] ??
        userDataToSend['phone'] ??
        userDataToSend['phoneNumber'] ??
        '';

    userDataToSend.removeWhere(
      (key, value) => key == 'phone' || key == 'phoneNumber',
    );

    return makeRequest(
      Endpoints.authRegisterCustomer,
      'POST',
      body: userDataToSend,
    );
  }

  // Login method
  static Future<http.Response> loginUser(
    Map<String, dynamic> credentials,
  ) async {
    return makeRequest(Endpoints.authLogin, 'POST', body: credentials);
  }

  // GET USER PROFILE
  static Future<http.Response> getUserProfile() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest(Endpoints.userProfile, 'GET', headers: headers);
  }

  // UPDATE USER PROFILE
  static Future<http.Response> updateUserProfile(
    Map<String, dynamic> profileData,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};

    final userId = profileData['id'];
    if (userId == null || userId.isEmpty) {
      throw Exception('User ID is required for profile update');
    }

    final updatePayload = Map<String, dynamic>.from(profileData);
    updatePayload.remove('id');

    final endpoint = Endpoints.buildPath(Endpoints.userUpdateProfile, {
      'id': userId,
    });

    print('📝 Updating user profile for ID: $userId');
    print('📝 Using endpoint: PATCH $endpoint');

    return makeRequest(
      endpoint,
      'PATCH',
      headers: headers,
      body: updatePayload,
    );
  }

  // UPLOAD PROFILE PHOTO - Enhanced version with better error handling
  static Future<http.Response> uploadProfilePhoto(
    List<int> imageBytes,
    String fileName,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl${Endpoints.userUploadProfilePhoto}');
    print('📸 Uploading to: $uri');

    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    try {
      // Create multipart file
      final multipartFile = http.MultipartFile.fromBytes(
        'photo', // Field name - try different names
        imageBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);

      print('📸 File prepared: $fileName, Size: ${imageBytes.length} bytes');

      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📸 Upload Response Status: ${response.statusCode}');
      print('📸 Upload Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ Upload Request Failed: $e');
      rethrow;
    }
  }

  // ALTERNATIVE UPLOAD PROFILE PHOTO - With user ID and different field names
  static Future<http.Response> uploadProfilePhotoWithId(
    String userId,
    List<int> imageBytes,
    String fileName,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final endpoint = Endpoints.buildPath(Endpoints.userUploadPhotoWithId, {
      'id': userId,
    });
    final uri = Uri.parse('$baseUrl$endpoint');

    print('📸 Alternative upload to: $uri');

    final request = http.MultipartRequest('PATCH', uri);
    request.headers['Authorization'] = 'Bearer $token';

    try {
      // Try different field names
      final multipartFile = http.MultipartFile.fromBytes(
        'image', // Try 'image' instead of 'photo'
        imageBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📸 Alternative Upload Response Status: ${response.statusCode}');
      print('📸 Alternative Upload Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ Alternative Upload Failed: $e');
      rethrow;
    }
  }

  // THIRD UPLOAD ATTEMPT - Using POST method
  static Future<http.Response> uploadProfilePhotoPost(
    List<int> imageBytes,
    String fileName,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final uri = Uri.parse('$baseUrl${Endpoints.userUploadProfilePhoto}');
    print('📸 POST Upload to: $uri');

    final request =
        http.MultipartRequest('POST', uri); // Using POST instead of PATCH
    request.headers['Authorization'] = 'Bearer $token';

    try {
      final multipartFile = http.MultipartFile.fromBytes(
        'file', // Try 'file' as field name
        imageBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      print('📸 POST Upload Response Status: ${response.statusCode}');
      print('📸 POST Upload Response Body: ${response.body}');

      return response;
    } catch (e) {
      print('❌ POST Upload Failed: $e');
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
      Endpoints.userChangePassword,
      'PATCH',
      headers: headers,
      body: passwordData,
    );
  }

  // Get services
  static Future<http.Response> getServices() async {
    return makeRequest(Endpoints.services, 'GET');
  }

  // Create booking
  static Future<http.Response> createBooking(
    Map<String, dynamic> bookingData,
  ) async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest(
      Endpoints.bookings,
      'POST',
      headers: headers,
      body: bookingData,
    );
  }

  // Get user bookings
  static Future<http.Response> getUserBookings() async {
    final token = await AuthService.getToken();
    if (token == null) {
      throw Exception('No authentication token found');
    }

    final headers = {'Authorization': 'Bearer $token'};
    return makeRequest(Endpoints.userBookings, 'GET', headers: headers);
  }
}
