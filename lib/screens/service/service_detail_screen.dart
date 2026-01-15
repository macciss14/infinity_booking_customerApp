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

  Future<void> _loadData() async {
    print('🔄 Loading service details for ID: ${widget.serviceId}');
    setState(() {
      _isLoading = true;
      _hasError = false;
      _loadedService = null;
      _provider = null;
      _providerPhone = null;
      _providerProfilePhoto = null;
    });

    try {
      _allServicesFuture = _serviceService.getAllServices();
      _reviewsFuture = _reviewService.getServiceReviews(widget.serviceId);

      final allServices = await _allServicesFuture;
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
        await _loadProviderDetails(foundService);
      }
    } catch (error) {
      print('❌ Error loading services: $error');
      _showError('Failed to load service details: $error');
    }
  }

  Future<void> _loadProviderDetails(ServiceModel service) async {
    print('🔍 Loading provider details...');
    
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
        } else {
          // Assume it's a MongoDB ID
          final provider =
              await _providerService.getProviderById(service.providerId!);
          _provider = provider;
          _providerPhone = provider.phonenumber;
          _providerProfilePhoto = provider.profilePhoto;
        }
      }
      // Fallback: Extract from service provider object if exists
      else if (service.provider != null && service.provider is Map) {
        _extractProviderFromServiceObject(service);
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

  Future<void> _retryLoading() async {
    await _loadData();
  }

  void _navigateToBooking() {
    if (_loadedService == null) {
      _showBookingError('Service not loaded');
      return;
    }

    // Debug print all provider information
    print('📋 Provider information check:');
    print('   - providerPid: ${_loadedService!.providerPid}');
    print('   - providerId: ${_loadedService!.providerId}');
    print('   - provider object: ${_loadedService!.provider}');
    print('   - loaded provider: $_provider');
    print('   - loaded provider PID: ${_provider?.pid}');

    // CRITICAL: Use providerPid first, then providerId as fallback
    String? bookingProviderId;
    String? providerName;

    // First priority: providerPid (should be PROV-xxx)
    if (_loadedService!.providerPid != null &&
        _loadedService!.providerPid!.isNotEmpty) {
      bookingProviderId = _loadedService!.providerPid!;
      print('✅ Using providerPid: $bookingProviderId');
    }
    // Second priority: providerId
    else if (_loadedService!.providerId != null &&
        _loadedService!.providerId!.isNotEmpty) {
      bookingProviderId = _loadedService!.providerId!;
      print('✅ Using providerId: $bookingProviderId');
    }
    // Third priority: provider PID from provider object
    else if (_provider?.pid != null && _provider!.pid.isNotEmpty) {
      bookingProviderId = _provider!.pid;
      print('✅ Using provider.pid: $bookingProviderId');
    }
    // Fourth priority: provider ID from provider object
    else if (_provider?.id != null && _provider!.id.isNotEmpty) {
      bookingProviderId = _provider!.id;
      print('✅ Using provider.id: $bookingProviderId');
    }
    // No provider ID found
    else {
      _showBookingError('Provider information not available. Cannot book.');
      return;
    }

    // Get provider name
    providerName = _provider?.fullname ?? 
                   _loadedService!.providerName ?? 
                   _loadedService!.displayProviderName;

    print('🎯 Navigating to booking with:');
    print('   - Service ID: ${widget.serviceId}');
    print('   - Provider ID: $bookingProviderId');
    print('   - Provider Name: $providerName');
    print('   - Service Name: ${_loadedService!.name}');

    // Try navigation with provider info
    try {
      RouteHelper.goToBookingWithProvider(
        context: context,
        serviceId: widget.serviceId,
        providerId: bookingProviderId!,
        service: _loadedService,
      );
    } catch (e) {
      print('❌ Navigation error: $e');
      
      // Fallback: Try regular booking without provider
      print('🔄 Trying fallback navigation...');
      try {
        RouteHelper.goToBookingWithModel(context, _loadedService!);
      } catch (e2) {
        print('❌ Fallback navigation also failed: $e2');
        _showBookingError('Unable to start booking process. Please try again.');
      }
    }
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

  void _handleReviewsTap() async {
    // SIMPLIFIED: Always navigate to view reviews first
    // User can try to write review from the reviews screen
    RouteHelper.goToReviews(context, widget.serviceId);
  }

  void _viewReviews() {
    RouteHelper.goToReviews(context, widget.serviceId);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Service Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(
              Icons.close,
              size: isSmallScreen ? 20 : 24,
            ),
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
                  : _buildServiceDetails(_loadedService!, screenWidth),
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red[400]),
            const SizedBox(height: 16),
            Text(
              'Service Error',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                _errorMessage.isNotEmpty
                    ? _errorMessage
                    : 'Failed to load service details',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(fontSize: 14, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoDataWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            const Text(
              'Service Not Found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'The service you are looking for does not exist or has been removed.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Go Back', style: TextStyle(fontSize: 14)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceDetails(ServiceModel service, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    final paddingValue = isSmallScreen ? 12.0 : 16.0;
    final buttonPadding = isSmallScreen 
      ? const EdgeInsets.symmetric(vertical: 14)
      : const EdgeInsets.symmetric(vertical: 16);

    return RefreshIndicator(
      onRefresh: _loadData,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.all(paddingValue),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            _buildServiceImage(service, screenWidth),
            const SizedBox(height: 16),
            
            // Service Name
            Text(
              service.name,
              style: TextStyle(
                fontSize: isSmallScreen ? 20 : 24,
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 8),
            
            // Pricing Card
            _buildPricingCard(service, screenWidth),
            const SizedBox(height: 16),
            
            // Provider Card (with contact info)
            _buildProviderCard(service, screenWidth),
            const SizedBox(height: 16),
            
            // Description
            _buildDescriptionCard(service, screenWidth),
            const SizedBox(height: 16),
            
            // Compact Performance Metrics with Smart Review Handling
            _buildCompactMetricsWithReviewLogic(service, screenWidth),
            const SizedBox(height: 16),
            
            // Availability Status
            _buildAvailabilityStatus(service, screenWidth),
            const SizedBox(height: 24),
            
            // Single Primary Action Button - Book Service
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _navigateToBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: buttonPadding,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
                  ),
                  elevation: 3,
                ),
                child: Text(
                  'Book This Service',
                  style: TextStyle(
                    fontSize: isSmallScreen ? 16 : 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceImage(ServiceModel service, double screenWidth) {
    final height = screenWidth * (9 / 16); // 16:9 aspect ratio
    final isSmallScreen = screenWidth < 360;
    
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        color: AppColors.primary.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        child: service.imageUrl?.isNotEmpty == true
            ? Image.network(
                service.imageUrl!,
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
                  return _buildPlaceholderImage();
                },
              )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.primary.withOpacity(0.05),
      child: Center(
        child: Icon(
          Icons.build,
          size: 48,
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  Widget _buildPricingCard(ServiceModel service, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pricing',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            // Service Price
            _buildPriceRow(
              'Service Price',
              '${service.price.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
              isSmallScreen,
            ),
            const SizedBox(height: 8),
            
            // Booking Fee
            _buildPriceRow(
              'Booking Fee',
              '${(service.bookingPrice ?? 0).toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
              isSmallScreen,
            ),
            
            const Divider(height: 20, thickness: 1),
            
            // Total
            _buildPriceRow(
              'Total Amount',
              '${service.totalPrice.toStringAsFixed(2)} ${service.priceUnit ?? 'ETB'}',
              isSmallScreen,
              isTotal: true,
            ),
            
            // Pricing Notes if available
            if (service.pricingNotes != null && service.pricingNotes!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Text(
                  service.pricingNotes!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.amber,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, bool isSmallScreen, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isSmallScreen ? 13 : 14,
            color: Colors.grey[700],
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isSmallScreen ? 14 : 15,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
            color: isTotal ? AppColors.secondary : Colors.grey[900],
          ),
        ),
      ],
    );
  }

  Widget _buildProviderCard(ServiceModel service, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Service Provider',
              style: TextStyle(
                fontSize: isSmallScreen ? 16 : 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            
            if (_isLoadingProvider)
              _buildProviderLoading()
            else if (_provider != null)
              _buildProviderInfo(service, isSmallScreen)
            else
              _buildProviderFallback(service, isSmallScreen),
          ],
        ),
      ),
    );
  }

  Widget _buildProviderLoading() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 20),
        child: CircularProgressIndicator(),
      ),
    );
  }

  Widget _buildProviderInfo(ServiceModel service, bool isSmallScreen) {
    final provider = _provider!;
    final phone = _providerPhone ?? provider.phonenumber;
    final profilePhoto = _providerProfilePhoto ?? provider.profilePhoto;
    final providerName = provider.fullname;
    final providerEmail = provider.email;
    final isVerified = provider.isVerified;
    final rating = provider.rating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Provider Header
        Row(
          children: [
            // Profile Photo/Avatar
            if (profilePhoto != null && profilePhoto.isNotEmpty)
              _buildProfilePhoto(profilePhoto, isSmallScreen)
            else
              _buildProfileAvatar(providerName, isSmallScreen),
            
            SizedBox(width: isSmallScreen ? 12 : 16),
            
            // Name and Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          providerName,
                          style: TextStyle(
                            fontSize: isSmallScreen ? 16 : 18,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (isVerified)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.verified, size: 12, color: Colors.blue),
                              const SizedBox(width: 2),
                              Text(
                                'Verified',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  
                  // Rating
                  if (rating != null && rating > 0) ...[
                    const SizedBox(height: 4),
                    Row(
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
                  ],
                ],
              ),
            ),
          ],
        ),
        
        // Contact Info
        if (providerEmail.isNotEmpty || (phone?.isNotEmpty == true)) ...[
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 12),
          
          // Email
          if (providerEmail.isNotEmpty)
            _buildContactRow(Icons.email_outlined, providerEmail, isSmallScreen),
          
          // Phone
          if (phone != null && phone.isNotEmpty)
            _buildContactRow(Icons.phone_outlined, phone, isSmallScreen),
        ],
      ],
    );
  }

  Widget _buildProviderFallback(ServiceModel service, bool isSmallScreen) {
    return Row(
      children: [
        _buildProfileAvatar(service.displayProviderName, isSmallScreen),
        SizedBox(width: isSmallScreen ? 12 : 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                service.displayProviderName,
                style: TextStyle(
                  fontSize: isSmallScreen ? 16 : 18,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              Text(
                'Contact details unavailable',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfilePhoto(String photoUrl, bool isSmallScreen) {
    final size = isSmallScreen ? 50.0 : 60.0;
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(size / 2),
        child: Image.network(
          photoUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: AppColors.primary.withOpacity(0.1),
              child: Center(
                child: Icon(
                  Icons.person,
                  size: size * 0.5,
                  color: AppColors.primary,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildProfileAvatar(String name, bool isSmallScreen) {
    final size = isSmallScreen ? 50.0 : 60.0;
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
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(size / 2),
        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : 'P',
          style: TextStyle(
            fontSize: size * 0.3,
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildContactRow(IconData icon, String text, bool isSmallScreen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactMetricsWithReviewLogic(ServiceModel service, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    final itemWidth = (screenWidth - 32 - 12) / 4;
    
    return FutureBuilder<List<ReviewModel>>(
      future: _reviewsFuture,
      builder: (context, reviewSnapshot) {
        int totalReviews = 0;
        double avgRating = 0.0;
        if (reviewSnapshot.hasData) {
          final reviews = reviewSnapshot.data!;
          totalReviews = reviews.length;
          if (totalReviews > 0) {
            avgRating = reviews.fold(0.0, (sum, r) => sum + (r.rating ?? 0)) / totalReviews;
          }
        } else if (service.reviewCount != null) {
          totalReviews = service.reviewCount!;
          avgRating = service.rating ?? 0.0;
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            border: Border.all(color: Colors.grey[300]!),
            color: Colors.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Bookings
              _buildCompactMetricItem(
                Icons.bookmark,
                '${service.totalBookings ?? 0}',
                'Bookings',
                itemWidth,
              ),
              
              // Reviews (Smart Tap - View reviews)
              GestureDetector(
                onTap: _viewReviews,
                child: _buildCompactMetricItem(
                  Icons.reviews,
                  '$totalReviews',
                  'Reviews',
                  itemWidth,
                  isTappable: true,
                ),
              ),
              
              // Rating
              GestureDetector(
                onTap: _viewReviews,
                child: _buildCompactMetricItem(
                  Icons.star,
                  avgRating > 0 ? avgRating.toStringAsFixed(1) : '0.0',
                  'Rating',
                  itemWidth,
                  isTappable: true,
                ),
              ),
              
              // Available Slots
              _buildCompactMetricItem(
                Icons.event_available,
                service.getAvailableSlotsCount().toString(),
                'Available',
                itemWidth,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCompactMetricItem(IconData icon, String value, String label, double width, 
      {bool isTappable = false}) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 20,
            color: isTappable ? AppColors.primary : Colors.grey[700],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isTappable ? AppColors.primary : Colors.grey[900],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isTappable 
                  ? AppColors.primary.withOpacity(0.8) 
                  : Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          if (isTappable)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Tap to view',
                style: TextStyle(
                  fontSize: 8,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvailabilityStatus(ServiceModel service, double screenWidth) {
    final availableSlots = service.getAvailableSlotsCount();
    final status = service.availabilityStatus;
    Color statusColor = availableSlots == 0
        ? Colors.red
        : availableSlots < 3
            ? Colors.orange
            : Colors.green;

    final isSmallScreen = screenWidth < 360;
    
    return Container(
      padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            availableSlots > 0 ? Icons.check_circle : Icons.error,
            color: statusColor,
            size: isSmallScreen ? 20 : 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 15 : 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '$availableSlots slots available',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(ServiceModel service, double screenWidth) {
    final isSmallScreen = screenWidth < 360;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description',
          style: TextStyle(
            fontSize: isSmallScreen ? 16 : 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
            color: Colors.grey[50],
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            service.description,
            style: TextStyle(
              fontSize: isSmallScreen ? 13 : 14,
              height: 1.5,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }
}