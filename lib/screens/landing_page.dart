// lib/screens/landing_page.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants
import 'home_content.dart'; // Import the existing home content widget
import 'about_content.dart';
import 'how_it_works_content.dart';
import 'contact_content.dart';
import 'login_screen.dart'; // Import LoginScreen for navigation
import 'home_services_screen.dart'; // Import the new service screens
import 'beauty_salon_screen.dart';
import 'education_tutoring_screen.dart';

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
      // Pass the callback to HomeContent - 'context' is available here
      HomeContent(
        onLoginRegisterPressed: () {
          Navigator.pushNamed(context, '/login');
        },
      ),
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
              Navigator.pushNamed(
                context,
                '/login',
              ); // Navigate to Login Screen
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
      body: SingleChildScrollView(
        // Wrap the entire body content with SingleChildScrollView for scrolling
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Container(
              height:
                  MediaQuery.of(context).size.height *
                  0.6, // Use screen height for hero section
              decoration: BoxDecoration(
                color: Colors.grey[300], // Light grey background for hero
              ),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Your Trusted Service Marketplace',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineLarge
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Find reliable providers for Home Services, Beauty & Salon, and Education & Tutoring. We\'re growing infinitely!',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: Colors.white.withOpacity(0.8)),
                      ),
                      SizedBox(height: 32),
                      // Get Started Button
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            '/login',
                          ); // Navigate to Login Screen
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 18,
                          ), // Increased padding
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.rocket_launch,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Get Started Now',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Service Categories Section
            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Explore Our Services',
                    style: Theme.of(context).textTheme.headlineMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  // Service Category Cards
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildServiceCategoryCard(
                        'Home Services',
                        Icons.home,
                        'Plumbing, electrical, cleaning, maintenance',
                        () {
                          // Navigate to Home Services Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => HomeServicesScreen(),
                            ),
                          );
                        },
                      ),
                      _buildServiceCategoryCard(
                        'Beauty & Salon',
                        Icons.face,
                        'Haircuts, manicures, facials, personal care',
                        () {
                          // Navigate to Beauty & Salon Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BeautySalonScreen(),
                            ),
                          );
                        },
                      ),
                      _buildServiceCategoryCard(
                        'Education & Tutoring',
                        Icons.school,
                        'Lessons, tutoring, skill development',
                        () {
                          // Navigate to Education & Tutoring Screen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => EducationTutoringScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Navigation Tabs (BottomNavigationBar)
            Container(
              color: Colors.white, // White background for bottom nav
              child: BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                selectedItemColor: Constants.primaryColor,
                unselectedItemColor: Colors.grey[600],
                type: BottomNavigationBarType
                    .fixed, // Ensure all labels are shown
                items: List.generate(
                  _sectionTitles.length,
                  (index) => BottomNavigationBarItem(
                    icon: Icon(_sectionIcons[index]),
                    label: _sectionTitles[index],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Service Category Cards (Used in Home section)
  Widget _buildServiceCategoryCard(
    String title,
    IconData icon,
    String description,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      // Wrap the card in GestureDetector for tap feedback
      onTap: onTap, // Handle the tap event
      child: Container(
        width: 140, // Fixed width for cards
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white, // White background for card
          borderRadius: BorderRadius.circular(12), // Slightly more rounded
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 8, // Increased blur for softer shadow
              offset: Offset(0, 4), // Increased offset for more depth
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: Constants.primaryColor),
            SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 16,
                color: Constants.forestGreen,
              ), // Darker green for title
            ),
            SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ), // Smaller, lighter text for description
            ),
          ],
        ),
      ),
    );
  }
}
