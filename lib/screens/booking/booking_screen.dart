// lib/screens/booking/booking_screen.dart - OPTIMIZED VERSION
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
  final Map<String, dynamic>? providerData; // ✅ Optional: Complete provider data

  const BookingScreen({
    super.key,
    required this.serviceId,
    this.providerId, // ✅ Accept the provider PID
    this.providerData, // ✅ Accept complete provider data
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
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    print('📋 BookingScreen initialization:');
    print('   - Service ID: ${widget.serviceId}');
    print('   - Provider ID: ${widget.providerId}');
    print('   - Provider Data: ${widget.providerData != null ? "Available" : "Not available"}');
    
    if (widget.providerId == null || widget.providerId!.isEmpty) {
      print('⚠️ WARNING: No providerId received from ServiceDetailScreen!');
      print('⚠️ This may cause 400 errors when creating booking.');
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    _serviceFuture = _serviceService.getServiceById(widget.serviceId);
    _bookingsFuture = _bookingService.getUserBookings();

    _serviceFuture.then((service) {
      print('✅ Service loaded: ${service.name}');
      
      // Log provider information for debugging
      if (service.providerId != null) {
        print('📊 Service has providerId: ${service.providerId}');
      }
      if (service.providerPid != null) {
        print('📊 Service has providerPid: ${service.providerPid}');
      }
      
      // Check if we have provider ID from any source
      final effectiveProviderId = widget.providerId ?? 
                                 service.providerPid ?? 
                                 service.providerId ?? '';
      
      if (effectiveProviderId.isEmpty) {
        print('❌ CRITICAL: No provider ID available for booking!');
        setState(() {
          _errorMessage = 'Provider information is not available. Cannot proceed with booking.';
        });
      } else if (!effectiveProviderId.startsWith('PROV-')) {
        print('⚠️ Provider ID "$effectiveProviderId" doesn\'t start with PROV-');
        print('⚠️ This may cause 400 errors in backend.');
      }
      
      setState(() => _isLoading = false);
    }).catchError((error) {
      print('❌ Error loading service: $error');
      setState(() {
        _errorMessage = 'Failed to load service details. Please try again.';
        _isLoading = false;
      });
    });
  }

  void _handleSlotSelection(Map<String, dynamic>? slot) {
    if (slot == null) {
      setState(() => _selectedSlot = null);
      return;
    }

    print('🎯 Time slot selected:');
    print('   - Date: ${slot['date']}');
    print('   - Time: ${slot['time']}');
    print('   - Day: ${slot['day']}');

    setState(() => _selectedSlot = slot);
  }

  Future<void> _proceedToPayment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    // Validate provider ID before proceeding
    final effectiveProviderId = widget.providerId ?? 
                               (await _serviceFuture).providerPid ?? 
                               (await _serviceFuture).providerId ?? '';
    
    if (effectiveProviderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider information unavailable. Cannot proceed.')),
      );
      return;
    }

    setState(() => _bookingInProgress = true);
    
    try {
      final service = await _serviceFuture;
      final double totalAmount = service.totalPrice;
      final String bookingDate = convertToDDMMYYYY(_selectedSlot!['date']);

      print('💰 Proceeding to payment:');
      print('   - Provider ID: $effectiveProviderId');
      print('   - Service: ${service.name}');
      print('   - Date: $bookingDate');
      print('   - Total: $totalAmount ETB');
      
      // ✅ FIXED: Pass providerId to PaymentMethodScreen
      RouteHelper.goToPaymentMethod(
        context,
        service: service,
        selectedSlot: _selectedSlot!,
        totalAmount: totalAmount,
        bookingDate: bookingDate,
        notes: _notesController.text.trim(),
        providerId: effectiveProviderId, // ✅ Critical for fixing 400 error
      );
    } catch (error) {
      print('❌ Error proceeding to payment: $error');
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

    // Validate provider ID before proceeding
    final effectiveProviderId = widget.providerId ?? 
                               (await _serviceFuture).providerPid ?? 
                               (await _serviceFuture).providerId ?? '';
    
    if (effectiveProviderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Provider information unavailable. Cannot proceed.')),
      );
      return;
    }

    setState(() => _bookingInProgress = true);
    
    try {
      final service = await _serviceFuture;
      final double totalAmount = service.totalPrice;
      final String bookingDate = convertToDDMMYYYY(_selectedSlot!['date']);

      print('⏭ Skipping payment:');
      print('   - Provider ID: $effectiveProviderId');
      print('   - Service: ${service.name}');
      print('   - Date: $bookingDate');
      print('   - Total: $totalAmount ETB');
      
      // ✅ FIXED: Pass providerId to SkipPaymentConfirmationScreen
      RouteHelper.goToSkipPayment(
        context,
        service: service,
        selectedSlot: _selectedSlot!,
        totalAmount: totalAmount,
        bookingDate: bookingDate,
        notes: _notesController.text.trim(),
        providerId: effectiveProviderId, // ✅ Critical for fixing 400 error
      );
    } catch (error) {
      print('❌ Error skipping payment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _bookingInProgress = false);
      }
    }
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

  Widget _buildProviderInfo(ServiceModel service) {
    final providerName = service.displayProviderName;
    final isVerified = service.isProviderVerified;
    final providerRating = service.providerRating;

    return Row(
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
              style: const TextStyle(
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
                          const Icon(
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
              if (providerRating != null && providerRating > 0)
                Row(
                  children: [
                    const Icon(
                      Icons.star,
                      size: 12,
                      color: Colors.amber,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      providerRating.toStringAsFixed(1),
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
    );
  }

  Widget _buildPricingInfo(ServiceModel service) {
    return Container(
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
          if (service.bookingPrice != null && service.bookingPrice! > 0)
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
              const Text(
                'Total Amount',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                service.formattedTotalPrice,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedSlotInfo() {
    return Container(
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
          const Icon(
            Icons.calendar_today,
            size: 20,
            color: AppColors.primary,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Selected: ${_formatSelectedSlot(_selectedSlot!)}',
              style: const TextStyle(
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
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
      ],
    );
  }

  Widget _buildBottomNavigationBar() {
    final isButtonDisabled = _bookingInProgress || _selectedSlot == null;
    
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
                onPressed: isButtonDisabled ? null : _proceedToPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _bookingInProgress
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
                onPressed: isButtonDisabled ? null : _skipPayment,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: AppColors.primary),
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
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                _selectedSlot == null
                    ? 'Select a time slot to proceed with booking'
                    : 'Ready to book! Select payment option above',
                style: const TextStyle(
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
              onPressed: _initializeData,
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

  Widget _buildCriticalErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning_amber,
              size: 64,
              color: Colors.orange[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Booking Not Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromARGB(255, 92, 91, 91),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage ?? 'Provider information is missing. Cannot proceed with booking.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Go Back',
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

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading booking details...'),
        ],
      ),
    );
  }

  Widget _buildServiceDetails(ServiceModel service) {
    return FutureBuilder<List<dynamic>>(
      future: _bookingsFuture,
      builder: (context, bookingsSnapshot) {
        final existingBookings = bookingsSnapshot.hasData ? bookingsSnapshot.data! : [];
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
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
                      
                      // Provider Info
                      _buildProviderInfo(service),
                      const SizedBox(height: 16),
                      
                      // Pricing Information
                      _buildPricingInfo(service),
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
              _buildNotesSection(),
              
              const SizedBox(height: 20),
              
              // Selected Slot Info (if any)
              if (_selectedSlot != null) _buildSelectedSlotInfo(),
              
              const SizedBox(height: 100), // Space for bottom buttons
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          if (_bookingInProgress)
            const Padding(
              padding: EdgeInsets.only(right: 16),
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
      body: _isLoading
          ? _buildLoadingWidget()
          : _errorMessage != null
              ? _buildCriticalErrorWidget()
              : FutureBuilder<ServiceModel>(
                  future: _serviceFuture,
                  builder: (context, serviceSnapshot) {
                    if (serviceSnapshot.connectionState == ConnectionState.waiting) {
                      return _buildLoadingWidget();
                    }
                    if (serviceSnapshot.hasError) {
                      return _buildErrorWidget('Failed to load service details');
                    }
                    if (!serviceSnapshot.hasData) {
                      return _buildErrorWidget('Service not found');
                    }
                    
                    return _buildServiceDetails(serviceSnapshot.data!);
                  },
                ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }
}