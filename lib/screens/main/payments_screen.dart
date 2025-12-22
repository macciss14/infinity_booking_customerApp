// lib/screens/payments/payments_screen.dart
import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({super.key});

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _pendingPayments = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments() async {
    setState(() => _loading = true);
    try {
      final bookings = await _bookingService.getUserBookings();
      _pendingPayments = bookings.where((b) => b.isPendingPayment).toList();
      print('✅ Loaded ${_pendingPayments.length} pending payments');
    } catch (error) {
      print('❌ Error loading payments: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load payments: $error'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _refreshPayments() async {
    await _loadPendingPayments();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshPayments,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshPayments,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _pendingPayments.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.payment, size: 64, color: Colors.green),
                        SizedBox(height: 16),
                        Text(
                          'No Pending Payments',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'All your payments are up to date',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _pendingPayments.length,
                    itemBuilder: (context, index) {
                      return _buildPaymentCard(_pendingPayments[index]);
                    },
                  ),
      ),
    );
  }

  Widget _buildPaymentCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Payment Pending',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Provider: ${booking.providerName}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Date: ${booking.formattedBookingDate}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Text(
              'Time: ${booking.formattedTimeRange}',
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 12),
            const Divider(color: Colors.grey),
            const SizedBox(height: 12),
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
                  '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _processPayment(booking);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Pay Now',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _processPayment(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Process Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select payment method:'),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.phone_android),
              title: const Text('Telebirr'),
              onTap: () {
                RouteHelper.pop(context);
                _initiateTelebirrPayment(booking);
              },
            ),
            ListTile(
              leading: const Icon(Icons.credit_card),
              title: const Text('Chapa'),
              onTap: () {
                RouteHelper.pop(context);
                _initiateChapaPayment(booking);
              },
            ),
            ListTile(
              leading: const Icon(Icons.money),
              title: const Text('Cash'),
              onTap: () {
                RouteHelper.pop(context);
                _markAsCashPayment(booking);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => RouteHelper.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _initiateTelebirrPayment(BookingModel booking) {
    // TODO: Implement Telebirr payment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Telebirr payment coming soon')),
    );
  }

  void _initiateChapaPayment(BookingModel booking) {
    // TODO: Implement Chapa payment
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chapa payment coming soon')),
    );
  }

  Future<void> _markAsCashPayment(BookingModel booking) async {
    try {
      // Update booking status to mark as cash payment
      await _bookingService.updateBookingStatus(
        booking.id,
        status: 'confirmed',
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Marked as cash payment')),
      );
      
      // Refresh the list
      await _refreshPayments();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update: $error')),
      );
    }
  }
}