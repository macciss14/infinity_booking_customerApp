import 'package:flutter/material.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../models/user_model.dart';
import '../../models/booking_model.dart';
import '../../utils/constants.dart';
import '../service/categories_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  List<Booking> _recentBookings = [];
  bool _isLoading = true;
  bool _loadingBookings = false;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentBookings();
  }

  Future<void> _loadUserData() async {
    try {
      print('🔄 HomeScreen - Loading user data...');
      final result = await AuthService.getProfileWithFallback();
      if (result['success'] && result['user'] != null) {
        setState(() {
          _currentUser = result['user'];
        });
        print('✅ HomeScreen - User data loaded: ${_currentUser?.fullName}');
      } else {
        print('❌ HomeScreen - Failed to load user data: ${result['message']}');
      }
    } catch (e) {
      print('💥 HomeScreen - Error loading user data: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadRecentBookings() async {
    if (_loadingBookings) return;

    setState(() {
      _loadingBookings = true;
    });

    try {
      print('🔄 HomeScreen - Loading recent bookings...');
      final bookings = await BookingService.getUserBookings();

      // Get only the 3 most recent bookings
      final recent = bookings.take(3).toList();

      setState(() {
        _recentBookings = recent;
      });

      print('✅ HomeScreen - Loaded ${recent.length} recent bookings');
    } catch (e) {
      print('💥 HomeScreen - Error loading recent bookings: $e');
      // Don't show error to user for recent bookings
    } finally {
      setState(() {
        _loadingBookings = false;
      });
    }
  }

  void _refreshData() {
    _loadUserData();
    _loadRecentBookings();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Infinity Booking',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshData,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _buildContent(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _navigateToScreen,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.construction),
            label: 'Services',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Constants.primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUserData();
        await _loadRecentBookings();
      },
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            _buildWelcomeSection(),
            SizedBox(height: 30),

            // Quick Actions
            _buildQuickActionsSection(),
            SizedBox(height: 30),

            // Recent Activity Section
            _buildRecentActivitySection(),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            SizedBox(height: 8),
            Text(
              _currentUser?.fullName ?? 'User',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Ready to book your next service?',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 12),

            // User info card
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Constants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.emoji_events,
                    color: Constants.primaryColor,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Complete your profile to get personalized service recommendations',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                        SizedBox(height: 4),
                        if (_currentUser?.phone?.isEmpty ?? true)
                          Text(
                            '📱 Add your phone number',
                            style: TextStyle(
                              fontSize: 12,
                              color: Constants.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (_currentUser?.address?.isEmpty ?? true)
                          Text(
                            '🏠 Add your address',
                            style: TextStyle(
                              fontSize: 12,
                              color: Constants.primaryColor,
                              fontWeight: FontWeight.w500,
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

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            _buildActionCard(
              Icons.construction,
              'Browse Services',
              Constants.primaryColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              ),
            ),
            _buildActionCard(
              Icons.calendar_today,
              'My Bookings',
              Constants.accentColor,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingsScreen()),
              ),
            ),
            _buildActionCard(
              Icons.history,
              'Booking History',
              Constants.forestGreen,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => BookingsScreen()),
              ),
            ),
            _buildActionCard(
              Icons.person,
              'My Profile',
              Colors.orange,
              () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileScreen()),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Bookings',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Constants.primaryColor,
              ),
            ),
            if (_recentBookings.isNotEmpty)
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BookingsScreen()),
                ),
                child: Text(
                  'View All',
                  style: TextStyle(color: Constants.primaryColor),
                ),
              ),
          ],
        ),
        SizedBox(height: 16),
        _buildRecentActivity(),
      ],
    );
  }

  Widget _buildActionCard(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    if (_loadingBookings) {
      return _buildLoadingActivity();
    }

    if (_recentBookings.isEmpty) {
      return _buildEmptyActivityState();
    }

    return Column(
      children:
          _recentBookings.map((booking) => _buildBookingItem(booking)).toList(),
    );
  }

  Widget _buildBookingItem(Booking booking) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: booking.statusColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.calendar_today,
            color: booking.statusColor,
            size: 20,
          ),
        ),
        title: Text(
          booking.serviceTitle,
          style: TextStyle(fontWeight: FontWeight.w500),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${booking.formattedDate} • ${booking.timeSlot}'),
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
        trailing: Text(
          booking.formattedAmount,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Constants.primaryColor,
          ),
        ),
        onTap: () {
          _showBookingDetails(booking);
        },
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
              SizedBox(height: 12),
              _buildDetailRow('Provider', booking.providerName),
              _buildDetailRow('Date', booking.formattedDate),
              _buildDetailRow('Time', booking.timeSlot),
              _buildDetailRow('Amount', booking.formattedAmount),
              _buildDetailRow('Status', booking.statusText),
              if (booking.customerNotes != null)
                _buildDetailRow('Your Notes', booking.customerNotes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Close'),
          ),
          if (booking.isPending || booking.isConfirmed)
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _showCancelBookingDialog(booking);
              },
              child: Text(
                'Cancel Booking',
                style: TextStyle(color: Constants.errorColor),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
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

  void _showCancelBookingDialog(Booking booking) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cancel Booking'),
        content: Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Keep Booking'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _cancelBooking(booking);
            },
            child: Text(
              'Cancel Booking',
              style: TextStyle(color: Constants.errorColor),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelBooking(Booking booking) async {
    try {
      await BookingService.cancelBooking(
          booking.id, 'User requested cancellation');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking cancelled successfully'),
          backgroundColor: Constants.successColor,
        ),
      );
      _loadRecentBookings(); // Refresh the list
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to cancel booking: $e'),
          backgroundColor: Constants.errorColor,
        ),
      );
    }
  }

  Widget _buildLoadingActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Row(
          children: [
            CircularProgressIndicator(color: Constants.primaryColor),
            SizedBox(width: 16),
            Text(
              'Loading bookings...',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today,
              size: 64,
              color: Colors.grey[300],
            ),
            SizedBox(height: 16),
            Text(
              'No bookings yet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[500],
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Book your first service to get started',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CategoriesScreen()),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Constants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text('Browse Services'),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToScreen(int index) {
    switch (index) {
      case 0:
        // Already on home
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => CategoriesScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => BookingsScreen()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        );
        break;
    }

    // Reset to home index after navigation
    Future.delayed(Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentIndex = 0;
        });
      }
    });
  }
}
