// lib/screens/booking/booking_screen.dart - FIXED VERSION
import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../services/booking_service.dart';
import '../../services/provider_service.dart';
import '../../models/service_model.dart';
import '../../models/provider_model.dart';
import '../../models/booking_model.dart';
import '../../widgets/time_slots_display.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';
import '../../utils/time_slots_utils.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String? providerId;
  final Map<String, dynamic>? providerData;
  final SelectedSlot? selectedSlot;
  final Map<String, dynamic>? bookingData;

  const BookingScreen({
    super.key,
    required this.serviceId,
    this.providerId,
    this.providerData,
    this.selectedSlot,
    this.bookingData,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final ServiceService _serviceService = ServiceService();
  final BookingService _bookingService = BookingService();
  final ProviderService _providerService = ProviderService();

  late Future<ServiceModel> _serviceFuture;
  late Future<List<BookingModel>> _bookingsFuture;

  final TextEditingController _notesController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  SelectedSlot? _selectedSlot;
  bool _bookingInProgress = false;
  bool _isLoading = true;
  bool _isLoadingProvider = true;
  String? _errorMessage;
  ProviderModel? _provider;
  List<BookingModel> _existingBookings = [];

  @override
  void initState() {
    super.initState();
    _initializeData();

    if (widget.selectedSlot != null) {
      _selectedSlot = widget.selectedSlot;
    }
  }

  void _initializeData() {
    setState(() {
      _isLoading = true;
      _isLoadingProvider = true;
      _errorMessage = null;
    });

    _serviceFuture = _serviceService.getServiceById(widget.serviceId);
    _bookingsFuture = _bookingService.getBookingsForService(widget.serviceId);

    _loadProviderDetails();

    _serviceFuture.then((service) {
      final effectiveProviderId =
          widget.providerId ?? service.providerPid ?? service.providerId ?? '';

      if (effectiveProviderId.isEmpty) {
        setState(() {
          _errorMessage =
              'Provider information is not available. Cannot proceed with booking.';
        });
      }

      setState(() => _isLoading = false);
    }).catchError((error) {
      setState(() {
        _errorMessage = 'Failed to load service details. Please try again.';
        _isLoading = false;
      });
    });

    _bookingsFuture.then((bookings) {
      setState(() {
        _existingBookings = bookings;
      });
    }).catchError((error) {
      print('⚠️ Could not load existing bookings: $error');
    });
  }

  Future<void> _loadProviderDetails() async {
    if (widget.providerId == null || widget.providerId!.isEmpty) {
      setState(() => _isLoadingProvider = false);
      return;
    }

    try {
      final provider =
          await _providerService.getProviderSmart(widget.providerId!);

      if (provider != null) {
        setState(() {
          _provider = provider;
        });
      } else {
        await _tryGetProviderFromService();
      }
    } catch (error) {
      await _tryGetProviderFromService();
    } finally {
      setState(() => _isLoadingProvider = false);
    }
  }

  Future<void> _tryGetProviderFromService() async {
    try {
      final service = await _serviceFuture;

      if (service.provider != null &&
          service.provider is Map<String, dynamic>) {
        final providerData = service.provider as Map<String, dynamic>;

        _provider = ProviderModel(
          id: providerData['_id']?.toString() ?? '',
          pid: providerData['pid']?.toString() ?? widget.providerId ?? '',
          fullname: providerData['fullname']?.toString() ??
              service.providerName ??
              'Unknown Provider',
          email: providerData['email']?.toString() ?? '',
          phonenumber: providerData['phonenumber']?.toString() ?? '',
          profilePhoto: providerData['profilePhoto']?.toString(),
          rating: providerData['rating'] != null
              ? (providerData['rating'] is num
                  ? providerData['rating'].toDouble()
                  : double.tryParse(providerData['rating'].toString()) ?? 0.0)
              : 0.0,
          reviewCount: _parseInt(providerData['reviewCount']),
          totalBookings: _parseInt(providerData['totalBookings']),
          isVerified: providerData['isVerified'] == true,
        );
      }
    } catch (error) {
      // Ignore error - we'll show fallback UI
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value.replaceAll(',', ''));
      } catch (_) {
        return 0;
      }
    }
    return 0;
  }

  void _handleSlotSelection(SelectedSlot? slot) {
    if (slot == null) {
      setState(() => _selectedSlot = null);
      return;
    }

    if (!TimeSlotsUtils.isValidTimeSlot(slot.timeSlot)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid time slot selected')),
      );
      return;
    }

    setState(() => _selectedSlot = slot);

    // Scroll to show selected slot info
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent * 0.8,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Map<String, dynamic> _prepareBookingData(ServiceModel service) {
    try {
      // Convert ProviderModel to Map<String, dynamic> for TimeSlotsUtils
      final Map<String, dynamic> providerMap = {};
      if (_provider != null) {
        providerMap['id'] = _provider!.id;
        providerMap['_id'] = _provider!.id;
        providerMap['pid'] = _provider!.pid;
        providerMap['fullname'] = _provider!.fullname;
        providerMap['email'] = _provider!.email;
        providerMap['phonenumber'] = _provider!.phonenumber;
      } else if (widget.providerData != null) {
        providerMap.addAll(widget.providerData!);
      }

      final bookingData = TimeSlotsUtils.prepareBookingData(
        selectedSlot: _selectedSlot!,
        service: service,
        provider: providerMap,
        customerId: 'current-user-id', // TODO: Replace with actual user ID
      );

      if (_notesController.text.trim().isNotEmpty) {
        bookingData['notes'] = _notesController.text.trim();
      }

      return bookingData;
    } catch (e) {
      print('❌ Error preparing booking data: $e');
      rethrow;
    }
  }

  Future<void> _proceedToPayment() async {
    if (_selectedSlot == null || _selectedSlot?.timeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final service = await _serviceFuture;
    final effectiveProviderId =
        widget.providerId ?? service.providerPid ?? service.providerId ?? '';

    if (effectiveProviderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Provider information unavailable. Cannot proceed.')),
      );
      return;
    }

    setState(() => _bookingInProgress = true);

    try {
      final double totalAmount = service.totalPrice;
      final bookingData = _prepareBookingData(service);

      // Get provider name for display
      String providerName = _provider?.fullname ??
          widget.providerData?['fullname'] ??
          'Service Provider';

      // Extract date and time from selected slot
      String bookingDate = '';
      Map<String, dynamic> selectedSlotData = {};

      if (_selectedSlot != null) {
        bookingDate = _selectedSlot!.date ?? '';
        if (_selectedSlot!.timeSlot != null) {
          selectedSlotData = {
            'startTime': _selectedSlot!.timeSlot!.startTime,
            'endTime': _selectedSlot!.timeSlot!.endTime,
            'date': _selectedSlot!.date,
          };
        }
      }

      print('💰 Proceeding to payment...');
      print('   Service: ${service.name}');
      print('   Provider ID: $effectiveProviderId');
      print('   Date: $bookingDate');
      print('   Time Slot: $selectedSlotData');
      print('   Amount: $totalAmount');

      // Use RouteHelper for navigation
      RouteHelper.goToPaymentMethod(
        context,
        service: service,
        selectedSlot: selectedSlotData,
        totalAmount: totalAmount,
        bookingDate: bookingDate,
        notes: _notesController.text.trim(),
        providerId: effectiveProviderId,
        providerName: providerName,
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
    if (_selectedSlot == null || _selectedSlot?.timeSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a time slot')),
      );
      return;
    }

    final service = await _serviceFuture;
    final effectiveProviderId =
        widget.providerId ?? service.providerPid ?? service.providerId ?? '';

    if (effectiveProviderId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Provider information unavailable. Cannot proceed.')),
      );
      return;
    }

    setState(() => _bookingInProgress = true);

    try {
      final double totalAmount = service.totalPrice;
      final bookingData = _prepareBookingData(service);

      // Get provider name for display
      String providerName = _provider?.fullname ??
          widget.providerData?['fullname'] ??
          'Service Provider';

      // Extract date and time from selected slot
      String bookingDate = '';
      Map<String, dynamic> selectedSlotData = {};

      if (_selectedSlot != null) {
        bookingDate = _selectedSlot!.date ?? '';
        if (_selectedSlot!.timeSlot != null) {
          selectedSlotData = {
            'startTime': _selectedSlot!.timeSlot!.startTime,
            'endTime': _selectedSlot!.timeSlot!.endTime,
            'date': _selectedSlot!.date,
          };
        }
      }

      print('⏭ Skipping payment...');
      print('   Service: ${service.name}');
      print('   Provider ID: $effectiveProviderId');
      print('   Date: $bookingDate');
      print('   Time Slot: $selectedSlotData');
      print('   Amount: $totalAmount');

      // Use RouteHelper for navigation
      RouteHelper.goToSkipPayment(
        context,
        service: service,
        selectedSlot: selectedSlotData,
        totalAmount: totalAmount,
        bookingDate: bookingDate,
        notes: _notesController.text.trim(),
        providerId: effectiveProviderId,
        providerName: providerName,
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

  String _formatSelectedSlot(SelectedSlot slot) {
    String formatted = '';

    if (slot.date != null) {
      try {
        final date = TimeSlotsUtils.parseDate(slot.date!);
        if (date != null) {
          formatted += TimeSlotsUtils.formatDateForDisplay(date);
        } else {
          formatted += slot.date!;
        }
      } catch (e) {
        formatted += slot.date!;
      }
    }

    if (slot.timeSlot != null) {
      final startTime = slot.timeSlot!.startTime;
      final endTime = slot.timeSlot!.endTime;
      if (startTime.isNotEmpty && endTime.isNotEmpty) {
        if (formatted.isNotEmpty) formatted += ' at ';
        formatted +=
            '${TimeSlotsUtils.formatTime(startTime)} - ${TimeSlotsUtils.formatTime(endTime)}';
      }
    }

    return formatted;
  }

  String get _providerDisplayName {
    if (_provider != null) return _provider!.fullname;
    if (widget.providerData != null &&
        widget.providerData!['fullname'] != null) {
      return widget.providerData!['fullname'];
    }
    return 'Service Provider';
  }

  double? get _providerRating => _provider?.rating;
  bool get _isProviderVerified => _provider?.isVerified ?? false;

  String get _providerInitials {
    final name = _providerDisplayName;
    if (name.isEmpty || name == 'Unknown Provider') return 'P';
    final parts =
        name.trim().split(' ').where((part) => part.isNotEmpty).toList();
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (name.length >= 2) return name.substring(0, 2).toUpperCase();
    return name.isNotEmpty ? name[0].toUpperCase() : 'P';
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (_bookingInProgress)
            Padding(
              padding: EdgeInsets.only(right: isSmallScreen ? 12 : 16),
              child: Center(
                child: SizedBox(
                  width: isSmallScreen ? 16 : 20,
                  height: isSmallScreen ? 16 : 20,
                  child: const CircularProgressIndicator(
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
                    if (serviceSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return _buildLoadingWidget();
                    }
                    if (serviceSnapshot.hasError || !serviceSnapshot.hasData) {
                      return _buildErrorWidget(
                          'Failed to load service details');
                    }

                    return _buildContent(serviceSnapshot.data!, screenSize);
                  },
                ),
      bottomNavigationBar: _buildBottomNavigationBar(screenSize),
    );
  }

  Widget _buildContent(ServiceModel service, Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    final padding = isSmallScreen ? 12.0 : 16.0;

    return SafeArea(
      child: Column(
        children: [
          // Selected Slot Banner (only if selected)
          if (_selectedSlot != null)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: padding,
                vertical: isSmallScreen ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.green[50],
                border: Border(
                  bottom: BorderSide(color: Colors.green[100]!),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: isSmallScreen ? 16 : 18,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Slot selected ✓',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.green[800],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handleSlotSelection(null),
                    child: Text(
                      'Change',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 13,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main Content
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: const ClampingScrollPhysics(),
              padding: EdgeInsets.all(padding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Service Card
                  _buildServiceCard(service, screenSize),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Time Slots Section
                  _buildTimeSlotsSection(service, screenSize),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Notes Section
                  _buildNotesSection(screenSize),
                  SizedBox(height: isSmallScreen ? 16 : 24),

                  // Selected Slot Details (if any)
                  if (_selectedSlot != null)
                    _buildSelectedSlotDetails(screenSize),

                  // Bottom spacing for navigation buttons
                  SizedBox(height: isSmallScreen ? 80 : 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(ServiceModel service, Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    final isMediumScreen = screenSize.width < 600;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Name
            Text(
              service.name,
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),

            // Provider Info
            _buildProviderInfo(screenSize),
            SizedBox(height: isSmallScreen ? 12 : 16),

            // Pricing Info
            _buildPricingInfo(service, screenSize),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Row(
      children: [
        // Avatar
        Container(
          width: isSmallScreen ? 36 : 40,
          height: isSmallScreen ? 36 : 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(isSmallScreen ? 18 : 20),
          ),
          child: Center(
            child: Text(
              _providerInitials,
              style: TextStyle(
                fontSize: isSmallScreen ? 14 : 16,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ),
        ),
        SizedBox(width: isSmallScreen ? 8 : 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name and Verification
              Row(
                children: [
                  Expanded(
                    child: Text(
                      _providerDisplayName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 15,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (_isProviderVerified)
                    Container(
                      margin: const EdgeInsets.only(left: 4),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 1),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(color: Colors.blue.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.verified,
                            size: 10,
                            color: Colors.blue,
                          ),
                          const SizedBox(width: 1),
                          Text(
                            'Verified',
                            style: TextStyle(
                              fontSize: 8,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              // Rating
              if (_providerRating != null && _providerRating! > 0)
                Padding(
                  padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.star,
                        size: isSmallScreen ? 10 : 12,
                        color: Colors.amber,
                      ),
                      SizedBox(width: isSmallScreen ? 2 : 4),
                      Text(
                        _providerRating!.toStringAsFixed(1),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 12,
                          color: Colors.grey,
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 2 : 4),
                      Text(
                        '(${_provider?.reviewCount ?? 0})',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 9 : 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

              // Loading Indicator
              if (_isLoadingProvider)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: isSmallScreen ? 12 : 16,
                        height: isSmallScreen ? 12 : 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 1.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      SizedBox(width: isSmallScreen ? 4 : 8),
                      Text(
                        'Loading details...',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 10 : 11,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPricingInfo(ServiceModel service, Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
      ),
      child: Column(
        children: [
          _buildPriceRow(
            'Service Price',
            service.formattedPrice,
            screenSize,
          ),
          SizedBox(height: isSmallScreen ? 4 : 6),
          if (service.bookingPrice != null && service.bookingPrice! > 0)
            _buildPriceRow(
              'Booking Fee',
              '${service.bookingPrice!.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
              screenSize,
            ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Divider(
            height: 1,
            color: Colors.grey[300],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          _buildPriceRow(
            'Total Amount',
            service.formattedTotalPrice,
            screenSize,
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, Size screenSize,
      {bool isTotal = false}) {
    final isSmallScreen = screenSize.width < 360;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 12 : 14,
            color: Colors.grey[700],
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? (isTotal ? 14 : 13) : (isTotal ? 16 : 14),
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.secondary : Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildTimeSlotsSection(ServiceModel service, Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select Time Slot',
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        TimeSlotsDisplay(
          service: service,
          existingBookings: _existingBookings,
          onSlotSelected: _handleSlotSelection,
        ),
      ],
    );
  }

  Widget _buildNotesSection(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Additional Notes (Optional)',
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: isSmallScreen ? 8 : 12),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 10),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: 4,
            minLines: 3,
            decoration: InputDecoration(
              hintText: 'Add any special instructions or notes...',
              contentPadding: EdgeInsets.all(isSmallScreen ? 10 : 12),
              border: InputBorder.none,
              hintStyle: TextStyle(
                fontSize: isSmallScreen ? 13 : 14,
                color: Colors.grey[500],
              ),
            ),
            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
          ),
        ),
      ],
    );
  }

  Widget _buildSelectedSlotDetails(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.event_available,
                size: isSmallScreen ? 18 : 20,
                color: AppColors.primary,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),
              Text(
                'Selected Time Slot',
                style: TextStyle(
                  fontSize: isSmallScreen ? 14 : 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.calendar_today,
                size: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Date',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatSelectedSlot(_selectedSlot!).split(' at ').first,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.access_time,
                size: isSmallScreen ? 14 : 16,
                color: Colors.grey[600],
              ),
              SizedBox(width: isSmallScreen ? 6 : 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Time',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        color: Colors.grey[600],
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      _formatSelectedSlot(_selectedSlot!).contains(' at ')
                          ? _formatSelectedSlot(_selectedSlot!)
                              .split(' at ')
                              .last
                          : '',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (_selectedSlot?.timeSlot != null) ...[
            SizedBox(height: isSmallScreen ? 8 : 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.timer,
                  size: isSmallScreen ? 14 : 16,
                  color: Colors.grey[600],
                ),
                SizedBox(width: isSmallScreen ? 6 : 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: isSmallScreen ? 11 : 12,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        TimeSlotsUtils.formatDuration(
                            TimeSlotsUtils.convertToMinutes(
                                    _selectedSlot!.timeSlot!.endTime) -
                                TimeSlotsUtils.convertToMinutes(
                                    _selectedSlot!.timeSlot!.startTime)),
                        style: TextStyle(
                          fontSize: isSmallScreen ? 13 : 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar(Size screenSize) {
    final isSmallScreen = screenSize.width < 360;
    final isButtonDisabled = _bookingInProgress || _selectedSlot == null;

    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
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
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
              ),
              child: _bookingInProgress
                  ? SizedBox(
                      height: isSmallScreen ? 20 : 24,
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      ),
                    )
                  : Text(
                      'Proceed to Payment',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 15 : 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 12),

          // Book Without Payment Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isButtonDisabled ? null : _skipPayment,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  vertical: isSmallScreen ? 14 : 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                ),
                side: BorderSide(color: AppColors.primary),
              ),
              child: Text(
                'Book Without Payment',
                style: TextStyle(
                  fontSize: isSmallScreen ? 15 : 16,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Help Text
          Padding(
            padding: EdgeInsets.only(top: isSmallScreen ? 8 : 12),
            child: Text(
              _selectedSlot == null
                  ? 'Select a time slot to proceed'
                  : 'Ready to book! Choose payment option',
              style: TextStyle(
                fontSize: isSmallScreen ? 11 : 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
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

  Widget _buildErrorWidget(String message) {
    return SingleChildScrollView(
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
    );
  }

  Widget _buildCriticalErrorWidget() {
    return SingleChildScrollView(
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
            _errorMessage ??
                'Provider information is missing. Cannot proceed with booking.',
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
    );
  }

  @override
  void dispose() {
    _notesController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}