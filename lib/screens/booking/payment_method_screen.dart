// lib/screens/booking/payment_method_screen.dart
import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../services/booking_service.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class PaymentMethodScreen extends StatefulWidget {
  final ServiceModel service;
  final Map<String, dynamic> selectedSlot;
  final double totalAmount;
  final String bookingDate;
  final String? notes;

  const PaymentMethodScreen({
    super.key,
    required this.service,
    required this.selectedSlot,
    required this.totalAmount,
    required this.bookingDate,
    this.notes,
  });

  @override
  State<PaymentMethodScreen> createState() => _PaymentMethodScreenState();
}

class _PaymentMethodScreenState extends State<PaymentMethodScreen> {
  final BookingService _bookingService = BookingService();
  List<Map<String, dynamic>> _paymentMethods = [];
  String? _selectedPaymentMethod;
  bool _loading = false;
  bool _loadingMethods = true;

  @override
  void initState() {
    super.initState();
    _loadPaymentMethods();
  }

  Future<void> _loadPaymentMethods() async {
    try {
      final methods = await _bookingService.getPaymentMethods();
      setState(() {
        _paymentMethods = methods;
        _loadingMethods = false;
      });
    } catch (error) {
      print('Error loading payment methods: $error');
      setState(() => _loadingMethods = false);
    }
  }

  Future<void> _proceedToPayment() async {
    if (_selectedPaymentMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a payment method')));
      return;
    }

    setState(() => _loading = true);
    try {
      final booking = await _bookingService.createBooking(
        serviceId: widget.service.id,
        providerId: widget.service.providerId ?? '',
        bookingDate: widget.bookingDate,
        startTime: widget.selectedSlot['timeSlot']['startTime'],
        endTime: widget.selectedSlot['timeSlot']['endTime'],
        totalAmount: widget.totalAmount,
        paymentMethod: _selectedPaymentMethod,
        notes: widget.notes,
      );

      final paymentResult = await _bookingService.processPayment(
        bookingId: booking.id,
        paymentMethod: _selectedPaymentMethod!,
        amount: widget.totalAmount,
      );

      RouteHelper.goToBookingConfirmation(
        context,
        booking: booking,
        paymentResult: paymentResult,
        skipPayment: false,
      );
    } catch (error) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: ${error.toString()}')));
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
        title: const Text('Payment Method'),
        backgroundColor: AppColors.primary,
        leading:
            IconButton(icon: const Icon(Icons.arrow_back), onPressed: _goBack),
      ),
      body: _loadingMethods
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildBookingSummary(),
                  const SizedBox(height: 24),
                  const Text('Select Payment Method',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ..._paymentMethods.map(_buildPaymentMethodCard),
                  if (_selectedPaymentMethod != null) ...[
                    const SizedBox(height: 20),
                    _buildPaymentInstructions(),
                  ],
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _proceedToPayment,
                      child: _loading
                          ? const CircularProgressIndicator()
                          : const Text('Proceed to Payment',
                              style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildBookingSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Booking Summary',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            _buildSummaryRow('Service', widget.service.name),
            _buildSummaryRow(
                'Provider', widget.service.providerName ?? 'Unknown'),
            _buildSummaryRow('Date', widget.bookingDate),
            _buildSummaryRow('Time',
                '${widget.selectedSlot['timeSlot']['startTime']} - ${widget.selectedSlot['timeSlot']['endTime']}'),
            const Divider(),
            _buildSummaryRow(
                'Total Amount', '${widget.totalAmount.toStringAsFixed(2)} ETB',
                isTotal: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value,
              style: TextStyle(
                  fontWeight: isTotal ? FontWeight.bold : null,
                  color: isTotal ? Colors.green : null)),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard(Map<String, dynamic> method) {
    final isSelected = _selectedPaymentMethod == method['id'];
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPaymentMethod = method['id']);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border:
              Border.all(color: isSelected ? Colors.green : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text(method['icon'] ?? '💰',
                      style: const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(method['name'] ?? 'Payment Method',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(method['description'] ?? '',
                      style: const TextStyle(color: Colors.grey, fontSize: 14)),
                ],
              ),
            ),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.green),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: Colors.blue),
              const SizedBox(width: 8),
              const Text('Payment Instructions',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue))
            ],
          ),
          const SizedBox(height: 8),
          const Text(
              'Click "Proceed to Payment" to complete your booking securely.'),
        ],
      ),
    );
  }
}
