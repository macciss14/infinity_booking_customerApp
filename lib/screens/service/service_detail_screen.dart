// lib/screens/service/service_detail_screen.dart
import 'package:flutter/material.dart';
import '../../services/service_service.dart';
import '../../models/service_model.dart';
import '../../utils/constants.dart';
import '../../config/route_helper.dart';

class ServiceDetailScreen extends StatefulWidget {
  final String serviceId;
  const ServiceDetailScreen({super.key, required this.serviceId});

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServiceService _serviceService = ServiceService();
  late Future<ServiceModel> _serviceFuture;

  @override
  void initState() {
    super.initState();
    _serviceFuture = _serviceService.getServiceById(widget.serviceId);
  }

  void _navigateToBooking() {
    RouteHelper.pushNamed(
      context,
      RouteHelper.booking,
      arguments: widget.serviceId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
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
                // Service Title
                Text(
                  service.name,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                // Status Badge - ✅ FIXED NULL SAFETY
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(service.status),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusBorderColor(service.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _getStatusText(service.status),
                    style: TextStyle(
                      color: _getStatusBorderColor(service.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Provider Information
                const Text(
                  'Provider Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          child: Text(service.providerName.substring(0, 1)),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.providerName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Service Provider',
                                style: const TextStyle(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Service Specifications
                const Text(
                  'Service Specifications',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Service Type:'),
                            const SizedBox(width: 8),
                            Text(
                              service.serviceType ?? 'Not specified',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Category:'),
                            const SizedBox(width: 8),
                            Text(
                              service.categoryId,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Subcategories:'),
                            const SizedBox(width: 8),
                            if (service.subcategoryIds.isNotEmpty)
                              Text(
                                service.subcategoryIds.join(', '),
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              )
                            else
                              const Text('None'),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Payment Method:'),
                            const SizedBox(width: 8),
                            Text(
                              service.paymentMethod ?? 'Not specified',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Price Unit:'),
                            const SizedBox(width: 8),
                            Text(
                              service.priceUnit ?? 'ETB',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Pricing Information
                const Text(
                  'Pricing Information',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Service Price:'),
                            const Spacer(),
                            Text(
                              '${service.price.toStringAsFixed(2)} ${service.priceUnit ?? "ETB"}',
                              style: const TextStyle(
                                color: AppColors.secondary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Total Bookings:'),
                            const Spacer(),
                            Text(
                              '${service.totalBookings ?? 0}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Views:'),
                            const Spacer(),
                            Text(
                              '${service.views ?? 0}',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Service Status
                const Text(
                  'Service Status',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text('Current Status:'),
                            const Spacer(),
                            Text(
                              service.status ?? 'Unknown',
                              style: TextStyle(
                                color: _getStatusColorText(service.status),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Text('Featured Service:'),
                            const Spacer(),
                            Text(
                              service.isFeatured == true ? 'Yes' : 'No',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Book This Service Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToBooking,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text('Book This Service',
                        style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Helper methods for status display
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey.withOpacity(0.2);
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green.withOpacity(0.2);
      case 'draft':
        return Colors.orange.withOpacity(0.2);
      case 'suspended':
        return Colors.red.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }

  Color _getStatusBorderColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColorText(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'published':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String? status) {
    return status?.toUpperCase() ?? 'UNKNOWN';
  }
}
