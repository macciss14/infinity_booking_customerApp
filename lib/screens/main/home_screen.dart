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
    Navigator.of(context)
        .popUntil((route) => route.settings.name == RouteHelper.main);
  }

  void _navigateToServiceDetail(String serviceId) {
    RouteHelper.pushNamed(context, RouteHelper.serviceDetail,
        arguments: serviceId);
  }

  void _navigateToCategoryServices(String categoryId) {
    RouteHelper.pushNamed(
      context,
      RouteHelper.serviceList,
      arguments: {'categoryId': categoryId},
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        _refreshData();
        await Future.delayed(const Duration(seconds: 1));
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<UserModel?>(
              future: _userFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text('Hello, Loading... 👋',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold));
                }
                final userName = snapshot.data?.fullname ?? 'Guest';
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Hello, $userName! 👋',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        )),
                    const SizedBox(height: 8),
                    Text('Book your favorite services with ease',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                        )),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            Text('Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.category,
                    title: 'Browse\nServices',
                    onTap: _navigateToServices,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.calendar_today,
                    title: 'My\nBookings',
                    onTap: _navigateToBookings,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickAction(
                    icon: Icons.local_offer,
                    title: 'Special\nOffers',
                    onTap: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text('Popular Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 16),
            FutureBuilder<List<CategoryModel>>(
              future: _categoriesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingGrid();
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                      'Failed to load categories: ${snapshot.error}');
                }
                if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  return _buildCategoriesGrid(snapshot.data!);
                }
                return _buildEmptyWidget('No categories available');
              },
            ),
            const SizedBox(height: 32),
            Text('Featured Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 16),
            FutureBuilder<List<ServiceModel>>(
              future: _servicesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingList();
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                      'Failed to load services: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  final featured = snapshot.data!.take(5).toList();
                  return _buildServicesList(featured);
                }
                return _buildEmptyWidget('No featured services');
              },
            ),
            const SizedBox(height: 32),
            Text('Recent Bookings',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                )),
            const SizedBox(height: 16),
            FutureBuilder<List<BookingModel>>(
              future: _recentBookingsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildLoadingList();
                }
                if (snapshot.hasError) {
                  return _buildErrorWidget(
                      'Failed to load bookings: ${snapshot.error}');
                }
                if (snapshot.hasData) {
                  final recent = snapshot.data!.take(3).toList();
                  return _buildBookingsList(recent);
                }
                return _buildEmptyWidget('No recent bookings');
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
        child: Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: AppColors.primary),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoriesGrid(List<CategoryModel> categories) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: categories.length > 6 ? 6 : categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          elevation: 2,
          child: InkWell(
            onTap: () => _navigateToCategoryServices(category.id),
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
            child: Container(
              padding: const EdgeInsets.all(12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: category.imageUrl != null
                        ? Image.network(
                            category.imageUrl!,
                            width: 24,
                            height: 24,
                            errorBuilder: (context, error, stackTrace) => Icon(
                                Icons.category,
                                color: AppColors.primary,
                                size: 24),
                          )
                        : Icon(Icons.category,
                            color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    category.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${category.serviceCount ?? 0} services',
                    style: TextStyle(
                      fontSize: 10,
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

  Widget _buildServicesList(List<ServiceModel> services) {
    return Column(
      children: services
          .map((service) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
                child: ListTile(
                  leading: service.imageUrl != null
                      ? CircleAvatar(
                          radius: 25,
                          backgroundImage: NetworkImage(service.imageUrl!),
                        )
                      : const CircleAvatar(
                          backgroundColor: Colors.grey,
                          child: Icon(Icons.build, color: Colors.white),
                        ),
                  title: Text(
                    service.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
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
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        service.formattedPrice,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                    ],
                  ),
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  onTap: () => _navigateToServiceDetail(service.id),
                ),
              ))
          .toList(),
    );
  }

  Widget _buildBookingsList(List<BookingModel> bookings) {
    return Column(
      children: bookings
          .map((booking) => Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.defaultBorderRadius,
                  ),
                ),
                child: ListTile(
                  leading: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getStatusColor(booking.status).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStatusIcon(booking.status),
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                  title: Text(
                    booking.serviceName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${booking.formattedDate} • ${booking.slotStart ?? 'Time pending'}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        booking.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(booking.status),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    booking.formattedPrice,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
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
        return Icons.schedule;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.help;
    }
  }

  Widget _buildLoadingGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.9,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return Card(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  width: 60,
                  height: 12,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 40,
                  height: 8,
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

  Widget _buildLoadingList() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.defaultBorderRadius),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 120,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        width: 180,
                        height: 12,
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
          Icon(Icons.error, color: Colors.red),
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
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
