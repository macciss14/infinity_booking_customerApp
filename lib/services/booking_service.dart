// lib/services/booking_service.dart - UPDATED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/booking_model.dart';
import '../utils/secure_storage.dart';

class BookingService {
  final SecureStorage _secureStorage = SecureStorage();

  // Get user's bookings
  Future<List<BookingModel>> getUserBookings() async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.userBookingsEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((json) => BookingModel.fromJson(json)).toList();
    } else {
      throw Exception(
          'Failed to load bookings: ${response.statusCode} ${response.body}');
    }
  }

  // Create a booking
  Future<BookingModel> createBooking(Map<String, dynamic> bookingData) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.createBookingEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(bookingData),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return BookingModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to create booking: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ ADD THIS METHOD: Cancel a booking
  Future<void> cancelBooking(String bookingId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = AppConstants.apiBaseUrl +
        AppConstants.replacePathParams(
          AppConstants.bookingDetailEndpoint,
          id: bookingId,
        );

    final response = await http.patch(
      Uri.parse('$url/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(
          'Failed to cancel booking: ${response.statusCode} ${response.body}');
    }
  }

  // ✅ Optional: Get booking by ID
  Future<BookingModel> getBookingById(String bookingId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final url = AppConstants.apiBaseUrl +
        AppConstants.replacePathParams(
          AppConstants.bookingDetailEndpoint,
          id: bookingId,
        );

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return BookingModel.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Failed to get booking: ${response.statusCode} ${response.body}');
    }
  }
}
