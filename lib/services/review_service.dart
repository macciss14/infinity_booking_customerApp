import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ReviewService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();

  // ==================== PRIVATE HELPER METHODS ====================

  Future<String> _getToken() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please log in again.');
    }
    return token;
  }

  // ==================== PUBLIC METHODS ====================

  // CREATE REVIEW - Main method
  Future<ReviewModel> createReview({
    required String serviceId,
    required String bookingId, // This should be the bookingId from backend (not MongoDB _id)
    required double rating,
    required String comment,
  }) async {
    try {
      print('📝 Creating review for service: $serviceId');
      print('📝 Using bookingId: $bookingId');
      
      final token = await _getToken();
      
      final url = AppConstants.buildUrl(AppConstants.createReviewEndpoint);
      
      final body = {
        'serviceId': serviceId,
        'bookingId': bookingId, // This is the bookingId string field from backend
        'rating': rating,
        'comment': comment,
      };

      print('🔗 URL: $url');
      print('📦 Request Body: $body');

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      print('📡 Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Review created successfully');
        return ReviewModel.fromJson(data);
      }

      // Handle specific error cases (from your backend)
      if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? errorData['error'] ?? 'Bad request';
          
          if (message.contains('completed bookings')) {
            throw Exception('You can only review completed bookings.');
          }
          throw Exception(message);
        } catch (_) {
          throw Exception('Invalid request. Please check your booking.');
        }
      }

      if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }

      if (response.statusCode == 403) {
        throw Exception('You can only review your own bookings.');
      }

      if (response.statusCode == 404) {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? errorData['error'] ?? 'Booking not found';
          throw Exception(message);
        } catch (_) {
          throw Exception('Booking not found with ID: $bookingId');
        }
      }

      if (response.statusCode == 409) {
        throw Exception('You have already reviewed this service.');
      }

      if (response.statusCode == 500) {
        print('❌ Server error creating review');
        throw Exception('Server error. Please try again later.');
      }

      // General error
      String errorMessage = 'Failed to create review (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
      } catch (_) {}

      throw Exception(errorMessage);
    } catch (error) {
      print('❌ Error creating review: $error');
      rethrow;
    }
  }

  // GET SERVICE REVIEWS
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    try {
      final token = await _getToken();
      
      final endpoint = AppConstants.serviceReviewsEndpoint.replaceAll('{serviceId}', serviceId);
      final url = AppConstants.buildUrl(endpoint);

      print('🔍 Fetching reviews for service: $serviceId');
      print('🔗 URL: $url');

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reviewsData = [];

        if (data is Map) {
          reviewsData = data['reviews'] ?? data['data'] ?? data['items'] ?? [];
        } else if (data is List) {
          reviewsData = data;
        }

        final reviews = reviewsData
            .map((json) => ReviewModel.fromJson(json))
            .where((review) => review.isPublished)
            .toList();
        
        print('✅ Successfully fetched ${reviews.length} reviews');
        return reviews;
      }

      print('⚠️ No reviews found (${response.statusCode})');
      return [];
    } catch (error) {
      print('❌ Error fetching service reviews: $error');
      return [];
    }
  }

  // GET USER'S REVIEWS
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final token = await _getToken();
      
      final url = AppConstants.buildUrl(AppConstants.userReviewsEndpoint);

      print('🔍 Fetching user reviews');
      print('🔗 URL: $url');

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reviewsData = [];

        if (data is Map) {
          reviewsData = data['reviews'] ?? data['data'] ?? data['items'] ?? [];
        } else if (data is List) {
          reviewsData = data;
        }

        final reviews = reviewsData.map((json) => ReviewModel.fromJson(json)).toList();
        print('✅ Successfully fetched ${reviews.length} user reviews');
        return reviews;
      }

      print('⚠️ No user reviews found (${response.statusCode})');
      return [];
    } catch (error) {
      print('❌ Error fetching user reviews: $error');
      return [];
    }
  }

  // GET REVIEW BY ID
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final token = await _getToken();
      
      final endpoint = AppConstants.reviewDetailEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      print('🔍 Fetching review: $reviewId');
      print('🔗 URL: $url');

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewModel.fromJson(data);
      }

      throw Exception('Failed to fetch review (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching review: $error');
      rethrow;
    }
  }

  // UPDATE REVIEW
  Future<ReviewModel> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
    bool? isVerified,
  }) async {
    try {
      final token = await _getToken();
      
      final endpoint = AppConstants.updateReviewEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final body = {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
        if (isVerified != null) 'isVerified': isVerified,
      };

      print('✏️ Updating review: $reviewId');
      print('🔗 URL: $url');

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewModel.fromJson(data);
      }

      throw Exception('Failed to update review (${response.statusCode})');
    } catch (error) {
      print('❌ Error updating review: $error');
      rethrow;
    }
  }

  // DELETE REVIEW
  Future<void> deleteReview(String reviewId) async {
    try {
      final token = await _getToken();
      
      final endpoint = AppConstants.deleteReviewEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      print('🗑️ Deleting review: $reviewId');
      print('🔗 URL: $url');

      final response = await _httpClient.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete review (${response.statusCode})');
      }
      
      print('✅ Review deleted successfully');
    } catch (error) {
      print('❌ Error deleting review: $error');
      rethrow;
    }
  }

  // Clean up
  void dispose() {
    _httpClient.close();
    print('♻️ ReviewService disposed');
  }
}