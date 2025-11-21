// lib/screens/home_screen.dart - FIXED VERSION

import 'package:flutter/material.dart';
import 'services_screen.dart';
import 'bookings_screen.dart';
import 'profile_screen.dart';
import 'payments_screen.dart';
import '../utils/constants.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  User? _currentUser;

  // List of screens corresponding to the navigation items
  final List<Widget> _screens = [
    // We'll build this dynamically to include user data
    Container(), // Placeholder - will be replaced in build method
    ServicesScreen(),
    BookingsScreen(),
    PaymentsScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = [
    'Home',
    'Services',
    'Bookings',
    'Payments',
    'Profile',
  ];

  final List<IconData> _drawerIcons = [
    Icons.home,
    Icons.list,
    Icons.book_online,
    Icons.payment,
    Icons.person,
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await AuthService.getCurrentUser();
      setState(() {
        _currentUser = user;
      });
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Widget _buildPostLoginHomeContent() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Constants.primaryColor.withOpacity(0.05),
            Constants.accentColor.withOpacity(0.02),
          ],
        ),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.home_filled,
                      size: 80,
                      color: Constants.primaryColor,
                    ),
                    SizedBox(height: 16),
                    Text(
                      _currentUser != null
                          ? 'Welcome back, ${_currentUser!.fullName.split(' ').first}!'
                          : 'Welcome to Infinity Booking!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Constants.primaryColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Explore services, manage bookings, and update your profile all in one place.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 30),

            // Quick Actions
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
              childAspectRatio: 1.2,
              children: [
                _buildQuickActionCard(
                  Icons.search,
                  'Find Services',
                  Constants.primaryColor,
                  () {
                    setState(() {
                      _currentIndex = 1; // Navigate to Services
                    });
                  },
                ),
                _buildQuickActionCard(
                  Icons.calendar_today,
                  'My Bookings',
                  Colors.orange,
                  () {
                    setState(() {
                      _currentIndex = 2; // Navigate to Bookings
                    });
                  },
                ),
                _buildQuickActionCard(
                  Icons.payment,
                  'Payments',
                  Colors.green,
                  () {
                    setState(() {
                      _currentIndex = 3; // Navigate to Payments
                    });
                  },
                ),
                _buildQuickActionCard(
                  Icons.person,
                  'Profile',
                  Colors.purple,
                  () {
                    setState(() {
                      _currentIndex = 4; // Navigate to Profile
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
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
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                Navigator.of(context).pushReplacementNamed('/');
              },
              child: Text('Logout', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Update the home screen with user data
    _screens[0] = _buildPostLoginHomeContent();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Constants.primaryColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 2,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            // Drawer Header with User Info
            DrawerHeader(
              decoration: BoxDecoration(
                color: Constants.primaryColor,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Constants.primaryColor,
                    Constants.primaryColor.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white.withOpacity(0.2),
                    child: Icon(Icons.person, color: Colors.white, size: 30),
                  ),
                  SizedBox(height: 12),
                  Text(
                    _currentUser?.fullName ?? 'Welcome!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    _currentUser?.email ?? '',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Navigation Items
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...List.generate(
                    _screens.length,
                    (index) => ListTile(
                      leading: Icon(
                        _drawerIcons[index],
                        color: _currentIndex == index
                            ? Constants.primaryColor
                            : Colors.grey[600],
                      ),
                      title: Text(
                        _titles[index],
                        style: TextStyle(
                          fontWeight: _currentIndex == index
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                      selected: _currentIndex == index,
                      selectedTileColor: Constants.primaryColor.withOpacity(
                        0.1,
                      ),
                      onTap: () {
                        setState(() {
                          _currentIndex = index;
                        });
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
              ),
            ),
            // Logout Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(top: BorderSide(color: Colors.grey[300]!)),
              ),
              child: ListTile(
                leading: Icon(Icons.logout, color: Colors.red),
                title: Text('Logout', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Close drawer first
                  _showLogoutConfirmation();
                },
              ),
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          selectedItemColor: Constants.primaryColor,
          unselectedItemColor: Colors.grey[600],
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
          showUnselectedLabels: true,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Services'),
            BottomNavigationBarItem(
              icon: Icon(Icons.book_online),
              label: 'Bookings',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payment),
              label: 'Payments',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
