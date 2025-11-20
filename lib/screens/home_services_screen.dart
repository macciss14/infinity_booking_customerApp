// lib/screens/home_services_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

class HomeServicesScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Services'),
        backgroundColor: Constants.forestGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView( // Make content scrollable
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Your Trusted Home Service Providers',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Find reliable professionals for all your home needs.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32),
              // Subcategory Cards for Home Services
              _buildSubCategoryCard('Plumbing', Icons.water_drop, 'Fix leaks, install fixtures, and handle all plumbing issues.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Electrical', Icons.electrical_services, 'Install lighting, repair wiring, and ensure your home\'s electrical safety.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Cleaning', Icons.cleaning_services, 'Professional cleaning for your home or office.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Maintenance', Icons.build, 'General maintenance and repairs for your property.'),
              SizedBox(height: 32),
              // Call to Action
              ElevatedButton(
                onPressed: () {
                  // Navigate to a "Book Now" screen or show a form
                  // For now, just show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Book a Home Service')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                ),
                child: Text('Book a Home Service', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Subcategory Cards
  Widget _buildSubCategoryCard(String title, IconData icon, String description) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 40, color: Constants.primaryColor),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Constants.forestGreen),
            ),
            SizedBox(height: 6),
            Text(
              description,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
