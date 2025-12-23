// lib/services/booking_service.dart - COMPLETE FIXED VERSION
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../utils/secure_storage.dart';
import '../utils/constants.dart';

class BookingService {
  final SecureStorage _secureStorage = SecureStorage();
  final http.Client _httpClient = http.Client();

  // ==================== GET USER BOOKINGS - FIXED ====================
  Future<List<BookingModel>> getUserBookings({
    String? status,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      print('🚀 Fetching user bookings...');
      
      // Step 1: Get authentication token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('Not authenticated. Please login again.');
      }
      print('✅ Token obtained successfully');

      // Step 2: Get current customer ID
      final customerId = await _getCurrentCustomerIdInCorrectFormat();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Could not determine customer ID. Please login again.');
      }
      print('📝 Customer ID: $customerId');

      // Step 3: Build the correct endpoint URL
      // According to your API: GET /infinity-booking/bookings/customer/{customerId}
      const String baseEndpoint = 'infinity-booking/bookings/customer/{customerId}';
      final endpoint = baseEndpoint.replaceAll('{customerId}', customerId);
      
      // Step 4: Build query parameters
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      // Add status filter if provided and not 'all'
      if (status != null && status.isNotEmpty && status.toLowerCase() != 'all') {
        queryParams['status'] = status.toLowerCase();
      }

      final queryString = Uri(queryParameters: queryParams).query;
      final String url = queryString.isNotEmpty
          ? '${AppConstants.buildUrl(endpoint)}?$queryString'
          : AppConstants.buildUrl(endpoint);

      print('🔗 Request URL: $url');
      print('📊 Query parameters: $queryParams');

      // Step 5: Make the API request
      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      // Step 6: Handle response
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Successfully fetched bookings');
        
        // Handle different response structures
        List<dynamic> bookingsData = [];
        
        if (data is Map) {
          if (data['bookings'] != null && data['bookings'] is List) {
            bookingsData = data['bookings'];
            print('📋 Found ${bookingsData.length} bookings in "bookings" field');
          } else if (data['data'] != null && data['data'] is List) {
            bookingsData = data['data'];
            print('📋 Found ${bookingsData.length} bookings in "data" field');
          } else if (data['items'] != null && data['items'] is List) {
            bookingsData = data['items'];
            print('📋 Found ${bookingsData.length} bookings in "items" field');
          } else {
            // Try to find any array in the response
            final possibleArrays = data.entries
                .where((entry) => entry.value is List)
                .toList();
            
            if (possibleArrays.isNotEmpty) {
              bookingsData = possibleArrays.first.value as List<dynamic>;
              print('📋 Found ${bookingsData.length} bookings in "${possibleArrays.first.key}" field');
            } else {
              print('⚠️ No array found in response, returning empty list');
              return [];
            }
          }
        } else if (data is List) {
          bookingsData = data;
          print('📋 Found ${bookingsData.length} bookings (direct array)');
        } else {
          print('⚠️ Unexpected response format: ${data.runtimeType}');
          return [];
        }

        // Parse bookings
        final List<BookingModel> bookings = [];
        for (var bookingData in bookingsData) {
          try {
            final booking = BookingModel.fromJson(bookingData);
            bookings.add(booking);
          } catch (e) {
            print('⚠️ Error parsing booking: $e');
            print('📋 Raw booking data: $bookingData');
          }
        }

