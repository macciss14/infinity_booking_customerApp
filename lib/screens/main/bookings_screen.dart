// lib/screens/main/bookings_screen.dart (Updated - No AppBar)
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
        _refreshAttempts = 0; // Reset attempts on success
      });
    } catch (error) {
      print('❌ Error loading bookings: $error');

      if (!mounted) return;

      _refreshAttempts++;

      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });

      // Only show snackbar on first error
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

  List<BookingModel> get _filteredBookings {
    switch (_selectedFilter) {
      case 'upcoming':
        return _bookings
            .where((b) => b.status.toLowerCase() == 'confirmed')
            .toList();
      case 'pending':
        return _bookings
            .where((b) =>
                b.status.toLowerCase() == 'pending' ||
                b.status.toLowerCase() == 'pending_payment')
            .toList();
      case 'completed':
        return _bookings
            .where((b) => b.status.toLowerCase() == 'completed')
            .toList();
      case 'cancelled':
        return _bookings
            .where((b) => b.status.toLowerCase() == 'cancelled')
            .toList();
      default:
        return _bookings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab Bar (no AppBar, just tabs)
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: Colors.grey,
            indicatorColor: AppColors.primary,
            indicatorSize: TabBarIndicatorSize.tab,
            tabs: [
              _buildTabItem('All', _bookingCounts['all']!),
              _buildTabItem('Upcoming', _bookingCounts['upcoming']!),
              _buildTabItem('Pending', _bookingCounts['pending']!),
              _buildTabItem('Completed', _bookingCounts['completed']!),
              _buildTabItem('Cancelled', _bookingCounts['cancelled']!),
            ],
          ),
        ),
        
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildTabContent('all'),
              _buildTabContent('upcoming'),
              _buildTabContent('pending'),
              _buildTabContent('completed'),
              _buildTabContent('cancelled'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabItem(String label, int count) {
    return Tab(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: TextStyle(
                fontSize: 12,
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent(String filter) {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
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
      return _buildEmptyState(filter);
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      color: AppColors.primary,
      backgroundColor: Colors.white,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildBookingCard(filteredList[index]);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    final isUpcoming = booking.status.toLowerCase() == 'confirmed' &&
        booking.bookingDate.isAfter(DateTime.now());
    final isToday = booking.bookingDate.day == DateTime.now().day &&
        booking.bookingDate.month == DateTime.now().month &&
        booking.bookingDate.year == DateTime.now().year;

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status Indicator
              Container(
                width: 8,
                height: 80,
                decoration: BoxDecoration(
                  color: _getStatusColor(booking.status),
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    BoxShadow(
                      color: _getStatusColor(booking.status).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),

              // Service Image
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
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
                        size: 30,
                        color: Colors.grey[500],
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Booking Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Service Name & Status
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            booking.serviceName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: _getStatusColor(booking.status)
                                .withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getStatusDisplay(booking.status),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getStatusColor(booking.status),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Provider Name
                    Text(
                      booking.providerName,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Date & Time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: isToday ? AppColors.primary : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isToday ? 'Today' : booking.formattedBookingDate,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isToday ? AppColors.primary : Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.formattedTimeRange,
                          style: const TextStyle(
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Price & Actions
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: booking.isPaid
                                ? Colors.green.withOpacity(0.1)
                                : AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: booking.isPaid
                                  ? Colors.green.withOpacity(0.3)
                                  : AppColors.primary.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                booking.isPaid
                                    ? Icons.check_circle
                                    : Icons.pending,
                                size: 14,
                                color: booking.isPaid
                                    ? Colors.green
                                    : AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: booking.isPaid
                                      ? Colors.green
                                      : AppColors.primary,
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
                              size: 20,
                              color: _getQuickActionColor(booking),
                            ),
                            padding: const EdgeInsets.all(4),
                            visualDensity: VisualDensity.compact,
                            tooltip: _getQuickActionTooltip(booking),
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 4,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Loading your bookings...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Please wait a moment',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            const SizedBox(height: 20),
            const Text(
              'Unable to Load Bookings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage ?? 'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _loadBookings,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 12),
                  ),
                ),
                if (_refreshAttempts >= _maxRefreshAttempts) ...[
                  const SizedBox(width: 16),
                  OutlinedButton.icon(
                    onPressed: () => RouteHelper.goToHome(context),
                    icon: const Icon(Icons.home),
                    label: const Text('Go Home'),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => _contactSupport(),
              child: const Text('Contact Support'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String filter) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(filter),
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 20),
            Text(
              _getEmptyStateMessage(filter),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                _getEmptyStateSubtitle(filter),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 30),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton(
                  onPressed: () {
                    // Navigate to services
                    RouteHelper.pushNamed(context, RouteHelper.serviceList);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  ),
                  child: const Text('Browse Services'),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    OutlinedButton(
                      onPressed: _loadBookings,
                      child: const Text('Refresh'),
                    ),
                    const SizedBox(width: 16),
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

  // Helper methods for quick actions
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
    // Implement copy to clipboard
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking ID copied')),
    );
  }

  void _shareBooking(BookingModel booking) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon')),
    );
  }

  void _printBooking(BookingModel booking) {
    // Implement print functionality
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

// Separate widget for booking details
class BookingDetailsBottomSheet extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onRefresh;
  final VoidCallback onAddReview;

  const BookingDetailsBottomSheet({
    super.key,
    required this.booking,
    required this.onRefresh,
    required this.onAddReview,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
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
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Booking Details',
                  style: Theme.of(context).textTheme.titleLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getStatusColor(booking.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    booking.status.toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStatusColor(booking.status),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Service Info
            _buildDetailSection(
              icon: Icons.build,
              title: 'Service',
              content: booking.serviceName,
              subtitle: booking.providerName,
              imageUrl: booking.serviceImage,
            ),
            const SizedBox(height: 24),

            // Date & Time
            _buildDetailSection(
              icon: Icons.calendar_today,
              title: 'Date & Time',
              content:
                  '${booking.formattedBookingDate} • ${booking.formattedTimeRange}',
            ),
            const SizedBox(height: 24),

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
            ),
            const SizedBox(height: 24),

            // Booking ID
            _buildDetailSection(
              icon: Icons.info,
              title: 'Booking Reference',
              content: booking.bookingReference ?? booking.id,
            ),
            const SizedBox(height: 24),

            // Notes
            if (booking.notes != null && booking.notes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Notes',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      booking.notes!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),

            // Actions
            _buildActionButtons(context),
            const SizedBox(height: 20),
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
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (imageUrl != null && imageUrl.isNotEmpty)
          Container(
            width: double.infinity,
            height: 150,
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
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        if (subtitle != null && subtitle.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
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
              // TODO: Navigate to payment
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Make Payment'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
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
              // TODO: Navigate to reschedule
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Reschedule'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () async {
              Navigator.pop(context);
              // TODO: Cancel booking
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
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
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.star, size: 20),
                SizedBox(width: 8),
                Text('Write a Review'),
              ],
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text('Close'),
          ),
        ],
      );
    }

    return OutlinedButton(
      onPressed: () => Navigator.pop(context),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
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