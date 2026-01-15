// lib/screens/main/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/category_service.dart';
import '../../services/service_service.dart';
import '../../services/booking_service.dart';
import '../../models/category_model.dart';
import '../../models/service_model.dart';
import '../../models/booking_model.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';
import '../../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final CategoryService _categoryService = CategoryService();
  final ServiceService _serviceService = ServiceService();
  final BookingService _bookingService = BookingService();
  final AuthService _authService = AuthService();

  late Future<List<CategoryModel>> _categoriesFuture;
  late Future<List<ServiceModel>> _servicesFuture;
  late Future<List<BookingModel>> _recentBookingsFuture;
  late Future<UserModel?> _userFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _categoriesFuture = _categoryService.getCategories();
    _servicesFuture = _serviceService.getAllServices();
    _recentBookingsFuture = _bookingService.getUserBookings();
    _userFuture = _authService.getCurrentUser();
  }

  void _refreshData() => setState(_loadData);

  void _navigateToServices() {
    RouteHelper.pushNamed(context, RouteHelper.serviceList);
  }

  void _navigateToBookings() {
    RouteHelper.pushNamed(context, RouteHelper.bookings);
  }

  void _navigateToServiceDetail(String serviceId) {
    RouteHelper.pushNamed(
      context,
      RouteHelper.serviceDetail,
      arguments: serviceId,
    );
  }

  void _navigateToCategoryServices(String categoryId) {
    RouteHelper.goToServiceList(
      context,
      categoryId: categoryId,
    );
  }

  Map<String, int> _calculateServiceCounts(
    List<CategoryModel> categories,
    List<ServiceModel> services,
  ) {
    final counts = <String, int>{};

    for (final category in categories) {
      counts[category.id] = 0;
    }

    for (final service in services) {
      if (service.isAvailableForBooking()) {
        final categoryId = service.categoryId;
        if (counts.containsKey(categoryId)) {
          counts[categoryId] = counts[categoryId]! + 1;
        }
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isPortrait = screenHeight > screenWidth;
    final isSmallScreen = screenWidth < 360;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          _refreshData();
          await Future.delayed(const Duration(seconds: 1));
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 600 ? 12 : 16,
                vertical: 12,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Section
                  FutureBuilder<UserModel?>(
                    future: _userFuture,
                    builder: (context, snapshot) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back 👋',
                            style: TextStyle(
                              fontSize: constraints.maxWidth < 600 ? 20 : 24,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Book your favorite services with ease',
                            style: TextStyle(
                              fontSize: constraints.maxWidth < 600 ? 14 : 16,
                              color: AppColors.textSecondary,
                              height: 1.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Quick Actions
                  Text(
                    'Quick Actions',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildQuickActionsGrid(constraints),
                  const SizedBox(height: 24),

                  // Popular Categories
                  Text(
                    'Popular Categories',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<CategoryModel>>(
                    future: _categoriesFuture,
                    builder: (context, categorySnapshot) {
                      if (categorySnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return _buildLoadingGrid(constraints);
                      }
                      if (categorySnapshot.hasError) {
                        return _buildErrorWidget(
                            'Failed to load categories: ${categorySnapshot.error}');
                      }
                      if (categorySnapshot.hasData &&
                          categorySnapshot.data!.isNotEmpty) {
                        final categories = categorySnapshot.data!;
                        return FutureBuilder<List<ServiceModel>>(
                          future: _servicesFuture,
                          builder: (context, serviceSnapshot) {
                            if (serviceSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return _buildLoadingGrid(constraints);
                            }
                            if (serviceSnapshot.hasError) {
                              return _buildErrorWidget(
                                  'Failed to load services: ${serviceSnapshot.error}');
                            }
                            final serviceCounts = _calculateServiceCounts(
                              categories,
                              serviceSnapshot.data ?? [],
                            );
                            return _buildCategoriesGrid(
                                categories, serviceCounts, constraints);
                          },
                        );
                      }
                      return _buildEmptyWidget('No categories available');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Featured Services
                  Text(
                    'Featured Services',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<ServiceModel>>(
                    future: _servicesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingList(constraints);
                      }
                      if (snapshot.hasError) {
                        return _buildErrorWidget(
                            'Failed to load services: ${snapshot.error}');
                      }
                      if (snapshot.hasData) {
                        final featuredServices = snapshot.data!
                            .where((service) => service.isFeatured == true)
                            .take(5)
                            .toList();

                        final services = featuredServices.isNotEmpty
                            ? featuredServices
                            : snapshot.data!.take(5).toList();

                        return _buildServicesList(services, constraints);
                      }
                      return _buildEmptyWidget('No featured services');
                    },
                  ),
                  const SizedBox(height: 24),

                  // Recent Bookings
                  Text(
                    'Recent Bookings',
                    style: TextStyle(
                      fontSize: constraints.maxWidth < 600 ? 18 : 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  FutureBuilder<List<BookingModel>>(
                    future: _recentBookingsFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return _buildLoadingList(constraints);
                      }
                      if (snapshot.hasError) {
                        return _buildErrorWidget(
                            'Failed to load bookings: ${snapshot.error}');
                      }
                      if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                        final recent = snapshot.data!.take(3).toList();
                        return _buildBookingsList(recent, constraints);
                      }
                      return _buildEmptyWidget('No recent bookings');
                    },
                  ),
                  SizedBox(height: constraints.maxWidth < 600 ? 24 : 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;
    final crossAxisCount = constraints.maxWidth > 600
        ? 3
        : constraints.maxWidth > 400
            ? 3
            : 3;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: isSmallScreen ? 8 : 12,
      mainAxisSpacing: isSmallScreen ? 8 : 12,
      childAspectRatio: 0.9,
      children: [
        _buildQuickActionItem(
          icon: Icons.category,
          title: 'Browse\nServices',
          onTap: _navigateToServices,
          constraints: constraints,
        ),
        _buildQuickActionItem(
          icon: Icons.calendar_today,
          title: 'My\nBookings',
          onTap: _navigateToBookings,
          constraints: constraints,
        ),
        _buildQuickActionItem(
          icon: Icons.local_offer,
          title: 'Special\nOffers',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Special offers coming soon!'),
                duration: Duration(seconds: 2),
              ),
            );
          },
          constraints: constraints,
        ),
      ],
    );
  }

  Widget _buildQuickActionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required BoxConstraints constraints,
  }) {
    final isSmallScreen = constraints.maxWidth < 400;
    
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      elevation: 2,
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Container(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: isSmallScreen ? 28 : 32,
                color: AppColors.primary,
              ),
              const SizedBox(height: 6),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: isSmallScreen ? 11 : 12,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(
    List<CategoryModel> categories,
    Map<String, int> serviceCounts,
    BoxConstraints constraints,
  ) {
    final crossAxisCount = constraints.maxWidth > 600
        ? 4
        : constraints.maxWidth > 400
            ? 3
            : 3;
    final isSmallScreen = constraints.maxWidth < 400;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
        childAspectRatio: constraints.maxWidth > 600
            ? 0.8
            : constraints.maxWidth > 400
                ? 0.9
                : 1.0,
      ),
      itemCount: categories.length > 6 ? 6 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        final count = serviceCounts[category.id] ?? 0;

        return Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: 2,
          margin: EdgeInsets.zero,
          child: InkWell(
            onTap: () => _navigateToCategoryServices(category.id),
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Container(
              padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: category.imageUrl != null
                        ? Image.network(
                            category.imageUrl!,
                            width: isSmallScreen ? 20 : 24,
                            height: isSmallScreen ? 20 : 24,
                            errorBuilder: (context, error, stackTrace) =>
                                Icon(Icons.category,
                                    color: AppColors.primary,
                                    size: isSmallScreen ? 20 : 24),
                          )
                        : Icon(Icons.category,
                            color: AppColors.primary,
                            size: isSmallScreen ? 20 : 24),
                  ),
                  SizedBox(height: isSmallScreen ? 6 : 8),
                  Flexible(
                    child: Text(
                      category.name,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 11 : 12,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 2 : 4),
                  Text(
                    '$count services',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildServicesList(
    List<ServiceModel> services,
    BoxConstraints constraints,
  ) {
    final isSmallScreen = constraints.maxWidth < 400;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: services.length,
      itemBuilder: (context, index) {
        final service = services[index];
        return Card(
          margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            leading: service.imageUrl != null && service.imageUrl!.isNotEmpty
                ? CircleAvatar(
                    radius: isSmallScreen ? 20 : 25,
                    backgroundImage: NetworkImage(service.imageUrl!),
                    backgroundColor: Colors.grey[200],
                  )
                : CircleAvatar(
                    radius: isSmallScreen ? 20 : 25,
                    backgroundColor: Colors.grey,
                    child: Icon(Icons.build,
                        color: Colors.white,
                        size: isSmallScreen ? 20 : 24),
                  ),
            title: Text(
              service.name,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  service.description.length > 60
                      ? '${service.description.substring(0, 60)}...'
                      : service.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: isSmallScreen ? 12 : 14,
                    height: 1.3,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        service.formattedPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                          fontSize: isSmallScreen ? 13 : 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: isSmallScreen ? 6 : 8),
                    if (service.rating != null && service.rating! > 0)
                      Row(
                        children: [
                          Icon(Icons.star,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.amber),
                          SizedBox(width: isSmallScreen ? 1 : 2),
                          Text(
                            service.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 11 : 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: isSmallScreen ? 14 : 16,
              color: AppColors.textSecondary,
            ),
            onTap: () => _navigateToServiceDetail(service.id),
          ),
        );
      },
    );
  }

  Widget _buildBookingsList(
    List<BookingModel> bookings,
    BoxConstraints constraints,
  ) {
    final isSmallScreen = constraints.maxWidth < 400;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Card(
          margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 12 : 16,
              vertical: isSmallScreen ? 8 : 12,
            ),
            leading: Container(
              width: isSmallScreen ? 40 : 50,
              height: isSmallScreen ? 40 : 50,
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getStatusIcon(booking.status),
                color: _getStatusColor(booking.status),
                size: isSmallScreen ? 18 : 24,
              ),
            ),
            title: Text(
              booking.serviceName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                fontSize: isSmallScreen ? 14 : 16,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(
                  child: Text(
                    '${booking.formattedBookingDate} • ${booking.formattedTimeRange}',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: isSmallScreen ? 12 : 14,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 4 : 6),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 6 : 8,
                    vertical: isSmallScreen ? 2 : 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: isSmallScreen ? 9 : 10,
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            trailing: SizedBox(
              width: isSmallScreen ? 60 : 80,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                      fontSize: isSmallScreen ? 11 : 12,
                    ),
                    textAlign: TextAlign.end,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (booking.isPendingPayment)
                    Text(
                      'Payment Pending',
                      style: TextStyle(
                        fontSize: isSmallScreen ? 9 : 10,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.end,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            onTap: () {
              RouteHelper.pushNamed(context, RouteHelper.bookings);
            },
          ),
        );
      },
    );
  }

  Widget _buildLoadingGrid(BoxConstraints constraints) {
    final crossAxisCount = constraints.maxWidth > 600
        ? 4
        : constraints.maxWidth > 400
            ? 3
            : 3;
    final isSmallScreen = constraints.maxWidth < 400;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: isSmallScreen ? 8 : 12,
        mainAxisSpacing: isSmallScreen ? 8 : 12,
        childAspectRatio: constraints.maxWidth > 600
            ? 0.8
            : constraints.maxWidth > 400
                ? 0.9
                : 1.0,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Container(
            padding: EdgeInsets.all(isSmallScreen ? 8 : 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: isSmallScreen ? 32 : 40,
                  height: isSmallScreen ? 32 : 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: isSmallScreen ? 6 : 8),
                Container(
                  width: isSmallScreen ? 40 : 60,
                  height: isSmallScreen ? 10 : 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: isSmallScreen ? 2 : 4),
                Container(
                  width: isSmallScreen ? 30 : 40,
                  height: isSmallScreen ? 8 : 10,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingList(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.only(bottom: isSmallScreen ? 8 : 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Padding(
            padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
            child: Row(
              children: [
                Container(
                  width: isSmallScreen ? 40 : 50,
                  height: isSmallScreen ? 40 : 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                SizedBox(width: isSmallScreen ? 12 : 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: isSmallScreen ? 80 : 120,
                        height: isSmallScreen ? 14 : 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 4 : 6),
                      Container(
                        width: isSmallScreen ? 120 : 180,
                        height: isSmallScreen ? 10 : 12,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.red),
            ),
          ),
          TextButton(
            onPressed: _refreshData,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.inbox, size: 64, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style:
                const TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
      case 'pending_payment':
        return Colors.orange;
      case 'completed':
        return AppColors.primary;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
      case 'pending_payment':
        return Icons.schedule;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }
}