        print('🎉 Successfully parsed ${bookings.length} bookings');
        return bookings;
      } else if (response.statusCode == 404) {
        print('❌ Endpoint not found (404). Trying alternative approach...');
        return await _getUserBookingsAlternative(token, status, page, limit);
      } else {
        String errorMessage = 'Failed to fetch bookings (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('❌ Error in getUserBookings: $error');
      rethrow;
    }
  }

  // Alternative method if customer endpoint doesn't work
  Future<List<BookingModel>> _getUserBookingsAlternative(
    String token,
    String? status,
    int page,
    int limit
  ) async {
    try {
      print('🔄 Trying alternative: GET /infinity-booking/bookings with filters');
      
      const String endpoint = 'infinity-booking/bookings';
      final Map<String, String> queryParams = {
        'page': page.toString(),
        'limit': limit.toString(),
      };

      final queryString = Uri(queryParameters: queryParams).query;
      final String url = '${AppConstants.buildUrl(endpoint)}?$queryString';

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<dynamic> allBookings = [];
        
        if (data is Map) {
          allBookings = data['bookings'] ?? data['data'] ?? data['items'] ?? [];
        } else if (data is List) {
          allBookings = data;
        }
        
        // Filter by current user client-side
        final customerId = await _getCurrentCustomerIdInCorrectFormat();
        final filteredBookings = allBookings.where((booking) {
          if (booking is Map) {
            final bookingCustomerId = booking['customerId']?.toString() ?? 
                                    booking['customer']?['_id']?.toString() ?? 
                                    booking['customer']?['id']?.toString();
            return bookingCustomerId == customerId;
          }
          return false;
        }).toList();

        // Apply status filter if needed
        final finalBookings = status != null && status.isNotEmpty && status != 'all'
            ? filteredBookings.where((booking) {
                if (booking is Map) {
                  final bookingStatus = booking['status']?.toString().toLowerCase() ?? '';
                  return bookingStatus == status.toLowerCase();
                }
                return false;
              }).toList()
            : filteredBookings;

        // Parse to BookingModel
        return finalBookings.map((json) => BookingModel.fromJson(json)).toList();
      }
      throw Exception('Alternative endpoint also failed');
    } catch (error) {
      print('❌ Alternative method failed: $error');
      rethrow;
    }
  }

  // ==================== CREATE BOOKING ====================
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
      print('🚀 Creating new booking...');
      
      // Get authentication token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('Session expired. Please login again.');
      }

      // Get customer ID
      final customerId = await _getCurrentCustomerIdInCorrectFormat();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Please login to create a booking.');
      }
      print('✅ Customer ID: $customerId');

      // Prepare the booking request
      final Map<String, dynamic> bookingRequest = {
        'serviceId': serviceId,
        'providerId': providerId,
        'customerId': customerId,
        'bookingDate': bookingDate,
        'startTime': startTime,
        'endTime': endTime,
        'totalAmount': totalAmount,
        'paymentMethod': paymentMethod ?? (skipPayment ? null : 'cash'),
        'notes': notes ?? '',
        'bookingReference': bookingReference,
        'skipPayment': skipPayment,
        'status': skipPayment ? 'pending_payment' : 'confirmed',
      };

      // Remove null values
      bookingRequest.removeWhere((key, value) => value == null);

      print('📦 Booking request: $bookingRequest');

      // Make API request
      final url = AppConstants.buildUrl(AppConstants.createBookingEndpoint);
      print('🔗 Endpoint: $url');

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(bookingRequest),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');
      
      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('🎉 Booking created successfully!');
        return BookingModel.fromJson(data);
      } else {
        String errorMessage = 'Failed to create booking (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('❌ Booking creation failed: $error');
      rethrow;
    }
  }

  // ==================== GET BOOKING BY ID ====================
  Future<BookingModel> getBookingById(String bookingId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/bookings/{id}';
      final endpoint = baseEndpoint.replaceAll('{id}', bookingId);
      final url = AppConstants.buildUrl(endpoint);

      print('🔍 Fetching booking by ID: $bookingId');
      print('🔗 URL: $url');

      final response = await _httpClient.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Booking fetched successfully');
        return BookingModel.fromJson(data);
      } else {
        String errorMessage = 'Failed to fetch booking (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('❌ Error fetching booking: $error');
      rethrow;
    }
  }

  // ==================== CANCEL BOOKING ====================
  Future<BookingModel> cancelBooking(String bookingId, {String? reason}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/bookings/{id}/cancel';
      final endpoint = baseEndpoint.replaceAll('{id}', bookingId);
      final url = AppConstants.buildUrl(endpoint);

      print('🗑️ Cancelling booking: $bookingId');
      print('🔗 URL: $url');

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'reason': reason ?? 'Cancelled by customer'}),
      ).timeout(const Duration(seconds: 30));

      print('📡 Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('✅ Booking cancelled successfully');
        return BookingModel.fromJson(data);
      } else {
        String errorMessage = 'Failed to cancel booking (${response.statusCode})';
        try {
          final errorData = jsonDecode(response.body);
          errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
        } catch (_) {}
        throw Exception(errorMessage);
      }
    } catch (error) {
      print('❌ Error cancelling booking: $error');
      rethrow;
    }
  }

  // ==================== UPDATE BOOKING STATUS ====================
  Future<BookingModel> updateBookingStatus(String bookingId, {required String status}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/bookings/{id}/status';
      final endpoint = baseEndpoint.replaceAll('{id}', bookingId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.put(
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

  // ==================== GET BOOKING STATISTICS ====================
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final customerId = await _getCurrentCustomerIdInCorrectFormat();
      if (customerId == null) throw Exception('Could not determine customer ID');

      const String baseEndpoint = 'infinity-booking/bookings/stats/customer/{customerId}';
      final endpoint = baseEndpoint.replaceAll('{customerId}', customerId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
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

  // ==================== CHECK SLOT AVAILABILITY ====================
  Future<bool> checkSlotAvailability({
    required String serviceId,
    required String providerId,
    required String bookingDate,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl('infinity-booking/bookings/check-availability');
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'serviceId': serviceId,
          'providerId': providerId,
          'bookingDate': bookingDate,
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

  // ==================== PROCESS PAYMENT ====================
  Future<Map<String, dynamic>> processPayment({
    required String bookingId,
    required String paymentMethod,
    required double amount,
    String? paymentReference,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/payments/process';
      final url = AppConstants.buildUrl(baseEndpoint);

      final response = await _httpClient.post(
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

  // ==================== VERIFY PAYMENT ====================
  Future<Map<String, dynamic>> verifyPayment({required String paymentReference}) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/payments/verify/{reference}';
      final endpoint = baseEndpoint.replaceAll('{reference}', paymentReference);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.get(
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

  // ==================== GET PAYMENT METHODS ====================
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/payments/methods';
      final url = AppConstants.buildUrl(baseEndpoint);

      final response = await _httpClient.get(
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
        'id': 'cash',
        'name': 'Cash',
        'description': 'Pay in person',
        'icon': '💰',
        'currency': 'ETB'
      },
      {
        'id': 'bank_transfer',
        'name': 'Bank Transfer',
        'description': 'Direct bank transfer',
        'icon': '🏦',
        'currency': 'ETB'
      }
    ];
  }

  // ==================== RESCHEDULE BOOKING ====================
  Future<BookingModel> rescheduleBooking({
    required String bookingId,
    required String newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/bookings/{id}/reschedule';
      final endpoint = baseEndpoint.replaceAll('{id}', bookingId);
      final url = AppConstants.buildUrl(endpoint);

      final response = await _httpClient.put(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'newDate': newDate,
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

  // ==================== GET UPCOMING BOOKINGS ====================
  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final bookings = await getUserBookings(status: 'confirmed');
      final now = DateTime.now();
      return bookings.where((booking) {
        final bookingDateTime = booking.bookingDate;
        return bookingDateTime.isAfter(now) || 
               bookingDateTime.isAtSameMomentAs(now);
      }).toList();
    } catch (error) {
      print('❌ Error fetching upcoming bookings: $error');
      rethrow;
    }
  }

  // ==================== COMPLETE BOOKING ====================
  Future<BookingModel> completeBooking(String bookingId) async {
    return await updateBookingStatus(bookingId, status: 'completed');
  }

  // ==================== RATE BOOKING ====================
  Future<BookingModel> rateBooking({
    required String bookingId,
    required double rating,
    String? review,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      const String baseEndpoint = 'infinity-booking/reviews';
      final url = AppConstants.buildUrl(baseEndpoint);

      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'bookingId': bookingId,
          'rating': rating,
          'review': review ?? '',
        }),
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        // Also update the booking status to reflect the review
        await updateBookingStatus(bookingId, status: 'completed');
        
        return BookingModel.fromJson(data);
      }
      throw Exception('Failed to rate booking (${response.statusCode})');
    } catch (error) {
      print('❌ Error rating booking: $error');
      rethrow;
    }
  }

  // ==================== HELPER METHODS ====================
  
  // Get customer ID in correct format
  Future<String?> _getCurrentCustomerIdInCorrectFormat() async {
    try {
      final user = await _secureStorage.getUserData();
      
      // Priority 1: cid field (CUST- format)
      if (user?.cid != null && user!.cid!.isNotEmpty) {
        return user.cid;
      }
      
      // Priority 2: Saved user ID
      final savedUserId = await _secureStorage.getUserId();
      if (savedUserId != null && savedUserId.isNotEmpty) {
        return savedUserId;
      }
      
      // Priority 3: Use user ID
      if (user != null && user.id.isNotEmpty) {
        return user.id;
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting customer ID: $e');
      return null;
    }
  }

  // Extract CUST- ID from JWT token
  String? _extractCustIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);
      
      final possibleFields = ['cid', 'customerId', 'customer_id', 'custId', 'userId', 'user_id'];
      
      for (final field in possibleFields) {
        final value = payloadMap[field]?.toString();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error decoding token: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _httpClient.close();
  }
}