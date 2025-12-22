// lib/services/review_service.dart
import '../models/review_model.dart';
import './api_service.dart';
import '../utils/constants.dart'; // ✅ For proper URL handling

class ReviewService {
  final ApiService _apiService = ApiService();

  // ✅ Get reviews for a service - ENHANCED ERROR HANDLING
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    try {
      // Use AppConstants.buildUrl for consistency
      final endpoint = AppConstants.replacePathParams(
        AppConstants.serviceReviewsEndpoint,
        serviceId: serviceId,
      );

      final response = await _apiService.get(endpoint);

      if (response is List) {
        return response.map((json) => ReviewModel.fromJson(json)).toList();
      } else if (response['reviews'] is List) {
        return (response['reviews'] as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
      } else if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching reviews for service $serviceId: $error');
      return [];
    }
  }

  // ✅ Create a new review - CORRECTED FOR PROVIDER RESPONSE
  Future<ReviewModel> createReview({
    required String serviceId,
    required double rating,
    required String comment,
    String? responseText, // This is for provider responses, not user reviews
  }) async {
    try {
      final body = {
        'serviceId': serviceId,
        'rating': rating,
        'comment': comment,
        // Note: responseText should typically be null for user reviews
        // Provider responses are usually handled separately via admin API
        if (responseText != null) 'response': responseText,
      };

      final response = await _apiService.post(
        AppConstants.reviewsEndpoint, // ✅ Use constant
        body: body,
      );

      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error creating review: $error');
      rethrow;
    }
  }

  // ✅ Add provider response to existing review (NEW METHOD)
  Future<ReviewModel> addProviderResponse({
    required String reviewId,
    required String responseText,
  }) async {
    try {
      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/reviews/{id}/response',
        id: reviewId,
      );

      final response = await _apiService.post(
        endpoint,
        body: {'response': responseText},
      );

      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error adding provider response: $error');
      rethrow;
    }
  }

  // ✅ Update a review
  Future<ReviewModel> updateReview({
    required String reviewId,
    double? rating,
    String? comment,
    String? responseText,
  }) async {
    try {
      final body = {
        if (rating != null) 'rating': rating,
        if (comment != null) 'comment': comment,
        if (responseText != null) 'response': responseText,
      };

      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/reviews/{id}',
        id: reviewId,
      );

      final response = await _apiService.put(
        endpoint,
        body: body,
      );

      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error updating review: $error');
      rethrow;
    }
  }

  // ✅ Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/reviews/{id}',
        id: reviewId,
      );

      await _apiService.delete(endpoint);
    } catch (error) {
      print('Error deleting review: $error');
      rethrow;
    }
  }

  // ✅ Mark review as helpful
  Future<void> markHelpful(String reviewId) async {
    try {
      final endpoint = AppConstants.replacePathParams(
        AppConstants.reviewHelpfulEndpoint,
        id: reviewId,
      );

      await _apiService.post(
        endpoint,
        body: {},
      );
    } catch (error) {
      print('Error marking review as helpful: $error');
      rethrow;
    }
  }

  // ✅ Get review statistics
  Future<Map<String, dynamic>> getReviewStatistics(String serviceId) async {
    try {
      final endpoint = AppConstants.replacePathParams(
        AppConstants.reviewStatisticsEndpoint,
        serviceId: serviceId,
      );

      final response = await _apiService.get(endpoint);
      return response;
    } catch (error) {
      print('Error fetching review statistics: $error');
      return {
        'averageRating': 0.0,
        'totalReviews': 0,
        'ratingDistribution': [],
      };
    }
  }

  // ✅ Get user's reviews
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final response = await _apiService.get(AppConstants.userReviewsEndpoint);

      if (response is List) {
        return response.map((json) => ReviewModel.fromJson(json)).toList();
      } else if (response['reviews'] is List) {
        return (response['reviews'] as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
      } else if (response['data'] is List) {
        return (response['data'] as List)
            .map((json) => ReviewModel.fromJson(json))
            .toList();
      } else {
        return [];
      }
    } catch (error) {
      print('Error fetching user reviews: $error');
      return [];
    }
  }

  // ✅ Get single review by ID
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/reviews/{id}',
        id: reviewId,
      );

      final response = await _apiService.get(endpoint);
      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error fetching review: $error');
      rethrow;
    }
  }

  // ✅ Report a review
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/reviews/{id}/report',
        id: reviewId,
      );

      await _apiService.post(
        endpoint,
        body: {'reason': reason},
      );
    } catch (error) {
      print('Error reporting review: $error');
      rethrow;
    }
  }
}
