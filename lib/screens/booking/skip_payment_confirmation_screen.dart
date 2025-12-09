import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/booking_service.dart';
import './booking_confirmation_screen.dart';

class SkipPaymentConfirmationScreen extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic> selectedSlot;
  final double totalAmount;
  final String bookingDate;
  final String? notes;

  const SkipPaymentConfirmationScreen({
    super.key,
    required this.service,
    required this.selectedSlot,
    required this.totalAmount,
    required this.bookingDate,
    this.notes,
  });

  @override
  State<SkipPaymentConfirmationScreen> createState() => _SkipPaymentConfirmationScreenState();
}

class _SkipPaymentConfirmationScreenState extends State<SkipPaymentConfirmationScreen> {
  final BookingService _bookingService = BookingService();
  bool _loading = false;

  Future<void> _confirmSkipPayment() async {
    setState(() => _loading = true);

    try {
      // Create booking with skipPayment flag
      final booking = await _bookingService.createBooking(
        serviceId: widget.service.id,
        providerId: widget.service.providerId ?? '',
        bookingDate: widget.bookingDate,
        startTime: widget.selectedSlot['timeSlot']['startTime'],
        endTime: widget.selectedSlot['timeSlot']['endTime'],
        totalAmount: widget.totalAmount,
        notes: widget.notes,
        skipPayment: true,
      );

      // Navigate to confirmation screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => BookingConfirmationScreen(
            booking: booking,
            skipPayment: true,
          ),
        ),
      );
    } catch (error) {
      print('Error creating booking without payment: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${error.toString()}')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  void _goBack() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Skip Payment Confirmation'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: _goBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Warning Header
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.orange[800]),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Skip Payment Confirmation',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.orange[800],
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),

            // Warning Message
            Text(
              'You are about to create a booking without payment. This booking will be marked as "pending payment" and must be paid before the service date.',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            SizedBox(height: 20),

            // Booking Summary
            Card(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Booking Summary',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 12),
                    _buildSummaryRow('Service', widget.service.name),
                    _buildSummaryRow('Provider', widget.service.providerName ?? 'Unknown'),
                    _buildSummaryRow('Date', widget.bookingDate),
                    _buildSummaryRow('Time',
                        '${widget.selectedSlot['timeSlot']['startTime']} - ${widget.selectedSlot['timeSlot']['endTime']}'),
                    _buildSummaryRow('Payment Status', 'Pending Payment',
                        statusColor: Colors.orange),
                    if (widget.notes != null && widget.notes!.isNotEmpty)
                      _buildSummaryRow('Notes', widget.notes!),
                    Divider(height: 24),
                    _buildSummaryRow('Total Amount',
                        '${widget.totalAmount.toStringAsFixed(2)} ETB',
                        isTotal: true),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Important Notes
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.yellow[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Important Information',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.orange[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• This booking requires payment confirmation before the service date\n'
                    '• You can pay later from your bookings page\n'
                    '• Service provider may cancel if payment is not confirmed\n'
                    '• Cancellation policy still applies',
                    style: TextStyle(
                      color: Colors.orange[700],
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _goBack,
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.arrow_back, size: 18),
                        SizedBox(width: 8),
                        Text('Go Back'),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _loading ? null : _confirmSkipPayment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _loading
                        ? CircularProgressIndicator(color: Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check, size: 18),
                              SizedBox(width: 8),
                              Text('Confirm Booking'),
                            ],
                          ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value,
      {bool isTotal = false, Color? statusColor}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTotal ? 16 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: statusColor ?? (isTotal ? Colors.green : Colors.grey[900]),
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}