// lib/screens/booking/skip_payment_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart'; // Make sure this is imported
import '../../models/provider_model.dart'; 
import '../../services/booking_service.dart';
import '../../services/provider_service.dart'; 
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class SkipPaymentConfirmationScreen extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic> selectedSlot;
  final double totalAmount;
  final String bookingDate;
  final String? notes;
  final String? providerId;
  final String? providerName;

  const SkipPaymentConfirmationScreen({
    super.key,
    required this.service,
    required this.selectedSlot,
    required this.totalAmount,
    required this.bookingDate,
    this.notes,
    this.providerId,
    this.providerName,
  });

  @override
  State<SkipPaymentConfirmationScreen> createState() =>
      _SkipPaymentConfirmationScreenState();
}

class _SkipPaymentConfirmationScreenState
    extends State<SkipPaymentConfirmationScreen> {
  final BookingService _bookingService = BookingService();
  final ProviderService _providerService = ProviderService();
  
  bool _loading = false;
  bool _isLoadingProvider = true;
  String? _providerDisplayName;
  ProviderModel? _provider;

  @override
  void initState() {
    super.initState();
    _loadProviderDetails();
  }

  Future<void> _loadProviderDetails() async {
    if (widget.providerId == null || widget.providerId!.isEmpty) {
      setState(() {
        _providerDisplayName = widget.providerName ?? widget.service.displayProviderName;
        _isLoadingProvider = false;
      });
      return;
    }

    try {
      debugPrint('🔄 Loading provider details for ID: ${widget.providerId}');
      final provider = await _providerService.getProviderSmart(widget.providerId!);
      
      if (provider != null) {
        setState(() {
          _provider = provider;
          _providerDisplayName = provider.fullname;
          debugPrint('✅ Loaded provider: $_providerDisplayName');
        });
      } else {
        // Fallback to provided name or service name
        setState(() {
          _providerDisplayName = widget.providerName ?? widget.service.displayProviderName;
          debugPrint('⚠️ Using fallback provider name: $_providerDisplayName');
        });
      }
    } catch (error) {
      debugPrint('❌ Error loading provider: $error');
      setState(() {
        _providerDisplayName = widget.providerName ?? widget.service.displayProviderName;
      });
    } finally {
      setState(() => _isLoadingProvider = false);
    }
  }

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
    debugPrint('🔍 Provider ID for skip payment booking: $providerId');
    debugPrint('🔍 Provider ID starts with PROV-: ${providerId.startsWith('PROV-')}');

    setState(() => _loading = true);

    try {
      debugPrint('📋 Creating booking without payment...');
      debugPrint('   - Service ID: ${widget.service.id}');
      debugPrint('   - Provider ID: $providerId');
      debugPrint('   - Provider Name: $_providerDisplayName');
      debugPrint('   - Date: ${widget.bookingDate}');
      debugPrint('   - Time: $startTime - $endTime');
      debugPrint('   - Amount: ${widget.totalAmount}');
      
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

      debugPrint('✅ Booking created successfully: ${booking.id}');
      debugPrint('✅ Booking status: ${booking.status}');
      
      RouteHelper.goToBookingConfirmation(
        context,
        booking: booking,
        skipPayment: true,
      );
    } catch (error) {
      debugPrint('❌ Booking creation failed: $error');
      
      String errorMessage = 'Failed to create booking. Please try again.';
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
      } else if (error.toString().contains('No provider')) {
        errorMessage = 'Provider not found. Please select a different service.';
      } else if (error.toString().contains('No available slots')) {
        errorMessage = 'Time slot no longer available. Please select another time.';
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Retry',
            textColor: Colors.white,
            onPressed: _confirmBooking,
          ),
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
            const Text(
              'Booking Summary',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildSummaryItem('Service', widget.service.name),
            
            // Provider Info with loading state
            if (_isLoadingProvider)
              _buildSummaryItem('Provider', 'Loading...')
            else
              _buildSummaryItem('Provider', _providerDisplayName ?? widget.service.displayProviderName),
            
            _buildSummaryItem('Date', widget.bookingDate),
            _buildSummaryItem('Time', timeRange),
            _buildSummaryItem(
              'Payment Status',
              'Pending Payment',
              valueColor: Colors.orange,
            ),
            if (widget.notes != null && widget.notes!.isNotEmpty)
              _buildSummaryItem('Notes', widget.notes!),
            
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
                  if (_provider!.address?.isNotEmpty == true)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _provider!.address!,
                              style: const TextStyle(fontSize: 14),
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
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: valueColor,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pending Payment Booking',
                          style: TextStyle(
                            color: Colors.orange[800],
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Payment must be completed before the service date to confirm your booking.',
                          style: TextStyle(
                            color: Colors.orange[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
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
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange[700], size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Important Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoItem('• This booking requires payment confirmation before service'),
                        _buildInfoItem('• You can pay later from your bookings page'),
                        _buildInfoItem('• Provider may cancel if payment is not confirmed'),
                        _buildInfoItem('• Standard cancellation policies apply'),
                        if (widget.service.cancellationPolicy?.isNotEmpty == true)
                          _buildInfoItem('• Cancellation Policy: ${widget.service.cancellationPolicy}'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Action Buttons
            Column(
              children: [
                ElevatedButton(
                  onPressed: _loading ? null : _confirmBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: const Size(double.infinity, 56),
                  ),
                  child: _loading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confirm Booking Without Payment',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading ? null : _goBack,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    minimumSize: const Size(double.infinity, 48),
                  ),
                  child: const Text(
                    'Go Back and Select Payment Method',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
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

  Widget _buildInfoItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.grey,
          height: 1.5,
        ),
      ),
    );
  }
}