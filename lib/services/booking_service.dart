import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class BookingService {
  static Future<Booking> createBooking({
    required String serviceId,
    required DateTime bookingDate,
    required String timeSlot,
    required double totalAmount,
    String? customerNotes,
  }) async {
    try {
      print('🔄 BookingService - Creating booking...');

      final bookingData = {
        'serviceId': serviceId,
        'bookingDate':
            bookingDate.toIso8601String().split('T')[0], // YYYY-MM-DD
        'timeSlot': timeSlot,
        'totalAmount': totalAmount,
        if (customerNotes != null && customerNotes.isNotEmpty)
          'customerNotes': customerNotes,
      };

      print('📤 Booking data: $bookingData');

      final response = await ApiService.makeRequest(
        Endpoints.bookings,
        'POST',
        body: bookingData,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ BookingService - Booking created successfully');
        return Booking.fromJson(data);
      } else {
        print(
            '❌ BookingService - Failed to create booking: ${response.statusCode}');
        throw Exception('Failed to create booking: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 BookingService - Error creating booking: $e');
      rethrow;
    }
  }

  static Future<List<Booking>> getUserBookings() async {
    try {
      print('🔄 BookingService - Fetching user bookings...');
      final response = await ApiService.makeRequest(
        Endpoints.userBookings,
        'GET',
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> bookingsJson =
            data is List ? data : data['bookings'] ?? data['data'] ?? [];

        final bookings =
            bookingsJson.map((json) => Booking.fromJson(json)).toList();
        print('✅ BookingService - Found ${bookings.length} bookings');
        return bookings;
      } else {
        print(
            '❌ BookingService - Failed to fetch bookings: ${response.statusCode}');
        throw Exception('Failed to load bookings: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 BookingService - Error fetching bookings: $e');
      rethrow;
    }
  }

  static Future<Booking> getBookingById(String id) async {
    try {
      final endpoint = Endpoints.buildPath(Endpoints.bookingById, {'id': id});
      final response = await ApiService.makeRequest(endpoint, 'GET');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to load booking: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 BookingService - Error fetching booking $id: $e');
      rethrow;
    }
  }

  static Future<Booking> cancelBooking(String bookingId, String reason) async {
    try {
      final endpoint =
          Endpoints.buildPath(Endpoints.bookingById, {'id': bookingId});
      final response = await ApiService.makeRequest(
        endpoint,
        'PATCH',
        body: {
          'status': 'cancelled',
          'cancellationReason': reason,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('✅ BookingService - Booking cancelled successfully');
        return Booking.fromJson(data);
      } else {
        throw Exception('Failed to cancel booking: ${response.statusCode}');
      }
    } catch (e) {
      print('💥 BookingService - Error cancelling booking: $e');
      rethrow;
    }
  }

  static Future<List<Booking>> getPendingBookings() async {
    try {
      final bookings = await getUserBookings();
      return bookings.where((booking) => booking.isPending).toList();
    } catch (e) {
      print('💥 BookingService - Error fetching pending bookings: $e');
      rethrow;
    }
  }

  static Future<List<Booking>> getConfirmedBookings() async {
    try {
      final bookings = await getUserBookings();
      return bookings.where((booking) => booking.isConfirmed).toList();
    } catch (e) {
      print('💥 BookingService - Error fetching confirmed bookings: $e');
      rethrow;
    }
  }

  static Future<List<Booking>> getCompletedBookings() async {
    try {
      final bookings = await getUserBookings();
      return bookings.where((booking) => booking.isCompleted).toList();
    } catch (e) {
      print('💥 BookingService - Error fetching completed bookings: $e');
      rethrow;
    }
  }
}
