// lib/models/create_booking_request.dart
class CreateBookingRequest {
  final String serviceId;
  final String providerId;
  final DateTime bookingDate;
  final String startTime;
  final String endTime;
  final double totalAmount;
  final String? notes;
  final String? paymentMethod;
  final bool skipPayment;

  CreateBookingRequest({
    required this.serviceId,
    required this.providerId,
    required this.bookingDate,
    required this.startTime,
    required this.endTime,
    required this.totalAmount,
    this.notes,
    this.paymentMethod,
    this.skipPayment = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'serviceId': serviceId,
      'providerId': providerId,
      'bookingDate': bookingDate.toIso8601String().split('T')[0],
      'startTime': startTime,
      'endTime': endTime,
      'totalAmount': totalAmount,
      'notes': notes ?? '',
      'paymentMethod': paymentMethod,
      'skipPayment': skipPayment,
      'status': 'pending', // Default status
    };
  }
}