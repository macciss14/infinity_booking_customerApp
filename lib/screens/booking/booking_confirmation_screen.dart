// lib/screens/booking/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../services/service_service.dart';
import '../../models/service_model.dart';
import '../../utils/secure_storage.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class BookingConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> bookingData;
  const BookingConfirmationScreen({super.key, required this.bookingData});

  @override
  State<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState extends State<BookingConfirmationScreen> {
  final ServiceService _serviceService = ServiceService();
  final BookingService _bookingService = BookingService();
  late Future<ServiceModel> _serviceFuture;
  bool _isProcessing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _serviceFuture =
        _serviceService.getServiceById(widget.bookingData['serviceId']);
  }

  // In BookingConfirmationScreen.dart
  Future<void> _confirmBooking() async {
    setState(() => _isProcessing = true);
    try {
      // ✅ Remove customerId completely - backend gets it from token
      final bookingData = {
        'serviceId': widget.bookingData['serviceId'],
        'slotId': widget.bookingData['slotId'],
        if (widget.bookingData['notes'] != null)
          'notes': widget.bookingData['notes'],
      };

      await _bookingService.createBooking(bookingData);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Booking confirmed!')),
      );
      RouteHelper.pushReplacementNamed(context, RouteHelper.main);
    } catch (e) {
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking failed: $_error')),
      );
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        backgroundColor: AppColors.primary,
      ),
      body: FutureBuilder<ServiceModel>(
        future: _serviceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final service = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Booking Summary',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSummaryCard(
                  title: 'Service',
                  content: service.name,
                  icon: Icons.build,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  title: 'Provider',
                  content: service.providerName,
                  icon: Icons.person,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  title: 'Price',
                  content: '\$${service.price.toStringAsFixed(2)}',
                  icon: Icons.attach_money,
                  color: AppColors.secondary,
                ),
                const SizedBox(height: 16),
                _buildSummaryCard(
                  title: 'Time Slot',
                  content: _getSlotDisplay(),
                  icon: Icons.access_time,
                ),
                if (widget.bookingData['notes'] != null &&
                    widget.bookingData['notes'].isNotEmpty) ...[
                  const SizedBox(height: 16),
                  _buildSummaryCard(
                    title: 'Notes',
                    content: widget.bookingData['notes'],
                    icon: Icons.note,
                  ),
                ],
                const SizedBox(height: 32),
                if (_error != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.red, width: 1),
                    ),
                    child: Text(
                      'Error: $_error',
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _confirmBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryLight,
                      foregroundColor: Colors.white,
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child:
                                CircularProgressIndicator(color: Colors.white),
                          )
                        : const Text('Confirm & Pay'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String content,
    required IconData icon,
    Color? color,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: (color ?? AppColors.primary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color ?? AppColors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    content,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getSlotDisplay() {
    // You can enhance this if your slot object has more data
    return 'Selected slot';
  }
}
