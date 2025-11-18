// lib/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'home_content.dart'; // Import the existing home content widget
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
    HomeContent(), // Use the existing HomeContent widget (no callback needed now)
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
}
