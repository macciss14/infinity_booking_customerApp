// lib/screens/beauty_salon_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

class BeautySalonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beauty & Salon'),
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
                'Pamper Yourself with Our Beauty Experts',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Discover top-rated beauty and salon services near you.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32),
              // Subcategory Cards for Beauty & Salon
              _buildSubCategoryCard('Haircuts', Icons.cut, 'Get a fresh haircut from our skilled stylists.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Manicures & Pedicures', Icons.spa, 'Beautiful, long-lasting manicures and pedicures.'), // FIXED: Changed icon to Icons.spa
              SizedBox(height: 16),
              _buildSubCategoryCard('Facials', Icons.face, 'Rejuvenate your skin with our expert facial treatments.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Personal Care', Icons.person, 'All other personal care services including waxing, makeup, etc.'),
              SizedBox(height: 32),
              // Call to Action
              ElevatedButton(
                onPressed: () {
                  // Navigate to a "Book Now" screen or show a form
                  // For now, just show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Book a Beauty Service')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                ),
                child: Text('Book a Beauty Service', style: TextStyle(color: Colors.white)),
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
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: Constants.forestGreen),
            ),
            SizedBox(height: 6),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }
}
