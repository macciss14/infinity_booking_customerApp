// lib/screens/service/service_detail_screen.dart - UPDATED
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
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load service',
                    style: TextStyle(fontSize: 18, color: Colors.red),
                  ),
                  const SizedBox(height: 8),
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
            );
          }

          final service = snapshot.data!;
          return SingleChildScrollView(
            padding: EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Service Image with Overlay
                if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
                  Stack(
                    children: [
                      Container(
                        height: 220,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(
                            image: NetworkImage(service.imageUrl!),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      // Featured badge overlay
                      if (service.isFeatured == true)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'FEATURED',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      // Status badge overlay
                      if (service.status != null && service.status!.isNotEmpty)
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(service.status)
                                  .withOpacity(0.9),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              service.status!.toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                else
                  Container(
                    height: 180,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.build,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),

                const SizedBox(height: 20),

                // Service Title and Price
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            service.name,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Category badge
                          if (service.categoryName != null &&
                              service.categoryName!.isNotEmpty)
                            Wrap(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    service.categoryName!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Price
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.secondary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        service.formattedPrice,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Provider Information Card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 32,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Service Provider',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                service.providerName ?? 'Service Provider',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              if (service.providerId != null &&
                                  service.providerId!.isNotEmpty)
                                Text(
                                  'ID: ${service.providerId}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Description Section
                const Text(
                  'Description',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      service.description,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.5,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Service Details Section
                const Text(
                  'Service Details',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Service Type
                        if (service.serviceType != null &&
                            service.serviceType!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.category,
                            label: 'Service Type',
                            value: service.serviceType!,
                          ),

                        // Duration
                        if (service.duration != null &&
                            service.duration!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.schedule,
                            label: 'Duration',
                            value: service.duration!,
                          ),

                        // Location Type
                        if (service.locationType != null &&
                            service.locationType!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.location_on,
                            label: 'Location Type',
                            value: service.locationType!,
                          ),

                        // Service Area
                        if (service.serviceArea != null &&
                            service.serviceArea!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.map,
                            label: 'Service Area',
                            value: service.serviceArea!,
                          ),

                        // Payment Method
                        if (service.paymentMethod != null &&
                            service.paymentMethod!.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.payment,
                            label: 'Payment Method',
                            value: service.paymentMethod!,
                          ),

                        // Subcategories
                        if (service.subcategoryIds.isNotEmpty)
                          _buildDetailRow(
                            icon: Icons.subdirectory_arrow_right,
                            label: 'Subcategories',
                            value: service.subcategoryIds.length.toString(),
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // Service Stats Section
                const Text(
                  'Service Stats',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        // Total Bookings
                        if (service.totalBookings != null &&
                            service.totalBookings! > 0)
                          _buildStatRow(
                            icon: Icons.book_online,
                            label: 'Total Bookings',
                            value: service.totalBookings!.toString(),
                            color: Colors.green,
                          ),

                        // Views
                        if (service.views != null && service.views! > 0)
                          _buildStatRow(
                            icon: Icons.remove_red_eye,
                            label: 'Views',
                            value: service.views!.toString(),
                            color: Colors.blue,
                          ),

                        // Rating
                        if (service.rating != null && service.rating! > 0)
                          _buildStatRow(
                            icon: Icons.star,
                            label: 'Rating',
                            value: service.rating!.toStringAsFixed(1),
                            color: Colors.amber,
                            isRating: true,
                          ),

                        // Verification Status
                        if (service.verificationStatus != null &&
                            service.verificationStatus!.isNotEmpty)
                          _buildStatRow(
                            icon: Icons.verified,
                            label: 'Verification',
                            value: service.verificationStatus!.toUpperCase(),
                            color: service.verificationStatus == 'verified'
                                ? Colors.green
                                : Colors.orange,
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Action Buttons
                Row(
                  children: [
                    // Share Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement share functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Share feature coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.share_outlined, size: 18),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),

                    // Save Button
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          // TODO: Implement save to favorites
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Save feature coming soon!')),
                          );
                        },
                        icon: const Icon(Icons.bookmark_border, size: 18),
                        label: const Text('Save'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: AppColors.primary),
                          foregroundColor: AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Book Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _navigateToBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Book This Service',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
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
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isRating = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
          if (isRating)
            Row(
              children: [
                Icon(Icons.star, size: 16, color: color),
                const SizedBox(width: 4),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
        ],
      ),
    );
  }

  // Helper methods for status display
  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
      case 'available':
        return Colors.green;
      case 'draft':
      case 'pending':
        return Colors.orange;
      case 'suspended':
      case 'unavailable':
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusBorderColor(String? status) {
    return _getStatusColor(status);
  }

  Color _getStatusColorText(String? status) {
    return _getStatusColor(status);
  }

  String _getStatusText(String? status) {
    return status?.toUpperCase() ?? 'UNKNOWN';
  }
}
