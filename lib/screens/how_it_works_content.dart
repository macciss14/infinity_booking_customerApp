// lib/screens/how_it_works_content.dart

import 'package:flutter/material.dart';
import '../utils/constants.dart'; // Import your constants

class HowItWorksContent extends StatelessWidget {
  const HowItWorksContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How It Works',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Constants.forestGreen,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Booking a service is simple and secure with Infinity-Booking.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.grey[700]),
            ),
            SizedBox(height: 30),
            // Step-by-step explanation from Proposal - Enhanced
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildStep(
                    1,
                    'Browse & Find',
                    Icons.search,
                    'Explore services by category, location, price, ratings, or availability. Find providers that match your specific needs.',
                  ),
                  SizedBox(height: 15),
                  _buildStep(
                    2,
                    'Select & Book',
                    Icons.event_available,
                    'Choose your preferred provider, select a convenient date and time, and confirm your booking instantly through the app.',
                  ),
                  SizedBox(height: 15),
                  _buildStep(
                    3,
                    'Pay Securely',
                    Icons.payment,
                    'Pay safely using Telebirr, Chapa, or PayPal. The payment is securely held by the admin until the service is completed, protecting both you and the provider.',
                  ),
                  SizedBox(height: 15),
                  _buildStep(
                    4,
                    'Receive & Rate',
                    Icons.rate_review,
                    'Enjoy your service. After completion, rate your provider and leave a review to build trust and help future users make informed decisions.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            // Customer Journey Highlight (from Proposal)
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Constants.primaryColor, width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Journey with Us',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Constants.primaryColor,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Sign Up/Log In -> Browse Services -> Select Provider & Service -> Book Appointment -> Make Payment -> Receive Service -> Rate & Review',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Steps (Enhanced)
  Widget _buildStep(
    int number,
    String title,
    IconData icon,
    String description,
  ) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Constants.primaryColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              color: Constants.primaryColor,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: Constants.primaryColor, size: 20),
                    SizedBox(width: 6),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Constants.forestGreen,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
