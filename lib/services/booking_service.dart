// lib/services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../utils/constants.dart';
import '../utils/secure_storage.dart'; // Make sure this import exists

class BookingService {
  // ✅ Create instance of SecureStorage
  final SecureStorage _secureStorage = SecureStorage();

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

  Future<Map<String, dynamic>> getBookingStats(String customerId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.get(
      Uri.parse(
          '${AppConstants.apiBaseUrl}/bookings/stats/customer/$customerId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> createBooking(
      Map<String, dynamic> bookingData) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final cleanData = Map<String, dynamic>.from(bookingData)
      ..remove('customerId');

    final response = await http.post(
      Uri.parse(
          '${AppConstants.apiBaseUrl}${AppConstants.createBookingEndpoint}'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(cleanData),
    );

    if (response.statusCode == 201) {
      return json.decode(response.body);
    } else {
      final error = response.body;
      throw Exception('Booking failed: ${response.statusCode} $error');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final token = await _secureStorage.getToken();
    if (token == null) throw Exception('Not authenticated');

    final response = await http.post(
      Uri.parse('${AppConstants.apiBaseUrl}/bookings/$bookingId/cancel'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to cancel booking: ${response.statusCode}');
    }
  }
}
