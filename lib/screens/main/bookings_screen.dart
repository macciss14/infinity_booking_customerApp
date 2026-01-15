// lib/screens/main/bookings_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking_service.dart';
import '../../services/review_service.dart';
import '../../models/booking_model.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  final ReviewService _reviewService = ReviewService();
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String _selectedFilter = 'all';
  late TabController _tabController;
  final Map<String, int> _bookingCounts = {
    'all': 0,
    'upcoming': 0,
    'pending': 0,
    'completed': 0,
    'cancelled': 0,
  };
  bool _hasError = false;
  String? _errorMessage;
  int _refreshAttempts = 0;
  final int _maxRefreshAttempts = 3;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _tabController.addListener(_handleTabSelection);
    _loadBookings();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      final filters = ['all', 'upcoming', 'pending', 'completed', 'cancelled'];
      setState(() {
        _selectedFilter = filters[_tabController.index];
      });
    }
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;

    setState(() {
      _loading = true;
      _hasError = false;
      _errorMessage = null;
    });

    try {
      final bookings = await _bookingService.getUserBookings();

      if (!mounted) return;

      setState(() {
        _bookings = bookings;
        _updateBookingCounts();
        _refreshAttempts = 0;
      });
    } catch (error) {
      print('❌ Error loading bookings: $error');

      if (!mounted) return;

      _refreshAttempts++;

      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });

      if (_refreshAttempts == 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('Failed to load bookings'),
                ),
                if (_refreshAttempts < _maxRefreshAttempts)
                  TextButton(
                    onPressed: _loadBookings,
                    child: const Text(
                      'RETRY',
                      style: TextStyle(color: Colors.yellow),
                    ),
                  ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _updateBookingCounts() {
    _bookingCounts['all'] = _bookings.length;
    _bookingCounts['upcoming'] =
        _bookings.where((b) => b.status.toLowerCase() == 'confirmed').length;
    _bookingCounts['pending'] = _bookings
        .where((b) =>
            b.status.toLowerCase() == 'pending' ||
            b.status.toLowerCase() == 'pending_payment')
        .length;
    _bookingCounts['completed'] =
        _bookings.where((b) => b.status.toLowerCase() == 'completed').length;
    _bookingCounts['cancelled'] =
        _bookings.where((b) => b.status.toLowerCase() == 'cancelled').length;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          children: [
            // Tab Bar - Fixed for mobile
            Container(
              color: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: constraints.maxWidth < 400 ? 8 : 16,
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: constraints.maxWidth < 600,
                labelPadding: EdgeInsets.symmetric(
                  horizontal: constraints.maxWidth < 400 ? 6 : 12,
                ),
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                indicatorColor: AppColors.primary,
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: _buildTabItems(constraints),
              ),
            ),
            
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTabContent('all', constraints),
                  _buildTabContent('upcoming', constraints),
                  _buildTabContent('pending', constraints),
                  _buildTabContent('completed', constraints),
                  _buildTabContent('cancelled', constraints),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildTabItems(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;
    final isVerySmallScreen = constraints.maxWidth < 360;

    return [
      _buildTabItem('All', _bookingCounts['all']!, isSmallScreen, isVerySmallScreen),
      _buildTabItem('Upcoming', _bookingCounts['upcoming']!, isSmallScreen, isVerySmallScreen),
      _buildTabItem('Pending', _bookingCounts['pending']!, isSmallScreen, isVerySmallScreen),
      _buildTabItem('Completed', _bookingCounts['completed']!, isSmallScreen, isVerySmallScreen),
      _buildTabItem('Cancelled', _bookingCounts['cancelled']!, isSmallScreen, isVerySmallScreen),
    ];
  }

  Widget _buildTabItem(String label, int count, bool isSmallScreen, bool isVerySmallScreen) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isVerySmallScreen && label.length > 6 ? label.substring(0, 6) : label,
            style: TextStyle(
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: isSmallScreen ? 4 : 6,
              vertical: isSmallScreen ? 1 : 2,
            ),
            constraints: BoxConstraints(
              minWidth: isSmallScreen ? 20 : 24,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                fontSize: isSmallScreen ? 10 : 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String filter, BoxConstraints constraints) {
    if (_loading) {
      return _buildLoadingState(constraints);
    }

    if (_hasError) {
      return _buildErrorState(constraints);
    }

    List<BookingModel> filteredList;

    switch (filter) {
      case 'upcoming':
        filteredList = _bookings
            .where((b) => b.status.toLowerCase() == 'confirmed')
            .toList();
        break;
      case 'pending':
        filteredList = _bookings
            .where((b) =>
                b.status.toLowerCase() == 'pending' ||
                b.status.toLowerCase() == 'pending_payment')
            .toList();
        break;
      case 'completed':
        filteredList = _bookings
            .where((b) => b.status.toLowerCase() == 'completed')
            .toList();
        break;
      case 'cancelled':
        filteredList = _bookings
            .where((b) => b.status.toLowerCase() == 'cancelled')
            .toList();
        break;
      default:
        filteredList = _bookings;
    }

    if (filteredList.isEmpty) {
      return _buildEmptyState(filter, constraints);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: EdgeInsets.all(constraints.maxWidth < 400 ? 12 : 16),
        itemCount: filteredList.length,
        separatorBuilder: (context, index) => SizedBox(height: constraints.maxWidth < 400 ? 8 : 12),
        itemBuilder: (context, index) {
          return _buildBookingCard(filteredList[index], constraints);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;
    final isVerySmallScreen = constraints.maxWidth < 360;
    final isUpcoming = booking.status.toLowerCase() == 'confirmed' &&
        booking.bookingDate.isAfter(DateTime.now());
    final isToday = booking.bookingDate.day == DateTime.now().day &&
        booking.bookingDate.month == DateTime.now().month &&
        booking.bookingDate.year == DateTime.now().year;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        side: BorderSide(
          color: isUpcoming 
              ? Colors.green.withOpacity(0.3) 
              : isToday
                  ? AppColors.primary.withOpacity(0.3)
                  : Colors.grey[300]!,
          width: isUpcoming || isToday ? 1.5 : 0.5,
        ),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
        onLongPress: () => _showQuickActions(booking),
        borderRadius: BorderRadius.circular(isSmallScreen ? 10 : 12),
        child: Padding(
          padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Indicator
              Container(
                width: isSmallScreen ? 6 : 8,
                height: isSmallScreen ? 60 : 80,
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status),
                  borderRadius: BorderRadius.circular(isSmallScreen ? 3 : 4),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(booking.status).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),

              // Service Image
              Container(
                width: isSmallScreen ? 50 : 70,
                height: isSmallScreen ? 50 : 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                  color: Colors.grey[200],
                  image: booking.serviceImage != null &&
                          booking.serviceImage!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(booking.serviceImage!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: booking.serviceImage == null ||
                        booking.serviceImage!.isEmpty
                    ? Icon(
                        Icons.build,
                        size: isSmallScreen ? 20 : 30,
                        color: Colors.grey[500],
                      )
                    : null,
              ),
              SizedBox(width: isSmallScreen ? 8 : 12),

              // Booking Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: TextStyle(
                              fontSize: isSmallScreen ? 14 : 16,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 6 : 8,
                            vertical: isSmallScreen ? 2 : 4,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 70 : 100,
                          ),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
                          ),
                          child: Text(
                            _getStatusDisplay(booking.status),
                            style: TextStyle(
                              fontSize: isSmallScreen ? 9 : 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(booking.status),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 2 : 4),

                    // Provider Name
                    Text(
                      booking.providerName,
                      style: TextStyle(
                        fontSize: isSmallScreen ? 12 : 14,
                        color: Colors.grey,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),

                    // Date & Time
                    Wrap(
                      spacing: isSmallScreen ? 8 : 12,
                      runSpacing: isSmallScreen ? 4 : 6,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: isSmallScreen ? 12 : 14,
                              color: isToday ? AppColors.primary : Colors.grey,
                            ),
                            SizedBox(width: isSmallScreen ? 2 : 4),
                            Text(
                              isToday ? 'Today' : booking.formattedBookingDate,
                              style: TextStyle(
                                fontSize: isSmallScreen ? 11 : 13,
                                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                                color: isToday ? AppColors.primary : Colors.grey[700],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.access_time,
                              size: isSmallScreen ? 12 : 14,
                              color: Colors.grey,
                            ),
                            SizedBox(width: isSmallScreen ? 2 : 4),
                            Flexible(
                              child: Text(
                                booking.formattedTimeRange,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 11 : 13,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: isSmallScreen ? 6 : 8),

                    // Price & Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: isSmallScreen ? 8 : 12,
                            vertical: isSmallScreen ? 4 : 6,
                          ),
                          constraints: BoxConstraints(
                            maxWidth: isSmallScreen ? 120 : 160,
                          ),
                          decoration: BoxDecoration(
                            color: booking.isPaid
                                ? Colors.green.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(isSmallScreen ? 6 : 8),
                            border: Border.all(
                              color: booking.isPaid
                                  ? Colors.green.withOpacity(0.3)
                                  : AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                booking.isPaid
                                    ? Icons.check_circle
                                    : Icons.pending,
                                size: isSmallScreen ? 12 : 14,
                                color: booking.isPaid
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                              SizedBox(width: isSmallScreen ? 4 : 6),
                              Flexible(
                                child: Text(
                                  '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: booking.isPaid
                                        ? Colors.green
                                        : AppColors.primary,
                                    fontSize: isSmallScreen ? 12 : 14,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quick Action Button
                        if (_hasQuickAction(booking))
                          IconButton(
                            onPressed: () => _handleQuickAction(booking),
                            icon: Icon(
                              _getQuickActionIcon(booking),
                              size: isSmallScreen ? 18 : 20,
                              color: _getQuickActionColor(booking),
                            ),
                            padding: EdgeInsets.all(isSmallScreen ? 2 : 4),
                            visualDensity: VisualDensity.compact,
                            tooltip: _getQuickActionTooltip(booking),
                            constraints: BoxConstraints(
                              minWidth: isSmallScreen ? 36 : 40,
                              minHeight: isSmallScreen ? 36 : 40,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: isSmallScreen ? 50 : 60,
            height: isSmallScreen ? 50 : 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: isSmallScreen ? 16 : 20),
          Text(
            'Loading your bookings...',
            style: TextStyle(
              fontSize: isSmallScreen ? 14 : 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: isSmallScreen ? 8 : 10),
          Text(
            'Please wait a moment',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isSmallScreen ? 12 : 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: isSmallScreen ? 60 : 80,
              color: Colors.red,
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              'Unable to Load Bookings',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 20 : 32),
              child: Text(
                _errorMessage ?? 'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadBookings,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 20 : 24,
                      vertical: isSmallScreen ? 10 : 12,
                    ),
                  ),
                ),
                if (_refreshAttempts >= _maxRefreshAttempts) ...[
                  SizedBox(height: isSmallScreen ? 12 : 16),
                  OutlinedButton.icon(
                    onPressed: () => RouteHelper.goToHome(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                  ),
                ],
              ],
            ),
            SizedBox(height: isSmallScreen ? 12 : 16),
            TextButton(
              onPressed: () => _contactSupport(),
              child: const Text('Contact Support'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter, BoxConstraints constraints) {
    final isSmallScreen = constraints.maxWidth < 400;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(filter),
              size: isSmallScreen ? 60 : 80,
              color: Colors.grey[400],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Text(
              _getEmptyStateMessage(filter),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isSmallScreen ? 18 : 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: isSmallScreen ? 8 : 12),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 24 : 40),
              child: Text(
                _getEmptyStateSubtitle(filter),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: isSmallScreen ? 13 : 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 24 : 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    RouteHelper.pushNamed(context, RouteHelper.serviceList);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 32 : 40,
                      vertical: isSmallScreen ? 12 : 14,
                    ),
                  ),
                  child: const Text('Browse Services'),
                ),
                SizedBox(height: isSmallScreen ? 12 : 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _loadBookings,
                      child: const Text('Refresh'),
                    ),
                    SizedBox(width: isSmallScreen ? 12 : 16),
                    if (filter != 'all')
                      OutlinedButton(
                        onPressed: () {
                          _tabController.animateTo(0);
                        },
                        child: const Text('View All'),
                      ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool _hasQuickAction(BookingModel booking) {
    final status = booking.status.toLowerCase();
    return status == 'pending_payment' ||
        status == 'confirmed' ||
        status == 'completed';
  }

  IconData _getQuickActionIcon(BookingModel booking) {
    final status = booking.status.toLowerCase();
    if (status == 'pending_payment') return Icons.payment;
    if (status == 'confirmed') return Icons.schedule;
    if (status == 'completed') return Icons.star;
    return Icons.info;
  }

  Color _getQuickActionColor(BookingModel booking) {
    final status = booking.status.toLowerCase();
    if (status == 'pending_payment') return Colors.green;
    if (status == 'confirmed') return AppColors.primary;
    if (status == 'completed') return Colors.orange;
    return Colors.grey;
  }

  String _getQuickActionTooltip(BookingModel booking) {
    final status = booking.status.toLowerCase();
    if (status == 'pending_payment') return 'Pay Now';
    if (status == 'confirmed') return 'Reschedule';
    if (status == 'completed') return 'Add Review';
    return 'View Details';
  }

  void _handleQuickAction(BookingModel booking) {
    final status = booking.status.toLowerCase();
    if (status == 'pending_payment') {
      _processPayment(booking);
    } else if (status == 'confirmed') {
      _rescheduleBooking(booking);
    } else if (status == 'completed') {
      _addReview(booking);
    } else {
      _showBookingDetails(booking);
    }
  }

  Future<void> _processPayment(BookingModel booking) async {
    print('Processing payment for booking: ${booking.id}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _rescheduleBooking(BookingModel booking) async {
    print('Rescheduling booking: ${booking.id}');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reschedule feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _showBookingDetails(BookingModel booking) async {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 400;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BookingDetailsBottomSheet(
          booking: booking,
          onRefresh: _loadBookings,
          onAddReview: () => _addReview(booking),
          isSmallScreen: isSmallScreen,
        );
      },
    );
  }

  void _showQuickActions(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.content_copy),
                title: const Text('Copy Booking ID'),
                onTap: () {
                  Navigator.pop(context);
                  _copyBookingId(booking);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('Share Booking'),
                onTap: () {
                  Navigator.pop(context);
                  _shareBooking(booking);
                },
              ),
              ListTile(
                leading: const Icon(Icons.print),
                title: const Text('Print Details'),
                onTap: () {
                  Navigator.pop(context);
                  _printBooking(booking);
                },
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyBookingId(BookingModel booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking ID copied')),
    );
  }

  void _shareBooking(BookingModel booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _printBooking(BookingModel booking) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Print functionality coming soon')),
    );
  }

  Future<void> _addReview(BookingModel booking) async {
    print('📝 Adding review for booking: ${booking.id}');

    try {
      final userReviews = await _reviewService.getUserReviews();
      final alreadyReviewed = userReviews
          .any((review) => review.bookingId == booking.id);

      if (alreadyReviewed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have already reviewed this booking.'),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }

      RouteHelper.goToWriteReview(
        context,
        serviceId: booking.serviceId,
        serviceName: booking.serviceName,
        bookingId: booking.id,
      );
    } catch (error) {
      print('⚠️ Error checking reviews: $error');
      RouteHelper.goToWriteReview(
        context,
        serviceId: booking.serviceId,
        serviceName: booking.serviceName,
        bookingId: booking.id,
      );
    }
  }

  void _contactSupport() {
    RouteHelper.showSuccessDialog(
      context,
      title: 'Contact Support',
      message: 'Please email support@infinitybooking.com\n'
          'or call +251-XXX-XXXXXX',
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'pending_payment':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusDisplay(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'UPCOMING';
      case 'pending':
        return 'PENDING';
      case 'pending_payment':
        return 'PAYMENT PENDING';
      case 'completed':
        return 'COMPLETED';
      case 'cancelled':
        return 'CANCELLED';
      default:
        return status.toUpperCase();
    }
  }

  IconData _getEmptyStateIcon(String filter) {
    switch (filter) {
      case 'upcoming':
        return Icons.upcoming;
      case 'pending':
        return Icons.pending;
      case 'completed':
        return Icons.done_all;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.calendar_today;
    }
  }

  String _getEmptyStateMessage(String filter) {
    switch (filter) {
      case 'upcoming':
        return 'No Upcoming Bookings';
      case 'pending':
        return 'No Pending Bookings';
      case 'completed':
        return 'No Completed Bookings';
      case 'cancelled':
        return 'No Cancelled Bookings';
      default:
        return 'No Bookings Yet';
    }
  }

  String _getEmptyStateSubtitle(String filter) {
    switch (filter) {
      case 'upcoming':
        return 'You don\'t have any upcoming bookings';
      case 'pending':
        return 'No bookings awaiting confirmation';
      case 'completed':
        return 'No completed services yet';
      case 'cancelled':
        return 'No cancelled bookings';
      default:
        return 'Book your first service to get started';
    }
  }
}

class BookingDetailsBottomSheet extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onRefresh;
  final VoidCallback onAddReview;
  final bool isSmallScreen;

  const BookingDetailsBottomSheet({
    super.key,
    required this.booking,
    required this.onRefresh,
    required this.onAddReview,
    required this.isSmallScreen,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Center(
              child: Container(
                width: 50,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'Booking Details',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 18 : 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSmallScreen ? 8 : 12,
                    vertical: isSmallScreen ? 4 : 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                      fontSize: isSmallScreen ? 12 : 14,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: isSmallScreen ? 16 : 20),

            // Service Info
            _buildDetailSection(
              icon: Icons.build,
              title: 'Service',
              content: booking.serviceName,
              subtitle: booking.providerName,
              imageUrl: booking.serviceImage,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Date & Time
            _buildDetailSection(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              content:
                  '${booking.formattedBookingDate} • ${booking.formattedTimeRange}',
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Payment Info
            _buildDetailSection(
              icon: Icons.payment,
              title: 'Payment',
              content:
                  '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
              subtitle: booking.isPaid
                  ? 'Paid on ${booking.paymentDate != null ? DateFormat('dd/MM/yyyy').format(booking.paymentDate!) : 'N/A'}'
                  : booking.paymentMethod != null
                      ? 'Payment via ${booking.paymentMethod}'
                      : 'Payment pending',
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Booking ID
            _buildDetailSection(
              icon: Icons.info,
              title: 'Booking Reference',
              content: booking.bookingReference ?? booking.id,
              isSmallScreen: isSmallScreen,
            ),
            SizedBox(height: isSmallScreen ? 20 : 24),

            // Notes
            if (booking.notes != null && booking.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 16 : 18,
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 8 : 12),
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.notes!,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),
                  ),
                  SizedBox(height: isSmallScreen ? 20 : 24),
                ],
              ),

            // Actions
            _buildActionButtons(context),
            SizedBox(height: isSmallScreen ? 16 : 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection({
    required IconData icon,
    required String title,
    required String content,
    String? subtitle,
    String? imageUrl,
    required bool isSmallScreen,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: isSmallScreen ? 18 : 20,
            ),
            SizedBox(width: isSmallScreen ? 6 : 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 16 : 18,
              ),
            ),
          ],
        ),
        SizedBox(height: isSmallScreen ? 10 : 12),
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: double.infinity,
            height: isSmallScreen ? 120 : 150,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
            margin: const EdgeInsets.only(bottom: 12),
          ),
        Text(
          content,
          style: TextStyle(
            fontSize: isSmallScreen ? 15 : 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty)
          Padding(
            padding: EdgeInsets.only(top: isSmallScreen ? 2 : 4),
            child: Text(
              subtitle,
              style: TextStyle(
                color: Colors.grey,
                fontSize: isSmallScreen ? 13 : 14,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final status = booking.status.toLowerCase();

    if (status == 'pending_payment') {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
            ),
            child: const Text('Make Payment'),
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
            ),
            child: const Text('Close'),
          ),
        ],
      );
    }

    if (status == 'confirmed' && booking.bookingDate.isAfter(DateTime.now())) {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
            ),
            child: const Text('Reschedule'),
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
              foregroundColor: Colors.red,
            ),
            child: const Text('Cancel Booking'),
          ),
        ],
      );
    }

    if (status == 'completed') {
      return Column(
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onAddReview();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: isSmallScreen ? 18 : 20),
                SizedBox(width: isSmallScreen ? 6 : 8),
                const Text('Write a Review'),
              ],
            ),
          ),
          SizedBox(height: isSmallScreen ? 10 : 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
            ),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: Size(double.infinity, isSmallScreen ? 48 : 50),
      ),
      child: const Text('Close'),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'pending_payment':
        return Colors.orangeAccent;
      case 'completed':
        return Colors.blue;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}