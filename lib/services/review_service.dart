// lib/services/review_service.dart - COMPLETE FIXED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/review_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';
import '../services/booking_service.dart';

class ReviewService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();
  final BookingService _bookingService = BookingService();

  // ==================== PRIVATE HELPER METHODS ====================

  Future<String> _getToken() async {
    final token = await _secureStorage.getToken();
    if (token == null || token.isEmpty) {
      throw Exception('Not authenticated. Please log in again.');
    }
    return token;
  }

  // Get user's booking ID for a specific service
  Future<String?> _getUserBookingIdForService(String serviceId) async {
    try {
      print('🔍 Looking for user booking for service: $serviceId');
      final bookings = await _bookingService.getUserBookings();
      
      if (bookings.isEmpty) {
        print('📭 No bookings found for user');
        return null;
      }

      // Find completed/approved bookings for this service
      final validBookings = bookings.where((booking) {
        final isSameService = booking.serviceId == serviceId;
        final isValidStatus = booking.status == 'completed' || 
                            booking.status == 'approved' ||
                            booking.status == 'delivered' ||
                            booking.status == 'fulfilled';
        
        if (isSameService && isValidStatus) {
          print('✅ Found valid booking: ${booking.id} (status: ${booking.status})');
          return true;
        }
        return false;
      }).toList();
      
      if (validBookings.isNotEmpty) {
        // Use the most recent booking
        validBookings.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final bookingId = validBookings.first.id;
        print('📋 Selected booking ID: $bookingId');
        return bookingId;
      }
      
      print('⚠️ No valid booking found for service: $serviceId');
      print('📊 Available bookings:');
      for (var booking in bookings) {
        print('   - ID: ${booking.id}, Service: ${booking.serviceId}, Status: ${booking.status}');
      }
      return null;
    } catch (error) {
      print('❌ Error finding booking for service: $error');
      return null;
    }
  }

  // ==================== PUBLIC METHODS ====================

  // CHECK IF USER CAN REVIEW A SERVICE
  Future<bool> canReviewService(String serviceId) async {
    try {
      print('🔍 Checking if user can review service: $serviceId');
      
      // First, check if user has a valid booking
      final bookingId = await _getUserBookingIdForService(serviceId);
      if (bookingId == null) {
        print('❌ No valid booking found - cannot review');
        return false;
      }
      
      // Then check with backend API
      final token = await _getToken();
      
      final endpoint = 'infinity-booking/reviews/can-review/{serviceId}'
          .replaceAll('{serviceId}', serviceId);
      final url = AppConstants.buildUrl(endpoint);

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
        final canReview = data['canReview'] == true;
        print('✅ Can review check: $canReview');
        return canReview;
      } else if (response.statusCode == 404) {
        print('⚠️ Service or user not found');
        return false;
      } else {
        print('⚠️ Unexpected response: ${response.statusCode}');
        // If API check fails, we'll still allow based on local booking check
        return true;
      }
    } catch (error) {
      print('⚠️ Error checking review eligibility: $error');
      // If there's an error, fall back to local booking check
      final bookingId = await _getUserBookingIdForService(serviceId);
      return bookingId != null;
    }
  }

  // GET SERVICE REVIEWS
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    try {
      final token = await _getToken();
      
      const String baseEndpoint = 'infinity-booking/reviews/service/{serviceId}';
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
              print('📋 Found ${reviewsData.length} reviews in "${entries.first.key}" field');
            }
          }
        } else if (data is List) {
          reviewsData = data;
          print('📋 Found ${reviewsData.length} reviews (direct list)');
        }

        final reviews = reviewsData
            .map((json) => ReviewModel.fromJson(json))
            .where((review) => review.isPublished) // Only show published reviews
            .toList();
        
        print('✅ Successfully parsed ${reviews.length} reviews');
        return reviews;
      }

      throw Exception('Failed to fetch reviews (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching service reviews: $error');
      rethrow;
    }
  }

  // CREATE REVIEW (FIXED - Automatically includes bookingId)
  Future<ReviewModel> createReview({
    required String serviceId,
    required double rating,
    required String comment,
  }) async {
    try {
      print('📝 Creating review for service: $serviceId');
      
      // 1. Get authentication token
      final token = await _getToken();
      
      // 2. Get the booking ID for this service
      final bookingId = await _getUserBookingIdForService(serviceId);
      if (bookingId == null) {
        throw Exception('You need to book and complete this service before writing a review.');
      }
      
      // 3. Prepare request body WITH bookingId
      const String endpoint = 'infinity-booking/reviews';
      final url = AppConstants.buildUrl(endpoint);
      
      final body = {
        'serviceId': serviceId,
        'bookingId': bookingId, // This is MANDATORY
        'rating': rating,
        'comment': comment,
      };

      print('🔗 URL: $url');
      print('📦 Body: $body');

      // 4. Make the API request
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

      // 5. Handle response
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Review created successfully');
        return ReviewModel.fromJson(data);
      }

      // Handle specific error cases
      if (response.statusCode == 400) {
        try {
          final errorData = jsonDecode(response.body);
          final message = errorData['message'] ?? errorData['error'] ?? 'Failed to create review';
          
          if (message.contains('bookingId') || message.contains('booking')) {
            throw Exception('You need to book this service first before writing a review.');
          }
          
          throw Exception(message);
        } catch (e) {
          throw Exception('Failed to create review. Please make sure you have booked this service.');
        }
      }

      if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      }

      if (response.statusCode == 403) {
        throw Exception('You are not allowed to review this service.');
      }

      if (response.statusCode == 409) {
        throw Exception('You have already reviewed this booking.');
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

  // GET USER'S REVIEWS
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final token = await _getToken();
      
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

        final reviews = reviewsData.map((json) => ReviewModel.fromJson(json)).toList();
        print('✅ Successfully fetched ${reviews.length} user reviews');
        return reviews;
      }

      throw Exception('Failed to fetch user reviews (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching user reviews: $error');
      rethrow;
    }
  }

  // GET REVIEW BY ID
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final token = await _getToken();
      
      const String baseEndpoint = 'infinity-booking/reviews/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
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
  }) async {
    try {
      final token = await _getToken();
      
      const String baseEndpoint = 'infinity-booking/reviews/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final body = {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
      };

      print('✏️ Updating review: $reviewId');
      print('🔗 URL: $url');
      print('📦 Body: $body');

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

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
      
      const String baseEndpoint = 'infinity-booking/reviews/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
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

  // MARK REVIEW AS HELPFUL
  Future<void> markHelpful(String reviewId) async {
    try {
      final token = await _getToken();
      
      const String baseEndpoint = 'infinity-booking/reviews/{id}/helpful';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      print('👍 Marking review as helpful: $reviewId');
      print('🔗 URL: $url');

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to mark helpful (${response.statusCode})');
      }
      
      print('✅ Review marked as helpful');
    } catch (error) {
      print('❌ Error marking review helpful: $error');
      rethrow;
    }
  }

  // REPORT REVIEW
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      final token = await _getToken();
      
      const String baseEndpoint = 'infinity-booking/reviews/{id}/report';
      final endpoint = baseEndpoint.replaceAll('{id}', reviewId);
      final url = AppConstants.buildUrl(endpoint);

      final body = {'reason': reason};

      print('⚠️ Reporting review: $reviewId');
      print('🔗 URL: $url');
      print('📦 Reason: $reason');

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to report review (${response.statusCode})');
      }
      
      print('✅ Review reported successfully');
    } catch (error) {
      print('❌ Error reporting review: $error');
      rethrow;
    }
  }

  // GET REVIEW STATISTICS
  Future<Map<String, dynamic>> getReviewStatistics(String serviceId) async {
    try {
      final token = await _getToken();
      
      const String baseEndpoint = 'infinity-booking/reviews/service/{serviceId}/stats';
      final endpoint = baseEndpoint.replaceAll('{serviceId}', serviceId);
      final url = AppConstants.buildUrl(endpoint);

      print('📊 Fetching review statistics for service: $serviceId');
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
        return data;
      }

      // Return default stats if API fails
      print('⚠️ Using default statistics (API returned ${response.statusCode})');
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

  // GET ALL REVIEWS WITH FILTERS
  Future<List<ReviewModel>> getAllReviews({
    String? status,
    String? serviceId,
    String? providerId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _getToken();
      
      const String endpoint = 'infinity-booking/reviews';
      String url = AppConstants.buildUrl(endpoint);

      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null && status.isNotEmpty) 'status': status,
        if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
        if (providerId != null && providerId.isNotEmpty) 'providerId': providerId,
      };

      final queryString = Uri(queryParameters: params).query;
      if (queryString.isNotEmpty) {
        url = '$url?$queryString';
      }

      print('🔍 Fetching all reviews with filters');
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
        print('✅ Successfully fetched ${reviews.length} reviews');
        return reviews;
      }

      throw Exception('Failed to fetch reviews (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching all reviews: $error');
      rethrow;
    }
  }

  // CHECK IF CAN REVIEW BOOKING
  Future<bool> canReviewBooking(String bookingId) async {
    try {
      final token = await _getToken();
      
      final endpoint = 'infinity-booking/reviews/can-review-booking/{bookingId}'
          .replaceAll('{bookingId}', bookingId);
      final url = AppConstants.buildUrl(endpoint);

      print('🔍 Checking if can review booking: $bookingId');
      print('🔗 URL: $url');

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

  // Clean up
  void dispose() {
    _httpClient.close();
    print('♻️ ReviewService disposed');
  }
}