// lib/screens/booking/payment_method_screen.dart 
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../models/provider_model.dart';
import '../../services/booking_service.dart';
import '../../services/provider_service.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class PaymentMethodScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  final String serviceId;
  final String providerId;

  const PaymentMethodScreen({
    super.key,
    required this.bookingData,
    required this.serviceId,
    required this.providerId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  late final BookingService _bookingService;
  final ProviderService _providerService = ProviderService();
  
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _selectedPaymentMethod;
  bool _loading = false;
  bool _loadingMethods = true;
  bool _isLoadingProvider = true;
  String? _providerDisplayName;
  ProviderModel? _provider;
  double? _totalAmount;
  String? _date;
  String? _serviceNotes;
  String? _startTime;
  String? _endTime;

  @override
  void initState() {
    super.initState();
    _bookingService = BookingService();
    _initializeData();
    _loadPaymentMethods();
    _loadProviderDetails();
  }

  void _initializeData() {
    // Extract data from bookingData
    if (widget.bookingData.isNotEmpty) {
      _totalAmount = widget.bookingData['totalAmount'] as double? ?? 0.0;
      _date = widget.bookingData['bookingDate']?.toString();
      _serviceNotes = widget.bookingData['notes']?.toString();
      _startTime = widget.bookingData['startTime']?.toString();
      _endTime = widget.bookingData['endTime']?.toString();
      
      debugPrint('📦 Booking data initialized:');
      debugPrint('   - Service ID: ${widget.serviceId}');
      debugPrint('   - Provider ID: ${widget.providerId}');
      debugPrint('   - Total Amount: $_totalAmount');
      debugPrint('   - Date: $_date');
      debugPrint('   - Start Time: $_startTime');
      debugPrint('   - End Time: $_endTime');
    }
  }

  Future<void> _loadProviderDetails() async {
    if (widget.providerId.isEmpty) {
      setState(() {
        _providerDisplayName = 'Service Provider';
        _isLoadingProvider = false;
      });
      return;
    }

    try {
      debugPrint('🔄 Loading provider details for ID: ${widget.providerId}');
      final provider = await _providerService.getProviderSmart(widget.providerId);
      
      if (provider != null) {
        setState(() {
          _provider = provider;
          _providerDisplayName = provider.fullname;
          debugPrint('✅ Loaded provider: $_providerDisplayName');
        });
      } else {
        setState(() {
          _providerDisplayName = 'Service Provider';
          debugPrint('⚠️ Using fallback provider name');
        });
      }
    } catch (error) {
      debugPrint('❌ Error loading provider: $error');
      setState(() {
        _providerDisplayName = 'Service Provider';
      });
    } finally {
      setState(() => _isLoadingProvider = false);
    }
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await _bookingService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _loadingMethods = false;
        
        // Auto-select first payment method
        if (methods.isNotEmpty) {
          _selectedPaymentMethod = methods.first['id'];
        }
      });
    } catch (error) {
      debugPrint('❌ Error loading payment methods: $error');
      setState(() {
        _paymentMethods = _getFallbackPaymentMethods();
        _loadingMethods = false;
        
        if (_paymentMethods.isNotEmpty) {
          _selectedPaymentMethod = _paymentMethods.first['id'];
        }
      });
    }
  }

  List<Map<String, dynamic>> _getFallbackPaymentMethods() {
    return [
      {
        'id': 'cash',
        'name': 'Cash',
        'description': 'Pay in person with cash',
        'icon': '💰',
        'currency': 'ETB',
        'isActive': true,
      },
      {
        'id': 'bank_transfer',
        'name': 'Bank Transfer',
        'description': 'Direct bank transfer',
        'icon': '🏦',
        'currency': 'ETB',
        'isActive': true,
      },
      {
        'id': 'credit_card',
        'name': 'Credit/Debit Card',
        'description': 'Pay with card',
        'icon': '💳',
        'currency': 'ETB',
        'isActive': true,
      },
      {
        'id': 'mobile_banking',
        'name': 'Mobile Banking',
        'description': 'Pay via mobile banking',
        'icon': '📱',
        'currency': 'ETB',
        'isActive': true,
      }
    ];
  }

  Future<void> _proceedToPayment() async {
    if (_selectedPaymentMethod == null) {
      _showSnackBar('Please select a payment method');
      return;
    }

    // Validate required data
    if (_startTime == null || _endTime == null || _date == null || _totalAmount == null) {
      _showSnackBar('Missing booking information. Please go back and try again.');
      return;
    }

    // Validate provider ID
    if (widget.providerId.isEmpty) {
      _showSnackBar('Provider information is missing. Please go back and try again.');
      return;
    }

    // Validate service ID
    if (widget.serviceId.isEmpty) {
      _showSnackBar('Service information is missing. Please go back and try again.');
      return;
    }

    // Log data for debugging
    debugPrint('💰 Creating booking with payment...');
    debugPrint('   - Service ID: ${widget.serviceId}');
    debugPrint('   - Provider ID: ${widget.providerId}');
    debugPrint('   - Date: $_date');
    debugPrint('   - Time: $_startTime - $_endTime');
    debugPrint('   - Total Amount: $_totalAmount');
    debugPrint('   - Payment Method: $_selectedPaymentMethod');

    setState(() => _loading = true);
    
    try {
      // Format date to DD/MM/YYYY for the API
      final formattedDate = _formatDateForAPI(_date!);
      if (formattedDate == null) {
        _showSnackBar('Invalid date format. Please try again.');
        setState(() => _loading = false);
        return;
      }

      // Create booking
      final booking = await _bookingService.createBooking(
        serviceId: widget.serviceId,
        providerId: widget.providerId,
        bookingDate: formattedDate,
        startTime: _startTime!,
        endTime: _endTime!,
        totalAmount: _totalAmount!,
        paymentMethod: _selectedPaymentMethod,
        notes: _serviceNotes,
        skipPayment: false,
      );

      debugPrint('✅ Booking created successfully: ${booking.id}');
      
      // Process payment
      final paymentResult = await _bookingService.processPayment(
        bookingId: booking.id,
        paymentMethod: _selectedPaymentMethod!,
        amount: _totalAmount!,
      );

      debugPrint('✅ Payment processed successfully');
      
      // Check if payment was successful
      final isSuccess = paymentResult['success'] == true;
      
      if (isSuccess) {
        // Navigate to confirmation screen
        _navigateToConfirmation(booking, paymentResult);
      } else {
        _showSnackBar('Payment failed: ${paymentResult['message'] ?? 'Unknown error'}');
      }
      
    } catch (error) {
      debugPrint('❌ Payment failed: $error');
      
      String errorMessage = 'Payment failed. Please try again.';
      if (error.toString().contains('providerId')) {
        errorMessage = 'Provider information error. Please go back and try again.';
      } else if (error.toString().contains('customerId')) {
        errorMessage = 'User session error. Please log in again.';
      } else if (error.toString().contains('400')) {
        errorMessage = 'Invalid booking data. Please check your selection.';
      } else if (error.toString().contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
      } else if (error.toString().contains('409')) {
        errorMessage = 'Time slot already booked. Please choose another time.';
      }
      
      _showErrorSnackBar(errorMessage);
    } finally {
      setState(() => _loading = false);
    }
  }

  String? _formatDateForAPI(String dateString) {
    try {
      // Try to parse the date string
      DateTime? dateTime;
      
      // Try multiple date formats
      final formats = [
        'yyyy-MM-dd',
        'dd/MM/yyyy',
        'MM/dd/yyyy',
        'yyyy/MM/dd',
      ];
      
      for (final format in formats) {
        try {
          // Simple parsing for common formats
          if (dateString.contains('-')) {
            final parts = dateString.split('-');
            if (parts.length == 3) {
              dateTime = DateTime.parse(dateString);
              break;
            }
          } else if (dateString.contains('/')) {
            final parts = dateString.split('/');
            if (parts.length == 3) {
              // Try DD/MM/YYYY
              if (parts[0].length == 2 && parts[1].length == 2 && parts[2].length == 4) {
                dateTime = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
                break;
              }
              // Try MM/DD/YYYY
              if (parts[0].length == 2 && parts[1].length == 2 && parts[2].length == 4) {
                dateTime = DateTime(int.parse(parts[2]), int.parse(parts[0]), int.parse(parts[1]));
                break;
              }
            }
          }
        } catch (e) {
          continue;
        }
      }
      
      // If parsing succeeded, format to DD/MM/YYYY
      if (dateTime != null) {
        final day = dateTime.day.toString().padLeft(2, '0');
        final month = dateTime.month.toString().padLeft(2, '0');
        final year = dateTime.year.toString();
        return '$day/$month/$year';
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ Error formatting date: $e');
      return null;
    }
  }

  void _navigateToConfirmation(BookingModel booking, Map<String, dynamic> paymentResult) {
    Navigator.pushNamed(
      context,
      RouteHelper.bookingConfirmation,
      arguments: {
        'booking': booking,
        'paymentResult': paymentResult,
      },
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    final isActive = method['isActive'] ?? true;
    
    return GestureDetector(
      onTap: isActive ? () {
        setState(() => _selectedPaymentMethod = method['id']);
      } : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected 
            ? AppColors.primary.withOpacity(0.1) 
            : (isActive ? Colors.white : Colors.grey[100]),
          border: Border.all(
            color: isSelected 
              ? AppColors.primary 
              : (isActive ? Colors.grey[300]! : Colors.grey[400]!),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isActive ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected 
                  ? AppColors.primary.withOpacity(0.2) 
                  : (isActive ? Colors.grey[100] : Colors.grey[200]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  method['icon'] ?? '💳',
                  style: TextStyle(
                    fontSize: 24,
                    color: isActive ? null : Colors.grey[500],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method['name'] ?? 'Payment Method',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: isActive ? null : Colors.grey[500],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method['description'] ?? '',
                    style: TextStyle(
                      color: isActive ? Colors.grey[600] : Colors.grey[500],
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (!isActive) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Currently unavailable',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (isSelected && isActive)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
            if (!isActive)
              Icon(
                Icons.block,
                color: Colors.grey[500],
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    String timeRange = 'Time not specified';
    if (_startTime != null && _endTime != null) {
      timeRange = '$_startTime - $_endTime';
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Service Info
            _buildSummaryItem('Service', 'Service ID: ${widget.serviceId.substring(0, min(widget.serviceId.length, 8))}...'),
            
            // Provider Info
            _buildSummaryItem('Provider', _isLoadingProvider 
                ? 'Loading...' 
                : _providerDisplayName ?? 'Service Provider'),
            
            // Date
            if (_date != null) _buildSummaryItem('Date', _formatDateForDisplay(_date!)),
            
            // Time
            _buildSummaryItem('Time', timeRange),
            
            // Notes if available
            if (_serviceNotes != null && _serviceNotes!.isNotEmpty)
              Column(
                children: [
                  const SizedBox(height: 8),
                  _buildSummaryItem('Notes', _serviceNotes!),
                ],
              ),
            
            // Provider contact info if available
            if (!_isLoadingProvider && _provider != null)
              Column(
                children: [
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  const Text(
                    'Provider Contact',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (_provider!.phonenumber.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            _provider!.phonenumber,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  if (_provider!.email.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(Icons.email, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _provider!.email,
                              style: const TextStyle(fontSize: 14),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total Amount',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_totalAmount?.toStringAsFixed(2) ?? '0.00'} ETB',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.secondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateForDisplay(String dateString) {
    try {
      // Try to parse and format nicely
      if (dateString.contains('-')) {
        final parts = dateString.split('-');
        if (parts.length == 3) {
          final date = DateTime.parse(dateString);
          return '${date.day}/${date.month}/${date.year}';
        }
      } else if (dateString.contains('/')) {
        // Already in DD/MM/YYYY format
        return dateString;
      }
      return dateString;
    } catch (e) {
      return dateString;
    }
  }

  int min(int a, int b) => a < b ? a : b;

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _loadingMethods
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading payment methods...'),
                ],
              ),
            )
          : Column(
              children: [
                // Booking Summary
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildBookingSummary(),
                        const SizedBox(height: 24),
                        
                        // Payment Methods
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Choose how you want to pay for this booking',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 16),
                        
                        if (_paymentMethods.isEmpty)
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.payment, size: 48, color: Colors.grey),
                                  SizedBox(height: 12),
                                  Text(
                                    'No payment methods available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Please try again later',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          ..._paymentMethods.map(_buildPaymentMethodCard),
                        
                        const SizedBox(height: 20),
                        
                        // Additional info
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Your payment is secure. You will receive a confirmation email and notification after successful payment.',
                                  style: TextStyle(
                                    color: Colors.blue[800],
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Payment Button
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: Colors.grey[300]!)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      if (_selectedPaymentMethod != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.credit_card,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                _paymentMethods.firstWhere(
                                  (method) => method['id'] == _selectedPaymentMethod,
                                  orElse: () => {'name': 'Unknown'},
                                )['name'] ?? 'Unknown',
                                style: TextStyle(
                                  color: Colors.grey[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _proceedToPayment,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: _loading
                              ? const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Processing...'),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Complete Payment',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, size: 20),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  @override
  void dispose() {
    _bookingService.dispose();
    super.dispose();
  }
}