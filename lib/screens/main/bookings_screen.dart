// lib/screens/main/bookings_screen.dart - FIXED & ENHANCED VERSION
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/booking_service.dart';
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
      });
    } catch (error) {
      print('❌ Error loading bookings: $error');
      
      if (!mounted) return;
      
      setState(() {
        _hasError = true;
        _errorMessage = error.toString();
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load bookings'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Retry',
            onPressed: _loadBookings,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _updateBookingCounts() {
    _bookingCounts['all'] = _bookings.length;
    _bookingCounts['upcoming'] = _bookings
        .where((b) => b.status.toLowerCase() == 'confirmed')
        .length;
    _bookingCounts['pending'] = _bookings
        .where((b) =>
            b.status.toLowerCase() == 'pending' ||
            b.status.toLowerCase() == 'pending_payment')
        .length;
    _bookingCounts['completed'] = _bookings
        .where((b) => b.status.toLowerCase() == 'completed')
        .length;
    _bookingCounts['cancelled'] = _bookings
        .where((b) => b.status.toLowerCase() == 'cancelled')
        .length;
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
            tooltip: 'Refresh',
          ),
        ],
        bottom: _bookings.isNotEmpty || _loading
            ? TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: [
                  _buildTabItem('All', _bookingCounts['all']!),
                  _buildTabItem('Upcoming', _bookingCounts['upcoming']!),
                  _buildTabItem('Pending', _bookingCounts['pending']!),
                  _buildTabItem('Completed', _bookingCounts['completed']!),
                  _buildTabItem('Cancelled', _bookingCounts['cancelled']!),
                ],
              )
            : null,
      ),
      body: _buildBody(),
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
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count',
              style: const TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return _buildLoadingState();
    }

    if (_hasError) {
      return _buildErrorState();
    }

    if (_bookings.isEmpty) {
      return _buildEmptyState();
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildBookingsList('all'),
        _buildBookingsList('upcoming'),
        _buildBookingsList('pending'),
        _buildBookingsList('completed'),
        _buildBookingsList('cancelled'),
      ],
    );
  }

  Widget _buildBookingsList(String filter) {
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getEmptyStateIcon(filter),
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _getEmptyStateMessage(filter),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _getEmptyStateSubtitle(filter),
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
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
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isUpcoming ? Colors.green.withOpacity(0.2) : Colors.grey[300]!,
          width: isUpcoming ? 1 : 0.5,
        ),
      ),
      elevation: 2,
      child: InkWell(
        onTap: () => _showBookingDetails(booking),
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
                ),
                child: booking.serviceImage == null ||
                        booking.serviceImage!.isEmpty
                    ? const Icon(
                        Icons.build,
                        size: 30,
                        color: Colors.grey,
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
                            booking.status.toUpperCase(),
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
                        const Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${booking.formattedBookingDate}',
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(width: 12),
                        const Icon(
                          Icons.access_time,
                          size: 14,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          booking.formattedTimeRange,
                          style: const TextStyle(fontSize: 13),
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
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),

                        // Action Buttons
                        Row(
                          children: _buildActionButtons(booking),
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

  List<Widget> _buildActionButtons(BookingModel booking) {
    final buttons = <Widget>[];
    final status = booking.status.toLowerCase();

    if (status == 'pending_payment') {
      buttons.add(
        ElevatedButton.icon(
          onPressed: () => _processPayment(booking),
          icon: const Icon(Icons.payment, size: 16),
          label: const Text('Pay'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      );
    }

    if (status == 'confirmed' &&
        booking.bookingDate.isAfter(DateTime.now())) {
      buttons.addAll([
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _rescheduleBooking(booking),
          icon: const Icon(Icons.schedule, size: 16),
          label: const Text('Reschedule'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          ),
        ),
        const SizedBox(width: 8),
        OutlinedButton.icon(
          onPressed: () => _cancelBooking(booking),
          icon: const Icon(Icons.cancel, size: 16),
          label: const Text('Cancel'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            foregroundColor: Colors.red,
          ),
        ),
      ]);
    }

    if (status == 'completed' && booking.isPaid == false) {
      buttons.add(
        OutlinedButton.icon(
          onPressed: () => _addReview(booking),
          icon: const Icon(Icons.star, size: 16),
          label: const Text('Review'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            foregroundColor: Colors.orange,
          ),
        ),
      );
    }

    return buttons;
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            'Loading your bookings...',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Failed to load bookings',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              _errorMessage ?? 'Please check your connection and try again.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadBookings,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 20),
          const Text(
            'No Bookings Yet',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'You haven\'t booked any services yet. Browse our services and book your first appointment!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 30),
          ElevatedButton(
            onPressed: () {
              RouteHelper.pushNamed(context, RouteHelper.home);
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Browse Services'),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: _loadBookings,
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
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
        );
      },
    );
  }

  Future<void> _processPayment(BookingModel booking) async {
    // TODO: Implement payment processing
    print('Processing payment for booking: ${booking.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _rescheduleBooking(BookingModel booking) async {
    // TODO: Implement reschedule
    print('Rescheduling booking: ${booking.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reschedule feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _cancelBooking(BookingModel booking) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Booking'),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _bookingService.cancelBooking(booking.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Colors.green,
          ),
        );
        _loadBookings();
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _addReview(BookingModel booking) async {
    // TODO: Implement review
    print('Adding review for booking: ${booking.id}');
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Review feature coming soon!'),
        duration: Duration(seconds: 2),
      ),
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

// Separate widget for booking details
class BookingDetailsBottomSheet extends StatelessWidget {
  final BookingModel booking;
  final VoidCallback onRefresh;

  const BookingDetailsBottomSheet({
    super.key,
    required this.booking,
    required this.onRefresh,
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
              content: '${booking.totalAmount.toStringAsFixed(2)} ${booking.currency}',
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
            const SizedBox(height: 10),
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

    if (status == 'confirmed' &&
        booking.bookingDate.isAfter(DateTime.now())) {
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