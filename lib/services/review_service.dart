// lib/services/review_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class ReviewService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();

  // ==================== GET SERVICE REVIEWS ====================
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint =
          'infinity-booking/reviews/service/{serviceId}';
      final endpoint = baseEndpoint.replaceAll('{serviceId}', serviceId);
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
          if (data['reviews'] is List) {
            reviewsData = data['reviews'];
            print('📋 Found ${reviewsData.length} reviews in "reviews" field');
          } else if (data['data'] is List) {
            reviewsData = data['data'];
            print('📋 Found ${reviewsData.length} reviews in "data" field');
          } else if (data['items'] is List) {
            reviewsData = data['items'];
            print('📋 Found ${reviewsData.length} reviews in "items" field');
          } else {
            // Try direct list
            final entries = data.entries.where((e) => e.value is List).toList();
            if (entries.isNotEmpty) {
              reviewsData = entries.first.value as List<dynamic>;
              print(
                  '📋 Found ${reviewsData.length} reviews in "${entries.first.key}" field');
            }
          }
        } else if (data is List) {
          reviewsData = data;
          print('📋 Found ${reviewsData.length} reviews (direct list)');
        }

        final reviews =
            reviewsData.map((json) => ReviewModel.fromJson(json)).toList();
        print('✅ Successfully parsed ${reviews.length} reviews');
        return reviews;
      }

      throw Exception('Failed to fetch reviews (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching service reviews: $error');
      rethrow;
    }
  }

  // ==================== CREATE REVIEW ====================
  Future<ReviewModel> createReview({
    required String serviceId,
    required double rating,
    required String comment,
    String? bookingId,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String endpoint = 'infinity-booking/reviews';
      final url = AppConstants.buildUrl(endpoint);

      final body = {
        'serviceId': serviceId,
        'rating': rating,
        'comment': comment,
        if (bookingId != null) 'bookingId': bookingId,
      };

      print('📝 Creating review for service: $serviceId');
      print('🔗 URL: $url');
      print('📦 Body: $body');

      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Review created successfully');
        return ReviewModel.fromJson(data);
      }

      String errorMessage = 'Failed to create review (${response.statusCode})';
      try {
        final errorData = jsonDecode(response.body);
        errorMessage =
            errorData['message'] ?? errorData['error'] ?? errorMessage;
      } catch (_) {}

      throw Exception(errorMessage);
    } catch (error) {
      print('❌ Error creating review: $error');
      rethrow;
    }
  }

  // ==================== GET USER REVIEWS ====================
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String endpoint = 'infinity-booking/reviews/my-reviews';
      final url = AppConstants.buildUrl(endpoint);

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

        final reviews =
            reviewsData.map((json) => ReviewModel.fromJson(json)).toList();
        print('✅ Successfully fetched ${reviews.length} user reviews');
        return reviews;
      }

      throw Exception('Failed to fetch user reviews (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching user reviews: $error');
      rethrow;
    }
  }

  // ==================== GET REVIEW BY ID ====================
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/reviews/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

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

  // ==================== UPDATE REVIEW ====================
  Future<ReviewModel> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/reviews/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final body = {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      };

      final response = await _httpClient
          .put(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

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

  // ==================== DELETE REVIEW ====================
  Future<void> deleteReview(String reviewId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/reviews/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.delete(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception('Failed to delete review (${response.statusCode})');
      }
    } catch (error) {
      print('❌ Error deleting review: $error');
      rethrow;
    }
  }

  // ==================== MARK HELPFUL ====================
  Future<void> markHelpful(String reviewId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/reviews/{id}/helpful';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to mark helpful (${response.statusCode})');
      }
    } catch (error) {
      print('❌ Error marking review helpful: $error');
      rethrow;
    }
  }

  // ==================== REPORT REVIEW ====================
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/reviews/{id}/report';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient
          .post(
            Uri.parse(url),
            headers: {
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'reason': reason}),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report review (${response.statusCode})');
      }
    } catch (error) {
      print('❌ Error reporting review: $error');
      rethrow;
    }
  }

  // ==================== GET REVIEW STATISTICS ====================
  Future<Map<String, dynamic>> getReviewStatistics(String serviceId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint =
          'infinity-booking/reviews/service/{serviceId}/stats';
      final endpoint = baseEndpoint.replaceAll('{serviceId}', serviceId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }

      // Return default stats if API fails
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {
          '5': 0,
          '4': 0,
          '3': 0,
          '2': 0,
          '1': 0,
        },
      };
    } catch (error) {
      print('❌ Error fetching review statistics: $error');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': {
          '5': 0,
          '4': 0,
          '3': 0,
          '2': 0,
          '1': 0,
        },
      };
    }
  }

  // ==================== CHECK IF CAN REVIEW ====================
  // Add these methods to review_service.dart if not present:

  Future<bool> canReviewService(String serviceId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return false;

      final endpoint = 'infinity-booking/reviews/can-review/{serviceId}'
          .replaceAll('{serviceId}', serviceId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['canReview'] == true;
      }
      return false;
    } catch (error) {
      print('❌ Error checking service review eligibility: $error');
      return false;
    }
  }

  Future<bool> canReviewBooking(String bookingId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return false;

      final endpoint = 'infinity-booking/reviews/can-review-booking/{bookingId}'
          .replaceAll('{bookingId}', bookingId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['canReview'] == true;
      }
      return false;
    } catch (error) {
      print('❌ Error checking booking review eligibility: $error');
      return false;
    }
  }

  // ==================== GET ALL REVIEWS ====================
  Future<List<ReviewModel>> getAllReviews({
    String? status,
    String? serviceId,
    String? providerId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String endpoint = 'infinity-booking/reviews';
      String url = AppConstants.buildUrl(endpoint);

      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
        if (providerId != null && providerId.isNotEmpty)
          'providerId': providerId,
      };

      final queryString = Uri(queryParameters: params).query;
      if (queryString.isNotEmpty) {
        url = '$url?$queryString';
      }

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> reviewsData = [];

        if (data is Map) {
          reviewsData = data['reviews'] ?? data['data'] ?? data['items'] ?? [];
        } else if (data is List) {
          reviewsData = data;
        }

        return reviewsData.map((json) => ReviewModel.fromJson(json)).toList();
      }

      throw Exception('Failed to fetch reviews (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching all reviews: $error');
      rethrow;
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}
