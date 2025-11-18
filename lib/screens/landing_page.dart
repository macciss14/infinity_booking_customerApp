// lib/screens/landing_page.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants
import 'home_content.dart'; // Import the new content widgets
import 'about_content.dart';
import 'how_it_works_content.dart';
import 'contact_content.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation

class LandingPage extends StatefulWidget {
  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _currentIndex = 0; // Track the currently selected section

  // List of section titles
  final List<String> _sectionTitles = [
    'Home',
    'About',
    'How It Works',
    'Contact',
  ];

  // List of section icons (optional, for BottomNavigationBar)
  final List<IconData> _sectionIcons = [
    Icons.home,
    Icons.info,
    Icons.how_to_reg,
    Icons.contact_mail,
  ];

  @override
  Widget build(BuildContext context) {
    // Create the list of widgets *inside* the build method
    final List<Widget> _sectionWidgets = [
      // Do NOT pass the callback to HomeContent anymore
      HomeContent(), // Use HomeContent without the callback
      AboutContent(), // Now correctly referencing the imported widget
      HowItWorksContent(),
      ContactContent(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Infinity-Booking'),
        backgroundColor: Constants.primaryColor,
        actions: [
          // Login/Register Button
          ElevatedButton(
            onPressed: () {
              // Navigate to Login Screen when the button is pressed
              Navigator.pushNamed(context, '/login');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Constants.accentColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: Text(
              'Login / Register',
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
      body:
          _sectionWidgets[_currentIndex], // Display the current section widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: List.generate(
          _sectionTitles.length,
          (index) => BottomNavigationBarItem(
            icon: Icon(_sectionIcons[index]),
            label: _sectionTitles[index],
          ),
        ),
        selectedItemColor: Constants.primaryColor,
        unselectedItemColor: Colors.grey[600],
        type: BottomNavigationBarType.fixed, // Ensure all labels are shown
      ),
    );
  }
}
