// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'home_content.dart'; // Import the existing home content widget (for post-login welcome)
import 'services_screen.dart'; // Import the new screens
import 'bookings_screen.dart';
import 'profile_screen.dart'; // Import the ProfileScreen
import 'payments_screen.dart'; // Import the PaymentsScreen
import '../utils/constants.dart'; // Import your constants for colors
import '../services/auth_service.dart'; // Import AuthService for logout

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Track the currently selected navigation item

  // List of screens corresponding to the navigation items
  final List<Widget> _screens = [
    // For the Home tab *after* login, you might want a different widget than HomeContent (which is for the landing page).
    // Create a new widget like WelcomeContent or use HomeContent with different logic if it suits.
    // For now, let's create a simple welcome widget for the post-login home screen.
    _buildPostLoginHomeContent(), // <-- NEW: Widget for logged-in home
    ServicesScreen(),
    BookingsScreen(),
    PaymentsScreen(),
    ProfileScreen(), // Now includes edit button internally
  ];

  // List of titles for the app bar (optional, can be dynamic based on _currentIndex)
  final List<String> _titles = [
    'Home',
    'Services',
    'Bookings',
    'Payments',
    'Profile',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_currentIndex],
        ), // Update title based on selected screen
        backgroundColor:
            Constants.forestGreen, // Use forest green from constants
        foregroundColor: Colors.white, // Text color for app bar
        automaticallyImplyLeading:
            false, // Don't show default back button as we have drawer
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Constants.primaryColor, // Use primary color for header
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Infinity-Booking',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                  // Optional: Add user info here if needed
                  // Text(
                  //   'User Name', // Fetch from AuthService
                  //   style: TextStyle(color: Colors.white70),
                  // ),
                ],
              ),
            ),
            // Navigation Items
            ...List.generate(
              _screens.length,
              (index) => ListTile(
                leading: index == 0
                    ? Icon(Icons.home)
                    : index == 1
                    ? Icon(Icons.list)
                    : index == 2
                    ? Icon(Icons.book_online)
                    : index == 3
                    ? Icon(Icons.payment)
                    : Icon(Icons.person),
                title: Text(_titles[index]),
                selected: index == _currentIndex,
                onTap: () {
                  setState(() {
                    _currentIndex = index;
                  });
                  Navigator.pop(context); // Close the drawer after selection
                },
              ),
            ),
            // Add other ListTile items if needed (e.g., Settings, Help, etc.)

            // Add the Logout button at the bottom of the drawer
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await AuthService.logout(); // Call logout from AuthService
                // Navigate back to Welcome Screen
                Navigator.of(context).pushReplacementNamed('/');
                // Or Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              },
            ),
          ],
        ),
      ),
      body: _screens[_currentIndex], // Display the current section widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed, // Ensure all labels are shown
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Services'),
          BottomNavigationBarItem(
            icon: Icon(Icons.book_online),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.payment), label: 'Payments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  // NEW: Widget for the Home tab after login
  static Widget _buildPostLoginHomeContent() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100], // Light background for post-login home
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.home, size: 100, color: Constants.forestGreen),
              SizedBox(height: 20),
              Text(
                'Welcome to Infinity-Booking!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Constants.forestGreen,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Explore services, manage bookings, and update your profile.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
