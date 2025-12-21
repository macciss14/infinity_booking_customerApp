// lib/services/booking_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/booking_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class BookingService {
  final SecureStorage _secureStorage = SecureStorage();

  // ✅ Create a new booking - VALIDATES providerId and converts date to ISO
  Future<BookingModel> createBooking({
    required String serviceId,
    required String providerId,
    required String bookingDate, // Format: DD/MM/YYYY (from UI)
    required String startTime,
    required String endTime,
    required double totalAmount,
    String? paymentMethod,
    String? notes,
    String? bookingReference,
    bool skipPayment = false,
  }) async {
    // 🔥 CRITICAL: Validate providerId before sending
    if (providerId.isEmpty) {
      throw Exception('[providerId should not be empty]');
    }
    
    // 🔥 Ensure providerId is a real PID (PROV-xxx) like Vue.js
    if (!providerId.startsWith('PROV-')) {
      print('⚠️ Warning: providerId "$providerId" doesn\'t start with PROV-. This may cause 400 errors.');
    }

    // 🔥 CRITICAL FIX: Convert DD/MM/YYYY → YYYY-MM-DD for backend
    final isoBookingDate = _convertToIsoDate(bookingDate);

    final body = {
      'serviceId': serviceId,
      'providerId': providerId, // ✅ Real PID like "PROV-123"
      'bookingDate': isoBookingDate, // ✅ Now in ISO format
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'paymentMethod': paymentMethod,
      'notes': notes,
      'bookingReference': bookingReference,
      'skipPayment': skipPayment,
      'status': skipPayment ? 'pending_payment' : 'confirmed',
    };

    print('📋 Creating booking with providerId: $providerId');
    print('📋 Booking body: $body');

    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.createBookingEndpoint);
      print('🔗 Booking URL: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(body),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('✅ Booking created successfully');
        return BookingModel.fromJson(data);
      }

      // Parse error message like Vue.js
      String errorMsg = 'Failed to create booking (${response.statusCode})';
      try {
        final errorJson = jsonDecode(response.body);
        errorMsg = errorJson['message'] ?? errorJson['error'] ?? errorMsg;
      } catch (_) {}
      throw Exception(errorMsg);
    } catch (error) {
      print('❌ Error creating booking: $error');
      rethrow;
    }
  }

  // ✅ Get user bookings
  Future<List<BookingModel>> getUserBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final params = {
        'page': page.toString(),
        'limit': limit.toString(),
        if (status != null) 'status': status,
      };

      String url = AppConstants.userBookingsEndpoint;
      if (params.isNotEmpty) {
        url = '$url?${Uri(queryParameters: params).query}';
      }

      final fullUrl = AppConstants.buildUrl(url);
      final response = await http.get(
        Uri.parse(fullUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bookings = data['bookings'] ?? data['data'] ?? data;
        return bookings.map((json) => BookingModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch bookings (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching bookings: $error');
      rethrow;
    }
  }

  // ✅ Get booking by ID
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        AppConstants.bookingDetailEndpoint,
        id: bookingId,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to fetch booking (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching booking: $error');
      rethrow;
    }
  }

  // ✅ Cancel booking
  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        AppConstants.cancelBookingEndpoint,
        id: bookingId,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to cancel booking (${response.statusCode})');
    } catch (error) {
      print('❌ Error cancelling booking: $error');
      rethrow;
    }
  }

  // ✅ Update booking status
  Future<BookingModel> updateBookingStatus(String bookingId, {required String status}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        AppConstants.updateBookingStatusEndpoint,
        id: bookingId,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'status': status}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to update booking status (${response.statusCode})');
    } catch (error) {
      print('❌ Error updating booking status: $error');
      rethrow;
    }
  }

  // ✅ Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.bookingStatisticsEndpoint);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to fetch booking statistics (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching booking statistics: $error');
      rethrow;
    }
  }

  // ✅ Check slot availability
  Future<bool> checkSlotAvailability({
    required String serviceId,
    required String providerId,
    required String bookingDate, // Format: DD/MM/YYYY (from UI)
    required String startTime,
    required String endTime,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      // 🔥 Convert to ISO for backend
      final isoBookingDate = _convertToIsoDate(bookingDate);

      final url = AppConstants.buildUrl(AppConstants.checkSlotAvailabilityEndpoint);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'serviceId': serviceId,
          'providerId': providerId,
          'bookingDate': isoBookingDate, // ✅ ISO format
          'startTime': startTime,
          'endTime': endTime,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['available'] == true;
      }
      return false;
    } catch (error) {
      print('❌ Error checking slot availability: $error');
      return false;
    }
  }

  // ✅ Process payment
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required String paymentMethod,
    required double amount,
    String? paymentReference,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.processPaymentEndpoint);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'paymentMethod': paymentMethod,
          'amount': amount,
          'paymentReference': paymentReference,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to process payment (${response.statusCode})');
    } catch (error) {
      print('❌ Error processing payment: $error');
      rethrow;
    }
  }

  // ✅ Verify payment
  Future<Map<String, dynamic>> verifyPayment({required String paymentReference}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        AppConstants.verifyPaymentEndpoint,
        reference: paymentReference,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      throw Exception('Failed to verify payment (${response.statusCode})');
    } catch (error) {
      print('❌ Error verifying payment: $error');
      rethrow;
    }
  }

  // ✅ Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.paymentMethodsEndpoint);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data['data'] is List) {
          return List<Map<String, dynamic>>.from(data['data']);
        }
      }
      return _getFallbackPaymentMethods();
    } catch (error) {
      print('❌ Error fetching payment methods: $error');
      return _getFallbackPaymentMethods();
    }
  }

  List<Map<String, dynamic>> _getFallbackPaymentMethods() {
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

  // ✅ Reschedule booking
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required String newDate, // Format: DD/MM/YYYY (from UI)
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      // 🔥 Convert to ISO for backend
      final isoNewDate = _convertToIsoDate(newDate);

      final endpoint = AppConstants.replacePathParams(
        AppConstants.rescheduleBookingEndpoint,
        id: bookingId,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'newDate': isoNewDate, // ✅ ISO format
          'newStartTime': newStartTime,
          'newEndTime': newEndTime,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to reschedule booking (${response.statusCode})');
    } catch (error) {
      print('❌ Error rescheduling booking: $error');
      rethrow;
    }
  }

  // ✅ Get upcoming bookings
  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.upcomingBookingsEndpoint);
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> bookings = data['bookings'] ?? data['data'] ?? data;
        return bookings.map((json) => BookingModel.fromJson(json)).toList();
      }
      throw Exception('Failed to fetch upcoming bookings (${response.statusCode})');
    } catch (error) {
      print('❌ Error fetching upcoming bookings: $error');
      rethrow;
    }
  }

  // ✅ Complete booking
  Future<BookingModel> completeBooking(String bookingId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/bookings/{id}/complete',
        id: bookingId,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({}),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to complete booking (${response.statusCode})');
    } catch (error) {
      print('❌ Error completing booking: $error');
      rethrow;
    }
  }

  // ✅ Rate booking
  Future<BookingModel> rateBooking({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        'infinity-booking/bookings/{id}/rate',
        id: bookingId,
      );
      final url = AppConstants.buildUrl(endpoint);

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'rating': rating,
          'review': review,
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to rate booking (${response.statusCode})');
    } catch (error) {
      print('❌ Error rating booking: $error');
      rethrow;
    }
  }

  // 🔥 HELPER: Convert DD/MM/YYYY → YYYY-MM-DD
  String _convertToIsoDate(String ddMmYyyy) {
    final parts = ddMmYyyy.split('/');
    if (parts.length == 3) {
      final day = parts[0].padLeft(2, '0');
      final month = parts[1].padLeft(2, '0');
      final year = parts[2];
      return '$year-$month-$day';
    }
    throw FormatException('Invalid date format. Expected DD/MM/YYYY, got: $ddMmYyyy');
  }
}