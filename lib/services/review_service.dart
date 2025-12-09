import 'dart:convert';
import '../models/review_model.dart';
import './api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  // Get reviews for a service
  Future<List<ReviewModel>> getServiceReviews(String serviceId) async {
    try {
      final response = await _apiService.get('reviews/service/$serviceId');

      // Response is already parsed by ApiService._handleResponse()
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
      print('Error fetching reviews: $error');
      return [];
    }
  }

  // Create a new review
  Future<ReviewModel> createReview({
    required String serviceId,
    required double rating,
    required String comment,
    String? responseText,
  }) async {
    try {
      final response = await _apiService.post(
        'reviews',
        body: {
          'serviceId': serviceId,
          'rating': rating,
          'comment': comment,
          if (responseText != null) 'response': responseText,
        },
      );

      // Response is already parsed by ApiService._handleResponse()
      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error creating review: $error');
      rethrow;
    }
  }

  // Update a review
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

      final response = await _apiService.put(
        'reviews/$reviewId',
        body: body,
      );

      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error updating review: $error');
      rethrow;
    }
  }

  // Delete a review
  Future<void> deleteReview(String reviewId) async {
    try {
      await _apiService.delete('reviews/$reviewId');
    } catch (error) {
      print('Error deleting review: $error');
      rethrow;
    }
  }

  // Mark review as helpful
  Future<void> markHelpful(String reviewId) async {
    try {
      await _apiService.post(
        'reviews/$reviewId/helpful',
        body: {},
      );
    } catch (error) {
      print('Error marking review as helpful: $error');
      rethrow;
    }
  }

  // Get review statistics
  Future<Map<String, dynamic>> getReviewStatistics(String serviceId) async {
    try {
      final response = await _apiService.get('reviews/statistics/$serviceId');
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

  // Get user's reviews
  Future<List<ReviewModel>> getUserReviews() async {
    try {
      final response = await _apiService.get('reviews/user');

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

  // Get single review by ID
  Future<ReviewModel> getReviewById(String reviewId) async {
    try {
      final response = await _apiService.get('reviews/$reviewId');
      return ReviewModel.fromJson(response);
    } catch (error) {
      print('Error fetching review: $error');
      rethrow;
    }
  }

  // Report a review
  Future<void> reportReview(String reviewId, String reason) async {
    try {
      await _apiService.post(
        'reviews/$reviewId/report',
        body: {'reason': reason},
      );
    } catch (error) {
      print('Error reporting review: $error');
      rethrow;
    }
  }
}
