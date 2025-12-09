import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../services/api_service.dart';
import '../utils/secure_storage.dart';

class BookingService {
  final ApiService _apiService = ApiService();
  final SecureStorage _secureStorage = SecureStorage();

  // Create a new booking
  Future<BookingModel> createBooking({
    required String serviceId,
    required String providerId,
    required String bookingDate, // Format: DD/MM/YYYY
    required String startTime,
    required String endTime,
    required double totalAmount,
    String? paymentMethod,
    String? notes,
    String? bookingReference,
    bool skipPayment = false,
  }) async {
    try {
      final response = await _apiService.post(
        'bookings',
        body: {
          'serviceId': serviceId,
          'providerId': providerId,
          'bookingDate': bookingDate,
          'startTime': startTime,
          'endTime': endTime,
          'totalAmount': totalAmount,
          'paymentMethod': paymentMethod,
          'notes': notes,
          'bookingReference': bookingReference,
          'skipPayment': skipPayment,
          'status': skipPayment ? 'pending_payment' : 'confirmed',
        },
      );

      // Response is already parsed by ApiService._handleResponse()
      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error creating booking: $error');
      rethrow;
    }
  }

  // Get user bookings
  Future<List<BookingModel>> getUserBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      final response = await _apiService.get(
        'bookings/user',
        params: params,
      );

      // Response is already parsed by ApiService._handleResponse()
      final List<dynamic> bookings =
          response['bookings'] ?? response['data'] ?? [];
      return bookings.map((json) => BookingModel.fromJson(json)).toList();
    } catch (error) {
      print('Error fetching bookings: $error');
      rethrow;
    }
  }

  // Get booking by ID
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final response = await _apiService.get('bookings/$bookingId');
      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error fetching booking: $error');
      rethrow;
    }
  }

  // Cancel booking
  Future<BookingModel> cancelBooking(
    String bookingId, {
    String? reason,
  }) async {
    try {
      final response = await _apiService.put(
        'bookings/$bookingId/cancel',
        body: {'reason': reason},
      );

      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error cancelling booking: $error');
      rethrow;
    }
  }

  // Update booking status
  Future<BookingModel> updateBookingStatus(
    String bookingId, {
    required String status,
  }) async {
    try {
      final response = await _apiService.put(
        'bookings/$bookingId/status',
        body: {'status': status},
      );

      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error updating booking status: $error');
      rethrow;
    }
  }

  // Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final response = await _apiService.get('bookings/statistics');
      return response;
    } catch (error) {
      print('Error fetching booking statistics: $error');
      rethrow;
    }
  }

  // Check slot availability
  Future<bool> checkSlotAvailability({
    required String serviceId,
    required String providerId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final response = await _apiService.post(
        'bookings/check-availability',
        body: {
          'serviceId': serviceId,
          'providerId': providerId,
          'bookingDate': bookingDate,
          'startTime': startTime,
          'endTime': endTime,
        },
      );

      return response['available'] == true;
    } catch (error) {
      print('Error checking slot availability: $error');
      rethrow;
    }
  }

  // Process payment for booking
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required String paymentMethod,
    required double amount,
    String? paymentReference,
  }) async {
    try {
      final response = await _apiService.post(
        'payments/process',
        body: {
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'paymentReference': paymentReference,
        },
      );

      return response;
    } catch (error) {
      print('Error processing payment: $error');
      rethrow;
    }
  }

  // Verify payment
  Future<Map<String, dynamic>> verifyPayment({
    required String paymentReference,
  }) async {
    try {
      final response =
          await _apiService.get('payments/verify/$paymentReference');
      return response;
    } catch (error) {
      print('Error verifying payment: $error');
      rethrow;
    }
  }

  // Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final response = await _apiService.get('payments/methods');

      if (response is List) {
        return List<Map<String, dynamic>>.from(response);
      } else if (response['data'] is List) {
        return List<Map<String, dynamic>>.from(response['data']);
      } else {
        return [
          {
            'id': 'telebirr',
            'name': 'Telebirr',
            'description': 'Mobile money payment',
            'icon': '📱',
            'currency': 'ETB'
          },
          {
            'id': 'chapa',
            'name': 'Chapa',
            'description': 'Card & mobile payment',
            'icon': '💳',
            'currency': 'ETB'
          },
          {
            'id': 'cash',
            'name': 'Cash',
            'description': 'Pay in person',
            'icon': '💰',
            'currency': 'ETB'
          }
        ];
      }
    } catch (error) {
      print('Error fetching payment methods: $error');
      return [
        {
          'id': 'telebirr',
          'name': 'Telebirr',
          'description': 'Mobile money payment',
          'icon': '📱',
          'currency': 'ETB'
        },
        {
          'id': 'chapa',
          'name': 'Chapa',
          'description': 'Card & mobile payment',
          'icon': '💳',
          'currency': 'ETB'
        },
        {
          'id': 'cash',
          'name': 'Cash',
          'description': 'Pay in person',
          'icon': '💰',
          'currency': 'ETB'
        }
      ];
    }
  }

  // Reschedule booking
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required String newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      final response = await _apiService.put(
        'bookings/$bookingId/reschedule',
        body: {
          'newDate': newDate,
          'newStartTime': newStartTime,
          'newEndTime': newEndTime,
        },
      );

      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error rescheduling booking: $error');
      rethrow;
    }
  }

  // Get upcoming bookings
  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final response = await _apiService.get('bookings/upcoming');

      final List<dynamic> bookings =
          response['bookings'] ?? response['data'] ?? [];
      return bookings.map((json) => BookingModel.fromJson(json)).toList();
    } catch (error) {
      print('Error fetching upcoming bookings: $error');
      rethrow;
    }
  }

  // Add a new method: Complete booking (mark as completed)
  Future<BookingModel> completeBooking(String bookingId) async {
    try {
      final response = await _apiService.put(
        'bookings/$bookingId/complete',
        body: {},
      );

      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error completing booking: $error');
      rethrow;
    }
  }

  // Add a new method: Rate booking
  Future<BookingModel> rateBooking({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    try {
      final response = await _apiService.post(
        'bookings/$bookingId/rate',
        body: {
          'rating': rating,
          'review': review,
        },
      );

      return BookingModel.fromJson(response);
    } catch (error) {
      print('Error rating booking: $error');
      rethrow;
    }
  }
}
