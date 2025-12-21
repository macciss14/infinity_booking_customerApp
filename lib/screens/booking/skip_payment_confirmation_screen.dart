// lib/screens/booking/skip_payment_confirmation_screen.dart - COMPLETE FIXED VERSION
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class SkipPaymentConfirmationScreen extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic> selectedSlot;
  final double totalAmount;
  final String bookingDate;
  final String? notes;
  final String? providerId;

  const SkipPaymentConfirmationScreen({
    super.key,
    required this.service,
    required this.selectedSlot,
    required this.totalAmount,
    required this.bookingDate,
    this.notes,
    this.providerId,
  });

  @override
  State<SkipPaymentConfirmationScreen> createState() =>
      _SkipPaymentConfirmationScreenState();
}

class _SkipPaymentConfirmationScreenState
    extends State<SkipPaymentConfirmationScreen> {
  final BookingService _bookingService = BookingService();
  bool _loading = false;

  Future<void> _confirmBooking() async {
    // Extract time slot data
    final timeSlot = widget.selectedSlot['timeSlot'] ?? widget.selectedSlot;
    final startTime = timeSlot['startTime']?.toString() ?? '';
    final endTime = timeSlot['endTime']?.toString() ?? '';
    
    if (startTime.isEmpty || endTime.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time slot selected')),
      );
      return;
    }

    // Get provider ID with fallback
    final String providerId = widget.providerId ?? 
                            widget.service.providerPid ?? 
                            widget.service.providerId ?? '';
    
    if (providerId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider information is missing')),
      );
      return;
    }

    setState(() => _loading = true);

    try {
      print('📋 Creating booking without payment...');
      print('   - Provider ID: $providerId');
      print('   - Date: ${widget.bookingDate}');
      print('   - Time: $startTime - $endTime');
      
      final booking = await _bookingService.createBooking(
        serviceId: widget.service.id,
        providerId: providerId,
        bookingDate: widget.bookingDate,
        startTime: startTime,
        endTime: endTime,
        totalAmount: widget.totalAmount,
        notes: widget.notes,
        skipPayment: true,
      );

      print('✅ Booking created successfully: ${booking.id}');
      
      RouteHelper.goToBookingConfirmation(
        context,
        booking: booking,
        skipPayment: true,
      );
    } catch (error) {
      print('❌ Booking creation failed: $error');
      
      String errorMessage = 'Failed to create booking';
      if (error.toString().contains('providerId')) {
        errorMessage = 'Provider information error. Please go back and try again.';
      } else if (error.toString().contains('400')) {
        errorMessage = 'Invalid booking data. Please check your selection.';
      } else if (error.toString().contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _goBack() {
    Navigator.pop(context);
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
            Text(
              'Booking Summary',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem('Service', widget.service.name),
            _buildSummaryItem('Provider', widget.service.displayProviderName),
            _buildSummaryItem('Date', widget.bookingDate),
            _buildSummaryItem('Time', timeRange),
            _buildSummaryItem(
              'Payment Status',
              'Pending Payment',
              valueColor: Colors.orange,
            ),
            if (widget.notes != null && widget.notes!.isNotEmpty)
              _buildSummaryItem('Notes', widget.notes!),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Amount',
                  style: const TextStyle(
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

  Widget _buildSummaryItem(String label, String value, {Color? valueColor}) {
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
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: valueColor,
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
        title: const Text('Skip Payment Confirmation'),
        backgroundColor: AppColors.primary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.orange.withOpacity(0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Colors.orange,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'You are booking without payment. Payment must be completed before the service date.',
                      style: TextStyle(
                        color: Colors.orange[800],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Booking Summary
            _buildBookingSummary(),
            
            const SizedBox(height: 24),
            
            // Important Information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Information',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• This booking requires payment confirmation before service\n'
                    '• You can pay later from your bookings page\n'
                    '• Provider may cancel if payment is not confirmed\n'
                    '• Standard cancellation policies apply',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _loading ? null : _goBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: Colors.grey[400]!),
                    ),
                    child: const Text(
                      'Go Back',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _loading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Confirm Booking',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}