// lib/screens/booking/payment_method_screen.dart
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class PaymentMethodScreen extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic> selectedSlot;
  final double totalAmount;
  final String bookingDate;
  final String? notes;
  final String? providerId;

  const PaymentMethodScreen({
    super.key,
    required this.service,
    required this.selectedSlot,
    required this.totalAmount,
    required this.bookingDate,
    this.notes,
    this.providerId,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final BookingService _bookingService = BookingService();
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _selectedPaymentMethod;
  bool _loading = false;
  bool _loadingMethods = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await _bookingService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _loadingMethods = false;
      });
    } catch (error) {
      print('❌ Error loading payment methods: $error');
      setState(() => _loadingMethods = false);
    }
  }

  Future<void> _proceedToPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a payment method')),
      );
      return;
    }

    // Get provider ID with fallback - CRITICAL
    final String providerId = widget.providerId ?? 
                            widget.service.providerPid ?? 
                            widget.service.providerId ?? '';
    
    if (providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider information is missing. Please go back and try again.')),
      );
      return;
    }

    // Log provider ID for debugging
    print('🔍 Provider ID for booking: $providerId');
    print('🔍 Provider ID starts with PROV-: ${providerId.startsWith('PROV-')}');

    setState(() => _loading = true);
    
    try {
      // Extract time slot data
      final timeSlot = widget.selectedSlot['timeSlot'] ?? widget.selectedSlot;
      final startTime = timeSlot['startTime']?.toString() ?? '';
      final endTime = timeSlot['endTime']?.toString() ?? '';
      
      if (startTime.isEmpty || endTime.isEmpty) {
        throw Exception('Invalid time slot data');
      }

      print('💰 Creating booking with payment...');
      print('   - Service ID: ${widget.service.id}');
      print('   - Provider ID: $providerId');
      print('   - Date: ${widget.bookingDate}');
      print('   - Time: $startTime - $endTime');
      print('   - Amount: ${widget.totalAmount}');
      print('   - Payment Method: $_selectedPaymentMethod');
      
      // Create booking first
      final booking = await _bookingService.createBooking(
        serviceId: widget.service.id,
        providerId: providerId,
        bookingDate: widget.bookingDate,
        startTime: startTime,
        endTime: endTime,
        totalAmount: widget.totalAmount,
        paymentMethod: _selectedPaymentMethod,
        notes: widget.notes,
        skipPayment: false,
      );

      print('✅ Booking created successfully: ${booking.id}');
      
      // Process payment
      final paymentResult = await _bookingService.processPayment(
        bookingId: booking.id,
        paymentMethod: _selectedPaymentMethod!,
        amount: widget.totalAmount,
      );

      print('✅ Payment processed successfully');
      print('✅ Payment result: $paymentResult');
      
      // Navigate to confirmation
      RouteHelper.goToBookingConfirmation(
        context,
        booking: booking,
        paymentResult: paymentResult,
        skipPayment: false,
      );
    } catch (error) {
      print('❌ Payment failed: $error');
      
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
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = method['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  method['icon'] ?? '💳',
                  style: const TextStyle(fontSize: 24),
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
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    method['description'] ?? '',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingSummary() {
    final timeSlot = widget.selectedSlot['timeSlot'] ?? widget.selectedSlot;
    final startTime = timeSlot['startTime']?.toString() ?? '';
    final endTime = timeSlot['endTime']?.toString() ?? '';
    final timeRange = startTime.isNotEmpty && endTime.isNotEmpty
        ? '$startTime - $endTime'
        : 'Time not specified';

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
            _buildSummaryItem('Service', widget.service.name),
            _buildSummaryItem('Provider', widget.service.displayProviderName),
            _buildSummaryItem('Date', widget.bookingDate),
            _buildSummaryItem('Time', timeRange),
            if (widget.notes != null && widget.notes!.isNotEmpty)
              _buildSummaryItem('Notes', widget.notes!),
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
                  '${widget.totalAmount.toStringAsFixed(2)} ${widget.service.priceUnit ?? 'ETB'}',
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: _loadingMethods
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(),
                  const SizedBox(height: 24),
                  const Text(
                    'Select Payment Method',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map(_buildPaymentMethodCard),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _proceedToPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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
                          : const Text(
                              'Complete Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}