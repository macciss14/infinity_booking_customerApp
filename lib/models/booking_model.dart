// lib/models/booking_model.dart
class BookingModel {
  final String id;
  final String serviceId;
  final String serviceName;
  final String providerName;
  final double price;
  final String status;
  final String? slotStart;
  final String bookingDate;
  final String? paymentMethod;
  final String? priceUnit;
  final String? serviceType;
  final String? duration;
  final String? locationType;
  final String? serviceArea;
  final bool? isFeatured;
  final String? verificationStatus;

  BookingModel({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.providerName,
    required this.price,
    required this.status,
    this.slotStart,
    required this.bookingDate,
    this.paymentMethod,
    this.priceUnit,
    this.serviceType,
    this.duration,
    this.locationType,
    this.serviceArea,
    this.isFeatured,
    this.verificationStatus,
  });

  String get formattedPrice => '\$${price.toStringAsFixed(2)}';

  String get formattedDate {
    try {
      final parts = bookingDate.split('T')[0].split('-');
      if (parts.length == 3) return '${parts[2]}/${parts[1]}/${parts[0]}';
      return bookingDate;
    } catch (e) {
      return bookingDate;
    }
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    // Handle service details from nested object
    String serviceName = 'Service';
    String providerName = 'Provider Unknown';
    double price = 0.0;
    String serviceId = '';

    if (json['service'] is Map<String, dynamic>) {
      final service = json['service'];
      serviceName = service['title'] ?? service['name'] ?? 'Service';
      serviceId = service['serviceId'] ?? '';

      // Handle nested provider
      if (service['provider'] is Map<String, dynamic>) {
        providerName = service['provider']['fullname'] ?? 'Provider Unknown';
      }

      // Use totalPrice from service
      price = (service['totalPrice'] ?? service['price'] ?? 0.0).toDouble();
    } else {
      // Fallback to flat structure
      serviceName = json['serviceName'] ?? json['title'] ?? 'Service';
      serviceId = json['serviceId'] ?? '';
      providerName = json['providerName'] ?? 'Provider Unknown';
      price = (json['totalPrice'] ?? json['price'] ?? 0.0).toDouble();
    }

    return BookingModel(
      id: json['id'] ?? '',
      serviceId: serviceId,
      serviceName: serviceName,
      providerName: providerName,
      price: price,
      status: json['status'] ?? 'pending',
      slotStart: json['slotStart'],
      bookingDate: json['bookingDate'] ??
          json['createdAt'] ??
          DateTime.now().toIso8601String(),
      paymentMethod: json['paymentMethod'],
      priceUnit: json['priceUnit'],
      serviceType: json['serviceType'],
      duration: json['duration'],
      locationType: json['locationType'],
      serviceArea: json['serviceArea'],
      isFeatured: json['isFeatured'] is bool ? json['isFeatured'] : null,
      verificationStatus: json['verificationStatus'],
    );
  }
}
