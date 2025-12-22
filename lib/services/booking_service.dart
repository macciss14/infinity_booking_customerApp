// lib/services/booking_service.dart - COMPLETE REWRITTEN VERSION
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

  // ✅ Create a new booking with smart provider ID handling
  Future<BookingModel> createBooking({
    required String serviceId,
    required String providerId, // This might be MongoDB ID, PID, or user ID
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
      print('🚀 Starting booking creation process...');
      print('   Input providerId: $providerId');
      print('   Service ID: $serviceId');
      print('   Date: $bookingDate');

      // 🔥 STEP 1: Validate and extract real provider PID
      final String realProviderPid = await _resolveProviderPid(providerId, serviceId);
      
      if (realProviderPid.isEmpty) {
        throw Exception('Could not determine valid provider ID. Please try again or contact support.');
      }

      print('✅ Resolved provider PID: $realProviderPid');

      // 🔥 STEP 2: Validate date format
      _validateDateFormat(bookingDate);

      // 🔥 STEP 3: Get customer ID in correct format
      final customerId = await _getCurrentCustomerIdInCorrectFormat();
      if (customerId == null || customerId.isEmpty) {
        throw Exception('Please login to create a booking.');
      }

      print('✅ Customer ID: $customerId');

      // 🔥 STEP 4: Prepare the booking request
      final Map<String, dynamic> bookingRequest = {
        'serviceId': serviceId,
        'providerId': realProviderPid, // ✅ Use the resolved PID
        'customerId': customerId,
        'bookingDate': bookingDate, // ✅ Keep as DD/MM/YYYY
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

      print('📦 Final booking request:');
      bookingRequest.forEach((key, value) {
        print('   $key: $value');
      });

      // 🔥 STEP 5: Get authentication token
      final token = await _secureStorage.getToken();
      if (token == null) {
        throw Exception('Session expired. Please login again.');
      }

      final url = AppConstants.buildUrl(AppConstants.createBookingEndpoint);
      print('🔗 Booking endpoint: $url');

      // 🔥 STEP 6: Make the API request
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
        print('📋 Booking ID: ${data['_id'] ?? data['id']}');
        return BookingModel.fromJson(data);
      }

      // 🔥 STEP 7: Handle error responses
      return await _handleBookingError(
        response: response,
        originalRequest: bookingRequest,
        serviceId: serviceId,
      );
    } catch (error) {
      print('❌ Booking creation failed: $error');
      rethrow;
    } finally {
      _httpClient.close();
    }
  }

  // 🔥 CRITICAL: Resolve provider PID from various input formats
  Future<String> _resolveProviderPid(String inputProviderId, String serviceId) async {
    print('🔍 Resolving provider PID from input: $inputProviderId');
    
    // Case 1: Already a valid PROV- PID
    if (inputProviderId.startsWith('PROV-')) {
      print('✅ Input is already a PROV- PID');
      return inputProviderId;
    }

    // Case 2: Try to fetch from service data
    print('🔄 Attempting to fetch provider PID from service data...');
    final serviceProviderPid = await _getProviderPidFromService(serviceId);
    if (serviceProviderPid.isNotEmpty) {
      print('✅ Found provider PID from service: $serviceProviderPid');
      return serviceProviderPid;
    }

    // Case 3: Input might be a user ID, try to get provider profile
    print('🔄 Attempting to fetch provider PID from user data...');
    final userProviderPid = await _getProviderPidFromUser(inputProviderId);
    if (userProviderPid.isNotEmpty) {
      print('✅ Found provider PID from user: $userProviderPid');
      return userProviderPid;
    }

    // Case 4: Last resort - try to use the input as-is (will likely fail)
    print('⚠️ Could not resolve PROV- PID, using input as-is');
    return inputProviderId;
  }

  // 🔥 Fetch provider PID from service data
  Future<String> _getProviderPidFromService(String serviceId) async {
    try {
      print('🔍 Fetching service details for: $serviceId');
      
      final token = await _secureStorage.getToken();
      if (token == null) return '';

      final serviceUrl = '${AppConstants.baseUrl}/infinity-booking/services/$serviceId';
      print('🔗 Service URL: $serviceUrl');

      final response = await _httpClient.get(
        Uri.parse(serviceUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final serviceData = jsonDecode(response.body);
        print('📊 Service data keys: ${serviceData.keys}');

        // Look for provider PID in various possible locations
        final possiblePidPaths = [
          'providerPid',
          'provider.pid',
          'pid',
          'providerId',
          'provider.id',
          'user.pid',
          'user.providerPid',
        ];

        for (final path in possiblePidPaths) {
          final pid = _extractValueByPath(serviceData, path);
          if (pid != null && pid.toString().isNotEmpty) {
            final pidStr = pid.toString();
            print('✅ Found provider reference at $path: $pidStr');
            
            if (pidStr.startsWith('PROV-')) {
              return pidStr;
            }
          }
        }

        // If we found a provider object, print its structure
        if (serviceData['provider'] != null && serviceData['provider'] is Map) {
          final provider = serviceData['provider'] as Map<String, dynamic>;
          print('📋 Provider object structure:');
          provider.forEach((key, value) => print('   $key: $value'));
        }

        print('❌ No valid PROV- PID found in service data');
      } else {
        print('❌ Failed to fetch service data: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error fetching service data: $e');
    }

    return '';
  }

  // 🔥 Extract value from nested object using dot notation
  dynamic _extractValueByPath(Map<String, dynamic> data, String path) {
    try {
      var current = data;
      final parts = path.split('.');
      
      for (int i = 0; i < parts.length - 1; i++) {
        if (current[parts[i]] is Map) {
          current = current[parts[i]] as Map<String, dynamic>;
        } else {
          return null;
        }
      }
      
      return current[parts.last];
    } catch (e) {
      return null;
    }
  }

  // 🔥 Fetch provider PID from user data
  Future<String> _getProviderPidFromUser(String userId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return '';

      // Try provider endpoint
      final providerUrl = '${AppConstants.baseUrl}/infinity-booking/providers/$userId';
      print('🔗 Trying provider endpoint: $providerUrl');
      
      final providerResponse = await _httpClient.get(
        Uri.parse(providerUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (providerResponse.statusCode == 200) {
        final providerData = jsonDecode(providerResponse.body);
        final pid = providerData['pid']?.toString();
        if (pid != null && pid.startsWith('PROV-')) {
          print('✅ Found PID from provider endpoint: $pid');
          return pid;
        }
      }

      // Try user endpoint
      final userUrl = '${AppConstants.baseUrl}/infinity-booking/users/$userId';
      print('🔗 Trying user endpoint: $userUrl');
      
      final userResponse = await _httpClient.get(
        Uri.parse(userUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 5));

      if (userResponse.statusCode == 200) {
        final userData = jsonDecode(userResponse.body);
        final pid = userData['pid']?.toString();
        if (pid != null && pid.startsWith('PROV-')) {
          print('✅ Found PID from user endpoint: $pid');
          return pid;
        }
      }

    } catch (e) {
      print('❌ Error fetching user/provider data: $e');
    }

    return '';
  }

  // 🔥 Handle booking errors with intelligent retry logic
  Future<BookingModel> _handleBookingError({
    required http.Response response,
    required Map<String, dynamic> originalRequest,
    required String serviceId,
  }) async {
    String errorMsg = 'Failed to create booking (${response.statusCode})';
    Map<String, dynamic>? errorData;

    try {
      errorData = jsonDecode(response.body);
      errorMsg = errorData?['message'] ?? errorData?['error'] ?? errorMsg;
      print('❌ Server error: $errorMsg');
      print('❌ Error details: $errorData');
    } catch (_) {
      print('❌ Raw error response: ${response.body}');
    }

    // 🔥 Handle specific error cases
    if (response.statusCode == 400) {
      if (errorMsg.toLowerCase().contains('provider')) {
        print('🔄 Provider error detected, attempting to find correct provider ID...');
        
        // Try to get provider ID directly from the service
        final serviceProviderId = await _getProviderIdFromServiceDirect(serviceId);
        if (serviceProviderId != null && serviceProviderId.startsWith('PROV-')) {
          print('✅ Found alternative provider ID: $serviceProviderId');
          
          // Update and retry
          originalRequest['providerId'] = serviceProviderId;
          
          final token = await _secureStorage.getToken();
          if (token != null) {
            print('🔄 Retrying with corrected provider ID...');
            
            final retryResponse = await _httpClient.post(
              Uri.parse(AppConstants.buildUrl(AppConstants.createBookingEndpoint)),
              headers: {
                'Authorization': 'Bearer $token',
                'Content-Type': 'application/json',
              },
              body: jsonEncode(originalRequest),
            ).timeout(const Duration(seconds: 20));

            if (retryResponse.statusCode == 201 || retryResponse.statusCode == 200) {
              final retryData = jsonDecode(retryResponse.body);
              print('✅ Booking created successfully on retry!');
              return BookingModel.fromJson(retryData);
            }
          }
        }
        
        errorMsg = 'Unable to verify service provider. Please try again or contact support.';
      } else if (errorMsg.toLowerCase().contains('date')) {
        errorMsg = 'Invalid date format. Please check the selected date.';
      } else {
        errorMsg = 'Invalid booking data. Please check all information.';
      }
    } else if (response.statusCode == 401) {
      errorMsg = 'Session expired. Please login again.';
    } else if (response.statusCode == 403) {
      errorMsg = 'Access denied. You do not have permission to create this booking.';
    } else if (response.statusCode == 404) {
      errorMsg = 'Service not found. The service may no longer be available.';
    } else if (response.statusCode == 409) {
      errorMsg = 'This time slot is already booked. Please choose another time.';
    } else if (response.statusCode == 500) {
      errorMsg = 'Server error. Please try again later.';
    }

    throw Exception(errorMsg);
  }

  // 🔥 Direct method to get provider ID from service (simpler approach)
  Future<String?> _getProviderIdFromServiceDirect(String serviceId) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) return null;

      final response = await _httpClient.get(
        Uri.parse('${AppConstants.baseUrl}/infinity-booking/services/$serviceId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final serviceData = jsonDecode(response.body);
        
        // Simple direct extraction - look for common field names
        if (serviceData['providerId'] != null) {
          return serviceData['providerId'].toString();
        }
        if (serviceData['providerPid'] != null) {
          return serviceData['providerPid'].toString();
        }
        if (serviceData['provider'] != null && serviceData['provider'] is Map) {
          final provider = serviceData['provider'] as Map<String, dynamic>;
          if (provider['pid'] != null) {
            return provider['pid'].toString();
          }
          if (provider['id'] != null) {
            return provider['id'].toString();
          }
        }
      }
    } catch (e) {
      print('❌ Error getting provider ID directly: $e');
    }
    
    return null;
  }

  // 🔥 Validate date format is DD/MM/YYYY
  void _validateDateFormat(String date) {
    try {
      final parts = date.split('/');
      if (parts.length != 3) {
        throw FormatException('Invalid date format. Expected DD/MM/YYYY, got: $date');
      }
      
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);
      
      if (day == null || month == null || year == null) {
        throw FormatException('Invalid date numbers. Expected DD/MM/YYYY, got: $date');
      }
      
      print('✅ Date format validated: $date (DD/MM/YYYY)');
    } catch (e) {
      print('❌ Date validation error: $e');
      rethrow;
    }
  }

  // 🔥 Get customer ID in correct format
  Future<String?> _getCurrentCustomerIdInCorrectFormat() async {
    try {
      final user = await _secureStorage.getUserData();
      
      // Priority 1: cid field (CUST- format)
      if (user?.cid != null && user!.cid!.startsWith('CUST-')) {
        return user.cid;
      }
      
      // Priority 2: Saved user ID
      final savedUserId = await _secureStorage.getUserId();
      if (savedUserId != null && savedUserId.isNotEmpty && savedUserId.startsWith('CUST-')) {
        return savedUserId;
      }
      
      // Priority 3: Extract from token
      final token = await _secureStorage.getToken();
      if (token != null) {
        final custId = _extractCustIdFromToken(token);
        if (custId != null && custId.isNotEmpty && custId.startsWith('CUST-')) {
          await _secureStorage.saveUserId(custId);
          return custId;
        }
      }
      
      // Priority 4: Use user ID (might be MongoDB format)
      if (user != null && user.id.isNotEmpty) {
        return user.id;
      }
      
      return null;
    } catch (e) {
      print('❌ Error getting customer ID: $e');
      return null;
    }
  }

  // 🔥 Extract CUST- ID from JWT token
  String? _extractCustIdFromToken(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;
      
      final payload = parts[1];
      final String normalized = base64Url.normalize(payload);
      final String decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> payloadMap = jsonDecode(decoded);
      
      // Look for CUST- ID in various fields
      final possibleFields = ['cid', 'customerId', 'customer_id', 'custId', 'user_id'];
      
      for (final field in possibleFields) {
        final value = payloadMap[field]?.toString();
        if (value != null && value.startsWith('CUST-')) {
          return value;
        }
      }
      
      return null;
    } catch (e) {
      print('❌ Error decoding token: $e');
      return null;
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
      final response = await _httpClient.get(
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

      final response = await _httpClient.get(
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

      final response = await _httpClient.put(
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

  // ✅ Get booking statistics
  Future<Map<String, dynamic>> getBookingStatistics() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.bookingStatisticsEndpoint);
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

  // ✅ Check slot availability
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

      // Resolve provider PID first
      final realProviderPid = await _resolveProviderPid(providerId, serviceId);

      final url = AppConstants.buildUrl(AppConstants.checkSlotAvailabilityEndpoint);
      final response = await _httpClient.post(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'serviceId': serviceId,
          'providerId': realProviderPid,
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

  // ✅ Get payment methods
  Future<List<Map<String, dynamic>>> getPaymentMethods() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.paymentMethodsEndpoint);
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
    required String newDate,
    required String newStartTime,
    required String newEndTime,
  }) async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final endpoint = AppConstants.replacePathParams(
        AppConstants.rescheduleBookingEndpoint,
        id: bookingId,
      );
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

  // ✅ Get upcoming bookings
  Future<List<BookingModel>> getUpcomingBookings() async {
    try {
      final token = await _secureStorage.getToken();
      if (token == null) throw Exception('Not authenticated');

      final url = AppConstants.buildUrl(AppConstants.upcomingBookingsEndpoint);
      final response = await _httpClient.get(
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

      final response = await _httpClient.put(
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

      final response = await _httpClient.post(
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
}