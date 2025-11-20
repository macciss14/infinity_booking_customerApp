// lib/screens/education_tutoring_screen.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

class EducationTutoringScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Education & Tutoring'),
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
                'Unlock Your Potential with Personalized Learning',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
              Text(
                'Connect with qualified tutors for personalized lessons in any subject.',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(height: 32),
              // Subcategory Cards for Education & Tutoring
              _buildSubCategoryCard('Lessons', Icons.menu_book, 'One-on-one or group lessons in any academic subject.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Tutoring', Icons.school, 'Personalized tutoring to help you master difficult concepts.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Skill Development', Icons.assignment, 'Learn practical skills like coding, design, or business.'),
              SizedBox(height: 16),
              _buildSubCategoryCard('Coaching', Icons.person, 'Personal or career coaching to achieve your goals.'),
              SizedBox(height: 32),
              // Call to Action
              ElevatedButton(
                onPressed: () {
                  // Navigate to a "Book Now" screen or show a form
                  // For now, just show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Book an Educational Service')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.primaryColor,
                ),
                child: Text('Book an Educational Service', style: TextStyle(color: Colors.white)),
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
