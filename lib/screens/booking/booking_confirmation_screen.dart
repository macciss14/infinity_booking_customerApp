import 'package:flutter/material.dart';
import '../../models/booking_model.dart';

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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: 60),

            // Success Icon
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                size: 60,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 24),

            // Title
            Text(
              skipPayment ? 'Booking Created!' : 'Booking Confirmed!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 12),

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
            SizedBox(height: 40),

            // Booking Details Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Booking Reference
                    if (booking.bookingReference != null)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt, color: Colors.blue, size: 16),
                            SizedBox(width: 8),
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
                    SizedBox(height: 20),

                    // Service Details
                    _buildDetailRow(
                      icon: Icons.build,
                      label: 'Service',
                      value: booking.serviceName,
                    ),
                    _buildDetailRow(
                      icon: Icons.person,
                      label: 'Provider',
                      value: booking.providerName,
                    ),
                    _buildDetailRow(
                      icon: Icons.calendar_today,
                      label: 'Date',
                      value: booking.formattedBookingDate,
                    ),
                    _buildDetailRow(
                      icon: Icons.schedule,
                      label: 'Time',
                      value: booking.formattedTimeRange,
                    ),
                    _buildDetailRow(
                      icon: Icons.payment,
                      label: 'Amount',
                      value: '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                    ),
                    _buildDetailRow(
                      icon: Icons.star,
                      label: 'Status',
                      value: booking.status.toUpperCase(),
                      valueColor: Color(int.parse(booking.statusColor.replaceAll('#', '0xFF'))),
                    ),
                    SizedBox(height: 20),

                    // Payment Status
                    if (skipPayment)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.orange[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange[800], size: 20),
                            SizedBox(width: 12),
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
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green[800], size: 20),
                            SizedBox(width: 12),
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
            SizedBox(height: 40),

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
                      backgroundColor: Theme.of(context).primaryColor,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'View My Bookings',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12),
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
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
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

            SizedBox(height: 60),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
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
          ),
        ],
      ),
    );
  }
}