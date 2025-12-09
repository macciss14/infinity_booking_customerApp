// lib/screens/service/service_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../models/review_model.dart';
import '../../services/service_service.dart';
import '../../services/review_service.dart';
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
  final ReviewService _reviewService = ReviewService();
  late Future<ServiceModel> _serviceFuture;
  late Future<List<ReviewModel>> _reviewsFuture;

  @override
  void initState() {
    super.initState();
    _serviceFuture = _serviceService.getServiceById(widget.serviceId);
    _reviewsFuture = _reviewService.getServiceReviews(widget.serviceId);
  }

  void _navigateToBooking() {
    RouteHelper.goToBooking(context, widget.serviceId);
  }

  void _viewReviews() {
    RouteHelper.goToReviews(context, widget.serviceId);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  int _getAvailableSlotsCount(ServiceModel service) {
    return service.getAvailableSlotsCount();
  }

  String _getAvailabilityStatus(ServiceModel service) {
    final slots = _getAvailableSlotsCount(service);
    if (slots == 0) return 'No Slots';
    if (slots < 3) return 'Limited';
    if (slots < 10) return 'Available';
    return 'Plenty Available';
  }

  Color _getAvailabilityColor(ServiceModel service) {
    final slots = _getAvailableSlotsCount(service);
    if (slots == 0) return Colors.red;
    if (slots < 3) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: AppColors.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: FutureBuilder<ServiceModel>(
        future: _serviceFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorWidget(
                'Failed to load service: ${snapshot.error}');
          }
          final service = snapshot.data!;
          return _buildServiceDetails(service);
        },
      ),
    );
  }

  Widget _buildServiceDetails(ServiceModel service) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Service Image with Badges
          if (service.imageUrl != null && service.imageUrl!.isNotEmpty)
            Stack(
              children: [
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(service.imageUrl!),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
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
                if (service.status != null)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: _getStatusColor(service.status).withOpacity(0.9),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        service.status!.toUpperCase(),
                        style: const TextStyle(
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
              child: const Icon(
                Icons.build,
                size: 60,
                color: AppColors.primary,
              ),
            ),
          const SizedBox(height: 20),

          // Service Header
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),

          // Pricing Card
          _buildPricingCard(service),
          const SizedBox(height: 20),

          // Provider Info Card
          _buildProviderCard(service),
          const SizedBox(height: 20),

          // Description
          const Text(
            'Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                service.description,
                style: const TextStyle(
                    fontSize: 15, height: 1.5, color: Colors.grey),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Performance Metrics
          _buildPerformanceMetrics(service),
          const SizedBox(height: 20),

          // Availability Card
          _buildAvailabilityCard(service),
          const SizedBox(height: 20),

          // Sidebar (Quick Info + Status)
          _buildSidebar(service),

          const SizedBox(height: 24),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Share feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Share'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Save feature coming soon!')),
                    );
                  },
                  icon: const Icon(Icons.bookmark_border, size: 18),
                  label: const Text('Save'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToBooking,
              child: const Text('Book This Service',
                  style: TextStyle(fontSize: 16)),
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildPricingCard(ServiceModel service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Pricing',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildPricingItem('Service Price',
                '${service.price.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}'),
            _buildPricingItem('Booking Fee',
                '${(service.bookingPrice ?? 0).toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}'),
            const Divider(),
            _buildPricingItem('Total',
                '${service.totalPrice.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
                isTotal: true),
            if (service.pricingNotes != null &&
                service.pricingNotes!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  service.pricingNotes!,
                  style: TextStyle(fontSize: 13, color: Colors.orange[700]),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPricingItem(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? AppColors.secondary : Colors.grey[900],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ServiceModel service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.primary.withOpacity(0.1),
              child: Icon(Icons.person, size: 32, color: AppColors.primary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Service Provider',
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  const SizedBox(height: 4),
                  // ✅ Use the new getter that always returns a valid name
                  Text(
                    service.displayProviderName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  if (service.isVerified == true)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('Verified',
                          style: TextStyle(
                              fontSize: 11,
                              color: Colors.blue,
                              fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPerformanceMetrics(ServiceModel service) {
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, reviewSnapshot) {
        int totalReviews = 0;
        double avgRating = 0.0;
        int fiveStarCount = 0;

        if (reviewSnapshot.hasData) {
          final reviews = reviewSnapshot.data!;
          totalReviews = reviews.length;
          if (totalReviews > 0) {
            avgRating = reviews.fold(0.0, (sum, r) => sum + (r.rating ?? 0)) /
                totalReviews;
            fiveStarCount =
                reviews.where((r) => (r.rating ?? 0).round() == 5).length;
          }
        } else if (service.reviewCount != null) {
          totalReviews = service.reviewCount!;
          avgRating = service.rating ?? 0.0;
        }

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Performance Metrics',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 2,
                  children: [
                    _buildMetricCard(
                        'Bookings', service.totalBookings?.toString() ?? '0'),
                    GestureDetector(
                      onTap: _viewReviews,
                      child: _buildMetricCard(
                        'Reviews',
                        totalReviews.toString(),
                        hasAction: totalReviews > 0,
                      ),
                    ),
                    _buildMetricCard('Rating',
                        avgRating > 0 ? avgRating.toStringAsFixed(1) : 'N/A'),
                    _buildMetricCard('Available Slots',
                        _getAvailableSlotsCount(service).toString()),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetricCard(String label, String value,
      {bool hasAction = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            hasAction ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: hasAction ? AppColors.primary : Colors.grey[900]),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
                fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          if (hasAction)
            Text(
              'Click to view',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(ServiceModel service) {
    final status = _getAvailabilityStatus(service);
    final color = _getAvailabilityColor(service);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Availability',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              alignment: Alignment.center,
              child: Text(
                status,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${service.workingDaysCount} days/week • ${service.totalTimeSlots} slots total',
              style: const TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(ServiceModel service) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Status
            const Text('Service Status',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusBadge(_getAvailabilityStatus(service),
                    _getAvailabilityColor(service)),
                _buildStatusBadge(service.status ?? 'published',
                    _getStatusColor(service.status)),
                if (service.isVerified == true)
                  _buildStatusBadge('Verified', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),

            // Quick Info
            const Text('Quick Info',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildInfoRow('👁 Views', service.views?.toString() ?? '0'),
            _buildInfoRow('📅 Created', _formatDate(service.createdAt)),
            _buildInfoRow('🔄 Updated', _formatDate(service.updatedAt)),
            FutureBuilder<List<ReviewModel>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                final count = snapshot.hasData
                    ? snapshot.data!.length
                    : (service.reviewCount ?? 0);
                return _buildInfoRow('💬 Reviews', count.toString());
              },
            ),

            const SizedBox(height: 20),

            // Actions
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _viewReviews,
                child: Text('View Reviews (${service.reviewCount ?? 0})'),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close Details'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style:
            TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildInfoRow(String icon, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  icon.split(' ')[0],
                  style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    switch (status.toLowerCase()) {
      case 'published':
      case 'active':
        return Colors.green;
      case 'draft':
        return Colors.orange;
      case 'archived':
      case 'suspended':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text('Service Error',
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
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
      ),
    );
  }
}
