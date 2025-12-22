// lib/screens/booking/booking_confirmation_screen.dart
import 'package:flutter/material.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';

class BookingConfirmationScreen extends StatelessWidget {
  final BookingModel booking;
  final Map<String, dynamic>? paymentResult;
  final bool skipPayment;

  const BookingConfirmationScreen({
    super.key,
    required this.booking,
    this.paymentResult,
    this.skipPayment = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(skipPayment ? 'Booking Created' : 'Booking Confirmed'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          children: [
            const SizedBox(height: 24),

            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              skipPayment ? 'Booking Created!' : 'Booking Confirmed!',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),

            // Subtitle
            Text(
              skipPayment
                  ? 'Your booking has been created successfully. Please complete payment before the service date.'
                  : 'Your booking has been confirmed successfully.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            // Booking Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Booking Reference
                    if (booking.bookingReference != null)
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.receipt, color: Colors.blue, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Booking ID: ${booking.bookingReference}',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),

                    // Service Details
                    _buildDetailRow(
                      context: context,
                      icon: Icons.build,
                      label: 'Service',
                      value: booking.serviceName,
                    ),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.person,
                      label: 'Provider',
                      value: booking.providerName,
                    ),
                    // 🔥 NEW: Show Provider ID (matches Vue.js)
                    ...[
                    _buildDetailRow(
                      context: context,
                      icon: Icons.person_outline,
                      label: 'Provider ID',
                      value: booking.providerId!,
                    ),
                  ],
                    _buildDetailRow(
                      context: context,
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: booking.formattedBookingDate,
                    ),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.schedule,
                      label: 'Time',
                      value: booking.formattedTimeRange,
                    ),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.payment,
                      label: 'Amount',
                      value:
                          '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                    ),
                    _buildDetailRow(
                      context: context,
                      icon: Icons.star,
                      label: 'Status',
                      value: booking.status.toUpperCase(),
                      valueColor: _getStatusColor(booking.status),
                    ),
                    const SizedBox(height: 20),

                    // Payment Status
                    if (skipPayment)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning,
                                color: Colors.orange[800], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Payment Pending - Please complete payment before the service date',
                                style: TextStyle(
                                  color: Colors.orange[800],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else if (paymentResult != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle,
                                color: Colors.green[800], size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Payment Successful',
                                style: TextStyle(
                                  color: Colors.green[800],
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
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
            const SizedBox(height: 32),

            // Action Buttons
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to bookings screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/bookings',
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'View My Bookings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      // Go back to home
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/home',
                        (route) => false,
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Back to Home',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: valueColor ?? Colors.grey[900],
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
          ),
        ],
      ),
    );
  }

  // 🔥 NEW: Get status color (matches Vue.js)
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
      case 'completed':
        return Colors.green;
      case 'pending':
      case 'pending_payment':
        return Colors.orange;
      case 'cancelled':
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
