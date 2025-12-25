import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/service_model.dart';
import '../../models/review_model.dart';
import '../../models/provider_model.dart';
import '../../services/service_service.dart';
import '../../services/review_service.dart';
import '../../services/provider_service.dart';
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
  final ProviderService _providerService = ProviderService();

  late Future<List<ServiceModel>> _allServicesFuture;
  late Future<List<ReviewModel>> _reviewsFuture;

  bool _isLoading = true;
  bool _isLoadingProvider = false;
  bool _hasError = false;
  String _errorMessage = '';
  ServiceModel? _loadedService;
  ProviderModel? _provider;
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
      _provider = null;
      _providerPhone = null;
      _providerProfilePhoto = null;
    });

    _allServicesFuture = _serviceService.getAllServices();
    _reviewsFuture = _reviewService.getServiceReviews(widget.serviceId);

    _allServicesFuture.then((allServices) {
      print('✅ Loaded ${allServices.length} services');

      // Find the specific service from the list
      ServiceModel? foundService;

      // First, check if we already have a service object passed in
      if (widget.service != null &&
          (widget.service!.id == widget.serviceId ||
              widget.service!.serviceId == widget.serviceId)) {
        foundService = widget.service!;
        print('✅ Using passed service object: ${foundService.name}');
      } else {
        // Otherwise search in the list
        for (var service in allServices) {
          if (service.id == widget.serviceId ||
              service.serviceId == widget.serviceId) {
            foundService = service;
            print('✅ Found service in list: ${service.name}');
            break;
          }
        }
      }

      if (foundService == null) {
        print('⚠️ Service not found');
        _showError('Service not found');
      } else {
        _loadedService = foundService;
        // Load provider details from provider service
        _loadProviderDetails(foundService);
      }
    }).catchError((error) {
      print('❌ Error loading services: $error');
      _showError('Failed to load service details: $error');
    });
  }

  Future<void> _loadProviderDetails(ServiceModel service) async {
    print('🔍 Loading provider details...');
    print('🔍 Provider PID from service: ${service.providerPid}');
    print('🔍 Provider ID from service: ${service.providerId}');

    setState(() => _isLoadingProvider = true);

    try {
      // Try to fetch provider using providerPid first (PROV-xxx format)
      if (service.providerPid != null &&
          service.providerPid!.isNotEmpty &&
          service.providerPid!.startsWith('PROV-')) {
        print('🔄 Fetching provider by PID: ${service.providerPid}');
        final provider =
            await _providerService.getProviderByPid(service.providerPid!);
        _provider = provider;

        // Extract details from provider model
        _providerPhone = provider.phonenumber;
        _providerProfilePhoto = provider.profilePhoto;

        print('✅ Successfully loaded provider by PID: ${provider.fullname}');
        print('   - Phone: $_providerPhone');
        print('   - Profile Photo: $_providerProfilePhoto');
      }
      // Fallback: Try to fetch by provider ID
      else if (service.providerId != null && service.providerId!.isNotEmpty) {
        print('🔄 Fetching provider by ID: ${service.providerId}');

        // Check if it's a PID format or MongoDB ID
        if (service.providerId!.startsWith('PROV-')) {
          final provider =
              await _providerService.getProviderByPid(service.providerId!);
          _provider = provider;
          _providerPhone = provider.phonenumber;
          _providerProfilePhoto = provider.profilePhoto;
          print(
              '✅ Successfully loaded provider by ID (PID format): ${provider.fullname}');
        } else {
          // Assume it's a MongoDB ID
          final provider =
              await _providerService.getProviderById(service.providerId!);
          _provider = provider;
          _providerPhone = provider.phonenumber;
          _providerProfilePhoto = provider.profilePhoto;
          print('✅ Successfully loaded provider by ID: ${provider.fullname}');
        }

        print('   - Phone: $_providerPhone');
        print('   - Profile Photo: $_providerProfilePhoto');
      }
      // Fallback: Extract from service provider object if exists
      else if (service.provider != null && service.provider is Map) {
        print('⚠️ No provider PID/ID, extracting from service provider object');
        _extractProviderFromServiceObject(service);
      } else {
        print('⚠️ No provider information available');
      }
    } catch (error) {
      print('❌ Error loading provider details: $error');
      // Fallback to extracting from service object
      if (service.provider != null && service.provider is Map) {
        _extractProviderFromServiceObject(service);
      }
    } finally {
      setState(() {
        _isLoadingProvider = false;
        _isLoading = false;
      });
    }
  }

  void _extractProviderFromServiceObject(ServiceModel service) {
    try {
      final providerMap = service.provider as Map<String, dynamic>;
      print('📋 Provider object keys: ${providerMap.keys}');

      // Extract using correct field names
      final fullname = providerMap['fullname']?.toString();
      final phonenumber = providerMap['phonenumber']?.toString();
      final profilePhoto = providerMap['profilePhoto']?.toString();
      final email = providerMap['email']?.toString();
      final address = providerMap['address']?.toString();

      // Create a temporary provider model
      _provider = ProviderModel(
        id: providerMap['_id']?.toString() ??
            providerMap['id']?.toString() ??
            '',
        pid: providerMap['pid']?.toString() ?? service.providerPid ?? '',
        fullname: fullname ?? service.providerName ?? 'Unknown Provider',
        email: email ?? service.providerEmail ?? '',
        phonenumber: phonenumber ?? '',
        profilePhoto: profilePhoto,
        rating: providerMap['rating'] != null
            ? (providerMap['rating'] is num
                ? providerMap['rating'].toDouble()
                : double.tryParse(providerMap['rating'].toString()) ?? 0.0)
            : null,
        reviewCount: _parseInt(providerMap['reviewCount']),
        totalBookings: _parseInt(providerMap['totalBookings']),
        isVerified: providerMap['isVerified'] == true,
        address: address,
      );

      _providerPhone = phonenumber;
      _providerProfilePhoto = profilePhoto;

      print('✅ Extracted provider from service object:');
      print('   - Full Name: ${_provider?.fullname}');
      print('   - Phone: $_providerPhone');
      print('   - Profile Photo: $_providerProfilePhoto');
    } catch (e) {
      print('⚠️ Error extracting provider from service object: $e');
    }
  }

  int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      try {
        return int.parse(value.replaceAll(',', ''));
      } catch (_) {
        return 0;
      }
    }
    return 0;
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
      _showBookingError('Service not loaded');
      return;
    }

    // CRITICAL: Use providerPid first, then providerId as fallback
    String? bookingProviderId;

    // First priority: providerPid (should be PROV-xxx)
    if (_loadedService!.providerPid != null &&
        _loadedService!.providerPid!.isNotEmpty) {
      bookingProviderId = _loadedService!.providerPid!;
      print('✅ Using providerPid for booking: $bookingProviderId');
    }
    // Second priority: providerId
    else if (_loadedService!.providerId != null &&
        _loadedService!.providerId!.isNotEmpty) {
      bookingProviderId = _loadedService!.providerId!;
      print('⚠️ Using providerId for booking (fallback): $bookingProviderId');
    }
    // Third priority: provider PID from provider object
    else if (_provider?.pid != null && _provider!.pid.isNotEmpty) {
      bookingProviderId = _provider!.pid;
      print('⚠️ Using provider PID from provider object: $bookingProviderId');
    }
    // No provider ID found
    else {
      _showBookingError('Provider information not available. Cannot book.');
      return;
    }

    print('📋 Booking details:');
    print('   - Service ID: ${widget.serviceId}');
    print('   - Provider ID for booking: $bookingProviderId');

    RouteHelper.goToBookingWithProvider(
      context: context,
      serviceId: widget.serviceId,
      providerId: bookingProviderId,
    );
  }

  void _showBookingError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _viewReviews() {
    RouteHelper.goToReviews(context, widget.serviceId);
  }

  void _checkAndNavigateToReview() async {
    try {
      final canReview = await _reviewService.canReviewService(widget.serviceId);

      if (canReview) {
        RouteHelper.goToWriteReview(
          context,
          serviceId: widget.serviceId,
          serviceName:
              _loadedService?.name ?? widget.service?.name ?? 'Unknown Service',
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'You need to book and complete this service before writing a review.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (error) {
      print('❌ Error checking review eligibility: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Error checking review eligibility: ${error.toString()}',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return DateFormat('dd/MM/yyyy HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Service Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
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
          Text(
            'Loading service details...',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(
              'The service you are looking for does not exist or has been removed.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

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

  Widget _buildProviderCard(ServiceModel service) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Provider',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color.fromARGB(255, 93, 90, 90),
              ),
            ),
            const SizedBox(height: 12),

            // Show loading indicator while loading provider
            if (_isLoadingProvider)
              const Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_provider != null)
              _buildProviderInfo(service)
            else
              _buildProviderFallback(service),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderInfo(ServiceModel service) {
    final provider = _provider!;
    final phone = _providerPhone ?? provider.phonenumber;
    final profilePhoto = _providerProfilePhoto ?? provider.profilePhoto;
    final providerName = provider.fullname;
    final providerEmail = provider.email;
    final isVerified = provider.isVerified;
    final rating = provider.rating;
    final providerPid = provider.pid;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider Header with Profile Photo and Name
        Row(
          children: [
            // Profile Photo or Avatar with Initials
            if (profilePhoto != null && profilePhoto.isNotEmpty)
              _buildProfilePhoto(profilePhoto)
            else
              _buildProfileAvatar(providerName),
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
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
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
                            border:
                                Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.verified,
                                  size: 14, color: Colors.blue),
                              const SizedBox(width: 4),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
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
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '(${provider.reviewCount ?? 0} reviews)',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
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

        // Provider ID Information
        if (providerPid.isNotEmpty)
          Container(
            margin: const EdgeInsets.only(top: 12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Provider ID:',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 116, 113, 113),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  providerPid,
                  style: TextStyle(
                    fontSize: 11,
                    color: providerPid.startsWith('PROV-')
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),

        // Contact Details Section
        if (providerEmail.isNotEmpty || (phone?.isNotEmpty == true))
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Contact Information',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),

                // Email
                if (providerEmail.isNotEmpty)
                  _buildContactRow(Icons.email_outlined, providerEmail),

                // Phone
                if (phone != null && phone.isNotEmpty)
                  _buildContactRow(Icons.phone_outlined, phone),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildProviderFallback(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildProfileAvatar(service.displayProviderName),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                service.displayProviderName,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        Container(
          margin: const EdgeInsets.only(top: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
          ),
          child: const Text(
            'Provider details could not be loaded. Contact information may be unavailable.',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(String photoUrl) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: 30,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String name) {
    // Get initials from name
    String initials = '';
    final nameParts = name.split(' ');
    if (nameParts.isNotEmpty) {
      initials = nameParts[0].isNotEmpty ? nameParts[0][0] : '';
      if (nameParts.length > 1 && nameParts[1].isNotEmpty) {
        initials += nameParts[1][0];
      }
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : 'P',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
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

  // ... [Keep all other methods the same: _buildPricingCard, _buildDescriptionCard,
  // _buildPerformanceMetrics, _buildAvailabilityCard, _buildSidebar, etc.]

  Widget _buildServiceDetails(ServiceModel service) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildServiceImage(service),
          const SizedBox(height: 20),
          Text(
            service.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          _buildPricingCard(service),
          const SizedBox(height: 20),

          // Provider Card with fetched provider details
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
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Book This Service',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _checkAndNavigateToReview,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Write a Review',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // Add these missing methods to make the code complete:

  Widget _buildPricingCard(ServiceModel service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pricing',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildPricingItem(
              'Service Price',
              '${service.price.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
            ),
            const SizedBox(height: 8),
            _buildPricingItem(
              'Booking Fee',
              '${(service.bookingPrice ?? 0).toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
            ),
            const Divider(height: 24),
            _buildPricingItem(
              'Total',
              '${service.totalPrice.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
              isTotal: true,
            ),
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
                child: Text(
                  service.pricingNotes!,
                  style: const TextStyle(fontSize: 13, color: Colors.amber),
                ),
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
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.secondary : Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionCard(ServiceModel service) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Description',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              service.description,
              style: const TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.grey,
              ),
            ),
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
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Performance Metrics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
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
                      'Bookings',
                      service.totalBookings?.toString() ?? '0',
                      icon: Icons.bookmark,
                    ),
                    GestureDetector(
                      onTap: _viewReviews,
                      child: _buildMetricCard(
                        'Reviews',
                        totalReviews.toString(),
                        icon: Icons.reviews,
                        hasAction: totalReviews > 0,
                      ),
                    ),
                    _buildMetricCard(
                      'Rating',
                      avgRating > 0 ? avgRating.toStringAsFixed(1) : 'N/A',
                      icon: Icons.star,
                    ),
                    _buildMetricCard(
                      'Available',
                      service.getAvailableSlotsCount().toString(),
                      icon: Icons.event_available,
                    ),
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
              : Colors.grey[300]!,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null)
            Icon(
              icon,
              size: 24,
              color: hasAction ? AppColors.primary : Colors.grey[600],
            ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: hasAction ? AppColors.primary : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: hasAction
                  ? AppColors.primary.withOpacity(0.8)
                  : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (hasAction)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Tap to view',
                style: TextStyle(
                  fontSize: 10,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
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
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Availability',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              alignment: Alignment.center,
              child: Column(
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$availableSlots slots available',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${service.workingDaysCount} days/week • ${service.totalTimeSlots} slots total',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSidebar(ServiceModel service) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Service Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildStatusBadge(
                  service.availabilityStatus,
                  _getAvailabilityColor(service),
                ),
                _buildStatusBadge(
                  service.status ?? 'published',
                  _getStatusColor(service.status),
                ),
                if (service.isVerified == true)
                  _buildStatusBadge('Verified', Colors.blue),
                if (service.isFeatured == true)
                  _buildStatusBadge('Featured', Colors.amber),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'Quick Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.remove_red_eye,
              'Views',
              service.views?.toString() ?? '0',
            ),
            _buildInfoRow(
              Icons.calendar_today,
              'Created',
              _formatDate(service.createdAt),
            ),
            _buildInfoRow(
              Icons.update,
              'Updated',
              _formatDate(service.updatedAt),
            ),
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
                    borderRadius: BorderRadius.circular(12),
                  ),
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

  Color _getAvailabilityColor(ServiceModel service) {
    final slots = service.getAvailableSlotsCount();
    if (slots == 0) return Colors.red;
    if (slots < 3) return Colors.orange;
    return Colors.green;
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

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: const Color.fromARGB(255, 116, 113, 113),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.grey),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
