import 'package:flutter/material.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';
import '../../config/route_helper.dart';
import '../../utils/constants.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  bool _loading = true;
  String _selectedFilter =
      'all'; // all, upcoming, pending, completed, cancelled

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  Future<void> _loadBookings() async {
    setState(() => _loading = true);
    try {
      _bookings = await _bookingService.getUserBookings();
    } catch (error) {
      print('Error loading bookings: $error');
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load bookings: $error'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _loading = false);
    }
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
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadBookings,
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _bookings.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.calendar_today,
                          size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      const Text(
                        'No Bookings Yet',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Book your first service to get started',
                        style: TextStyle(color: Colors.grey),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.pushNamed(context, RouteHelper.home),
                        child: const Text('Browse Services'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Filter chips
                    Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 16),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildFilterChip('All', 'all'),
                            _buildFilterChip('Upcoming', 'upcoming'),
                            _buildFilterChip('Pending', 'pending'),
                            _buildFilterChip('Completed', 'completed'),
                            _buildFilterChip('Cancelled', 'cancelled'),
                          ],
                        ),
                      ),
                    ),
                    // Bookings list
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadBookings,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            return _buildBookingCard(_filteredBookings[index]);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: _selectedFilter == value,
        onSelected: (selected) {
          setState(() => _selectedFilter = value);
        },
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getStatusColor(booking.status).withOpacity(0.1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            _getStatusIcon(booking.status),
            color: _getStatusColor(booking.status),
          ),
        ),
        title: Text(
          booking.serviceName ?? 'Unknown Service',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                '${booking.formattedBookingDate} • ${booking.formattedTimeRange}'),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                booking.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _getStatusColor(booking.status),
                ),
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${booking.totalAmount?.toStringAsFixed(2) ?? "0.00"} ${booking.currency ?? "ETB"}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (booking.status.toLowerCase() == 'pending_payment')
              const Text(
                'Payment Pending',
                style: TextStyle(fontSize: 11, color: Colors.orange),
              ),
          ],
        ),
        onTap: () {
          _showBookingDetails(booking);
        },
      ),
    );
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Booking Details',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge, // FIXED: headline6 to titleLarge
              ),
              const SizedBox(height: 20),
              _buildDetailRow('Service', booking.serviceName ?? 'Unknown'),
              _buildDetailRow('Provider', booking.providerName ?? 'Unknown'),
              _buildDetailRow('Date', booking.formattedBookingDate),
              _buildDetailRow('Time', booking.formattedTimeRange),
              _buildDetailRow('Amount',
                  '${booking.totalAmount ?? 0} ${booking.currency ?? "ETB"}'),
              _buildDetailRow('Status', booking.status,
                  valueColor: _getStatusColor(booking.status)),
              if (booking.notes != null && booking.notes!.isNotEmpty)
                _buildDetailRow('Notes', booking.notes!),
              const SizedBox(height: 30),
              Row(
                children: [
                  if (booking.status.toLowerCase() == 'pending_payment')
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Implement payment navigation
                        },
                        child: const Text('Pay Now'),
                      ),
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: valueColor ?? Colors.black,
            ),
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
        return Colors.blue;
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
