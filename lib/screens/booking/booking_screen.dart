// lib/screens/booking/booking_screen.dart
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
  const BookingScreen({super.key, required this.serviceId});

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
  }

  void _handleSlotSelection(Map<String, dynamic>? slot) {
    setState(() {
      _selectedSlot = slot;
    });
  }

  void _proceedToPayment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    final service = await _serviceFuture;
    final double totalAmount = service.totalPrice;
    final String bookingDate = convertToDDMMYYYY(_selectedSlot!['date']);

    RouteHelper.goToPaymentMethod(
      context,
      service: service,
      selectedSlot: _selectedSlot!,
      totalAmount: totalAmount,
      bookingDate: bookingDate,
      notes: _notesController.text,
    );
  }

  void _skipPayment() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a time slot')));
      return;
    }

    final service = await _serviceFuture;
    final double totalAmount = service.totalPrice;
    final String bookingDate = convertToDDMMYYYY(_selectedSlot!['date']);

    RouteHelper.goToSkipPayment(
      context,
      service: service,
      selectedSlot: _selectedSlot!,
      totalAmount: totalAmount,
      bookingDate: bookingDate,
      notes: _notesController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Service'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<ServiceModel>(
        future: _serviceFuture,
        builder: (context, serviceSnapshot) {
          if (serviceSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (serviceSnapshot.hasError) {
            return _buildErrorWidget('Failed to load service');
          }
          final service = serviceSnapshot.data!;

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
                    // Service Summary
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(service.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 8),
                            Text(
                                'Provider: ${service.providerName ?? 'Unknown'}'),
                            const SizedBox(height: 8),
                            Text('Total: ${service.formattedTotalPrice}',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.secondary)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Time Slots
                    TimeSlotsDisplay(
                      service: service,
                      viewOnly: false,
                      existingBookings: existingBookings,
                      onSlotSelected: _handleSlotSelection,
                    ),
                    const SizedBox(height: 24),
                    // Notes
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: 'Booking Notes (Optional)',
                        hintText: 'Special instructions...',
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selectedSlot == null ? null : _proceedToPayment,
                  child: const Text('Proceed to Payment'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _selectedSlot == null ? null : _skipPayment,
                  child: const Text('Book Without Payment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(message, style: TextStyle(color: Colors.red[700])),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _serviceFuture =
                      _serviceService.getServiceById(widget.serviceId);
                });
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
