// lib/screens/home_content.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

class HomeContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1534670007418-fbb7f6a878c5?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1920&q=80',
          ), // Replace with your image
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          // Dark Overlay - Adjusted opacity for better visibility
          Container(color: Colors.black.withOpacity(0.5)),
          // Safe Area Content
          SafeArea(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Spacer to push content down
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Main Headline - Updated for logged-in user
                            Text(
                              'Welcome Back!',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                            ),
                            SizedBox(height: 16),
                            // Sub-headline/Description - Updated for logged-in user
                            Text(
                              'Ready to book a service or manage your bookings?',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                            ),
                            SizedBox(height: 32),
                            // Explore Services Section
                            Text(
                              'Explore Our Services',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 20),
                            // Service Category Cards (Example)
                            Wrap(
                              spacing: 16.0,
                              runSpacing: 16.0,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildServiceCard(
                                  'Home Services',
                                  Icons.home,
                                  'Plumbing, electrical, cleaning, maintenance',
                                ),
                                _buildServiceCard(
                                  'Beauty & Salon',
                                  Icons.face,
                                  'Haircuts, manicures, facials, personal care',
                                ),
                                _buildServiceCard(
                                  'Education & Tutoring',
                                  Icons.school,
                                  'Lessons, tutoring, skill development',
                                ),
                                // Add more cards as needed based on your service categories
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper Widget for Service Category Cards (Used in Home section)
  Widget _buildServiceCard(String title, IconData icon, String description) {
    return Container(
      width: 140, // Fixed width for cards
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(
          0.95,
        ), // More opaque white for better contrast
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
    );
  }
}
