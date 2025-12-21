// lib/screens/service/service_detail_screen.dart - OPTIMIZED VERSION
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
  final ServiceModel? service;

  const ServiceDetailScreen({
    super.key,
    required this.serviceId,
    this.service,
  });

  @override
  State<ServiceDetailScreen> createState() => _ServiceDetailScreenState();
}

class _ServiceDetailScreenState extends State<ServiceDetailScreen> {
  final ServiceService _serviceService = ServiceService();
  final ReviewService _reviewService = ReviewService();

  late Future<List<ServiceModel>> _allServicesFuture;
  late Future<List<ReviewModel>> _reviewsFuture;

  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';
  ServiceModel? _loadedService;
  String? _providerPhone;
  String? _providerProfilePhoto;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    print('🔄 Loading service details for ID: ${widget.serviceId}');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadedService = null;
      _providerPhone = null;
      _providerProfilePhoto = null;
    });

    _allServicesFuture = _serviceService.getAllServices();
    _reviewsFuture = _reviewService.getServiceReviews(widget.serviceId);

    _allServicesFuture.then((allServices) {
      print('✅ Loaded ${allServices.length} services');

      // Find the specific service from the list
      ServiceModel? foundService;

      for (var service in allServices) {
        if (service.id == widget.serviceId ||
            service.serviceId == widget.serviceId) {
          foundService = service;
          print('✅ Found service in list: ${service.name}');

          // Extract provider phone and profile photo
          _extractProviderDetails(service);
          break;
        }
      }

      if (foundService == null) {
        print('⚠️ Service not found in list');
        _showError('Service not found');
      } else {
        _loadedService = foundService;
        setState(() => _isLoading = false);
      }
    }).catchError((error) {
      print('❌ Error loading services: $error');
      _showError('Failed to load service details');
    });
  }

  void _extractProviderDetails(ServiceModel service) {
    print('🔍 Extracting provider details...');

    // 1. First try to get phone from service.providerPhone
    if (service.providerPhone != null && service.providerPhone!.isNotEmpty) {
      _providerPhone = service.providerPhone;
      print('✅ Got phone from service.providerPhone: $_providerPhone');
    }

    // 2. Try to get phone from provider object
    if ((_providerPhone == null || _providerPhone!.isEmpty) &&
        service.provider != null &&
        service.provider is Map) {
      final providerMap = service.provider as Map<String, dynamic>;

      // Try different phone field names
      _providerPhone = providerMap['phone']?.toString() ??
          providerMap['phoneNumber']?.toString() ??
          providerMap['mobile']?.toString() ??
          providerMap['contactNumber']?.toString();

      if (_providerPhone != null && _providerPhone!.isNotEmpty) {
        print('✅ Got phone from provider object: $_providerPhone');
      }

      // Get profile photo from provider object
      _providerProfilePhoto = providerMap['profilePhoto']?.toString() ??
          providerMap['avatar']?.toString() ??
          providerMap['image']?.toString() ??
          providerMap['photo']?.toString() ??
          providerMap['profileImage']?.toString();

      if (_providerProfilePhoto != null && _providerProfilePhoto!.isNotEmpty) {
        print(
            '✅ Got profile photo from provider object: $_providerProfilePhoto');
      }
    }

    // 3. If still no phone, check service JSON for any phone-related fields
    if (_providerPhone == null || _providerPhone!.isEmpty) {
      final serviceJson = service.toJson();
      for (var key in serviceJson.keys) {
        final keyStr = key.toString().toLowerCase();
        if ((keyStr.contains('phone') ||
                keyStr.contains('mobile') ||
                keyStr.contains('contact')) &&
            serviceJson[key] != null &&
            serviceJson[key]!.toString().isNotEmpty) {
          _providerPhone = serviceJson[key]!.toString();
          print('✅ Found phone in service field "$key": $_providerPhone');
          break;
        }
      }
    }

    // 4. If still no profile photo, check service JSON for any image fields
    if (_providerProfilePhoto == null || _providerProfilePhoto!.isEmpty) {
      final serviceJson = service.toJson();
      for (var key in serviceJson.keys) {
        final keyStr = key.toString().toLowerCase();
        if ((keyStr.contains('profile') ||
                keyStr.contains('avatar') ||
                keyStr.contains('image')) &&
            serviceJson[key] != null &&
            serviceJson[key]!.toString().isNotEmpty) {
          _providerProfilePhoto = serviceJson[key]!.toString();
          print(
              '✅ Found profile photo in service field "$key": $_providerProfilePhoto');
          break;
        }
      }
    }

    print('📊 Final extracted details:');
    print('   - Phone: $_providerPhone');
    print('   - Profile Photo: $_providerProfilePhoto');
  }

  void _showError(String message) {
    if (mounted) {
      setState(() {
        _hasError = true;
        _errorMessage = message;
        _isLoading = false;
      });
    }
  }

  void _retryLoading() {
    _loadData();
  }

  void _navigateToBooking() {
    if (_loadedService == null) {
      _showBookingError();
      return;
    }

    final providerId = _loadedService!.providerId;

    if (providerId == null || providerId.isEmpty) {
      _showBookingError();
      return;
    }

    print('📋 Booking with provider ID: $providerId');
    RouteHelper.goToBookingWithProvider(
      context: context,
      serviceId: widget.serviceId,
      providerId: providerId,
    );
  }

  void _showBookingError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Provider information unavailable. Cannot book.')),
    );
  }

  void _viewReviews() {
    RouteHelper.goToReviews(context, widget.serviceId);
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  Color _getAvailabilityColor(ServiceModel service) {
    final slots = service.getAvailableSlotsCount();
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
              onPressed: () => Navigator.pop(context)),
        ],
      ),
      body: _isLoading
          ? _buildLoadingWidget()
          : _hasError
              ? _buildErrorWidget()
              : _loadedService == null
                  ? _buildNoDataWidget()
                  : _buildServiceDetails(_loadedService!),
    );
  }

  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading service details...'),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Service Error',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage.isNotEmpty
                  ? _errorMessage
                  : 'Failed to load service details',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text(
            'Service Not Found',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'The service you are looking for does not exist',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildProviderCard(ServiceModel service) {
    final providerName = service.displayProviderName;
    final providerEmail = service.providerEmail;
    final providerPhone = _providerPhone;
    final profilePhoto = _providerProfilePhoto;
    final isVerified = service.isProviderVerified;
    final rating = service.providerRating;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section title - REMOVED provider ID display
            const Text('Service Provider',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 93, 90, 90))),
            const SizedBox(height: 12),

            // Provider Header with Profile Photo and Name
            Row(
              children: [
                // Profile Photo or Avatar with Initials
                if (profilePhoto != null && profilePhoto.isNotEmpty)
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      image: DecorationImage(
                        image: NetworkImage(profilePhoto),
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                else
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        service.providerInitials,
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary),
                      ),
                    ),
                  ),
                const SizedBox(width: 16),

                // Name and verification badge
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              providerName,
                              style: const TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w700),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isVerified)
                            Container(
                              margin: const EdgeInsets.only(left: 8),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.verified,
                                      size: 14, color: Colors.blue),
                                  const SizedBox(width: 4),
                                  Text('Verified',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue[700])),
                                ],
                              ),
                            ),
                        ],
                      ),

                      // Provider rating if available
                      if (rating != null && rating > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Row(
                            children: [
                              Icon(Icons.star, size: 14, color: Colors.amber),
                              const SizedBox(width: 4),
                              Text(rating.toStringAsFixed(1),
                                  style: const TextStyle(fontSize: 12)),
                              const SizedBox(width: 4),
                              Text('(${service.reviewCount ?? 0} reviews)',
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.grey)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            // Contact Details Section
            if (providerEmail != null || providerPhone != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text('Contact Information',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),

                    // Email
                    if (providerEmail != null && providerEmail.isNotEmpty)
                      _buildContactRow(Icons.email_outlined, providerEmail),

                    // Phone
                    if (providerPhone != null && providerPhone.isNotEmpty)
                      _buildContactRow(Icons.phone_outlined, providerPhone),
                  ],
                ),
              ),

            // Status indicator (optional, shows what data is available)
            Container(
              margin: const EdgeInsets.only(top: 12),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(6),
                border:
                    Border.all(color: const Color.fromARGB(255, 237, 233, 233)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 14,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact info available',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Email: ${providerEmail != null ? '✓' : '✗'} • Phone: ${providerPhone != null ? '✓' : '✗'}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // [Keep all other UI methods exactly as they were in the previous version]
  // _buildServiceImage, _buildPricingCard, _buildDescriptionCard, etc.

  Widget _buildServiceImage(ServiceModel service) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: AppColors.primary.withOpacity(0.1),
          image: service.imageUrl?.isNotEmpty == true
              ? DecorationImage(
                  image: NetworkImage(service.imageUrl!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: service.imageUrl?.isEmpty != false
            ? Center(
                child: Icon(
                  Icons.build,
                  size: 60,
                  color: AppColors.primary.withOpacity(0.5),
                ),
              )
            : Stack(
                children: [
                  if (service.isFeatured == true)
                    Positioned(
                      top: 16,
                      left: 16,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
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
                ],
              ),
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
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildPricingItem('Service Price',
                '${service.price.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}'),
            const SizedBox(height: 8),
            _buildPricingItem('Booking Fee',
                '${(service.bookingPrice ?? 0).toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}'),
            const Divider(height: 24),
            _buildPricingItem('Total',
                '${service.totalPrice.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
                isTotal: true),
            if (service.pricingNotes != null &&
                service.pricingNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(service.pricingNotes!,
                    style: const TextStyle(fontSize: 13, color: Colors.amber)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPricingItem(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 15,
                color: Colors.grey[700],
                fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal)),
        Text(value,
            style: TextStyle(
                fontSize: 15,
                fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
                color: isTotal ? AppColors.secondary : Colors.grey[900])),
      ],
    );
  }

  Widget _buildDescriptionCard(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Description',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(service.description,
                style: const TextStyle(
                    fontSize: 15, height: 1.6, color: Colors.grey)),
          ),
        ),
      ],
    );
  }

  Widget _buildPerformanceMetrics(ServiceModel service) {
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, reviewSnapshot) {
        int totalReviews = 0;
        double avgRating = 0.0;
        if (reviewSnapshot.hasData) {
          final reviews = reviewSnapshot.data!;
          totalReviews = reviews.length;
          if (totalReviews > 0) {
            avgRating = reviews.fold(0.0, (sum, r) => sum + (r.rating ?? 0)) /
                totalReviews;
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
                        TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMetricCard(
                        'Bookings', service.totalBookings?.toString() ?? '0',
                        icon: Icons.bookmark),
                    GestureDetector(
                      onTap: _viewReviews,
                      child: _buildMetricCard(
                          'Reviews', totalReviews.toString(),
                          icon: Icons.reviews, hasAction: totalReviews > 0),
                    ),
                    _buildMetricCard('Rating',
                        avgRating > 0 ? avgRating.toStringAsFixed(1) : 'N/A',
                        icon: Icons.star),
                    _buildMetricCard('Available',
                        service.getAvailableSlotsCount().toString(),
                        icon: Icons.event_available),
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
      {IconData? icon, bool hasAction = false}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            hasAction ? AppColors.primary.withOpacity(0.1) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: hasAction
                ? AppColors.primary.withOpacity(0.3)
                : Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(icon,
                size: 24,
                color: hasAction ? AppColors.primary : Colors.grey[600]),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: hasAction ? AppColors.primary : Colors.grey[900])),
          const SizedBox(height: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 13,
                  color: hasAction
                      ? AppColors.primary.withOpacity(0.8)
                      : Colors.grey[600],
                  fontWeight: FontWeight.w500)),
          if (hasAction)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text('Tap to view',
                  style: TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold)),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityCard(ServiceModel service) {
    final availableSlots = service.getAvailableSlotsCount();
    final status = service.availabilityStatus;
    Color statusColor = availableSlots == 0
        ? Colors.red
        : availableSlots < 3
            ? Colors.orange
            : Colors.green;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Availability',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(status,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: statusColor)),
                  const SizedBox(height: 8),
                  Text('$availableSlots slots available',
                      style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
                '${service.workingDaysCount} days/week • ${service.totalTimeSlots} slots total',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center),
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
            const Text('Service Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusBadge(
                    service.availabilityStatus, _getAvailabilityColor(service)),
                _buildStatusBadge(service.status ?? 'published',
                    _getStatusColor(service.status)),
                if (service.isVerified == true)
                  _buildStatusBadge('Verified', Colors.blue),
                if (service.isFeatured == true)
                  _buildStatusBadge('Featured', Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Quick Info',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            _buildInfoRow(Icons.remove_red_eye, 'Views',
                service.views?.toString() ?? '0'),
            _buildInfoRow(Icons.calendar_today, 'Created',
                _formatDate(service.createdAt)),
            _buildInfoRow(
                Icons.update, 'Updated', _formatDate(service.updatedAt)),
            FutureBuilder<List<ReviewModel>>(
              future: _reviewsFuture,
              builder: (context, snapshot) {
                final count = snapshot.hasData
                    ? snapshot.data!.length
                    : (service.reviewCount ?? 0);
                return _buildInfoRow(Icons.chat, 'Reviews', count.toString());
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _viewReviews,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: FutureBuilder<List<ReviewModel>>(
                  future: _reviewsFuture,
                  builder: (context, snapshot) {
                    final count = snapshot.hasData
                        ? snapshot.data!.length
                        : (service.reviewCount ?? 0);
                    return Text('View Reviews ($count)');
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(text.toUpperCase(),
          style: TextStyle(
              fontSize: 12, fontWeight: FontWeight.bold, color: color)),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color.fromARGB(255, 116, 113, 113)),
          const SizedBox(width: 12),
          Expanded(
              child: Text(label,
                  style: const TextStyle(fontSize: 15, color: Colors.grey))),
          Text(value,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return const Color.fromARGB(255, 167, 167, 167);
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

  Widget _buildServiceDetails(ServiceModel service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceImage(service),
          const SizedBox(height: 20),
          Text(service.name,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, height: 1.3)),
          const SizedBox(height: 8),
          _buildPricingCard(service),
          const SizedBox(height: 20),

          // Provider Card with phone and profile photo
          _buildProviderCard(service),

          const SizedBox(height: 20),
          _buildDescriptionCard(service),
          const SizedBox(height: 20),
          _buildPerformanceMetrics(service),
          const SizedBox(height: 20),
          _buildAvailabilityCard(service),
          const SizedBox(height: 20),
          _buildSidebar(service),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _navigateToBooking,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Book This Service',
                  style: TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
