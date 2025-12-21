// lib/screens/booking/booking_screen.dart - FIXED TO PASS PROVIDERID
import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../services/booking_service.dart';
import '../../models/service_model.dart';
import '../../widgets/time_slots_display.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';
import '../../utils/time_slots_utils.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String? providerId; // ✅ Critical: Real PID from ServiceDetailScreen

  const BookingScreen({
    super.key,
    required this.serviceId,
    this.providerId, // ✅ Accept the provider PID
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ServiceService _serviceService = ServiceService();
  final BookingService _bookingService = BookingService();
  late Future<ServiceModel> _serviceFuture;
  late Future<List<dynamic>> _bookingsFuture;
  final TextEditingController _notesController = TextEditingController();
  Map<String, dynamic>? _selectedSlot;
  bool _bookingInProgress = false;

  @override
  void initState() {
    super.initState();
    _serviceFuture = _serviceService.getServiceById(widget.serviceId);
    _bookingsFuture = _bookingService.getUserBookings();
    
    // 🔥 Log the received providerId for debugging
    print('📋 BookingScreen received providerId: ${widget.providerId}');
    if (widget.providerId == null || widget.providerId!.isEmpty) {
      print('⚠️ WARNING: No providerId received from ServiceDetailScreen!');
    }
  }

  void _handleSlotSelection(Map<String, dynamic>? slot) {
    setState(() {
      _selectedSlot = slot;
    });
  }

  Future<void> _proceedToPayment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    try {
      setState(() => _bookingInProgress = true);
      
      final service = await _serviceFuture;
      
      // 🔥 CRITICAL: Use the providerId from constructor (real PID like "PROV-123")
      final String providerId = widget.providerId ?? service.providerPid ?? service.providerId ?? '';
      
      if (providerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider information unavailable. Cannot proceed.')),
        );
        return;
      }

      final double totalAmount = service.totalPrice;
      final String bookingDate = convertToDDMMYYYY(_selectedSlot!['date']);

      print('💰 Proceeding to payment with providerId: $providerId');
      
      // 🔥 FIXED: Pass providerId to PaymentMethodScreen
      RouteHelper.goToPaymentMethod(
        context,
        service: service,
        selectedSlot: _selectedSlot!,
        totalAmount: totalAmount,
        bookingDate: bookingDate,
        notes: _notesController.text.trim(),
        providerId: providerId, // ✅ Pass providerId to payment
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _bookingInProgress = false);
      }
    }
  }

  Future<void> _skipPayment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    try {
      setState(() => _bookingInProgress = true);
      
      final service = await _serviceFuture;
      
      // 🔥 CRITICAL: Use the providerId from constructor
      final String providerId = widget.providerId ?? service.providerPid ?? service.providerId ?? '';
      
      if (providerId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider information unavailable. Cannot skip payment.')),
        );
        return;
      }

      final double totalAmount = service.totalPrice;
      final String bookingDate = convertToDDMMYYYY(_selectedSlot!['date']);

      print('⏭ Skipping payment with providerId: $providerId');
      
      // 🔥 FIXED: Pass providerId to SkipPaymentConfirmationScreen
      RouteHelper.goToSkipPayment(
        context,
        service: service,
        selectedSlot: _selectedSlot!,
        totalAmount: totalAmount,
        bookingDate: bookingDate,
        notes: _notesController.text.trim(),
        providerId: providerId, // ✅ Pass providerId to skip payment
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _bookingInProgress = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.primary,
        actions: [
          if (_bookingInProgress)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: FutureBuilder<ServiceModel>(
        future: _serviceFuture,
        builder: (context, serviceSnapshot) {
          if (serviceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          if (serviceSnapshot.hasError) {
            return _buildErrorWidget('Failed to load service');
          }
          final service = serviceSnapshot.data!;

          // Get provider info (DO NOT SHOW PID TO CUSTOMERS)
          final providerName = service.displayProviderName;
          final isVerified = service.isProviderVerified;

          return FutureBuilder<List<dynamic>>(
            future: _bookingsFuture,
            builder: (context, bookingsSnapshot) {
              final existingBookings =
                  bookingsSnapshot.hasData ? bookingsSnapshot.data! : [];
              return SingleChildScrollView(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Summary Card
                    Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Service Name
                            Text(
                              service.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 12),
                            
                            // Provider Info (NO PID DISPLAYED)
                            Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Center(
                                    child: Text(
                                      service.providerInitials,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              providerName,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w600,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          if (isVerified)
                                            Container(
                                              margin: const EdgeInsets.only(left: 8),
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 6,
                                                vertical: 2,
                                              ),
                                              decoration: BoxDecoration(
                                                color: Colors.blue[50],
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.verified,
                                                    size: 12,
                                                    color: Colors.blue,
                                                  ),
                                                  const SizedBox(width: 2),
                                                  Text(
                                                    'Verified',
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight: FontWeight.bold,
                                                      color: Colors.blue[700],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      if (service.providerRating != null &&
                                          service.providerRating! > 0)
                                        Row(
                                          children: [
                                            Icon(
                                              Icons.star,
                                              size: 12,
                                              color: Colors.amber,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              service.providerRating!.toStringAsFixed(1),
                                              style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Pricing Information
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Service Price',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                      Text(
                                        service.formattedPrice,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  if (service.bookingPrice != null &&
                                      service.bookingPrice! > 0)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Booking Fee',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        Text(
                                          '${service.bookingPrice!.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  const SizedBox(height: 8),
                                  const Divider(height: 1),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Total Amount',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        service.formattedTotalPrice,
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Time Slots Section
                    const Text(
                      'Select Time Slot',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TimeSlotsDisplay(
                      service: service,
                      viewOnly: false,
                      existingBookings: existingBookings,
                      onSlotSelected: _handleSlotSelection,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Notes Section
                    const Text(
                      'Additional Notes (Optional)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: _notesController,
                        maxLines: 4,
                        minLines: 3,
                        decoration: const InputDecoration(
                          hintText: 'Add any special instructions or notes for the provider...',
                          contentPadding: EdgeInsets.all(12),
                          border: InputBorder.none,
                        ),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Selected Slot Info (if any)
                    if (_selectedSlot != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.primary.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 20,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Selected: ${_formatSelectedSlot(_selectedSlot!)}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 18,
                                color: Colors.grey[600],
                              ),
                              onPressed: () => _handleSlotSelection(null),
                            ),
                          ],
                        ),
                      ),
                    
                    const SizedBox(height: 100), // Space for bottom buttons
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  String _formatSelectedSlot(Map<String, dynamic> slot) {
    final date = slot['date'];
    final time = slot['time'];
    final day = slot['day'];
    
    String formatted = '';
    if (date != null) {
      formatted += convertToDDMMYYYY(date);
    }
    if (day != null) {
      if (formatted.isNotEmpty) formatted += ' ($day)';
      if (time != null) formatted += ' at $time';
    }
    
    return formatted;
  }

  Widget _buildBottomNavigationBar() {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Proceed to Payment Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookingInProgress || _selectedSlot == null
                    ? null
                    : _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _bookingInProgress
                    ? Row(
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
                          const SizedBox(width: 12),
                          const Text('Processing...'),
                        ],
                      )
                    : const Text(
                        'Proceed to Payment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Book Without Payment Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _bookingInProgress || _selectedSlot == null
                    ? null
                    : _skipPayment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: AppColors.primary),
                ),
                child: const Text(
                  'Book Without Payment',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            
            // Help Text
            const Padding(
              padding: EdgeInsets.only(top: 12),
              child: Text(
                'Select a time slot to proceed with booking',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Service Unavailable',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _serviceFuture = _serviceService.getServiceById(widget.serviceId);
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}