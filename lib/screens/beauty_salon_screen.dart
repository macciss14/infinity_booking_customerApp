// lib/screens/beauty_salon_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

class BeautySalonScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Beauty & Salon'),
        backgroundColor: Constants.primaryColor,
      ),
      body: SingleChildScrollView(
        // Make the content scrollable
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                'Beauty & Salon',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Pamper yourself with our top-rated beauty services.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 20),
              // Subcategory Cards
              _buildSubcategoryCard(
                'Haircuts',
                'Men\'s, women\'s, kids\' haircuts and styling.',
                Icons.cut,
              ),
              SizedBox(height: 16),
              _buildSubcategoryCard(
                'Manicures',
                'Nail care, polish, and designs.',
                Icons.nail,
              ),
              SizedBox(height: 16),
              _buildSubcategoryCard(
                'Facials',
                'Skin care treatments and rejuvenation.',
                Icons.face,
              ),
              SizedBox(height: 16),
              _buildSubcategoryCard(
                'Personal Care',
                'Waxing, threading, and other personal grooming.',
                Icons.person,
              ),
              SizedBox(height: 40), // Add some space at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Helper Widget for Subcategory Cards
  Widget _buildSubcategoryCard(
    String title,
    String description,
    IconData icon,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
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
      child: Row(
        children: [
          Icon(icon, size: 40, color: Constants.primaryColor),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Constants.forestGreen,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
