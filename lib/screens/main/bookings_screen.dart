import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';

class BookingsScreen extends StatefulWidget {
  @override
  _BookingsScreenState createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Booking> _bookings = [];
  Map<String, List<Booking>> _filteredBookings = {
    'upcoming': [],
    'completed': [],
    'cancelled': [],
  };
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      print('🔄 Loading user bookings...');
      final bookings = await BookingService.getUserBookings();

      setState(() {
        _bookings = bookings;
        _filterBookings();
        _isLoading = false;
      });

      print('✅ Loaded ${bookings.length} bookings');
    } catch (e) {
      print('💥 Error loading bookings: $e');
      setState(() {
        _errorMessage = 'Failed to load bookings: $e';
        _isLoading = false;
      });
    }
  }

  void _filterBookings() {
    final now = DateTime.now();

    _filteredBookings['upcoming'] = _bookings.where((booking) {
      return booking.isPending || booking.isConfirmed;
    }).toList();

    _filteredBookings['completed'] = _bookings.where((booking) {
      return booking.isCompleted;
    }).toList();

    _filteredBookings['cancelled'] = _bookings.where((booking) {
      return booking.isCancelled;
    }).toList();
  }

  void _cancelBooking(Booking booking) async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to cancel this booking?'),
            SizedBox(height: 16),
            Text(
              'Service: ${booking.serviceTitle}',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Date: ${booking.formattedDate}'),
            Text('Time: ${booking.timeSlot}'),
            SizedBox(height: 16),
            TextFormField(
              decoration: InputDecoration(
                labelText: 'Cancellation reason (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              onChanged: (value) {
                // Store the reason
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'confirmed'),
            child: Text(
              'Cancel Booking',
              style: TextStyle(color: Constants.errorColor),
            ),
          ),
        ],
      ),
    );

    if (result == 'confirmed') {
      try {
        await BookingService.cancelBooking(booking.id, 'User cancelled');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Booking cancelled successfully'),
            backgroundColor: Constants.successColor,
          ),
        );
        _loadBookings(); // Refresh the list
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to cancel booking: $e'),
            backgroundColor: Constants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Bookings'),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadBookings,
            tooltip: 'Refresh',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(
              text: 'Upcoming (${_filteredBookings['upcoming']!.length})',
            ),
            Tab(
              text: 'Completed (${_filteredBookings['completed']!.length})',
            ),
            Tab(
              text: 'Cancelled (${_filteredBookings['cancelled']!.length})',
            ),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
        ),
      ),
      body: _isLoading
          ? _buildLoadingState()
          : _errorMessage.isNotEmpty
              ? _buildErrorState()
              : _bookings.isEmpty
                  ? _buildEmptyState()
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildBookingsList(
                            _filteredBookings['upcoming']!, true),
                        _buildBookingsList(
                            _filteredBookings['completed']!, false),
                        _buildBookingsList(
                            _filteredBookings['cancelled']!, false),
                      ],
                    ),
    );
  }

  Widget _buildBookingsList(List<Booking> bookings, bool showActions) {
    if (bookings.isEmpty) {
      return _buildEmptyTabState(
        icon: Icons.calendar_today,
        message: 'No bookings in this category',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBookings,
      child: ListView.builder(
        padding: EdgeInsets.all(AppConstants.defaultPadding),
        itemCount: bookings.length,
        itemBuilder: (context, index) {
          final booking = bookings[index];
          return _buildBookingCard(booking, showActions);
        },
      ),
    );
  }

  Widget _buildBookingCard(Booking booking, bool showActions) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.defaultBorderRadius),
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status and amount
            Row(
              children: [
                Expanded(
                  child: Text(
                    booking.serviceTitle,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      booking.formattedAmount,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Constants.primaryColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: booking.statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        booking.statusText,
                        style: TextStyle(
                          color: booking.statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 12),

            // Booking details
            _buildBookingDetail(
              icon: Icons.person,
              text: booking.providerName,
            ),
            _buildBookingDetail(
              icon: Icons.calendar_today,
              text: '${booking.formattedDate} • ${booking.timeSlot}',
            ),
            _buildBookingDetail(
              icon: Icons.schedule,
              text: booking.createdAt.toString().split(' ')[0],
            ),

            // Customer notes
            if (booking.customerNotes != null &&
                booking.customerNotes!.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Your notes:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    booking.customerNotes!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

            // Cancellation reason
            if (booking.isCancelled && booking.cancellationReason != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8),
                  Text(
                    'Cancellation reason:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Constants.errorColor,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    booking.cancellationReason!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Constants.errorColor,
                    ),
                  ),
                ],
              ),

            // Actions
            if (showActions && (booking.isPending || booking.isConfirmed))
              Column(
                children: [
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            // View details or contact provider
                            _showBookingDetails(booking);
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Constants.primaryColor),
                          ),
                          child: Text(
                            'View Details',
                            style: TextStyle(color: Constants.primaryColor),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _cancelBooking(booking),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Constants.errorColor.withOpacity(0.1),
                            foregroundColor: Constants.errorColor,
                          ),
                          child: Text('Cancel'),
                        ),
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

  Widget _buildBookingDetail({required IconData icon, required String text}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                booking.serviceTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16),
              _buildDetailRow('Provider', booking.providerName),
              _buildDetailRow('Date', booking.formattedDate),
              _buildDetailRow('Time', booking.timeSlot),
              _buildDetailRow('Amount', booking.formattedAmount),
              _buildDetailRow('Status', booking.statusText),
              _buildDetailRow(
                  'Booked on', booking.createdAt.toString().split(' ')[0]),
              if (booking.customerNotes != null)
                _buildDetailRow('Your Notes', booking.customerNotes!),
              if (booking.isCancelled && booking.cancellationReason != null)
                _buildDetailRow(
                    'Cancellation Reason', booking.cancellationReason!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: Colors.grey[800]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: Constants.primaryColor),
          SizedBox(height: 16),
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
          Icon(Icons.error_outline, size: 64, color: Colors.orange),
          SizedBox(height: 16),
          Text(
            'Unable to load bookings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 8),
          Text(
            _errorMessage,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[600]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _loadBookings,
            icon: Icon(Icons.refresh),
            label: Text('Try Again'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
            ),
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
          Icon(Icons.calendar_today, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Book your first service to get started',
            style: TextStyle(color: Colors.grey[500]),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              );
            },
            icon: Icon(Icons.construction),
            label: Text('Browse Services'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTabState(
      {required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
